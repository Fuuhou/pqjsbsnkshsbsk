#!/bin/bash
set -euo pipefail  # Enable strict mode for better error handling

# ==============================================
# CONFIGURATION SECTION
# ==============================================
readonly REPO_BASE_URL="https://raw.githubusercontent.com/wibuxie/autoscript/main/"
readonly INSTALL_DIR="/usr/bin"
readonly LOG_PREFIX="[INFO]"

# Date retrieval with proper error handling
get_current_date() {
    local date_from_server
    if ! date_from_server=$(curl -s --fail --insecure https://google.com/ 2>&1 | grep -i '^Date:' | sed -e 's/^Date: //'); then
        date_from_server=$(date -u +"%a, %d %b %Y %H:%M:%S %Z")
        echo "$LOG_PREFIX Falling back to system date" >&2
    fi
    date +"%Y-%m-%d" -d "$date_from_server"
}

# ==============================================
# FILE DOWNLOAD LIST
# ==============================================
declare -A FILES_TO_DOWNLOAD=(
    # Menu scripts
    ["menu"]="menu/menu.sh"
    ["m-trgo"]="menu/m-trgo.sh"
    ["restore"]="menu/restore.sh"
    ["backup"]="menu/backup.sh"
    ["m-noobz"]="menu/m-noobz.sh"
    ["m-ip"]="menu/m-ip.sh"
    ["m-bot"]="menu/m-bot.sh"
    ["m-theme"]="menu/m-theme.sh"
    ["m-vmess"]="menu/m-vmess.sh"
    ["m-vless"]="menu/m-vless.sh"
    ["m-trojan"]="menu/m-trojan.sh"
    ["m-system"]="menu/m-system.sh"
    ["m-sshovpn"]="menu/m-sshovpn.sh"
    ["running"]="menu/running.sh"
    ["m-backup"]="menu/m-backup.sh"
    ["bckpbot"]="menu/bckpbot.sh"
    ["tendang"]="menu/tendang.sh"
    ["bottelegram"]="menu/bottelegram.sh"
    ["xraylimit"]="menu/xraylimit.sh"
    
    # Trial scripts
    ["trialvmess"]="menu/trialvmess.sh"
    ["trialvless"]="menu/trialvless.sh"
    ["trialtrojan"]="menu/trialtrojan.sh"
    ["trialssh"]="menu/trialssh.sh"
    
    # Install scripts
    ["speedtest"]="install/speedtest_cli.py"
    ["autocpu"]="install/autocpu.sh"
    ["bantwidth"]="install/bantwidth"
    
    # Bot scripts
    ["addnoobz"]="bot/addnoobz.sh"
    ["cek-noobz"]="bot/cek-noobz.sh"
)

# ==============================================
# FUNCTIONS SECTION
# ==============================================
download_and_install() {
    local filename=$1
    local remote_path=$2
    
    echo "$LOG_PREFIX Downloading $filename..."
    if ! wget -q -O "$INSTALL_DIR/$filename" "${REPO_BASE_URL}${remote_path}"; then
        echo "$LOG_PREFIX Failed to download $filename" >&2
        return 1
    fi
    
    if ! chmod +x "$INSTALL_DIR/$filename"; then
        echo "$LOG_PREFIX Failed to make $filename executable" >&2
        return 1
    fi
}

# ==============================================
# MAIN EXECUTION
# ==============================================
main() {
    echo "$LOG_PREFIX Installation started at $(get_current_date)"
    
    # Download all files
    local success_count=0
    local total_files=${#FILES_TO_DOWNLOAD[@]}
    
    for filename in "${!FILES_TO_DOWNLOAD[@]}"; do
        if download_and_install "$filename" "${FILES_TO_DOWNLOAD[$filename]}"; then
            ((success_count++))
        fi
    done
    
    # Report results
    echo "$LOG_PREFIX Downloaded $success_count of $total_files files successfully"
    
    if (( success_count < total_files )); then
        echo "$LOG_PREFIX Warning: Some files failed to download" >&2
        exit 1
    fi
    
    exit 0
}

main "$@"