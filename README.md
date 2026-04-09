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

### 🧩 Obsidian CLI

Obsidian CLI 相關安裝與使用方式（Windows / macOS）已整理至：

- [docs/OBSIDIAN_CLI.md](docs/OBSIDIAN_CLI.md)

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

### 🧪 MemPalace MCP 完整安裝與測試指南（2026-04-09）

#### 0) 環境資訊

| 項目 | 規格 |
|:---|:---|
| **OS** | macOS 25.3.0 (Tahoe) |
| **Python** | 3.x |
| **MemPalace 版本** | 3.0.14 |
| **Claude Code** | 2.1.97+ |
| **測試時間** | 2026-04-09 |

---

#### 1) 安裝 MemPalace 套件

##### 1-1 系統環境檢查

```bash
# 檢查 Python 版本
python3 --version  # 需要 3.9+

# 檢查 pip 是否正常
pip --version
```

##### 1-2 安裝 MemPalace（推薦使用虛擬環境）

```bash
# 若使用 pyenv（推薦）
pyenv shell 3.11.9    # 或任何支援的版本

# 若使用 venv
python3 -m venv ~/.venv-mempalace
source ~/.venv-mempalace/bin/activate

# 安裝 MemPalace
pip install mempalace

# 驗證安裝
mempalace --version    # 應顯示 3.0.14 或更新版本
```

##### 1-3 初始化宮殿

```bash
# 建立宮殿資料夾（第一次執行）
mempalace init ~/.mempalace

# 檢查狀態
mempalace status
```

**預期輸出示例**：
```
=======================================================
  MemPalace Status — 22 drawers
=======================================================

  WING: mempalace_docs
    ROOM: general                 22 drawers

=======================================================
```

---

#### 2) Claude Code 整合設定

##### 2-1 檢查 Claude Code 支援的 MCP 伺服器列表

```bash
# 列出已知的 MCP 伺服器
ls -la ~/.claude/mcp-servers.json 2>/dev/null || echo "檔案不存在，需要手動建立"
```

##### 2-2 設定 Claude Code MCP（使用 `.mcp.json`）

在**專案根目錄**建立 `.mcp.json`：

```json
{
  "mcpServers": {
    "mempalace": {
      "command": "/Users/liao-eli/.local/pipx/venvs/mempalace/bin/python",
      "args": ["-m", "mempalace.mcp_server"],
      "env": {
        "MEMPALACE_HOME": "/Users/liao-eli/.mempalace"
      }
    }
  }
}
```

**文件位置**：
```
MemPalace/
├── .mcp.json          ← 在這裡
├── README.md
├── src/
└── ...
```

> **重要**：
> - Claude Code **不支援在 `settings.json` 中直接設定 MCP servers**
> - 必須使用 `.mcp.json`（由 Claude Code 自動識別）
> - `command` 應為完整絕對路徑（特別是 pipx 環境）
> - `MEMPALACE_HOME` 指向宮殿所在路徑

##### 2-3 驗證 MCP 連線

1. **完全重啟 Claude Code**（不只是關閉窗口）
2. **打開新 Session**
3. **在 Claude Code 中測試 MCP 工具**（AI 會自動調用）

或使用 CLI 驗證基礎狀態：
```bash
mempalace status      # 確認宮殿正常
```

**預期結果**：Claude Code 重啟後，mempalace MCP 工具應自動可用。

---

#### 3) CLI 功能全面測試

##### 3-1 查詢宮殿狀態

```bash
mempalace status
```

**預期輸出**：Wing 數量、Room 數量、總 Drawers 數。

##### 3-2 語義搜尋（基礎）

```bash
mempalace search "codex:setup"
```

**預期輸出**：命中的相關記憶 + 相似度分數。

##### 3-3 語義搜尋（進階過濾）

```bash
# 限定專案範圍
mempalace search "Laravel" --wing mempalace_docs --results 3

# 限定房間範圍
mempalace search "Vue" --room general --results 2
```

**支援參數**：
- `--wing <name>`：限定特定 Wing（人/專案）
- `--room <name>`：限定特定 Room（主題）
- `--results <n>`：限制回傳筆數（預設 20）

##### 3-4 快速喚醒（生成上下文摘要）

```bash
mempalace wake-up
```

