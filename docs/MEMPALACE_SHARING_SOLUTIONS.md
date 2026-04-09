# 🏛️ MemPalace 跨電腦共享方案

> 本文檔整理多種將 MemPalace 記憶宮殿共享到其他電腦的工具與方法。

---

## 📦 資料庫結構

MemPalace 使用兩種資料庫：

| 資料庫 | 用途 | 檔案位置 |
|:---|:---|:---|
| **ChromaDB** | 向量資料庫（語意記憶） | `~/.mempalace/palace/chroma.sqlite3` |
| **SQLite** | 知識圖譜（時序實體關係） | `~/.mempalace/knowledge_graph.sqlite3` |

---

## 🔄 共享方案分類

### 方案 1：即時同步工具

#### 1.1 Syncthing（⭐ 推薦）

**適合情境**：兩台或多台電腦需要長期保持同步

**優點**：
- ✅ 開源免費
- ✅ 點對點同步，無需雲端伺服器
- ✅ 加密傳輸，安全性高
- ✅ 自動偵測變更並同步
- ✅ 支援版本控制（避免誤刪）

**安裝與設定**：
```bash
# macOS 安裝
brew install syncthing

# 啟動
syncthing

# 瀏覽器開啟管理介面
# http://127.0.0.1:8384
```

**設定步驟**：
1. 在兩台電腦分別啟動 Syncthing
2. 互相加入裝置 ID
3. 共享 `~/.mempalace/` 資料夾
4. 設定同步方向（雙向/單向）

**注意事項**：
- ⚠️ 避免兩台電腦同時寫入，可能導致資料庫衝突
- ⚠️ 建議設定為「單向同步」或確保同一時間僅一台電腦在使用

---

#### 1.2 rsync（macOS 內建）

**適合情境**：一次性傳輸或手動觸發同步

**優點**：
- ✅ macOS 內建，無需安裝
- ✅ 增量同步，只傳輸變更部分
- ✅ 支援壓縮與進度顯示
- ✅ 可透過 SSH 加密傳輸

**基本用法**：
```bash
# 區域網路直接傳輸
rsync -avz ~/.mempalace/ user@192.168.1.100:~/.mempalace/

# 透過 SSH 傳輸（推薦）
rsync -avz -e ssh ~/.mempalace/ user@remote-host:~/.mempalace/

# 從遠端下載到新電腦
rsync -avz -e ssh user@remote-host:~/.mempalace/ ~/.mempalace/
```

**常用參數**：
- `-a`：歸檔模式（保留權限、時間戳等）
- `-v`：顯示詳細資訊
- `-z`：傳輸時壓縮
- `-n`：預演模式（不實際執行，僅顯示會做什麼）
- `--progress`：顯示進度

**預演測試**：
```bash
# 先預演看看會同步哪些檔案
rsync -avn ~/.mempalace/ user@remote-host:~/.mempalace/
```

---

#### 1.3 scp（快速單次傳輸）

**適合情境**：簡單快速的一次性複製

**優點**：
- ✅ 命令簡單好記
- ✅ SSH 加密傳輸
- ✅ macOS/Linux/Windows 10+ 內建

**基本用法**：
```bash
# 複製到遠端電腦
scp -r ~/.mempalace/ user@remote-host:~/.mempalace/

# 從遠端下載
scp -r user@remote-host:~/.mempalace/ ~/.mempalace/

# 指定埠號（若非預設 22）
scp -P 2222 -r ~/.mempalace/ user@remote-host:~/.mempalace/
```

---

### 方案 2：雲端同步工具

#### 2.1 Dropbox / Google Drive / iCloud Drive

**適合情境**：需要透過雲端備份或多裝置存取

**優點**：
- ✅ 設定簡單，自動同步
- ✅ 支援版本歷史（可回溯）
- ✅ 無需保持兩台電腦同時在線

**設定方式**：
```bash
# 將 MemPalace 資料夾搬到雲端同步目錄
mv ~/.mempalace/ ~/Dropbox/mempalace/

# 建立符號連結（讓 MemPalace 仍從原路徑讀取）
ln -s ~/Dropbox/mempalace/ ~/.mempalace
```

**注意事項**：
- ⚠️ **重要**：SQLite 檔案若在同步過程中被打開，可能導致資料庫損毀
- ⚠️ 建議在關閉所有 MemPalace 程序後再同步
- ⚠️ 雲端同步可能有延遲，不適合即時共用

---

#### 2.2 rclone（多功能雲端工具）

**適合情境**：需要備份到多種雲端服務

