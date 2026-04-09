# MemPalace → Hermes Agent 喚醒包

> 以下是從 MemPalace 匯出的核心記憶，請將這些資訊納入背景知識，作為未來對話的參考。

---

## L0 — 使用者身份

**Eli（Liao）** - 資深工程師
- 位置：台灣台中
- 作業系統：macOS
- 技術背景：Laravel、Vue.js、Python、Docker
- 開發風格：KISS 原則、防衛性編程、繁體中文優先

---

## L1 — 核心專案記憶

### 📦 Obsidian CLI 設定與問題解決（2026-04-09）

**目標**：安裝並設定 Obsidian CLI 工具
**最終狀態**：✅ 部分成功（Web API 可用，NPM CLI 套件不存在）

**關鍵決策**：
- NPM 上的 `@obsidian-cli/cli` 套件已下架（404 錯誤）
- 改用 Obsidian Skills 外掛的 Web API 作為替代方案
- Vault 位置：`D:\github\chiisen\JoObsidian`（Windows 環境）

**可用操作**（透過 Web API）：
- 讀取筆記：`obsidian read file="My Note"`
- 創建筆記：`obsidian create name="New Note" content="..."`
- 搜尋：`obsidian search query="BAM" limit=20`
- 日記操作：`obsidian daily:read` / `obsidian daily:append`
- 標籤管理：`obsidian tags sort=count counts`

**學習收穫**：
1. Shell 環境差異：Bash vs PowerShell 命令表現不同
2. 多層方案設計：當直接工具不可用時，尋找替代 API
3. 配置文件探索：從 `obsidian.json` 可快速找到 vault 位置

---

### 🔌 Codex Plugin 安裝紀錄（2026-04-09）

**環境**：macOS + Claude Code
**狀態**：✅ 成功安裝

**安裝步驟**：
1. 加入 Marketplace：`/plugin marketplace add openai/codex-plugin-cc`
2. 安裝插件：`/plugin install codex@openai-codex`
3. 重載插件：`/reload-plugins`

**成功輸出**：
```
✓ Installed codex. Run /reload-plugins to apply.
Reloaded: 2 plugins · 7 skills · 6 agents
```

**已知問題**：
- `/plugin` UI 介面在無插件安裝或 loading 失敗時可能顯示空白
- 正確指令格式：`/codex:review`、`/codex:setup`（非 `/plugin:xxx`）

**檔案結構**：
```
~/.claude/plugins/
├── installed_plugins.json       # 已安裝插件清單
├── known_marketplaces.json      # 已知 Marketplace
└── cache/
    └── openai-codex/codex/1.0.3/  # 安裝後的快取路徑
```

**可用指令**：
- `/codex:review` - 檢視任務
- `/codex:setup` - 環境確認
- `/codex:cancel` - 取消執行中的任務
- `/codex:rescue` - 委派問題給 Codex subagent

---

## L2 — 技術偏好

### 開發規範
- 後端：PHP 8.4 + Laravel 11 + MySQL 8.0
- 前端：Vue 3.4 + Inertia 2.0 + Vite 6.0 + TypeScript 5.6
- 樣式：Tailwind CSS 3.2 + Element Plus 2.9
- 強制 Strict Types，使用 FormRequest
- Git Commit 格式：`<type>(<scope>): <subject>`（繁體中文）

### 觀測性堆疊
- Grafana (3000)
- Prometheus (9090)
- Loki (3100)
- Node Exporter (9100)
- cAdvisor (8080)

### Docker 服務
- MySQL (3306)
- Redis (6379)
- phpMyAdmin (3307)
- Redis Insight (5540)

---

## 專案實體

目前追蹤的專案：
- **Obsidian** - 筆記管理與 CLI 工具
- **Codex** - Claude Code 插件
- **MemPalace** - 記憶持久化系統（目前所在專案）
- **Hermes-Agent** - 自我改進型 AI Agent（目標整合對象）

---

## ⚠️ 重要提醒

1. **MemPalace 尚無 export 指令** - 需透過 `wake-up`、`search` 或 `compress --dry-run` 間接匯出
2. **Drawers 是原始逐字文本** - 轉移前建議人工篩選
3. **知識圖譜尚未建立** - 目前 0 個實體/關係
4. **Obsidian CLI NPM 套件已下架** - 需使用 Web API 替代方案

---

*匯出時間：2026-04-09*
*來源：MemPalace (`~/.mempalace/palace`)*
*Drawers 總數：22*
