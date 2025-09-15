#!/bin/bash

# -------------------------------------------------------------------
#  INITIAL CONFIGURATION
# -------------------------------------------------------------------

REPO_URL="https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/"
START_TIME=$(date +%s)
THEME_DIR="/etc/rmbl/theme"
LOG_FILE="/var/log/setup.log"

declare -A COLORS=(
  [RED]='\e[1;31m'
  [GREEN]='\e[0;32m'
  [YELLOW]='\e[1;33m'
  [BLUE]='\033[1;94m'
  [BGCOLOR]='\e[1;97;101m'
  [CYAN]='\e[1;36m'
  [NC]='\e[0m'
)

# -------------------------------------------------------------------
#  UTILITY FUNCTIONS
# -------------------------------------------------------------------

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "$LOG_FILE"
}

secs_to_human() {
  local h m s
  h=$(( $1 / 3600 ))
  m=$(( ($1 % 3600) / 60 ))
  s=$(( $1 % 60 ))
  log "Installation time: ${h}h ${m}m ${s}s"
}

print_header() {
  local title=$1
  echo -e "${COLORS[BLUE]}┌───────────────────────────────────────────┐${COLORS[NC]}"
  echo -e "${COLORS[BLUE]}│       ${COLORS[NC]}\033[1;37m${title}${COLORS[BLUE]}${COLORS[NC]}${COLORS[BLUE]}│${COLORS[NC]}"
  echo -e "${COLORS[BLUE]}└───────────────────────────────────────────┘${COLORS[NC]}"
  echo
}

print_banner() {
  echo -e "${COLORS[BLUE]}│${COLORS[BGCOLOR]} $1 ${COLORS[NC]}${COLORS[BLUE]}│${COLORS[NC]}"
}

clear_screen() {
  clear
  sleep 0.5
}

# -------------------------------------------------------------------
#  REQUIREMENTS CHECK
# -------------------------------------------------------------------

if [[ "$EUID" -ne 0 ]]; then
  log "[ERROR] This script must be run as root."
  exit 1
fi

if [[ "$(systemd-detect-virt)" == "openvz" ]]; then
  log "[ERROR] OpenVZ is not supported."
  exit 1
fi

# -------------------------------------------------------------------
#  HOSTNAME & DNS SETUP
# -------------------------------------------------------------------

LOCAL_IP=$(hostname -I | awk '{print $1}')
HOSTNAME_CURRENT=$(hostname)
if ! grep -q "$HOSTNAME_CURRENT" /etc/hosts; then
  echo "$LOCAL_IP $HOSTNAME_CURRENT" | tee -a /etc/hosts &>/dev/null
  log "[INFO] Added $HOSTNAME_CURRENT to /etc/hosts"
fi

# -------------------------------------------------------------------
#  DIRECTORY INITIALIZATION
# -------------------------------------------------------------------

# Clean and recreate directories safely
rm -rf /etc/rmbl
mkdir -p /etc/rmbl/theme /var/lib
echo "IP=" > /var/lib/ipvps.conf
log "[INFO] Initialized directories and files"

# -------------------------------------------------------------------
#  AUTHOR PROMPT
# -------------------------------------------------------------------

user_prompt() {
  clear_screen
  print_banner "MASUKKAN NAMA KAMU"
  while true; do
    read -rp "Masukkan Nama Kamu (tanpa spasi): " name
    if [[ "$name" =~ ^[a-zA-Z0-9_.-]+$ ]]; then
      break
    else
      echo -e "${COLORS[RED]}Nama tidak valid. Gunakan huruf, angka, titik, garis bawah, atau minus.${COLORS[NC]}"
    fi
  done
  echo "$name" > /etc/profil
  clear_screen
  echo -e "${COLORS[GREEN]}Nama berhasil disimpan sebagai: $name${COLORS[NC]}"
  log "[INFO] User profile set to $name"
}
user_prompt

# -------------------------------------------------------------------
#  DOMAIN CONFIGURATION
# -------------------------------------------------------------------

configure_domain() {
  clear_screen
  print_header "Configure Server Domain"
  local dnss nss
  until [[ "$dnss" =~ ^[a-zA-Z0-9_.-]+$ ]]; do
    read -rp "🌐 Masukkan domain kamu: " dnss
  done
  until [[ "$nss" =~ ^[a-zA-Z0-9_.-]+$ ]]; do
    read -rp "🛰️  Masukkan NS Domain (contoh: ns1.${dnss}): " nss
  done

  rm -rf /etc/xray /etc/v2ray /etc/domain /etc/per /root/subdomainx
  mkdir -p /etc/xray /etc/v2ray /etc/domain /etc/per
  touch /etc/xray/{domain,slwdomain,scdomain} /etc/v2ray/{domain,scdomain} /etc/per/{id,token} /etc/domain/{nsdomain,subdomain}

  echo "$dnss" | tee /root/domain /root/scdomain /etc/xray/domain /etc/xray/scdomain /etc/v2ray/domain /etc/v2ray/scdomain &>/dev/null
  echo "$nss" > /etc/domain/nsdomain
  echo "$dnss" > /etc/domain/subdomain
  echo "IP=$dnss" > /var/lib/ipvps.conf

  { sleep 2 && touch "$HOME/fim"; } &
  echo -ne "🔧 Updating domain configuration... ["
  while true; do
    for _ in {1..20}; do
      echo -n "#"
      sleep 0.05
    done
    [[ -f "$HOME/fim" ]] && { rm -f "$HOME/fim"; break; }
    echo -en "]\r"
    echo -ne "🔧 Updating domain configuration... ["
  done
  echo -e "] ✅ Done!"
  clear_screen
  log "[INFO] Domain $dnss configured"
}
configure_domain

