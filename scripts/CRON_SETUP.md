# MemPalace → Hermes Agent 同步設定

## 📖 概覽

本目錄包含自動化同步腳本，將 MemPalace 的知識圖譜定期同步至 Hermes Agent 的 Context Files。

### 檔案說明

| 檔案 | 用途 |
|------|------|
| `sync_kg_to_hermes.py` | Python 核心同步腳本（處理轉換邏輯） |
| `sync_to_hermes.sh` | Shell 包裝腳本（支援 cron 排程） |
| `CRON_SETUP.md` | 本檔案（設定說明） |

---

## 🚀 快速開始

### 1. 手動執行同步

```bash
cd /Users/liao-eli/github/MemPalace/scripts

# 執行同步
./sync_to_hermes.sh

# 預覽變更（不寫入）
./sync_to_hermes.sh --dry-run

# 強制覆蓋
./sync_to_hermes.sh --force
```

### 2. 設定 Cron 排程

#### 選項 A：自動設定（推薦）

```bash
./sync_to_hermes.sh --setup-cron
```

這會自動添加 crontab 項目：**每天凌晨 2:00 執行同步**

#### 選項 B：手動設定

```bash
# 編輯 crontab
crontab -e

# 添加以下行（每天凌晨 2 點執行）
0 2 * * * /Users/liao-eli/github/MemPalace/scripts/sync_to_hermes.sh >> /Users/liao-eli/.mempalace/logs/sync_hermes.log 2>&1

# 儲存後查看
crontab -l
```

#### 選項 C：使用 launchd（macOS 推薦）

macOS 推荐使用 `launchd` 而非 cron，更可靠：

```bash
# 建立 plist 檔案
cat > ~/Library/LaunchAgents/com.mempalace.sync-hermes.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.mempalace.sync-hermes</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/liao-eli/github/MemPalace/scripts/sync_to_hermes.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>2</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>/Users/liao-eli/.mempalace/logs/sync_hermes.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/liao-eli/.mempalace/logs/sync_hermes_error.log</string>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

# 載入服務
launchctl load ~/Library/LaunchAgents/com.mempalace.sync-hermes.plist

# 查看狀態
launchctl list | grep mempalace

# 移除服務（如需）
# launchctl unload ~/Library/LaunchAgents/com.mempalace.sync-hermes.plist
```

---

## 📊 同步內容

### 目前同步的資料

- ✅ **知識圖譜實體與關係**（從 MemPalace KG）
- ✅ **專案清單**（從 `docs/entities.json`）
- ✅ **關係類型與時間戳記**

### 未來可擴展的資料

- 🔲 Drawers（原始文本 → Hermes Skills）
- 🔲 Agent Diary（日記 → 歷史經驗）
- 🔲 Wing/Room 結構（→ Context 分類）

---

## 🔍 查看同步狀態

### 查看最後同步時間

```bash
cat ~/.mempalace/sync_state.json | python3 -m json.tool
```

### 查看同步日誌

```bash
# 最近 20 行
tail -n 20 ~/.mempalace/logs/sync_hermes.log

# 即時追蹤
tail -f ~/.mempalace/logs/sync_hermes.log
```

### 查看生成的 Context File

```bash
cat ~/.hermes/context/mempalace_kg.md
```

---

## ⚙️ 進階設定

### 自訂同步頻率

**每 6 小時同步一次**：
```bash
0 */6 * * * /path/to/sync_to_hermes.sh
```

**每小時同步一次**：
```bash
0 * * * * /path/to/sync_to_hermes.sh
```

**僅工作日同步**：
```bash
0 2 * * 1-5 /path/to/sync_to_hermes.sh
```

### 同步前觸發（可選）

如果想在 MemPalace 有新資料時**立即同步**，可結合以下機制：

1. **MemPalace Hook**: 當呼叫 `mempalace_kg_add` 時觸發同步
2. **檔案監聽**: 監聽 `~/.mempalace/palace/` 目錄變化

---

## ⚠️ 疑難排解

### 問題：同步腳本找不到 `mempalace` 命令

**解法**：確保 Python 環境正確

```bash
# 檢查 mempalace 路徑
which mempalace

# 在 crontab 中使用完整路徑
0 2 * * * /Users/liao-eli/.local/bin/mempalace ...
```

### 問題：Hermes Context 目錄不存在

**解法**：手動建立目錄

```bash
mkdir -p ~/.hermes/context
```

### 問題：同步後 Hermes 未讀取新資料

**解法**：Hermes 會自動載入 `~/.hermes/context/` 下的 `.md` 檔案，重啟 Hermes 即可：

```bash
# 重啟 Hermes
hermes reset
# 或重新啟動 gateway
hermes gateway
```

---

*最後更新：2026-04-09*
