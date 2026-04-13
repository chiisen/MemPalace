# 🏛️ MemPalace MCP 整合指南

> 將 MemPalace 記憶宮殿連接到各 AI 工具，讓 AI 自動搜尋與儲存記憶。

## 📋 前置準備

### 1. 安裝 MemPalace

```powershell
uv tool install mempalace
```

### 2. 初始化 Palace

```powershell
# 建立 palace 目錄
New-Item -ItemType Directory -Force -Path "C:\Users\chiis\.mempalace\palace"

# 初始化（自動接受所有偵測到的實體）
mempalace init C:\Users\chiis\.mempalace\palace --yes
```

### 3. 建立 Wrapper 腳本（Claude Code / Qwen 共用）

部分工具的 `mcp add` 指令不支援帶旗標的啟動命令（如 `python -m`），需要建立一個 wrapper：

```powershell
# 建立 wrapper 腳本
$content = "@echo off`r`n`"C:\Users\chiis\AppData\Roaming\uv\tools\mempalace\Scripts\python.exe`" -m mempalace.mcp_server --palace `"C:\Users\chiis\.mempalace\palace`" %*"
Set-Content -Path "C:\Users\chiis\.local\bin\mempalace-mcp.cmd" -Value $content
```

`C:\Users\chiis\.local\bin\mempalace-mcp.cmd` 內容：

```batch
@echo off
"C:\Users\chiis\AppData\Roaming\uv\tools\mempalace\Scripts\python.exe" -m mempalace.mcp_server --palace "C:\Users\chiis\.mempalace\palace" %*
```

---

## 🤖 各工具設定方式

### Antigravity

編輯 `C:\Users\chiis\.gemini\antigravity\mcp_config.json`：

```json
{
  "mcpServers": {
    "mempalace": {
      "command": "C:\\Users\\chiis\\AppData\\Roaming\\uv\\tools\\mempalace\\Scripts\\python.exe",
      "args": [
        "-m",
        "mempalace.mcp_server",
        "--palace",
        "C:\\Users\\chiis\\.mempalace\\palace"
      ]
    }
  }
}
```

**重啟 Antigravity** 後生效。

---

### Claude Code

使用 `claude mcp add` 搭配 wrapper 腳本（`-s user` 代表全域生效，所有專案皆可使用）：

```powershell
claude mcp add -s user mempalace "C:\Users\chiis\.local\bin\mempalace-mcp.cmd"
```

驗證：

```powershell
claude mcp get mempalace
# 預期輸出：Status: ✓ Connected
```

移除：

```powershell
claude mcp remove "mempalace" -s user
```

---

### Codex

Codex 支援 `-- <command> [args...]` 格式，可以直接帶 Python 旗標，不需要 wrapper：

```powershell
codex mcp add mempalace -- "C:\Users\chiis\AppData\Roaming\uv\tools\mempalace\Scripts\python.exe" -m mempalace.mcp_server --palace "C:\Users\chiis\.mempalace\palace"
```

驗證：

```powershell
codex mcp get mempalace
# 預期輸出：enabled: true / transport: stdio
```

移除：

```powershell
codex mcp remove mempalace
```

---

### Opencode

`opencode mcp add` 不支援直接傳遞複雜啟動參數，需直接編輯設定檔：

**檔案路徑**：`C:\Users\chiis\.opencode\opencode.json`

在 `"mcp"` 區塊中新增 `mempalace` 條目：

```json
{
  "mcp": {
    "mempalace": {
      "type": "local",
      "command": [
        "C:\\Users\\chiis\\AppData\\Roaming\\uv\\tools\\mempalace\\Scripts\\python.exe",
        "-m",
        "mempalace.mcp_server",
        "--palace",
        "C:\\Users\\chiis\\.mempalace\\palace"
      ],
      "enabled": true
    }
  }
}
```

驗證：

```powershell
opencode mcp list
# 預期輸出：mempalace connected
```

---

### Qwen Code

使用 `qwen mcp add` 搭配 wrapper 腳本（Qwen 的 add 語法不支援帶旗標的啟動命令）：

```powershell
qwen mcp add mempalace "C:\Users\chiis\.local\bin\mempalace-mcp.cmd"
```

驗證：

```powershell
qwen mcp list
# 預期輸出：mempalace: ... (stdio) - Connected
```

移除：

```powershell
qwen mcp remove mempalace
```

---

## ✅ 整合狀態總覽

| AI 工具 | 設定方式 | 驗證指令 |
|---------|---------|---------|
| **Antigravity** | 編輯 `mcp_config.json` | 重啟後側邊欄確認 |
| **Claude Code** | `claude mcp add -s user` | `claude mcp get mempalace` |
| **Codex** | `codex mcp add --` | `codex mcp get mempalace` |
| **Opencode** | 編輯 `opencode.json` | `opencode mcp list` |
| **Qwen Code** | `qwen mcp add` | `qwen mcp list` |

所有工具共用同一個 palace：`C:\Users\chiis\.mempalace\palace`

---

## 🔧 關鍵路徑

| 用途 | 路徑 |
|------|------|
| MemPalace Python 執行檔 | `C:\Users\chiis\AppData\Roaming\uv\tools\mempalace\Scripts\python.exe` |
| Palace 資料目錄 | `C:\Users\chiis\.mempalace\palace` |
| Wrapper 腳本 | `C:\Users\chiis\.local\bin\mempalace-mcp.cmd` |
| Antigravity MCP 設定 | `C:\Users\chiis\.gemini\antigravity\mcp_config.json` |
| Opencode 設定 | `C:\Users\chiis\.opencode\opencode.json` |

---

## 💡 使用方式

MCP 連線成功後，在任何支援的 AI 工具中，可以直接用自然語言操作記憶：

```
請搜尋記憶中關於 Flutter 的紀錄
請幫我記住：todo_list 使用 Supabase 作為後端
```

### 可用的 MCP 工具

- `mempalace_search` — 語意搜尋記憶
- `mempalace_store` — 儲存新記憶
- `mempalace_graph_query` — 查詢知識圖譜
- 其他共 19 個工具（`mempalace --help` 查看完整清單）

### 手動 mine 對話記錄（補充歷史記憶）

```powershell
mempalace mine C:\Users\chiis\.gemini\antigravity\brain --mode convos
```

### 查看記憶狀態

```powershell
mempalace status
mempalace wake-up
```