# -------------------------------------------------------------------
#  THEMES INITIALIZATION
# -------------------------------------------------------------------

mkdir -p "$THEME_DIR"
declare -A THEMES=(
  [green]="\E[40;1;42m|\033[0;32m"
  [yellow]="\E[40;1;43m|\033[0;33m"
  [red]="\E[40;1;41m|\033[0;31m"
  [blue]="\E[40;1;44m|\033[0;34m"
  [magenta]="\E[40;1;45m|\033[0;35m"
  [cyan]="\E[40;1;46m|\033[0;36m"
  [lightgray]="\E[40;1;47m|\033[0;37m"
  [darkgray]="\E[40;1;100m|\033[0;90m"
  [lightred]="\E[40;1;101m|\033[0;91m"
  [lightgreen]="\E[40;1;102m|\033[0;92m"
  [lightyellow]="\E[40;1;103m|\033[0;93m"
  [lightblue]="\E[40;1;104m|\033[0;94m"
  [lightmagenta]="\E[40;1;105m|\033[0;95m"
  [lightcyan]="E[40;1;106m|\033[0;96m"
)
for theme in "${!THEMES[@]}"; do
  IFS="|" read -r bg text <<< "${THEMES[$theme]}"
  cat <<EOF > "$THEME_DIR/$theme"
BG: $bg
TEXT: $text
EOF
done
echo "lightcyan" > "$THEME_DIR/color.conf"
log "[INFO] Theme files initialized"

# -------------------------------------------------------------------
#  INSTALLATION STAGES
# -------------------------------------------------------------------

stage_1() {
  set -e
  clear_screen
  log "[INFO] Disabling IPv6"
  sysctl -w net.ipv6.conf.all.disable_ipv6=1 &>/dev/null
  sysctl -w net.ipv6.conf.default.disable_ipv6=1 &>/dev/null

  log "[INFO] Downloading tools.sh"
  if wget -q "${REPO_URL}tools.sh" -O tools.sh; then
    chmod +x tools.sh
    log "[INFO] Running tools.sh"
    bash tools.sh || { log "[ERROR] Failed to run tools.sh"; exit 1; }
    rm -f tools.sh
  else
    log "[ERROR] Failed to download tools.sh"
    exit 1
  fi

  log "[INFO] Setting timezone and installing dependencies"
  ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
  apt-get update && apt-get install -y --no-install-recommends git curl python3 &>/dev/null
  clear_screen
}

stage_2() {
  declare -A INSTALLERS=(
    ["SSH & OVPN"]="${REPO_URL}install/ssh-vpn.sh"
    ["XRAY"]="${REPO_URL}install/ins-xray.sh"
    ["WebSocket SSH"]="${REPO_URL}sshws/insshws.sh"
    ["Backup Menu"]="${REPO_URL}install/set-br.sh"
    ["OHP"]="${REPO_URL}sshws/ohp.sh"
    ["Extra Menu"]="${REPO_URL}update.sh"
    ["SlowDNS"]="${REPO_URL}slowdns/installsl.sh"
    ["UDP Custom"]="${REPO_URL}install/udp-custom.sh"
  )
  for name in "${!INSTALLERS[@]}"; do
    print_banner "INSTALLING: ${name}"
    log "[INFO] Downloading installer for $name"
    if wget -q "${INSTALLERS[$name]}" -O temp_install.sh; then
      chmod +x temp_install.sh
      log "[INFO] Running installer for $name"
      bash temp_install.sh || log "[WARNING] Installer for $name failed"
      rm -f temp_install.sh
    else
      log "[ERROR] Failed to download installer for $name"
    fi
    clear_screen
  done
}

stage_1
stage_2

# -------------------------------------------------------------------
#  POST-INSTALLATION
# -------------------------------------------------------------------

cat > /root/.profile <<EOF
if [ "\$BASH" ]; then
  [ -f ~/.bashrc ] && . ~/.bashrc
fi
mesg n || true
clear
menu
EOF
chmod 644 /root/.profile

# Cleanup
rm -f /root/{setup.sh,log-install.txt,tools.sh,slhost.sh,ssh-vpn.sh,ins-xray.sh,insshws.sh,set-br.sh,ohp.sh,update.sh,slowdns.sh} &>/dev/null

[[ ! -f "/etc/log-create-user.log" ]] && echo "Log All Account " > /etc/log-create-user.log
curl -sS ifconfig.me > /etc/myipvps
curl -s "ipinfo.io/city" > /etc/xray/city
curl -s "ipinfo.io/org" | cut -d " " -f 2-10 > /etc/xray/isp

secs_to_human "$(($(date +%s) - START_TIME))" | tee -a log-install.txt
sleep 3

print_banner "INSTALLATION COMPLETE"
echo
echo -e "${COLORS[YELLOW]}WARNING: Reboot is recommended after installation.${COLORS[NC]}"
while true; do
  read -rp "Reboot now? (y/n): " answer
  case "$answer" in
    [Yy]* ) reboot;;
    [Nn]* ) exit 0;;
    * ) echo "Please answer yes (y) or no (n).";;
  esac
done
