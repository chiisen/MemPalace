#!/bin/bash
# MemPalace → Hermes Agent 知識圖譜同步 Shell 腳本
# 用途：設定 cron 排程或手動執行
#
# 使用方式：
#   ./sync_to_hermes.sh           # 執行同步
#   ./sync_to_hermes.sh --dry-run # 預覽變更
#   ./sync_to_hermes.sh --setup-cron  # 設定每日凌晨 2 點自動同步

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_SCRIPT="${SCRIPT_DIR}/sync_kg_to_hermes.py"
LOG_FILE="${HOME}/.mempalace/logs/sync_hermes.log"

# 顏色輸出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} - $1"
}

# 確保日誌目錄存在
mkdir -p "$(dirname "${LOG_FILE}")"

log "${GREEN}🔄 開始同步 MemPalace → Hermes Agent${NC}"
log "========================================="

# 執行 Python 同步腳本
if python3 "${SYNC_SCRIPT}" "$@" 2>&1 | tee -a "${LOG_FILE}"; then
    log "${GREEN}✅ 同步完成${NC}"
else
    log "${RED}❌ 同步失敗，請查看日誌: ${LOG_FILE}${NC}"
    exit 1
fi

log "========================================="
