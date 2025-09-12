#!/bin/bash
set -euo pipefail  # Enable strict mode for better error handling

# ==============================================
# CONFIGURATION SECTION
# ==============================================
readonly REPO_BASE_URL="https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/"
readonly VNSTAT_VERSION="2.6"
readonly VNSTAT_ARCHIVE="vnstat-${VNSTAT_VERSION}.tar.gz"

# Color definitions using tput for better portability
readonly RED=$(tput setaf 1)
readonly GREEN=$(tput setaf 2)
readonly YELLOW=$(tput setaf 3)
readonly NC=$(tput sgr0)  # No Color

# Network interface detection
readonly NETWORK_INTERFACE=$(ip route get 1 | awk '{print $5;exit}')

# ==============================================
# FUNCTION DEFINITIONS
# ==============================================

# Print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Execute a command with error handling
safe_exec() {
    local command=$1
    local description=${2:-$1}
    
    print_message "${YELLOW}" "Executing: ${description}"
    if ! eval "$command"; then
        print_message "${RED}" "Failed: ${description}"
        return 1
    fi
}

# Install packages with proper error handling
install_packages() {
    local packages=("$@")
    print_message "${YELLOW}" "Updating package lists..."
    safe_exec "apt-get update -y" "Package list update"
    
    print_message "${YELLOW}" "Installing packages: ${packages[*]}"
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${packages[@]}"
}

# Remove packages with proper error handling
remove_packages() {
    local packages=("$@")
    print_message "${YELLOW}" "Removing packages: ${packages[*]}"
    apt-get remove --purge -y "${packages[@]}"
}

# Clean up system packages
system_cleanup() {
    print_message "${YELLOW}" "Performing system cleanup..."
    safe_exec "apt-get autoremove -y" "Remove unused packages"
    safe_exec "apt-get autoclean -y" "Clean package cache"
    safe_exec "apt-get clean -y" "Clean downloaded packages"
}

# Install and configure vnstat
install_vnstat() {
    print_message "${YELLOW}" "Installing and configuring vnstat..."
    
    # Install from package manager first
    install_packages vnstat libsqlite3-dev
    
    # Download and compile latest version
    safe_exec "wget -q \"${REPO_BASE_URL}${VNSTAT_ARCHIVE}\"" "Download vnstat"
    safe_exec "tar zxvf \"${VNSTAT_ARCHIVE}\"" "Extract vnstat"
    
    (
        cd "vnstat-${VNSTAT_VERSION}" || exit 1
        safe_exec "./configure --prefix=/usr --sysconfdir=/etc" "Configure vnstat"
        safe_exec "make" "Build vnstat"
        safe_exec "make install" "Install vnstat"
    )
    
    # Configure vnstat
    sed -i "s/Interface \"eth0\"/Interface \"${NETWORK_INTERFACE}\"/g" /etc/vnstat.conf
    chown vnstat:vnstat /var/lib/vnstat -R
    systemctl enable vnstat
    systemctl restart vnstat
    
    # Cleanup
    rm -f "${VNSTAT_ARCHIVE}"
    rm -rf "vnstat-${VNSTAT_VERSION}"
}

# ==============================================
# MAIN EXECUTION
# ==============================================
main() {
    clear
    print_message "${GREEN}" "====[ SYSTEM SETUP TOOL ]===="
    print_message "${GREEN}" "====[ INITIALIZING ]===="
    
    # System upgrade
    print_message "${YELLOW}" "Starting system upgrade..."
    safe_exec "apt-get update -y" "Package list update"
    safe_exec "apt-get upgrade -y" "System upgrade"
    safe_exec "apt-get dist-upgrade -y" "Distribution upgrade"
    
    # Essential package installation
    install_packages sudo debconf-utils software-properties-common
    
    # Package removal
    remove_packages ufw firewalld exim4
    
    # Install main dependencies
    local main_dependencies=(
        iptables iptables-persistent netfilter-persistent figlet ruby libxml-parser-perl
        squid nmap screen curl jq bzip2 gzip coreutils rsyslog iftop htop zip unzip
        net-tools sed gnupg gnupg1 bc apt-transport-https build-essential dirmngr
        libxml-parser-perl neofetch screenfetch lsof openssl openvpn easy-rsa fail2ban
        tmux stunnel4 squid3 dropbear socat cron bash-completion ntpdate xz-utils inotify-tools
        apt-transport-https gnupg2 dnsutils lsb-release chrony libnss3-dev libnspr4-dev
        pkg-config libpam0g-dev libcap-ng-dev libcap-ng-utils libselinux1-dev
        libcurl4-nss-dev flex bison make libnss3-tools libevent-dev xl2tpd pptpd
        git speedtest-cli p7zip-full libjpeg-dev zlib1g-dev python python3 python3-pip
        shc build-essential nodejs nginx php php-fpm php-cli php-mysql
    )
    install_packages "${main_dependencies[@]}"
    
    # Additional cleanup
    remove_packages unscd samba* apache2* bind9* sendmail*
    system_cleanup
    
    sudo locale-gen id_ID.UTF-8
    sudo update-locale
    
    # Install vnstat
    install_vnstat
    
    print_message "${GREEN}" "====[ SYSTEM SETUP COMPLETED SUCCESSFULLY ]===="
    exit 0
}

main "$@"