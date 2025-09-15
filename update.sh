#!/bin/bash
set -euo pipefail  # Enable strict mode for better error handling

# ==============================================
# CONFIGURATION SECTION
# ==============================================
readonly REPO_BASE_URL="https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/"
readonly INSTALL_DIR="/usr/bin"
readonly LOG_PREFIX="[INFO]"
readonly ERROR_PREFIX="[ERROR]"

# Function to get current date with proper error handling
get_current_date() {
    local date_from_server
    # Try to get date from Google server with timeout
    if date_from_server=$(curl -s --fail --max-time 5 --insecure https://google.com/ 2>&1 | grep -i '^Date:' | sed -e 's/^Date: //' 2>/dev/null); then
        if date +"%Y-%m-%d" -d "$date_from_server" >/dev/null 2>&1; then
            date +"%Y-%m-%d" -d "$date_from_server"
            return 0
        fi
    fi
    
    # Fallback to system date
    echo "$LOG_PREFIX Falling back to system date" >&2
    date +"%Y-%m-%d"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "$ERROR_PREFIX This script must be run as root" >&2
        exit 1
    fi
}

# Function to validate installation directory
validate_install_dir() {
    if [[ ! -d "$INSTALL_DIR" ]]; then
        echo "$ERROR_PREFIX Installation directory $INSTALL_DIR does not exist" >&2
        exit 1
    fi
    
    if [[ ! -w "$INSTALL_DIR" ]]; then
        echo "$ERROR_PREFIX No write permission for installation directory $INSTALL_DIR" >&2
        exit 1
    fi
}

# Function to check required commands
check_requirements() {
    local requirements=("wget" "curl" "chmod")
    local missing=()
    
    for cmd in "${requirements[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "$ERROR_PREFIX Missing required commands: ${missing[*]}" >&2
        exit 1
    fi
}

# ==============================================
# FILE DOWNLOAD LIST
# ==============================================
declare -A FILES_TO_DOWNLOAD=(
    # Menu scripts
    ["menu"]="menu/menu.sh"
    ["restore"]="menu/restore.sh"
    ["backup"]="menu/backup.sh"
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
    ["m-bbr"]="menu/m-bbr.sh"
    ["m-update"]="menu/m-update.sh"
    
    # Trial scripts
    ["trialvmess"]="menu/trialvmess.sh"
    ["trialvless"]="menu/trialvless.sh"
    ["trialtrojan"]="menu/trialtrojan.sh"
    ["trialssh"]="menu/trialssh.sh"
    
    # Install scripts
    ["speedtest"]="install/speedtest_cli.py"
)

# ==============================================
# FUNCTIONS SECTION
# ==============================================
download_and_install() {
    local filename=$1
    local remote_path=$2
    local temp_file
    
    # Create a temporary file for download
    temp_file=$(mktemp)
    
    echo "$LOG_PREFIX Downloading $filename..."
    
    # Download with timeout and retry logic
    if ! wget -q --timeout=15 --tries=2 -O "$temp_file" "${REPO_BASE_URL}${remote_path}"; then
        echo "$ERROR_PREFIX Failed to download $filename" >&2
        rm -f "$temp_file"
        return 1
    fi
    
    # Check if downloaded file is not empty and appears to be a script/text file
    if [[ ! -s "$temp_file" ]] || ! file "$temp_file" | grep -q "text"; then
        echo "$ERROR_PREFIX Downloaded file $filename appears to be invalid" >&2
        rm -f "$temp_file"
        return 1
    fi
    
    # Move to destination
    if ! mv "$temp_file" "$INSTALL_DIR/$filename"; then
        echo "$ERROR_PREFIX Failed to install $filename" >&2
        rm -f "$temp_file"
        return 1
    fi
    
    # Set executable permission
    if ! chmod +x "$INSTALL_DIR/$filename"; then
        echo "$ERROR_PREFIX Failed to make $filename executable" >&2
        # Continue even if chmod fails, as the file was successfully installed
    fi
    
    return 0
}

# ==============================================
# MAIN EXECUTION
# ==============================================
main() {
    echo "$LOG_PREFIX Starting installation at $(get_current_date)"
    
    # Pre-flight checks
    check_root
    validate_install_dir
    check_requirements
    
    # Download all files
    local success_count=0
    local total_files=${#FILES_TO_DOWNLOAD[@]}
    local failed_files=()
    
    for filename in "${!FILES_TO_DOWNLOAD[@]}"; do
        if download_and_install "$filename" "${FILES_TO_DOWNLOAD[$filename]}"; then
            ((success_count++))
        else
            failed_files+=("$filename")
        fi
    done
    
    # Report results
    echo "$LOG_PREFIX Downloaded $success_count of $total_files files successfully"
    
    if [[ ${#failed_files[@]} -gt 0 ]]; then
        echo "$ERROR_PREFIX Failed to download the following files:" >&2
        printf '%s\n' "${failed_files[@]}" >&2
        exit 1
    fi
    
    echo "$LOG_PREFIX Installation completed successfully"
    exit 0
}

# Handle script interruption
cleanup() {
    echo "$LOG_PREFIX Installation interrupted"
    exit 1
}

trap cleanup INT TERM

main "$@"
