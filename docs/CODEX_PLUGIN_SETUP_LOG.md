---
title: Codex Plugin (openai/codex-plugin-cc) 安裝與操作紀錄
date: 2026-04-09
tags:
  - claude-code
  - codex
  - plugin
status: completed
---

# Codex Plugin 安裝與操作紀錄

**日期**: 2026-04-09  
**環境**: macOS Tahoe / Claude Code 2.1.97  
**插件**: `codex@openai-codex`（來源：[openai/codex-plugin-cc](https://github.com/openai/codex-plugin-cc)）

---

## 目標

在 Claude Code 中安裝並啟用 OpenAI Codex Plugin，使其可透過 `/codex:*` 指令呼叫 Codex CLI 進行 code review 與任務委派。

---

## 安裝流程

### 步驟一：加入 Marketplace

```bash
/plugin marketplace add openai/codex-plugin-cc
```

> [!warning] 常見誤解
> 此步驟**只是將 openai/codex-plugin-cc 登記為 Marketplace 來源**，並非安裝插件本身。
> 執行後 `/codex` 指令**不會出現**，這是正常行為。

### 步驟二：從 Marketplace 安裝插件

```bash
/plugin install codex@openai-codex
```

成功輸出：

```
✓ Installed codex. Run /reload-plugins to apply.
```

### 步驟三：重載插件

```bash
/reload-plugins
```

成功輸出：

```
Reloaded: 2 plugins · 7 skills · 6 agents · 3 hooks · 0 plugin MCP servers · 1 plugin LSP server
```

### 步驟四：確認設定

```bash
/codex:setup
```

---

## 遇到的問題與解決方式

### 問題一：安裝後找不到 `/codex` 指令

**症狀**：執行 `/plugin marketplace add openai/codex-plugin-cc` 後，輸入 `/codex` 無反應，也沒有任何補全候選項。

**原因**：`marketplace add` 只是登記來源（相當於加入 App Store），並非安裝。需要額外執行 `/plugin install` 才會真正安裝插件。

**解決**：
```bash
/plugin install codex@openai-codex
/reload-plugins
```

---

### 問題二：`/plugin` 回傳空白內容

**症狀**：執行 `/plugin` 後，畫面完全空白，看不到任何插件清單。

**原因**：`/plugin` UI 介面在無插件安裝或 loading 失敗時可能顯示空白，非錯誤提示。

**排查方式**：直接查看設定檔確認狀態：

```bash
cat ~/.claude/plugins/installed_plugins.json
cat ~/.claude/plugins/known_marketplaces.json
```

確認 `known_marketplaces.json` 中有 `openai-codex` 項目但 `installed_plugins.json` 中無 `codex@openai-codex`，即可確定問題。

---

### 問題三：指令名稱錯誤

**症狀**：以為安裝後會有 `/codex` 這個頂層指令。

**原因**：Claude Code Plugin 的 slash command 一律以**插件名稱作為 namespace**，格式為 `/插件名:指令名`。

**正確指令**：`/codex:review`、`/codex:setup` 等（詳見下方列表）。

---

## 檔案結構說明

Marketplace 與插件快取儲存於：

```
~/.claude/plugins/
├── installed_plugins.json       # 已安裝插件清單
├── known_marketplaces.json      # 已登記的 Marketplace 來源
├── marketplaces/
│   └── openai-codex/            # openai/codex-plugin-cc 的本地快取
│       ├── plugins/
│       │   └── codex/
│       │       ├── .claude-plugin/plugin.json   # 插件 manifest
│       │       ├── commands/    # slash commands (.md)
│       │       ├── skills/      # 技能模組
│       │       ├── hooks/       # hooks 設定
│       │       └── scripts/     # 執行腳本
│       └── package.json
└── cache/
    └── openai-codex/codex/1.0.3/  # 安裝後的快取路徑
```

---

## Marketplace vs Plugin 概念釐清

| 動作 | 指令 | 說明 |
|------|------|------|
| 加入 Marketplace | `/plugin marketplace add openai/codex-plugin-cc` | 登記 GitHub 倉庫為插件來源 |
| 安裝插件 | `/plugin install codex@openai-codex` | 從 Marketplace 安裝特定插件 |
| 重載生效 | `/reload-plugins` | 讓當前 session 載入新插件 |
| 確認狀態 | `/codex:setup` | 檢查 Codex CLI 是否就緒 |

---

## 可用指令一覽

| 指令 | 功能說明 |
|------|----------|
| `/codex:setup` | 檢查 Codex CLI 環境與認證狀態，可選擇安裝或啟用 review gate |
| `/codex:review` | 請 Codex 對目前程式碼進行 code review |
| `/codex:adversarial-review` | 對抗性審查，以批判視角深度分析程式碼 |
| `/codex:status` | 查看目前執行中的 Codex 任務狀態 |
| `/codex:result` | 取得已完成任務的輸出結果 |
| `/codex:cancel` | 取消執行中的任務 |
| `/codex:rescue` | 將問題或修復工作委派給 Codex subagent 處理 |

---

## 環境確認結果（`/codex:setup` 輸出）

```json
{
  "ready": true,
  "node": { "available": true, "detail": "v25.8.2" },
  "npm":  { "available": true, "detail": "11.11.1" },
  "codex": {
    "available": true,
    "detail": "codex-cli 0.118.0; advanced runtime available"
  },
  "auth": {
    "available": true,
    "loggedIn": true,
    "detail": "ChatGPT login active for liawchiisen@gmail.com",
    "source": "app-server",
    "authMethod": "chatgpt",
    "verified": true
  },
  "sessionRuntime": {
    "mode": "direct",
    "label": "direct startup",
    "detail": "No shared Codex runtime is active yet. The first review or task command will start one on demand."
  },
  "reviewGateEnabled": false
}
```

---

## 備註

- Codex CLI 版本：`0.118.0`
- 認證方式：ChatGPT Login（非 OpenAI API Key）
- `reviewGateEnabled: false`：可透過 `/codex:setup --enable-review-gate` 開啟，要求每次停止前做一次 review
- Session runtime 採 `direct` 模式：第一次執行 review 或任務時才啟動 runtime，非常駐