**預期輸出**：~800+ tokens 的關鍵事實摘要，含以下層級：
- **L0 — IDENTITY**：身份識別（若已設定）
- **L1 — ESSENTIAL STORY**：核心故事（最重要的記憶）
- **L2 & L3**：擴展事實與細節

**用途**：可直接複製貼到 AI 系統提示詞中快速恢復上下文。

##### 3-5 壓縮記憶（預覽模式）

```bash
mempalace compress --dry-run
```

**預期輸出**：
- 每個 Drawer 的原始 Token 數與壓縮後 Token 數
- 整體壓縮倍率（示例：5.4x）
- **不實際儲存任何檔案**

**實際壓縮**（非預覽）：
```bash
mempalace compress
```

---

#### 4) 實測結果總結

| 功能 | CLI | MCP | 狀態 | 備註 |
|:---|:---:|:---:|:---|:---|
| **status** | ✅ | ✅ | 正常 | 22 drawers 已加載 |
| **search** | ✅ | ✅ | 正常 | 語義搜尋精準度高 |
| **wake-up** | ✅ | ⭕ | 正常 | CLI 專用，生成 ~826 tokens |
| **compress** | ✅ | ⭕ | 正常 | 平均 5.4x 壓縮率 |
| **split** | ✅ | ⭕ | 就緒 | 用於拆分大型對話檔 |

> ⭕ = 工具於 Claude Code 不可用（已排除或 CLI 專用）

---

#### 5) 測試過程中遇到的問題與解決方案

##### 問題 A：MCP 工具未被 Claude Code 識別

**症狀**：
- 設定了 `settings.json`，但 Claude Code 仍無法呼叫 mempalace 工具。

**原因**：
- MCP 伺服器設定需在 Claude Code 啟動時載入。
- `settings.json` 變更後未重啟 session。

**解決方案**：
1. 確認 `~/.claude/settings.json` 已正確設定 `mempalace` server。
2. **完全重啟 Claude Code**（不是只關視窗）。
3. 開啟新對話或 session。
4. 測試 `mempalace status` 命令。

##### 問題 B：Python 找不到 mempalace 模組

**症狀**：
```
ModuleNotFoundError: No module named 'mempalace'
```

**原因**：
- MemPalace 安裝在不同的 Python 環境（venv / pyenv）。
- Claude Code 使用的 Python 未包含 mempalace。

**解決方案**：
1. 確認 `mempalace --version` 可正常執行。
2. 查詢 MemPalace 的實際路徑：
   ```bash
   which mempalace
   # 或找到 Python 模組路徑
   python3 -c "import mempalace; print(mempalace.__file__)"
   ```
3. 在 `settings.json` 中指定完整 Python 路徑：
   ```json
   "command": "/Users/liao-eli/.pyenv/versions/3.11.9/bin/python"
   ```

##### 問題 C：宮殿資料夾路徑設定錯誤

**症狀**：
- `mempalace status` 回傳空白或「0 drawers」。

**原因**：
- `MEMPALACE_HOME` 環境變數指向錯誤位置。
- 宮殿初始化失敗。

**解決方案**：
1. 確認宮殿存在：
   ```bash
   ls -la ~/.mempalace
   ```
2. 若不存在，重新初始化：
   ```bash
   mempalace init ~/.mempalace
   ```
3. 在 `settings.json` 中設定正確路徑（用絕對路徑）。

##### 問題 D：搜尋結果為空或相似度異常低

**症狀**：
- `mempalace search "query"` 回傳 0 筆結果或相似度 > 0.5。

**原因**：
- 記憶向量化尚未完成（新安裝）。
- 搜尋詞過於特異。

**解決方案**：
1. 若新安裝，先使用 `mempalace mine` 匯入內容：
   ```bash
   mempalace mine /path/to/project --mode files
   ```
2. 嘗試更通用的搜尋詞。
3. 檢查 ChromaDB 是否正常初始化：
   ```bash
   ls -la ~/.mempalace/chroma/  # 應有 .db 檔案
   ```

##### 問題 E：「加 Marketplace」但插件未出現

**症狀**：
```bash
/plugin marketplace add milla-jovovich/mempalace
# 執行後，/mempalace 指令仍不存在
```

**原因**：
- `marketplace add` 只是登記來源，不是安裝插件本身。

