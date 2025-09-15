#!/bin/bash

# -------------------------------------------------------------------
#  INITIAL CONFIGURATION
# -------------------------------------------------------------------
REPO_URL="https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/"
START_TIME=$(date +%s)
THEME_DIR="/etc/rmbl/theme"

# Color and Style Configuration
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
secs_to_human() {
  local h=$(( $1 / 3600 ))
  local m=$(( ($1 / 60) % 60 ))
  local s=$(( $1 % 60 ))
  echo "Installation time: $h hours $m minutes $s seconds"
}

print_header() {
  local title=$1
  echo -e "${COLORS[BLUE]}┌───────────────────────────────────────────┐${COLORS[NC]}"
  echo -e "${COLORS[BLUE]}│       \033[1;37m${title}${COLORS[BLUE]}│${COLORS[NC]}"
  echo -e "${COLORS[BLUE]}└───────────────────────────────────────────┘${COLORS[NC]}"
  echo
}

print_banner() {
  local text=$1
  echo -e "${COLORS[BLUE]}│ ${COLORS[BGCOLOR]} ${text} ${COLORS[NC]}${COLORS[BLUE]} │${COLORS[NC]}"
}

clear_screen() {
  clear
  sleep 0.5
}

# -------------------------------------------------------------------
#  REQUIREMENTS CHECK
# -------------------------------------------------------------------
if [[ "${EUID}" -ne 0 ]]; then
  echo -e "${COLORS[RED]}You must run this script as root.${COLORS[NC]}"
  exit 1
fi

if [[ "$(systemd-detect-virt)" == "openvz" ]]; then
  echo -e "${COLORS[RED]}OpenVZ is not supported by this script.${COLORS[NC]}"
  exit 1
fi

# -------------------------------------------------------------------
#  HOSTNAME & DNS SETUP
# -------------------------------------------------------------------
LOCAL_IP=$(hostname -I | awk '{print $1}')
HOSTNAME_CURRENT=$(hostname)
HOSTNAME_REGISTERED=$(awk -v host="$HOSTNAME_CURRENT" '$0 ~ host {print $2}' /etc/hosts)

if [[ "$HOSTNAME_CURRENT" != "$HOSTNAME_REGISTERED" ]]; then
  echo "$LOCAL_IP $HOSTNAME_CURRENT" >> /etc/hosts
fi

# -------------------------------------------------------------------
#  DIRECTORY INITIALIZATION
# -------------------------------------------------------------------
rm -rf /etc/rmbl
mkdir -p /etc/rmbl/theme
mkdir -p /var/lib &>/dev/null
echo "IP=" > /var/lib/ipvps.conf

# -------------------------------------------------------------------
#  AUTHOR PROMPT
# -------------------------------------------------------------------
clear_screen
print_banner "MASUKKAN NAMA KAMU"

while true; do
  read -rp "Masukan Nama Kamu Disini tanpa spasi: " name
  if [[ "$name" =~ ^[a-zA-Z0-9_.-]+$ ]]; then
    break
  else
    echo -e "${COLORS[RED]}Nama tidak valid. Gunakan huruf, angka, titik, garis bawah, atau minus.${COLORS[NC]}"
  fi
done

echo "$name" > /etc/profil
clear_screen
echo -e "${COLORS[GREEN]}Nama berhasil disimpan sebagai: $name${COLORS[NC]}"

# -------------------------------------------------------------------
#  DOMAIN CONFIGURATION
# -------------------------------------------------------------------
configure_domain() {
  clear_screen
  print_header "Konfigurasi Domain Server Kamu"
  tput civis

  local dnss nss
  until [[ "$dnss" =~ ^[a-zA-Z0-9_.-]+$ ]]; do
    read -rp "🌐 Masukkan domain kamu: " dnss
  done

  until [[ "$nss" =~ ^[a-zA-Z0-9_.-]+$ ]]; do
    read -rp "🛰️  Masukkan NS Domain (contoh: ns1.${dnss}): " nss
  done

  # Clean and recreate config directories
  rm -rf /etc/xray /etc/v2ray /etc/domain /etc/per /root/subdomainx
  mkdir -p /etc/xray /etc/v2ray /etc/domain /etc/per
  touch /etc/xray/{domain,slwdomain,scdomain} /etc/v2ray/{domain,scdomain} /etc/per/{id,token} /etc/domain/{nsdomain,subdomain}

  # Save domain and nameserver
  echo "$dnss" | tee /root/domain /root/scdomain /etc/xray/domain /etc/xray/scdomain /etc/v2ray/domain /etc/v2ray/scdomain >/dev/null
  echo "$nss" > /etc/domain/nsdomain
  echo "$dnss" > /etc/domain/subdomain
  echo "IP=$dnss" > /var/lib/ipvps.conf

  # Simulate progress bar
  {
    sleep 2
    touch "$HOME/fim"
  } &
  echo -ne "🔧 Mengupdate konfigurasi domain... ["
  while true; do
    for ((i = 0; i < 20; i++)); do
      echo -ne "#"
      sleep 0.05
    done
    [[ -e "$HOME/fim" ]] && { rm "$HOME/fim"; break; }
    echo -e "]"
    tput cuu1 && tput dl1
    echo -ne "🔧 Mengupdate konfigurasi domain... ["
  done
  echo -e "] ✅ Selesai!"
  tput cnorm
  sleep 1
  clear_screen
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
  [lightcyan]="\E[40;1;106m|\033[0;96m"
)

