# Obsidian CLI 設定與測試操作紀錄

**日期**: 2026-04-09  
**專案**: `D:\github\chiisen\MemPalace`  
**目標**: 在 Windows PowerShell 環境可穩定使用 Obsidian CLI（不使用 API Key）

---

## 1. 背景與需求

使用者要求：
- 參考既有設定文件安裝 Obsidian CLI 功能
- 不使用 `OBSIDIAN_API_KEY`
- 可直接測試查詢 `BAM`

---

## 2. 實際操作步驟

### Step A: 讀取既有參考文件

讀取：
- `OBSIDIAN_CLI_SETUP_LOG.md`

確認到先前結論：
- `@obsidian-cli/cli` 不可用
- 建議改走可替代方案

### Step B: 驗證 NPM 套件現況

執行：

```powershell
npm view obsidian-cli version
```

結果：
- 查到版本 `0.5.1`

接著安裝：

```powershell
npm install -g obsidian-cli
```

安裝成功，但驗證後發現這個 `obsidian-cli` 是 **ObsidianQA** 相關工具，不是 Obsidian 筆記 App 的 CLI。

驗證命令：

```powershell
& 'C:\Users\chiis\AppData\Roaming\npm\obsidian.cmd' --help
```

關鍵輸出特徵：
- 出現 `testruns`
- 出現 `Imports given test results into Obsidianqa.com`

結論：
- 套件名稱雖為 `obsidian-cli`，但用途不符合本需求。

### Step C: 實作專案內可控 CLI 腳本

新增檔案：
- `scripts/obsidian-cli.ps1`

初版曾使用 API 模式，後續依使用者要求改為「純檔案模式（無 API Key）」。

目前支援命令：
- `read`
- `create`
- `search`
- `daily-read`
- `daily-append`
- `tags`

### Step D: 設定預設 Vault 路徑

依使用者要求新增使用者層級環境變數：

```powershell
[Environment]::SetEnvironmentVariable('OBSIDIAN_VAULT_PATH','D:\github\chiisen\JoObsidian','User')
```

已確認寫入成功：
- `OBSIDIAN_VAULT_PATH = D:\github\chiisen\JoObsidian`

### Step E: 功能測試（BAM 查詢）

執行：

```powershell
pwsh -NoProfile -File '.\scripts\obsidian-cli.ps1' search 'BAM'
```

結果：
- 成功回傳多筆命中
- 命中文件包含：
  - `20_Technical/BAM_Development_Guide.md`
  - `20_Technical/BAM_Laravel_Connectivity_Guide.md`
  - `CHANGELOG.md`
  - `20_Technical/MOC_Technical.md`

---

## 3. 問題與解決

### 問題 1：`obsidian` 指令找不到

現象：
- `obsidian --help` 顯示未識別指令

原因：
- 全域安裝路徑在 `C:\Users\chiis\AppData\Roaming\npm`，目前 shell session PATH 未即時生效

解法：
- 直接以完整路徑呼叫 `.cmd` 驗證
- 長期改用專案內 `scripts/obsidian-cli.ps1`（避免 PATH 依賴）

### 問題 2：NPM 的 `obsidian-cli` 不是想要的 Obsidian 筆記 CLI

現象：
- `--help` 顯示 ObsidianQA test run import 功能

原因：
- 同名套件用途不同

解法：
- 不依賴該套件作為筆記 CLI
- 改用專案內 PowerShell 腳本直接操作 Vault 檔案

### 問題 3：使用者不接受 API Key

現象：
- 使用者明確要求「不要 API Key」

解法：
- 將腳本從 REST API 模式改為本地檔案模式
- 以 `OBSIDIAN_VAULT_PATH` 指定 vault 根路徑

---

## 4. 最終可用命令

```powershell
# 查詢
.\scripts\obsidian-cli.ps1 search "BAM"

# 讀取
.\scripts\obsidian-cli.ps1 read "Daily/2026-04-09.md"

# 建立/覆寫
.\scripts\obsidian-cli.ps1 create "Inbox/Test.md" -Content "# Hello"

# 今日日誌讀取
.\scripts\obsidian-cli.ps1 daily-read

# 今日日誌追加
.\scripts\obsidian-cli.ps1 daily-append -Content "- [ ] 測試項目"

# 標籤統計
.\scripts\obsidian-cli.ps1 tags
```

---

## 5. 相關變更檔案

- `scripts/obsidian-cli.ps1`（新增並改為純檔案模式）
- `README.md`（新增 Obsidian CLI 使用說明並改為無 API Key 版）
- `.agent_task_state.md`（任務狀態摘要）

---

## 6. 當前狀態

- Obsidian CLI 功能：**可用**
- API Key：**不需要**
- 預設 Vault：`D:\github\chiisen\JoObsidian`
- `BAM` 搜尋測試：**通過**

