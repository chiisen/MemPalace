param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet("read", "create", "search", "daily-read", "daily-append", "tags")]
    [string]$Command,

    [Parameter(Position = 1)]
    [string]$Target = "",

    [string]$Content = "",
    [string]$VaultPath = $env:OBSIDIAN_VAULT_PATH
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-VaultPath {
    if (-not [string]::IsNullOrWhiteSpace($VaultPath)) {
        return $VaultPath
    }

    $defaultVault = "D:\github\chiisen\JoObsidian"
    if (Test-Path -LiteralPath $defaultVault) {
        return $defaultVault
    }

    throw "缺少 Vault 路徑。請設定 `$env:OBSIDIAN_VAULT_PATH。"
}

function Get-NotePath {
    param([Parameter(Mandatory = $true)][string]$RelativePath)
    $vault = Resolve-VaultPath
    $safeRelative = $RelativePath -replace '/', '\'
    return Join-Path -Path $vault -ChildPath $safeRelative
}

function Ensure-ParentDirectory {
    param([Parameter(Mandatory = $true)][string]$FilePath)
    $parent = Split-Path -Path $FilePath -Parent
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -Path $parent -ItemType Directory -Force | Out-Null
    }
}

function Get-TodayNotePath {
    $today = Get-Date -Format "yyyy-MM-dd"
    return Get-NotePath -RelativePath ("Daily/{0}.md" -f $today)
}

try {
    switch ($Command) {
        "read" {
            if ([string]::IsNullOrWhiteSpace($Target)) { throw "read 需要檔案路徑，例如：.\scripts\obsidian-cli.ps1 read 'Daily/2026-04-09.md'" }
            $notePath = Get-NotePath -RelativePath $Target
            if (-not (Test-Path -LiteralPath $notePath)) { throw "找不到筆記：$Target" }
            Get-Content -LiteralPath $notePath -Raw
        }
        "create" {
            if ([string]::IsNullOrWhiteSpace($Target)) { throw "create 需要檔案路徑。" }
            $notePath = Get-NotePath -RelativePath $Target
            Ensure-ParentDirectory -FilePath $notePath
            Set-Content -LiteralPath $notePath -Value $Content -Encoding UTF8
            Write-Output "已建立/覆寫：$Target"
        }
        "search" {
            if ([string]::IsNullOrWhiteSpace($Target)) { throw "search 需要查詢字串。" }
            $vault = Resolve-VaultPath
            if (Get-Command rg -ErrorAction SilentlyContinue) {
                rg --line-number --with-filename --glob "*.md" --fixed-strings --ignore-case -- "$Target" "$vault"
            }
            else {
                Get-ChildItem -LiteralPath $vault -Recurse -Filter "*.md" |
                    Select-String -SimpleMatch -Pattern $Target |
                    ForEach-Object { "{0}:{1}:{2}" -f $_.Path, $_.LineNumber, $_.Line.Trim() }
            }
        }
        "daily-read" {
            $dailyPath = Get-TodayNotePath
            if (-not (Test-Path -LiteralPath $dailyPath)) { throw "今日日誌不存在：$dailyPath" }
            Get-Content -LiteralPath $dailyPath -Raw
        }
        "daily-append" {
            if ([string]::IsNullOrWhiteSpace($Content)) { throw "daily-append 需要 -Content 內容。" }
            $dailyPath = Get-TodayNotePath
            Ensure-ParentDirectory -FilePath $dailyPath
            Add-Content -LiteralPath $dailyPath -Value $Content -Encoding UTF8
            Write-Output "已追加到今日日誌。"
        }
        "tags" {
            $vault = Resolve-VaultPath
            $pattern = '(?<!\w)#([\p{L}\p{N}_/-]+)'
            $tags = Get-ChildItem -LiteralPath $vault -Recurse -Filter "*.md" |
                ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw } |
                ForEach-Object { [regex]::Matches($_, $pattern) } |
                ForEach-Object { $_ } |
                ForEach-Object { $_.Groups[1].Value.ToLowerInvariant() }
            $tags |
                Group-Object |
                Sort-Object Count -Descending |
                ForEach-Object { "{0}`t{1}" -f $_.Count, $_.Name }
        }
    }
}
catch {
    Write-Error "Obsidian CLI 執行失敗：$($_.Exception.Message)"
    exit 1
}