for theme in "${!THEMES[@]}"; do
  IFS="|" read -r bg text <<< "${THEMES[$theme]}"
  cat <<EOF > "$THEME_DIR/$theme"
BG: $bg
TEXT: $text
EOF
done

echo "lightcyan" > "$THEME_DIR/color.conf"

# -------------------------------------------------------------------
#  INSTALLATION STAGES
# -------------------------------------------------------------------
stage_1() {
  set -e
  clear_screen
  echo "🔧 Menonaktifkan IPv6..."
  sysctl -w net.ipv6.conf.all.disable_ipv6=1 &>/dev/null
  sysctl -w net.ipv6.conf.default.disable_ipv6=1 &>/dev/null

  echo "📦 Mengunduh tools.sh..."
  if wget -q "${REPO_URL}tools.sh"; then
    chmod +x tools.sh
    echo "▶ Menjalankan tools.sh..."
    bash tools.sh
  else
    echo "❌ Gagal mengunduh tools.sh! Periksa koneksi internet dan URL repo."
    exit 1  # Keluar jika unduhan gagal
  fi

  echo "🕒 Mengatur zona waktu & menginstal dependensi..."
  ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
  apt install -y git curl python &>/dev/null
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
    print_banner "INSTALASI: ${name}"
    wget -q "${INSTALLERS[$name]}" -O temp_install.sh
    chmod +x temp_install.sh
    bash temp_install.sh
    rm -f temp_install.sh
    clear_screen
  done
}

stage_3() {
  clear_screen
  local CHATID="-1002085952759"
  local TOKEN="8225871391:AAEj5jZPSfw76fFjDK4cGIOz0bQXC4AFqc0"   # ganti dengan token asli
  local URL="https://api.telegram.org/bot${TOKEN}/sendMessage"
  local TIMEOUT=10
  local DOMAIN=$(< /etc/xray/domain)
  local ISP=$(< /etc/xray/isp)
  local CITY=$(< /etc/xray/city)
  local OS_INFO=$(grep -w PRETTY_NAME /etc/os-release | sed -e 's/^.*=//' -e 's/"//g')
  local RAM_TOTAL=$(free -m | awk 'NR==2 {print $2}')
  local TIME=$(date '+%d %b %Y')
  local MYIP=$(curl -sS ipv4.icanhazip.com)
  local TEXT="
<b>INSTALLASI BERHASIL - AUTOSCRIPT PREMIUM</b>
━━━━━━━━━━━━━━━━━━━━
<b>📦 Informasi Sistem:</b>
<code>🔎 IP       : $MYIP</code>
<code>🌐 Domain  : $DOMAIN</code>
<code>🏢 ISP     : $ISP</code>
<code>📍 Kota    : $CITY</code>
<code>🧠 RAM     : ${RAM_TOTAL} MB</code>
<code>🖥️ OS      : $OS_INFO</code>
<code>📆 Tanggal : $TIME</code>
━━━━━━━━━━━━━━━━━━━━
<i>🔔 Notifikasi otomatis via Script</i>"
  local BUTTONS='&reply_markup={"inline_keyboard":[[{"text":"ᴏʀᴅᴇʀ","url":"https://t.me/xiesz"},{"text":"JOIN","url":"https://t.me/xiestorez"}]]}'
  curl -s --max-time "$TIMEOUT" \
    -d "chat_id=$CHATID&disable_web_page_preview=true&parse_mode=html&text=$TEXT$BUTTONS" \
    "$URL" > /dev/null
}

# -------------------------------------------------------------------
#  MAIN EXECUTION
# -------------------------------------------------------------------
stage_1
stage_2

# Auto-load menu on login
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
rm -f /root/log-install.txt /etc/afak.conf \
      /root/{setup.sh,slhost.sh,ssh-vpn.sh,ins-xray.sh,insshws.sh,set-br.sh,ohp.sh,update.sh,slowdns.sh} &>/dev/null

# Initialize logs
[[ ! -f "/etc/log-create-user.log" ]] && echo "Log All Account " > /etc/log-create-user.log

# System info
curl -sS ifconfig.me > /etc/myipvps
curl -s "ipinfo.io/city" > /etc/xray/city
curl -s "ipinfo.io/org" | cut -d " " -f 2-10 > /etc/xray/isp

# Record install time
secs_to_human "$(($(date +%s) - START_TIME))" | tee -a log-install.txt
sleep 3

# Send Telegram notification
stage_3

print_banner "INSTALL SCRIPT SELESAI.."
echo

read -rp "[ ${COLORS[YELLOW]}WARNING${COLORS[NC]} ] Do you want to reboot now? (y/n): " answer
[[ "$answer" =~ ^[Yy]$ ]] && reboot || exit 0