**優點**：
- ✅ 支援 70+ 種雲端服務（Google Drive, Dropbox, S3, OneDrive 等）
- ✅ 可排程自動備份
- ✅ 支援加密傳輸

**安裝與設定**：
```bash
# macOS 安裝
brew install rclone

# 互動式設定雲端
rclone config

# 同步到雲端
rclone sync ~/.mempalace remote:mempalace-backup

# 從雲端還原
rclone sync remote:mempalace-backup ~/.mempalace

# 僅同步變更（較快）
rclone sync --update ~/.mempalace remote:mempalace-backup
```

**進階用法**：
```bash
# 帶進度條與速度限制
rclone sync ~/.mempalace remote:mempalace-backup \
  --progress \
  --bwlimit 1M

# 排除快取檔案
rclone sync ~/.mempalace remote:mempalace-backup \
  --exclude "*.lock" \
  --exclude "*.tmp"
```

---

### 方案 3：打包傳輸工具

#### 3.1 tar + scp/rsync（⭐ 推薦用於一次性遷移）

**適合情境**：完整遷移到新電腦

**優點**：
- ✅ 完整打包，避免遺漏檔案
- ✅ 壓縮後傳輸較快
- ✅ 可驗證檔案完整性

**操作流程**：
```bash
# === 在原始電腦 ===

# 1. 打包並壓縮
tar -czf mempalace_backup.tar.gz -C ~/ .mempalace/

# 2. 查看壓縮檔大小
ls -lh mempalace_backup.tar.gz

# 3. 傳輸到新電腦（選擇一種方式）
scp mempalace_backup.tar.gz user@new-computer:~/
# 或
rsync -avz mempalace_backup.tar.gz user@new-computer:~/


# === 在新電腦 ===

# 4. 解壓到家目錄
tar -xzf mempalace_backup.tar.gz -C ~/

# 5. 驗證資料完整性
mempalace status

# 6. 測試搜尋
mempalace search "test"
```

**驗證完整性**：
```bash
# 產生 checksum（在原始電腦）
shasum -a 256 mempalace_backup.tar.gz > mempalace_backup.tar.gz.sha256

# 在新電腦驗證
shasum -a 256 -c mempalace_backup.tar.gz.sha256
```

---

#### 3.2 Python 簡易 HTTP 伺服器

**適合情境**：區域網路內快速分享，無需 SSH

**優點**：
- ✅ 零設定，Python 內建
- ✅ 適合臨時快速傳輸
- ✅ 接收端直接用 `curl` 或瀏覽器下載

**操作流程**：
```bash
# === 在原始電腦 ===

# 1. 先打包
tar -czf mempalace_backup.tar.gz -C ~/ .mempalace/

# 2. 進入打包檔案所在目錄
cd ~

# 3. 啟動 HTTP 伺服器（Python 3）
python3 -m http.server 8000

# 4. 查看本機 IP
ifconfig | grep "inet " | grep -v 127.0.0.1
# 假設是 192.168.1.50


# === 在新電腦 ===

# 5. 下載檔案
curl http://192.168.1.50:8000/mempalace_backup.tar.gz -O

# 或用瀏覽器開啟
# http://192.168.1.50:8000

# 6. 解壓
tar -xzf mempalace_backup.tar.gz -C ~/

# 7. 驗證
mempalace status
```

**停止伺服器**：`Ctrl + C`

---

### 方案 4：MemPalace 內建匯出/匯入

#### 4.1 使用 export/import 指令

**適合情境**：需要跨平台或轉換格式

**優點**：
- ✅ 官方支援，格式標準
- ✅ 可匯出為 JSON 或 Markdown（可讀性高）
- ✅ 適合部分匯出或篩選

**操作流程**：
```bash
# 匯出為 JSON
mempalace export --format json --output mempalace_export.json

# 或匯出為 Markdown
mempalace export --format markdown --output mempalace_export.md

# 匯出特定 Wing
mempalace export --wing myproject --output project_backup.json


# === 在新電腦 ===

# 匯入
mempalace import mempalace_export.json

# 驗證
mempalace status
mempalace search "test"
```

---

## 🎯 方案比較表

