#!/usr/bin/env bash
# ============================================================
# MemPalace MCP 快速狀態檢查
# 用法: ./scripts/mempalace-mcp-status.sh
# ============================================================
set -euo pipefail

MEMPALACE_PYTHON="/Users/liao-eli/.local/pipx/venvs/mempalace/bin/python"
MEMPALACE_HOME="${MEMPALACE_HOME:-/Users/liao-eli/.mempalace}"

echo "🏛️  MemPalace MCP 狀態檢查"
echo "============================================================"

# 1. 檢查 Python 與模組
echo -n "📦 Python 環境... "
if "$MEMPALACE_PYTHON" -c "import mempalace" 2>/dev/null; then
    echo "✅ OK"
else
    echo "❌ mempalace 模組找不到"
    exit 1
fi

# 2. 檢查 MCP Server 模組
echo -n "🔌 MCP Server... "
if "$MEMPALACE_PYTHON" -c "from mempalace.mcp_server import main" 2>/dev/null; then
    echo "✅ OK"
else
    echo "❌ MCP Server 模組載入失敗"
    exit 1
fi

# 3. 檢查宮殿路徑
echo -n "🏰 宮殿路徑... "
if [ -d "$MEMPALACE_HOME/palace" ]; then
    echo "✅ $MEMPALACE_HOME/palace"
else
    echo "⚠️  $MEMPALACE_HOME/palace (不存在)"
fi

# 4. 檢查 ChromaDB
echo -n "📊 ChromaDB... "
CHROMA_DB=$(find "$MEMPALACE_HOME/palace" -name "chroma.sqlite3" 2>/dev/null | head -1)
if [ -n "$CHROMA_DB" ]; then
    echo "✅ OK ($(dirname "$CHROMA_DB" | xargs basename))"
else
    echo "⚠️  ChromaDB 找不到"
fi

# 5. 快速 MCP 連線測試
echo -n "🔗 MCP 連線測試... "
RESPONSE=$(python3 << 'PYEOF'
import subprocess, json, signal, sys, select, os, time

MCP_PYTHON = os.environ.get('MEMPALACE_PYTHON', '/Users/liao-eli/.local/pipx/venvs/mempalace/bin/python')
MEMPALACE_HOME = os.environ.get('MEMPALACE_HOME', '/Users/liao-eli/.mempalace')

env = {**dict(os.environ), 'MEMPALACE_HOME': MEMPALACE_HOME}
proc = subprocess.Popen([MCP_PYTHON, '-m', 'mempalace.mcp_server'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env, text=True)

def send(method, params=None, rid=1):
    msg = json.dumps({"jsonrpc": "2.0", "id": rid, "method": method, "params": params or {}})
    proc.stdin.write(msg + '\n')
    proc.stdin.flush()
    time.sleep(0.8)
    ready, _, _ = select.select([proc.stdout], [], [], 2)
    if ready:
        return proc.stdout.readline().strip()
    return None

r = send("initialize", {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "status", "version": "1.0"}}, 1)
if r:
    d = json.loads(r)
    v = d.get('result', {}).get('serverInfo', {}).get('version', '?')
    tools_r = send("tools/list", {}, 2)
    tool_count = '?'
    if tools_r:
        td = json.loads(tools_r)
        tool_count = len(td.get('result', {}).get('tools', []))
    print(f"OK|{v}|{tool_count}")
else:
    print("FAIL")

proc.send_signal(signal.SIGTERM)
proc.wait(timeout=3)
PYEOF
)

if [[ "$RESPONSE" == OK* ]]; then
    IFS='|' read -r STATUS VERSION TOOLS <<< "$RESPONSE"
    echo "✅ OK (v${VERSION})"
    echo -n "🛠️  可用工具數... "
    echo "✅ ${TOOLS} 個工具"
else
    echo "❌ MCP 伺服器啟動失敗"
    exit 1
fi

# 6. 宮殿摘要
echo ""
echo "📋 宮殿摘要"
echo "------------------------------------------------------------"
python3 << 'PYEOF'
import subprocess, json, signal, select, os, time

MCP_PYTHON = os.environ.get('MEMPALACE_PYTHON', '/Users/liao-eli/.local/pipx/venvs/mempalace/bin/python')
MEMPALACE_HOME = os.environ.get('MEMPALACE_HOME', '/Users/liao-eli/.mempalace')

env = {**dict(os.environ), 'MEMPALACE_HOME': MEMPALACE_HOME}
proc = subprocess.Popen([MCP_PYTHON, '-m', 'mempalace.mcp_server'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env, text=True)

def send(method, params=None, rid=1):
    msg = json.dumps({"jsonrpc": "2.0", "id": rid, "method": method, "params": params or {}})
    proc.stdin.write(msg + '\n')
    proc.stdin.flush()
    time.sleep(0.8)
    ready, _, _ = select.select([proc.stdout], [], [], 2)
    if ready:
        return proc.stdout.readline().strip()
    return None

send("initialize", {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "status", "version": "1.0"}}, 1)
r = send("tools/call", {"name": "mempalace_status", "arguments": {}}, 2)
if r:
    d = json.loads(r)
    res = d.get('result', {})
    # MCP 回傳的 content 是文字陣列
    content_list = res.get('content', [])
    if content_list:
        text = content_list[0].get('text', '')
        # 嘗試解析 JSON 文字
        try:
            data = json.loads(text)
            print(f"  Wings:   {len(data.get('wings', {}))} ({', '.join(data.get('wings', {}).keys())})")
            print(f"  Rooms:   {len(data.get('rooms', {}))} ({', '.join(data.get('rooms', {}).keys())})")
            print(f"  Drawers: {data.get('total_drawers', 0)}")
            print(f"  Path:    {data.get('palace_path', 'N/A')}")
        except:
            # 如果無法解析 JSON，顯示原始文字前 200 字
            print(f"  {text[:200]}")
    else:
        print("  無法取得宮殿摘要")
else:
    print("  無法取得宮殿摘要")

proc.send_signal(signal.SIGTERM)
proc.wait(timeout=3)
PYEOF

echo ""
echo "============================================================"
echo "✅ MemPalace MCP 運行正常"
