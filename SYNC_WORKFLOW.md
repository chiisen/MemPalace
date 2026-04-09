# MemPalace → Hermes Agent 同步工作流

> 自動化將 MemPalace 的知識圖譜同步至 Hermes Agent，實現**零手動**的經驗傳承。

---

## 🎯 設計理念

```
┌─────────────────┐
│  MemPalace      │
│  (知識收集)     │
│                 │
│  • 知識圖譜     │
│  • 實體關係     │
│  • 專案決策     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  同步腳本       │
│  (排程執行)     │
│                 │
│  • 比對變更     │
│  • 格式轉換     │
│  • 增量同步     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Hermes Agent   │
│  (知識消費)     │
│                 │
│  • Context File │
│  • Skills       │
│  • 使用者模型   │
└─────────────────┘
```

---

## 📦 安裝與設定

### 1. 確認環境

```bash
# 確認 MemPalace 可用
mempalace status

# 確認 Hermes 已安裝
hermes --version
```

### 2. 同步腳本位置

```
/Users/liao-eli/github/MemPalace/scripts/
├── sync_kg_to_hermes.py    # Python 核心腳本
├── sync_to_hermes.sh       # Shell 包裝腳本
└── CRON_SETUP.md           # 詳細設定說明
```

### 3. 快速測試

```bash
cd /Users/liao-eli/github/MemPalace/scripts

# 預覽變更
python3 sync_kg_to_hermes.py --dry-run

# 執行同步
python3 sync_kg_to_hermes.py --force
```

---

## 🔄 同步內容

### 目前同步的資料

| 資料類型 | 來源 | 目標 | 說明 |
|---------|------|------|------|
| **專案清單** | `docs/entities.json` | `~/.hermes/context/mempalace_kg.md` | 已知專案名稱 |
| **實體關係** | MemPalace KG | Context File | 實體間的關係（三元組） |
| **時間戳記** | KG metadata | Context File | 關係生效時間 |

### 未來可擴展

- 🔲 **Drawers** → Hermes Skills（SOP 自動生成）
- 🔲 **Agent Diary** → 歷史經驗總結
- 🔲 **Wing/Room 結構** → Context 分類

---

## ⚙️ 設定排程

### 選項 A：Cron（簡單）

```bash
# 編輯 crontab
crontab -e

# 添加：每天凌晨 2 點同步
0 2 * * * /Users/liao-eli/github/MemPalace/scripts/sync_to_hermes.sh >> ~/.mempalace/logs/sync_hermes.log 2>&1

# 查看設定
crontab -l
```

### 選項 B：launchd（macOS 推薦）

```bash
# 建立 plist
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

# 載入
launchctl load ~/Library/LaunchAgents/com.mempalace.sync-hermes.plist

# 查看狀態
launchctl list | grep mempalace
```

---

## 📊 監控與除錯

### 查看同步狀態

```bash
# 最後同步時間
cat ~/.mempalace/sync_state.json | python3 -m json.tool

# 同步日誌（最近 20 行）
tail -n 20 ~/.mempalace/logs/sync_hermes.log

# 即時追蹤
tail -f ~/.mempalace/logs/sync_hermes.log
```

### 查看生成的 Context

```bash
# 查看內容
cat ~/.hermes/context/mempalace_kg.md

# 查看檔案大小與修改時間
ls -lh ~/.hermes/context/mempalace_kg.md
```

### 驗證 Hermes 是否讀取

重啟 Hermes 後，它會自動載入 `~/.hermes/context/` 下的所有 `.md` 檔案。

```bash
# 重啟 Hermes
hermes reset

# 或在 gateway 模式下
# Ctrl+C 停止後重新執行 hermes gateway
```

---

## 🎓 使用情境

### 情境 1：Hermes 理解專案背景

當你對 Hermes 說：
>「幫我部署 Obsidian 專案」

Hermes 會自動參考 `mempalace_kg.md`，理解：
- Obsidian 是什麼
- 使用的技術棧
- 過去的決策背景

### 情境 2：知識圖譜更新

當你在 MemPalace 中添加新關係：
```python
# 透過 MCP 工具
mempalace_kg_add(
    subject='MemPalace',
    predicate='integrates_with',
    object='Hermes-Agent'
)
```

下次排程同步時，Hermes 會自動得知這個整合關係。

---

## 🔧 進階設定

### 自訂同步頻率

**每 6 小時**：
```bash
0 */6 * * * /path/to/sync_to_hermes.sh
```

**每小時**：
```bash
0 * * * * /path/to/sync_to_hermes.sh
```

**僅工作日**：
```bash
0 2 * * 1-5 /path/to/sync_to_hermes.sh
```

### 手動觸發同步

```bash
# 隨時可手動執行
/Users/liao-eli/github/MemPalace/scripts/sync_to_hermes.sh

# 或使用完整路徑
python3 /Users/liao-eli/github/MemPalace/scripts/sync_kg_to_hermes.py --force
```

---

## ⚠️ 注意事項

1. **知識圖譜需先充實**
   - 目前 KG 為空，僅同步專案清單
   - 建議開始使用 `mempalace_kg_add` 添加實體關係

2. **Hermes 需重啟才會讀取新 Context**
   - Hermes 在啟動時載入 `~/.hermes/context/*.md`
   - 同步後重啟 Hermes 即可

3. **同步為單向**
   - MemPalace → Hermes（單向）
   - Hermes 的 Skills 不會回寫到 MemPalace

4. **衝突處理**
   - 同步腳本會比對變更，避免無意義寫入
   - 使用 `--force` 可強制覆蓋

---

## 📚 相關文件

- [Hermes-Agent README](/Users/liao-eli/github/Hermes-Agent/README.md) — Hermes 完整功能說明
- [MemPalace Migration Guide](/Users/liao-eli/github/Hermes-Agent/docs/MEMPALACE_MIGRATION.md) — 四階段轉移流程
- [Cron 設定說明](CRON_SETUP.md) — 詳細排程設定

---

*最後更新：2026-04-09*
*狀態：✅ 同步腳本已建立並測試通過*