**解決方案**：
```bash
# 第一步：登記 Marketplace
/plugin marketplace add milla-jovovich/mempalace

# 第二步：從 Marketplace 安裝插件
/plugin install mempalace@milla-jovovich

# 第三步：重載插件
/reload-plugins

# 第四步：驗證
/skills  # 應看到 mempalace:* 指令
```

##### 問題 F：MCP 伺服器啟動時找不到 Python 模組

**症狀**：
```
❌ ModuleNotFoundError: No module named 'mempalace'
```
或 Claude Code 重啟後仍無法呼叫 mempalace MCP 工具。

**原因**：
- MemPalace 通常使用 **pipx** 安裝（隔離的虛擬環境）。
- MCP 伺服器設定中的 `command` 若指向系統 `python3`，無法找到 pipx venv 內的模組。
- `.mcp.json` 或 `settings.json` 中的 Python 路徑不正確。

**排查步驟**：

1. 確認 mempalace 安裝方式：
```bash
which mempalace
# 若輸出類似 /Users/xxx/.local/bin/mempalace，則為 pipx 安裝
```

2. 查詢 pipx venv 的 Python 路徑：
```bash
head -1 /Users/xxx/.local/bin/mempalace
# 輸出形如：#!/Users/xxx/.local/pipx/venvs/mempalace/bin/python
# 這就是正確的 Python 路徑
```

**解決方案**：

在 `.mcp.json` 中使用完整 pipx Python 路徑：

```json
{
  "mcpServers": {
    "mempalace": {
      "command": "/Users/liao-eli/.local/pipx/venvs/mempalace/bin/python",
      "args": ["-m", "mempalace.mcp_server"],
      "env": {
        "MEMPALACE_HOME": "/Users/liao-eli/.mempalace"
      }
    }
  }
}
```

> **說明**：
> - `.mcp.json` 位於專案根目錄，由 Claude Code 自動識別
> - Claude Code **不支援在 `settings.json` 中直接設定 MCP servers**
> - `command` 必須為完整絕對路徑

**驗證**：

```bash
# 測試該 Python 環境是否能載入 mempalace
/Users/liao-eli/.local/pipx/venvs/mempalace/bin/python -c "import mempalace; print('✅')"
```

---

#### 6) 健康檢查清單

每次環境異動後，依序執行以下檢查：

- [ ] **CLI 環境**：`mempalace status` 顯示 drawers 數 > 0
- [ ] **宮殿搜尋**：`mempalace search "test"` 回傳結果（相似度 < 0.3）
- [ ] **向量資料庫**：`ls ~/.mempalace/chroma/` 確認 .db 檔存在
- [ ] **`.mcp.json` 設定**：專案根目錄存在且路徑正確
- [ ] **Python 模組**：
  ```bash
  # 若使用 pipx：
  /Users/liao-eli/.local/pipx/venvs/mempalace/bin/python -c "import mempalace; print('✅')"
  ```
- [ ] **MCP 連線**（Claude Code）：
  - 完全重啟 Claude Code
  - 開新 Session
  - 測試 mempalace MCP 工具可否呼叫

---

#### 7) `.mcp.json` 設定示例

> ⚠️ **重要**：Claude Code **不支援在 `settings.json` 中直接設定 MCP servers**。
> 必須使用專案根目錄的 `.mcp.json` 檔案。

##### 組合 1：pipx 安裝（推薦）

```json
{
  "mcpServers": {
    "mempalace": {
      "command": "/Users/liao-eli/.local/pipx/venvs/mempalace/bin/python",
      "args": ["-m", "mempalace.mcp_server"],
      "env": {
        "MEMPALACE_HOME": "/Users/liao-eli/.mempalace"
      }
    }
  }
}
```

**位置**：`.mcp.json`（專案根目錄）

**優點**：
- pipx 提供隔離的虛擬環境
- 自動處理依賴版本衝突
- 易於更新與卸載

**查詢 pipx Python 路徑**：
```bash
head -1 /Users/liao-eli/.local/bin/mempalace
# 輸出的 #! 後面就是完整路徑
```

##### 組合 2：系統 Python（簡單但不推薦）

```json
{
  "mcpServers": {
    "mempalace": {
      "command": "python3",
      "args": ["-m", "mempalace.mcp_server"]
    }
  }
}
```

適用於 `pip install mempalace` 至系統全域時。
> ⚠️ 易產生依賴衝突，建議優先使用 pipx。

##### 組合 3：pyenv 隔離環境

