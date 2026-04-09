#!/usr/bin/env zsh
# Obsidian CLI - macOS 純檔案模式（無需 API Key）
# 用法: ./scripts/obsidian-cli.sh <command> [target] [options]
#
# Commands:
#   install  [vault-path]     安裝 CLI 到 ~/.local/bin/obsidian-note，並設定 shell 環境
#   search   <query>          搜尋 vault 中的筆記
#   read     <path>           讀取指定筆記（相對於 vault 根目錄）
#   create   <path> <content> 建立/覆寫筆記
#   daily-read               讀取今日日誌
#   daily-append <content>   追加內容到今日日誌
#   tags                     統計所有標籤

set -euo pipefail

# ── Vault 路徑解析 ────────────────────────────────────────────────────────────
DEFAULT_VAULT="/Users/liao-eli/github/JoObsidian"

resolve_vault() {
    local vault="${OBSIDIAN_VAULT_PATH:-}"
    if [[ -n "$vault" ]]; then
        echo "$vault"
        return
    fi
    if [[ -d "$DEFAULT_VAULT" ]]; then
        echo "$DEFAULT_VAULT"
        return
    fi
    # 嘗試從 Obsidian 設定檔讀取
    local config="$HOME/Library/Application Support/obsidian/obsidian.json"
    if [[ -f "$config" ]]; then
        local path
        path=$(python3 -c "
import json, sys
data = json.load(open('$config'))
vaults = data.get('vaults', {})
if vaults:
    print(list(vaults.values())[0].get('path',''))
" 2>/dev/null)
        if [[ -n "$path" && -d "$path" ]]; then
            echo "$path"
            return
        fi
    fi
    echo "錯誤: 找不到 Vault 路徑。請設定 OBSIDIAN_VAULT_PATH 環境變數。" >&2
    exit 1
}

resolve_shell_rc() {
    case "${SHELL:-}" in
        */zsh) echo "$HOME/.zshrc" ;;
        */bash) echo "$HOME/.bashrc" ;;
        *) echo "$HOME/.zshrc" ;;
    esac
}

get_note_path() {
    local vault
    vault=$(resolve_vault)
    echo "$vault/$1"
}

ensure_parent_dir() {
    local dir
    dir=$(dirname "$1")
    mkdir -p "$dir"
}

get_today_path() {
    local today
    today=$(date +%Y-%m-%d)
    get_note_path "Daily/$today.md"
}

# ── 命令處理 ──────────────────────────────────────────────────────────────────
command="${1:-}"
if [[ -z "$command" ]]; then
    echo "用法: $0 <install|read|create|search|daily-read|daily-append|tags> [args...]" >&2
    exit 1
fi
shift

case "$command" in
    install)
        if command -v realpath &>/dev/null; then
            script_path="$(realpath "$0")"
        else
            script_path="$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$0")"
        fi
        bin_dir="$HOME/.local/bin"
        link_path="$bin_dir/obsidian-note"
        rc_file="$(resolve_shell_rc)"
        path_line='export PATH="$HOME/.local/bin:$PATH"'

        mkdir -p "$bin_dir"
        chmod +x "$script_path"
        ln -sf "$script_path" "$link_path"

        if [[ -f "$rc_file" ]]; then
            if ! grep -Fq "$path_line" "$rc_file"; then
                printf '\n# Obsidian CLI local bin\n%s\n' "$path_line" >> "$rc_file"
            fi
        else
            printf '# Obsidian CLI local bin\n%s\n' "$path_line" > "$rc_file"
        fi

        vault_input="${1:-}"
        vault_path=""
        if [[ -n "$vault_input" ]]; then
            vault_path="$vault_input"
        else
            vault_path="$(resolve_vault 2>/dev/null || true)"
        fi

        if [[ -n "$vault_path" ]]; then
            vault_line="export OBSIDIAN_VAULT_PATH=\"$vault_path\""
            if [[ -f "$rc_file" ]]; then
                if ! grep -Fq 'export OBSIDIAN_VAULT_PATH=' "$rc_file"; then
                    printf '\n# Obsidian Vault path\n%s\n' "$vault_line" >> "$rc_file"
                fi
            fi
            echo "已安裝：$link_path"
            echo "已設定 OBSIDIAN_VAULT_PATH：$vault_path"
        else
            echo "已安裝：$link_path"
            echo "尚未設定 OBSIDIAN_VAULT_PATH。可執行：obsidian-note install '/path/to/vault'"
        fi

        echo "請執行：source $rc_file"
        ;;

    read)
        target="${1:-}"
        if [[ -z "$target" ]]; then
            echo "錯誤: read 需要檔案路徑，例如：$0 read 'Daily/2026-04-09.md'" >&2
            exit 1
        fi
        note_path=$(get_note_path "$target")
        if [[ ! -f "$note_path" ]]; then
            echo "錯誤: 找不到筆記：$target" >&2
            exit 1
        fi
        cat "$note_path"
        ;;

    create)
        target="${1:-}"
        content="${2:-}"
        if [[ -z "$target" ]]; then
            echo "錯誤: create 需要檔案路徑。" >&2
            exit 1
        fi
        note_path=$(get_note_path "$target")
        ensure_parent_dir "$note_path"
        printf '%s' "$content" > "$note_path"
        echo "已建立/覆寫：$target"
        ;;

    search)
        query="${1:-}"
        if [[ -z "$query" ]]; then
            echo "錯誤: search 需要查詢字串。" >&2
            exit 1
        fi
        vault=$(resolve_vault)
        if command -v rg &>/dev/null; then
            rg --line-number --with-filename --glob "*.md" \
               --fixed-strings --ignore-case -- "$query" "$vault"
        else
            grep -rn --include="*.md" -i -F "$query" "$vault"
        fi
        ;;

    daily-read)
        daily_path=$(get_today_path)
        if [[ ! -f "$daily_path" ]]; then
            echo "錯誤: 今日日誌不存在：$daily_path" >&2
            exit 1
        fi
        cat "$daily_path"
        ;;

    daily-append)
        content="${1:-}"
        if [[ -z "$content" ]]; then
            echo "錯誤: daily-append 需要內容參數。" >&2
            exit 1
        fi
        daily_path=$(get_today_path)
        ensure_parent_dir "$daily_path"
        printf '\n%s' "$content" >> "$daily_path"
        echo "已追加到今日日誌。"
        ;;

    tags)
        vault=$(resolve_vault)
        grep -roh --include="*.md" -E '#[[:alpha:]][[:alnum:]_/-]*' "$vault" \
            | sed 's/.*://' \
            | tr '[:upper:]' '[:lower:]' \
            | sort \
            | uniq -c \
            | sort -rn \
            | awk '{printf "%s\t%s\n", $1, $2}'
        ;;

    *)
        echo "錯誤: 不支援的命令 '$command'。支援: install, read, create, search, daily-read, daily-append, tags" >&2
        exit 1
        ;;
esac
