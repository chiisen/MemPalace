# 🏛️ MemPalace - AI 記憶宮殿

> **完全本地運行、免費的 AI 記憶系統** —— 目前基準測試中得分最高的 AI 記憶方案

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Python 3.9+](https://img.shields.io/badge/Python-3.9+-blue.svg)](https://www.python.org/downloads/)
[![Version](https://img.shields.io/badge/Version-3.0.0-orange.svg)](https://github.com/milla-jovovich/mempalace/releases)
[![Stars](https://img.shields.io/github/stars/milla-jovovich/mempalace?style=social)](https://github.com/milla-jovovich/mempalace)

---

## 📖 專案簡介

**MemPalace** 解決了一個核心問題：**AI 對話結束後，上下文與決策遺失了怎麼辦？**

仿照古希臘「記憶宮殿」的結構化儲存方式，將對話、專案與人員資訊分層組織，結合語意搜尋與知識圖譜，讓 AI 能在**無需外部 API 或雲端服務**的情況下，精確喚醒與檢索過往記憶。

### ✨ 核心特色

- 🏰 **記憶宮殿架構**：結構化過濾提升 34% 檢索準確率
- 📝 **原始逐字儲存**：預設不經 LLM 摘要，確保資訊零遺失
- 🔌 **MCP 無縫串接**：19 個 MCP 工具，支援 Claude Code、ChatGPT、Cursor、Gemini
- 🕰️ **時序知識圖譜**：支援「有效時間窗」，可查詢歷史狀態並失效過時事實
- 🤖 **專用 Agent 日誌**：跨 Session 保持專業知識，無需修改系統提示詞
- ⚡ **離線高效能**：完全本機運行，零網路請求
- 🗜️ **AAAK 壓縮方言**（實驗性）：節省上下文 Token

---

## 🛠️ 技術棧

| 項目 | 技術 |
|:---|:---|
| **程式語言** | Python 3.9+ (98.3%)、Shell (1.7%) |
| **向量資料庫** | ChromaDB |
| **知識圖譜** | SQLite（時序實體關係圖） |
| **協定整合** | MCP (Model Context Protocol) Server |
| **套件管理** | `pyproject.toml` + `uv.lock` |

---

## 📥 安裝方式

### 1️⃣ 安裝套件

```bash
pip install mempalace
```

### 2️⃣ 初始化設定

```bash
mempalace init ~/projects/myapp
```

此指令會建立宮殿路徑與設定檔。

### 3️⃣ 安裝 Claude Code 外掛（推薦）

```bash
# 加入 Marketplace
claude plugin marketplace add milla-jovovich/mempalace

# 安裝至使用者範圍
claude plugin install --scope user mempalace
```

安裝完成後**重啟 Claude Code**，輸入 `/skills` 確認 "mempalace" 已啟用。

---

## 🚀 使用說明

### 📊 常用指令速查表

| 動作 | 指令 | 說明 |
|:---|:---|:---|
| **資料擷取** | `mempalace mine <dir>` | 擷取專案程式碼、文件、筆記 |
| | `mempalace mine <dir> --mode convos` | 匯入對話紀錄（Claude/ChatGPT/Slack 匯出檔） |
| **分割檔案** | `mempalace split <dir>` | 將大型對話檔案拆分為獨立 Session |
| **語意搜尋** | `mempalace search "query"` | 全站語意搜尋 |
| | `mempalace search "query" --wing <name>` | 限定特定人或專案範圍 |
| **喚醒 AI** | `mempalace wake-up` | 輸出約 170 tokens 關鍵事實，直接貼入系統提示詞 |
| **AI 自動調用** | （無需指令） | 連線 MCP 後，AI 自動執行搜尋工具 |

### 🧩 Obsidian CLI（Windows / PowerShell）

本專案提供 `scripts/obsidian-cli.ps1`，以**純檔案模式**直接操作 Obsidian vault（不需 API Key）。

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

### 🧩 Obsidian CLI（macOS / zsh）

本專案提供 `scripts/obsidian-cli.sh`，以**純檔案模式**直接操作 Obsidian vault（不需 API Key）。

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

### 🏗️ 記憶宮殿架構

MemPalace 採用五層階層式儲存結構：

```
🏰 Palace（宮殿）
 └── 🦅 Wings（翼）：人 / 專案
      └── 🏛️ Halls（廳）：記憶類型（事實 / 事件 / 偏好等）
           └── 🚪 Rooms（房）：特定主題
                └── 🗄️ Closets（櫃）：摘要指引
                     └── 📥 Drawers（抽屜）：原始逐字檔
```

**結構化過濾**可提升 **34%** 檢索準確率，避免傳統向量搜尋的雜訊問題。

### 🤖 MCP 整合（AI 自動呼叫）

安裝 MCP 外掛後，AI 會自動使用以下工具：

- `mempalace_search`：語意搜尋記憶
- `mempalace_store`：儲存新記憶
- `mempalace_graph_query`：查詢知識圖譜
- ...等共 19 個工具

**使用者無需手動下指令**，只需用自然語言提問，AI 會自動調用對應工具。

### 🧠 喚醒 AI（適用於無 MCP 的模型）

對於不支援 MCP 的本地模型（如 Llama、Mistral），可使用 `wake-up` 指令：

```bash
mempalace wake-up
```

此指令會輸出約 **170 tokens** 的關鍵事實（L0+L1 層級），可直接貼入 Local LLM 的系統提示詞中，讓 AI 快速「想起」重要資訊。

---

## ⚙️ 進階功能

### 📔 Agent 日誌系統

為不同領域的 AI Agent 建立獨立 Wing 與日記，實現跨 Session 的專業知識累積：

```bash
# 建立專屬 Agent Wing
mempalace create-wing "coding-assistant"

# 記錄 Agent 決策
mempalace log "coding-assistant" "選擇使用 FastAPI 而非 Flask，因為..."
```

### ⚡ 自動儲存 Hooks

每 **15 則訊息**或**上下文壓縮前**自動觸發結構化儲存，支援背景執行：

```yaml
# config.yaml
hooks:
  auto_store: true
  message_threshold: 15
  background: true
```

### 🕰️ 時序知識圖譜

基於 SQLite，支援實體關係的「有效時間窗」（Temporal Validity）：

```bash
# 查詢實體歷史
mempalace graph history "專案A"

# 標記事實過期
mempalace graph expire "舊技術方案"
```

### 🗜️ AAAK 壓縮方言（實驗性）

針對大量重複實體設計的有損縮寫系統，LLM 無需解碼器即可閱讀：

```bash
# 啟用 AAAK 模式
mempalace search "query" --aaak
```

> ⚠️ **注意**：AAAK 為有損壓縮，目前 LongMemEval 基準得分 **84.2%**，低於 Raw mode 的 **96.6%**。建議僅在 Token 受限時使用。

---

## ⚠️ 注意事項與已知限制

### 🔴 重要提醒

1. **AAAK 壓縮狀態**：
   - 屬於**有損壓縮**，小規模文本下因編碼開銷反而增加 Token
   - LongMemEval 基準得分 84.2%，**低於** Raw mode 的 96.6%
   - **預設儲存格式仍為原始逐字文本**

2. **基準數據澄清**：
   - 標榜的 96.6% 僅限 Raw mode
   - "34% palace boost" 來自 ChromaDB 標準的元數據過濾功能，非全新演算法

3. **矛盾檢測功能**：
   - `fact_checker.py` 功能存在，但**尚未**自動整合至知識圖譜操作中
   - 正由 [Issue #27](https://github.com/milla-jovovich/mempalace/issues/27) 追蹤修復

### 🐛 已知問題

| 問題 | 追蹤 Issue | 狀態 |
|:---|:---|:---|
| ChromaDB 版本鎖定 | [#100](https://github.com/milla-jovovich/mempalace/issues/100) | 🔄 修復中 |
| Shell 注入漏洞 | [#110](https://github.com/milla-jovovich/mempalace/issues/110) | 🔄 修復中 |
| macOS ARM64 段錯誤 | [#74](https://github.com/milla-jovovich/mempalace/issues/74) | 🔄 修復中 |

### 💡 使用建議

- ✅ **推薦**：使用 Raw mode 儲存重要對話，確保資訊完整性
- ✅ **推薦**：定期執行 `mempalace wake-up` 保持 AI 上下文更新
- ⚠️ **謹慎**：AAAK 壓縮僅適用於 Token 嚴重受限的場景
- 🔒 **安全**：避免在記憶宮殿中儲存敏感資訊（密碼、API Key 等）

---

## 📦 依賴環境

| 套件 | 版本 |
|:---|:---|
| Python | 3.9+ |
| ChromaDB | >= 0.4.0 |
| PyYAML | >= 6.0 |

**無需 API Key、無需網際網路連線**，所有運算與儲存皆於本機完成。

---

## 📊 專案資訊

- **授權**：[MIT License](LICENSE)
- **版本**：v3.0.0（2026-04-06）
- **社群熱度**：⭐ 25.9k | 🍴 3.2k | 👁️ 195
- **原始碼**：[github.com/milla-jovovich/mempalace](https://github.com/milla-jovovich/mempalace)

---

## 🤝 貢獻指南

歡迎提交 Pull Request 與 Issue！詳細規範請參閱 [CONTRIBUTING.md](https://github.com/milla-jovovich/mempalace/blob/main/CONTRIBUTING.md)。

### 開發環境設定

```bash
# 複製專案
git clone https://github.com/milla-jovovich/mempalace.git
cd mempalace

# 安裝開發依賴
pip install -e ".[dev]"

# 執行測試
pytest
```

---

## 📚 常見問題

### Q：MemPalace 需要網路連線嗎？

**不需要**。所有運算與儲存皆於本機完成，無需 API Key 或雲端服務。

### Q：支援哪些 AI 工具？

- ✅ **完整支援（MCP）**：Claude Code、ChatGPT、Cursor、Gemini
- ⚠️ **手動整合**：Llama、Mistral 等需使用 `wake-up` 或 `search` 輸出文字檔

### Q：如何備份記憶宮殿？

記憶宮殿資料夾包含 ChromaDB 與 SQLite 檔案，直接複製整個資料夾即可備份。

### Q：可以匯出記憶嗎？

可以使用 `mempalace export` 指令將記憶匯出為 JSON 或 Markdown 格式。

---

## 🙏 致謝

感謝所有貢獻者與社群成員，讓 MemPalace 成為最強大的 AI 記憶方案！

---

**🏛️ 讓 AI 真正「記住」你的每一段對話！**
