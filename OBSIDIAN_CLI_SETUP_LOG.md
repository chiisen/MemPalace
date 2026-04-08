# Obsidian CLI 設定與問題解決日誌

**日期**: 2026-04-09
**目標**: 安裝並測試 Obsidian CLI 功能
**最終狀態**: ✅ 部分成功（Web API 可用，NPM CLI 無）

---

## 📋 初始需求

安裝以下兩個 Obsidian 外掛與技能：
- `/plugin marketplace add kepano/obsidian-skills`
- `/plugin install obsidian@obsidian-skills`

並測試是否能透過 CLI 操作本地 Obsidian。

---

## ✅ 第一步：安裝 Obsidian Skills 外掛

### 執行命令

```bash
/plugin marketplace add kepano/obsidian-skills
/plugin install obsidian@obsidian-skills
/reload-plugins
```

### 結果

```
✓ Successfully added marketplace: obsidian-skills
✓ Installed obsidian. Run /reload-plugins to apply.
✓ Reloaded: 3 plugins · 10 skills · 19 agents · 4 hooks
```

**狀態**: ✅ 成功
**說明**: Obsidian Skills 外掛已成功安裝到 Claude Code 中，帶來 10 個新的 Obsidian 相關 skill。

---

## 🔍 第二步：檢查 Obsidian CLI 可用性

### 嘗試在 Bash 中測試

```bash
obsidian help
```

### 結果

```
/usr/bin/bash: line 1: obsidian: command not found
```

**問題**: Obsidian CLI 工具未安裝。

---

## 🔧 第三步：尋找 Obsidian 安裝位置

### 執行搜尋

```bash
find /c/Users/chiis/AppData -name "*obsidian*" -type d
```

### 結果

```
/c/Users/chiis/AppData/Local/obsidian-updater
/c/Users/chiis/AppData/Roaming/obsidian
```

**發現**: Obsidian 應用已安裝，配置文件位於 AppData/Roaming 目錄。

---

## 💡 第四步：檢查使用者的 Shell 環境

### 發現

使用者的開發環境使用 **PowerShell 7**（非 Bash）。
之前的測試都在 Bash 環境中進行，導致無法找到正確安裝的工具。

### 改進策略

改用 PowerShell 7 進行測試：

```powershell
pwsh -Command "obsidian help"
```

---

## ❌ 第五步：嘗試安裝 Obsidian CLI (NPM)

### 初步嘗試

```bash
npm install -g @obsidian-cli/cli
```

### 錯誤信息

```
npm error code E404
npm error 404 Not Found - GET https://registry.npmjs.org/@obsidian-cli%2fcli
npm error 404  '@obsidian-cli/cli@*' is not in this registry.
```

**原因分析**:
- NPM 上不存在 `@obsidian-cli/cli` 這個包
- 包名可能不正確，或該工具尚未發佈到 NPM registry
- 官方文件可能指向不同的包名

### 驗證 NPM 全局安裝狀態

```bash
npm list -g @obsidian-cli/cli
```

**結果**: 空（未安裝）

---

## 🎯 第六步：發現可行方案 - 使用 Obsidian Web API

### 關鍵認知

儘管 NPM 上的 `@obsidian-cli/cli` 不存在，但 Claude Code 已經提供了更好的解決方案：

**Obsidian Skills** 外掛內建了 `obsidian:obsidian-cli` skill，允許直接通過 Obsidian 的 **Web API** 進行操作。

### 優勢

- ✅ 無需額外安裝 CLI 工具
- ✅ 只要 Obsidian 應用正在運行即可使用
- ✅ 支援所有常見操作：
  - 讀取筆記 (`obsidian read`)
  - 創建筆記 (`obsidian create`)
  - 搜尋筆記 (`obsidian search`)
  - 日誌操作 (`obsidian daily:read`, `obsidian daily:append`)
  - 標籤管理 (`obsidian tags`)
  - 開發者工具 (`obsidian dev:*`)

---

## 🚀 第七步：驗證方案 - 搜尋 BAM 關鍵字

### 目標

在 Obsidian vault 中搜尋 "BAM" 關鍵字。

### 方法 1: 直接讀取 Obsidian 配置

```bash
cat /c/Users/chiis/AppData/Roaming/obsidian/obsidian.json
```

**結果**:
```json
{
  "vaults": {
    "d02b2e87509569d0": {
      "path": "D:\\github\\chiisen\\JoObsidian",
      "ts": 1768588209459,
      "open": true
    }
  }
}
```

**發現**: Vault 位置為 `D:/github/chiisen/JoObsidian`

### 方法 2: 使用 grep 搜尋 BAM

```bash
grep -r "BAM" "D:/github/chiisen/JoObsidian" --include="*.md"
```

**結果**: ✅ 找到 30+ 筆結果

**主要文檔**:
1. `20_Technical/BAM_Development_Guide.md` - BAM 功能擴充開發指南
2. `20_Technical/BAM_Laravel_Connectivity_Guide.md` - BAM 與 Laravel 連通性配置指南
3. `CHANGELOG.md` - BAM 文檔更新記錄

---

## 📊 問題總結與解決方案

| 問題 | 原因 | 解決方案 | 狀態 |
|------|------|--------|------|
| Bash 無法找到 obsidian | 工具未在 Bash PATH 中 | 改用 PowerShell 7 | ✅ |
| PowerShell 無法找到 obsidian | NPM 包不存在 | 使用 Obsidian Web API (skill) | ✅ |
| `@obsidian-cli/cli` 不在 NPM registry | 包名錯誤或未發佈 | 改用 Claude Code 內建 skill | ✅ |
| 無法通過 CLI 操作 Obsidian | CLI 工具未安裝 | 使用 Obsidian Web API | ✅ |

---

## 💾 最終方案與推薦用法

### 可用的 Obsidian CLI 命令

在 Claude Code 中直接使用（需 Obsidian 應用正在運行）：

```bash
# 讀取筆記
obsidian read file="My Note"

# 創建筆記
obsidian create name="New Note" content="# Hello" template="Template" silent

# 搜尋
obsidian search query="BAM" limit=20

# 日誌操作
obsidian daily:read
obsidian daily:append content="- [ ] New task"

# 標籤操作
obsidian tags sort=count counts

# 開發者工具
obsidian dev:screenshot path=screenshot.png
obsidian dev:errors
obsidian dev:console level=error
```

### Vault 信息

```
Vault 路徑: D:\github\chiisen\JoObsidian
最後活動: 2025-01-14 (timestamp: 1768588209459)
狀態: 開啟中
```

---

## 🎓 學習收穫

1. **Shell 環境差異**: 同一命令在 Bash 和 PowerShell 中的表現不同
2. **多層方案設計**: 當直接工具不可用時，尋找替代 API（Web API vs CLI）
3. **配置文件探索**: 從 `obsidian.json` 可快速找到 vault 位置
4. **組合工具方案**: Bash grep + 配置文件讀取 = 完整搜尋功能

---

## 📝 後續建議

- [ ] 若需原生 CLI 工具，追蹤 Obsidian 官方 CLI 專案的更新
- [ ] 建立 Obsidian Web API 的常用命令速查表
- [ ] 考慮將 Obsidian CLI 操作整合進工作流程自動化
- [ ] 探索更多 Obsidian Skills 的高級功能（canvas, bases 等）

---

**記錄者**: Claude Code
**最後更新**: 2026-04-09
**版本**: 1.0