| 方案 | 適合情境 | 設定難度 | 速度 | 是否需要額外安裝 | 推薦度 |
|:---|:---|:---:|:---:|:---:|:---:|
| **Syncthing** | 長期多機同步 | ⭐⭐ | 快 | ✅ | ⭐⭐⭐⭐⭐ |
| **rsync** | 手動觸發同步 | ⭐ | 快 | ❌（內建） | ⭐⭐⭐⭐⭐ |
| **scp** | 快速單次傳輸 | ⭐ | 中 | ❌（內建） | ⭐⭐⭐⭐ |
| **tar + scp** | 一次性遷移 | ⭐ | 快 | ❌（內建） | ⭐⭐⭐⭐⭐ |
| **Python HTTP** | 區域網路臨時分享 | ⭐ | 中 | ❌（內建） | ⭐⭐⭐ |
| **rclone** | 雲端備份 | ⭐⭐ | 依雲端而定 | ✅ | ⭐⭐⭐⭐ |
| **雲端同步** | 自動備份 | ⭐ | 慢（延遲） | ✅ | ⭐⭐⭐ |
| **export/import** | 格式轉換/部分匯出 | ⭐ | 中 | ❌（內建） | ⭐⭐⭐⭐ |

---

## ⚠️ 遷移注意事項

### 1. 路徑設定

新電腦需更新 `MEMPALACE_HOME` 環境變數或 `.mcp.json` 設定：

```bash
# 檢查目前路徑
echo $MEMPALACE_HOME

# 在 .mcp.json 中更新
{
  "mcpServers": {
    "mempalace": {
      "command": "/path/to/python",
      "args": ["-m", "mempalace.mcp_server"],
      "env": {
        "MEMPALACE_HOME": "/Users/yourname/.mempalace"
      }
    }
  }
}
```

### 2. MCP 設定

若使用 Claude Code 或其他 MCP 客戶端，需更新：
- Python 路徑（可能因環境而異）
- 環境變數路徑

### 3. 版本相容性

確保新電腦的 MemPalace 版本相同或更新：
```bash
# 檢查版本
mempalace --version

# 更新到最新版
pip install --upgrade mempalace
```

### 4. 資料庫安全

- ⚠️ **避免同時存取**：兩台電腦不要同時讀寫同一資料庫
- ⚠️ **同步前關閉程序**：確保 MemPalace 和 MCP 伺服器已停止
- ⚠️ **備份先行**：遷移前先備份原始資料

---

## 📋 遷移檢查清單

遷移完成後，依序執行以下檢查：

- [ ] 複製 `~/.mempalace/` 整個資料夾
- [ ] 在新電腦安裝相同版本的 MemPalace（`pip install mempalace`）
- [ ] 更新 `.mcp.json` 或 MCP 設定中的路徑
- [ ] 執行 `mempalace status` 驗證資料完整性
- [ ] 測試搜尋功能（`mempalace search "test"`）
- [ ] 確認 MCP 工具正常運作（若使用 Claude Code）
- [ ] 檢查向量資料庫：`ls ~/.mempalace/palace/` 確認 `chroma.sqlite3` 存在
- [ ] 檢查知識圖譜：`ls ~/.mempalace/knowledge_graph.sqlite3` 存在

---

## 🚀 快速開始範例

### 情境 A：遷移到新電腦（推薦流程）

```bash
# 1. 舊電腦打包
tar -czf ~/mempalace_backup.tar.gz -C ~/ .mempalace/

# 2. 使用 AirDrop / USB / 雲端傳輸到新電腦

# 3. 新電腦解壓
tar -xzf ~/mempalace_backup.tar.gz -C ~/

# 4. 安裝 MemPalace
pip install mempalace

# 5. 驗證
mempalace status
mempalace search "test"

# 6. 更新 MCP 設定（若使用 Claude Code）
# 編輯 .mcp.json 中的路徑
```

### 情境 B：兩台電腦定期同步

```bash
# 使用 rsync 建立同步腳本
#!/bin/bash
# sync-mempalace.sh

REMOTE_USER="user"
REMOTE_HOST="192.168.1.100"

echo "🔄 同步 MemPalace 到遠端..."
rsync -avz --progress \
  ~/.mempalace/ \
  $REMOTE_USER@$REMOTE_HOST:~/.mempalace/

echo "✅ 同步完成"
```

**加入 crontab 定期執行**：
```bash
# 每天凌晨 2 點同步
0 2 * * * /path/to/sync-mempalace.sh >> /var/log/mempalace-sync.log 2>&1
```

---

## 📚 相關文件

- [📖 README.md](../README.md) - MemPalace 主文件
- [🔧 MCP 狀態檢查](../scripts/mempalace-mcp-status.sh) - MCP 連線測試腳本

---

**🏛️ 讓你的記憶宮殿無縫跨機，隨時隨地存取 AI 記憶！**
