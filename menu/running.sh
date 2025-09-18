#!/bin/bash
set -euo pipefail

# =================== THEME COLOR =================== #
colornow=$(cat /etc/rmbl/theme/color.conf 2>/dev/null || echo "default")
export NC="\e[0m"
export RED="\033[0;31m"
export GREEN="\033[0;32m"
export ORANGE="\033[0;33m"
export BLUE="\033[0;34m"
export PURPLE="\033[0;35m"
export CYAN="\033[0;36m"
export WHITE="\033[1;37m"
export COLOR1=$(grep -w "TEXT" /etc/rmbl/theme/"$colornow" 2>/dev/null | cut -d: -f2 | sed 's/ //g' || echo "$CYAN")
export COLBG1=$(grep -w "BG" /etc/rmbl/theme/"$colornow" 2>/dev/null | cut -d: -f2 | sed 's/ //g' || echo "$BLUE")

# =================== SYSTEM INFO =================== #
source /etc/os-release
Versi_OS=${VERSION:-"N/A"}
Tipe=${NAME:-"Linux"}
ISP=$(cat /etc/xray/isp 2>/dev/null || echo "Unknown")
CITY=$(cat /etc/xray/city 2>/dev/null || echo "Unknown")
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "Unknown")
MYIP=$(cat /etc/myipvps 2>/dev/null || hostname -I | awk '{print $1}')
total_ram=$(free -h | awk '/Mem:/ {print $2}')
kernel=$(uname -r)
uptime_sys=$(uptime -p || echo "N/A")
cpu_info=$(lscpu | grep "Model name" | head -n1 | cut -d: -f2 | sed 's/^ *//')

# =================== SERVICE LIST =================== #
declare -A service_status
services=(
  "openvpn:openvpn"
  "ssh:ssh"
  "xray:xray"
  "dropbear:dropbear"
  "stunnel:stunnel4"
  "vnstat:vnstat"
  "cron:cron"
  "fail2ban:fail2ban"
  "ws_tls:ws-stunnel.service"
  "ws_ovpn:ws-ovpn"
  "sslh:sslh"
  "udp_custom:udp-custom"
  "server:server"
  "client:client"
)

# =================== CHECK SERVICE STATUS =================== #
for service in "${services[@]}"; do
  key=${service%%:*}
  svc=${service#*:}
  if systemctl list-unit-files | grep -qw "$svc"; then
    status=$(systemctl is-active "$svc" 2>/dev/null)
    if [[ "$status" == "active" ]]; then
      service_status["$key"]="${GREEN}Online${NC}"
    else
      service_status["$key"]="${RED}Offline${NC}"
    fi
  else
    service_status["$key"]="${ORANGE}Not Installed${NC}"
  fi
done

# =================== DISPLAY =================== #
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLBG1}           SYSTEM INFORMATION                  ${NC}"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}OS Name        :${NC} $Tipe $Versi_OS"
echo -e "${WHITE}Kernel Version :${NC} $kernel"
echo -e "${WHITE}CPU            :${NC} $cpu_info"
echo -e "${WHITE}Total RAM      :${NC} $total_ram"
echo -e "${WHITE}Uptime         :${NC} $uptime_sys"
echo -e "${WHITE}IP Server      :${NC} $MYIP"
echo -e "${WHITE}ISP            :${NC} $ISP"
echo -e "${WHITE}City           :${NC} $CITY"
echo -e "${WHITE}Domain         :${NC} $DOMAIN"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLBG1}           SERVICE STATUS                      ${NC}"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
for key in "${!service_status[@]}"; do
  printf "%-15s : %b\n" "$key" "${service_status[$key]}"
done
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -n 1 -s -r -p "Press [Enter] to return to the menu"
menu
