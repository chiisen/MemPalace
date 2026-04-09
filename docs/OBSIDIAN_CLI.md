# Obsidian CLI 使用說明

本專案提供兩種 Obsidian CLI 腳本，皆為**純檔案模式**（不需 API Key）：

- Windows / PowerShell：`scripts/obsidian-cli.ps1`
- macOS / zsh：`scripts/obsidian-cli.sh`

## Windows / PowerShell

1. 設定 vault 路徑環境變數（若未設定，預設使用 `D:\github\chiisen\JoObsidian`）：

```powershell
$env:OBSIDIAN_VAULT_PATH = "D:\github\chiisen\JoObsidian"
```

2. 執行範例：

```powershell
# 讀取筆記
.\scripts\obsidian-cli.ps1 read "Daily/2026-04-09.md"

# 建立/覆寫筆記
.\scripts\obsidian-cli.ps1 create "Inbox/Test.md" -Content "# Hello from CLI"

# 搜尋關鍵字
.\scripts\obsidian-cli.ps1 search "BAM"
```

## macOS / zsh

1. 一鍵安裝（會建立 `~/.local/bin/obsidian-note` 並寫入 shell 設定）：

```bash
./scripts/obsidian-cli.sh install
source ~/.zshrc
```

2. 若要指定 vault 路徑：

```bash
./scripts/obsidian-cli.sh install "/Users/你的帳號/your-vault"
source ~/.zshrc
```

3. 執行範例：

```bash
# 搜尋關鍵字
obsidian-note search "BAM"

# 讀取筆記
obsidian-note read "Daily/2026-04-09.md"

# 建立/覆寫筆記
obsidian-note create "Inbox/Test.md" "# Hello from CLI"
```

## 支援指令

- `read`
- `create`
- `search`
- `daily-read`
- `daily-append`
- `tags`
- `install`（僅 `scripts/obsidian-cli.sh`）
