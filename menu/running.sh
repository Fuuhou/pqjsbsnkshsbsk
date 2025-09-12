#!/bin/bash
set -euo pipefail

# Load theme colors
colornow=$(cat /etc/rmbl/theme/color.conf)
export NC="\e[0m"
export RED="\033[0;31m"
export GREEN="\033[0;32m"
export ORANGE="\033[0;33m"
export BLUE="\033[0;34m"
export PURPLE="\033[0;35m"
export CYAN="\033[0;36m"
export WHITE="\033[1;37m"
export COLOR1=$(grep -w "TEXT" /etc/rmbl/theme/"$colornow" | cut -d: -f2 | sed 's/ //g')
export COLBG1=$(grep -w "BG" /etc/rmbl/theme/"$colornow" | cut -d: -f2 | sed 's/ //g')

# Load system information
source /etc/os-release
Versi_OS=$VERSION
Tipe=$NAME
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
DOMAIN=$(cat /etc/xray/domain)
MYIP=$(cat /etc/myipvps)
total_ram=$(grep "MemTotal: " /proc/meminfo | awk '{ print $2}' | awk '{print $1/1024 "MB"}')
kernel=$(uname -r)

# Define services and their status
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

# Check service status
for service in "${services[@]}"; do
  key=${service%%:*}
  svc=${service#*:}
  status=$(systemctl status "$svc" 2>/dev/null | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
  if [[ "$status" == "running" ]]; then
    service_status["$key"]="${GREEN}Online${NC}"
  else
    service_status["$key"]="${RED}Offline${NC}"
  fi
done

# Clear screen and display system information
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLBG1}           SYSTEM INFORMATION                  ${NC}"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}OS Name        :${NC} $Tipe $Versi_OS"
echo -e "${WHITE}Kernel Version :${NC} $kernel"
echo -e "${WHITE}Total RAM      :${NC} $total_ram"
echo -e "${WHITE}IP Server      :${NC} $MYIP"
echo -e "${WHITE}ISP            :${NC} $ISP"
echo -e "${WHITE}City           :${NC} $CITY"
echo -e "${WHITE}Domain         :${NC} $DOMAIN"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLBG1}           SERVICE STATUS                      ${NC}"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}OpenVPN        :${NC} ${service_status[openvpn]}"
echo -e "${WHITE}SSH            :${NC} ${service_status[ssh]}"
echo -e "${WHITE}Xray           :${NC} ${service_status[xray]}"
echo -e "${WHITE}Dropbear       :${NC} ${service_status[dropbear]}"
echo -e "${WHITE}Stunnel        :${NC} ${service_status[stunnel]}"
echo -e "${WHITE}VnStat         :${NC} ${service_status[vnstat]}"
echo -e "${WHITE}Cron           :${NC} ${service_status[cron]}"
echo -e "${WHITE}Fail2Ban       :${NC} ${service_status[fail2ban]}"
echo -e "${WHITE}Websocket TLS  :${NC} ${service_status[ws_tls]}"
echo -e "${WHITE}Websocket OVPN :${NC} ${service_status[ws_ovpn]}"
echo -e "${WHITE}SSLH           :${NC} ${service_status[sslh]}"
echo -e "${WHITE}UDP Custom     :${NC} ${service_status[udp_custom]}"
echo -e "${WHITE}Server         :${NC} ${service_status[server]}"
echo -e "${WHITE}Client         :${NC} ${service_status[client]}"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
read -n 1 -s -r -p "Press [Enter] to return to the menu"
menu