```json
{
  "mcpServers": {
    "mempalace": {
      "command": "/Users/liao-eli/.pyenv/versions/3.11.9/bin/python",
      "args": ["-m", "mempalace.mcp_server"],
      "env": {
        "MEMPALACE_HOME": "/Users/liao-eli/.mempalace"
      }
    }
  }
}
```

適用於多 Python 版本環境時。

##### 組合 4：venv 虛擬環境

```json
{
  "mcpServers": {
    "mempalace": {
      "command": "/Users/liao-eli/.venv-mempalace/bin/python",
      "args": ["-m", "mempalace.mcp_server"],
      "env": {
        "MEMPALACE_HOME": "/Users/liao-eli/.mempalace"
      }
    }
  }
}
```

適用於需要完全隔離依賴的情況。

---

#### 8) 進階調試

##### 手動啟動 MCP 伺服器（觀察錯誤）

若使用 pipx 安裝：

```bash
/Users/liao-eli/.local/pipx/venvs/mempalace/bin/python \
  -m mempalace.mcp_server
```

或直接測試模組載入：

```bash
/Users/liao-eli/.local/pipx/venvs/mempalace/bin/python << 'EOF'
import sys
print(f"Python: {sys.executable}")
print(f"Version: {sys.version}")

try:
    import mempalace
    print("✅ mempalace 模組載入成功")
    from mempalace.mcp_server import main
    print("✅ MCP server 可用")
except ImportError as e:
    print(f"❌ 模組錯誤：{e}")
    sys.exit(1)
EOF
```

##### Claude Code MCP 除錯

1. **確認 `.mcp.json` 存在**：
   ```bash
   cat ./mcp.json  # 在專案根目錄執行
   ```

2. **驗證 Python 路徑**：
   ```bash
   /Users/liao-eli/.local/pipx/venvs/mempalace/bin/python --version
   ```

3. **測試模組呼叫**（見上方示例）

4. **重啟 Claude Code**：
   - 完全關閉（不只是視窗最小化）
   - 重新打開
   - 打開新 Session

---

#### 9) OpenCode MCP 使用者層級設定（2026-04-09 更新）

> **情境**：希望在所有專案中使用 MemPalace MCP，無需每個專案都設定 `.mcp.json`

##### 9-1 背景說明

**OpenCode** 是另一個 AI 編碼助手，其 MCP 設定方式與 Claude Code 不同：

| 平台 | 設定檔位置 | 設定格式 |
|:---|:---|:---|
| **Claude Code** | `~/.claude/mcp.json` 或 `./.mcp.json` | `mcpServers` 物件 |
| **OpenCode** | `~/.opencode/opencode.json` | `mcp` 物件 |

##### 9-2 操作流程

###### 步驟 1：檢查 OpenCode 設定檔

```bash
# 檢查 opencode 設定目錄
ls -la ~/.opencode/

# 查看現有 opencode.json
cat ~/.opencode/opencode.json
```

###### 步驟 2：檢查現有 MCP 設定

```bash
# 查看現有 MCP 設定
cat ~/.opencode/opencode.json | jq '.mcp'
```

**預期輸出**（若有其他 MCP 已設定）：
```json
{
  "grepai": {
    "type": "local",
    "command": ["grepai", "mcp-serve"],
    "enabled": true
  }
}
```

###### 步驟 3：加入 MemPalace MCP

編輯 `~/.opencode/opencode.json`，在 `mcp` 區塊中加入：

```json
"mempalace": {
  "type": "local",
  "command": ["/Users/liao-eli/.local/pipx/venvs/mempalace/bin/python", "-m", "mempalace.mcp_server"],
  "env": {
    "MEMPALACE_HOME": "/Users/liao-eli/.mempalace"
  },
  "enabled": true
}
```

**完整範例**：
```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": { ... },
  "mcp": {
    "grepai": {
      "type": "local",
      "command": ["grepai", "mcp-serve"],
      "enabled": true
    },
    "mempalace": {
      "type": "local",
      "command": ["/Users/liao-eli/.local/pipx/venvs/mempalace/bin/python", "-m", "mempalace.mcp_server"],
      "env": {
        "MEMPALACE_HOME": "/Users/liao-eli/.mempalace"
      },
      "enabled": true
    }
  }
}
```

###### 步驟 4：驗證設定

