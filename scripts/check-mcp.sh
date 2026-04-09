#!/usr/bin/env bash
set -euo pipefail

echo "== [1/3] 檢查 Codex MCP 設定 =="
if [ -f "$HOME/.codex/config.toml" ]; then
  rg -n "mcp_servers\\.mempalace|mempalace_status|mempalace_search" "$HOME/.codex/config.toml" || true
else
  echo "找不到 ~/.codex/config.toml"
fi

echo ""
echo "== [2/3] 檢查 MemPalace CLI =="
if command -v mempalace >/dev/null 2>&1; then
  mempalace --version || true
  mempalace status || true
  mempalace search "MemPalace" --limit 3 || true
else
  echo "找不到 mempalace 指令，請先安裝（建議使用 venv 或 pipx）"
fi

echo ""
echo "== [3/3] 下一步建議 =="
echo "1) 若剛修改 config.toml，請重啟 Codex CLI / session。"
echo "2) 在新 session 再測一次 mempalace_status 與 mempalace_search。"