```bash
# 驗證 MCP 設定已加入
cat ~/.opencode/opencode.json | jq '.mcp'
```

**預期輸出**：
```json
{
  "grepai": { ... },
  "mempalace": {
    "type": "local",
    "command": [...],
    "env": { ... },
    "enabled": true
  }
}
```

###### 步驟 5：測試 MemPalace MCP

```bash
# 測試 CLI 狀態
mempalace status

# 測試 Python 模組
/Users/liao-eli/.local/pipx/venvs/mempalace/bin/python -c "import mempalace; print('✅')"

# 測試 MCP Server import
/Users/liao-eli/.local/pipx/venvs/mempalace/bin/python -c "from mempalace.mcp_server import main; print('✅')"
```

**預期結果**：全部顯示 ✅

##### 9-3 設定層級差異

| 位置 | 範圍 | 優先權 |
|:---|:---|:---|
| `~/.opencode/opencode.json` | **全域（所有專案）** | 低 |
| `./.opencode.json`（專案根目錄） | 僅該專案 | **高**（會覆蓋全域） |

> **建議**：將 MemPalace 設為使用者層級，所有專案即可共用，無需重複設定。

##### 9-4 實測結果

| 測試項目 | 狀態 | 結果 |
|:---|:---:|:---|
| **CLI 狀態** | ✅ | 22 drawers 已載入 |
| **Python 模組** | ✅ | mempalace 模組正常 |
| **MCP Server** | ✅ | 可正常 import |
| **語意搜尋** | ✅ | 搜尋 "MCP" 回傳 3 筆結果 |
| **OpenCode MCP** | ✅ | 設定檔已加入 |

##### 9-5 遇到的問題與解決方案

###### 問題 G：找不到 opencode 設定檔

**症狀**：
```bash
cat ~/.opencode/opencode.json
# 檔案不存在
```

**原因**：
- opencode 尚未初始化
- 設定檔位於其他位置

**解決方案**：
```bash
# 檢查 opencode 目錄是否存在
ls -la ~/.opencode/

# 若目錄不存在，需先執行 opencode 初始化
opencode init
```

###### 問題 H：MCP 設定格式錯誤

**症狀**：
- opencode 無法啟動 MCP
- 錯誤訊息指向 JSON 格式問題

**原因**：
- JSON 語法錯誤（缺少逗號、括號不匹配）
- 設定格式不符合 opencode 規範

**解決方案**：
```bash
# 使用 jq 驗證 JSON 格式
cat ~/.opencode/opencode.json | jq .

# 若有錯誤，jq 會顯示錯誤行號
```

**正確格式要點**：
- `command` 為**陣列格式**（非字串）
- `env` 為物件格式
- `enabled` 為布林值
- 每個 MCP server 之間用逗號分隔

###### 問題 I：pipx Python 路徑不正確

**症狀**：
```
❌ ModuleNotFoundError: No module named 'mempalace'
```

**原因**：
- `command` 中的 Python 路徑不正確
- mempalace 安裝在不同的 Python 環境

**解決方案**：
```bash
# 查詢正確的 pipx Python 路徑
head -1 /Users/liao-eli/.local/bin/mempalace
# 輸出：#!/Users/liao-eli/.local/pipx/venvs/mempalace/bin/python

# 或使用 which 查詢
which mempalace
# 然後查看該腳本的 shebang 行
```

##### 9-6 完整健康檢查清單

每次環境異動後，依序執行以下檢查：

- [ ] **CLI 環境**：`mempalace status` 顯示 drawers 數 > 0
- [ ] **宮殿搜尋**：`mempalace search "test"` 回傳結果（相似度 < 0.3）
- [ ] **向量資料庫**：`ls ~/.mempalace/chroma/` 確認 .db 檔存在
- [ ] **OpenCode 設定**：`~/.opencode/opencode.json` 存在且包含 mempalace
- [ ] **Python 模組**：
  ```bash
  /Users/liao-eli/.local/pipx/venvs/mempalace/bin/python -c "import mempalace; print('✅')"
  ```
- [ ] **MCP Server**：
  ```bash
  /Users/liao-eli/.local/pipx/venvs/mempalace/bin/python -c "from mempalace.mcp_server import main; print('✅')"
  ```
- [ ] **OpenCode 重啟**：
  - 完全關閉 opencode
  - 重新打開
  - 測試 mempalace MCP 工具可否呼叫

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
