#!/bin/bash

# ======================================================
# Script Initialization - Setup Environment & Metadata
# Author Profil Setup, Root Check, and Host Fixing
# ======================================================

REPO_URL="https://raw.githubusercontent.com/wibuxie/autoscript/main"

# --- Styling / Color Configuration ---
RED='\e[1;31m'
GREEN='\e[0;32m'
YELLOW='\e[1;33m'
BLUE='\033[1;94m'
BGCOLOR='\e[1;97;101m'
CYAN='\e[1;36m'
NC='\e[0m'

# --- Ensure running as root ---
if [[ "${EUID}" -ne 0 ]]; then
  echo -e "${RED}You must run this script as root.${NC}"
  exit 1
fi

# --- Check if OpenVZ is used (unsupported) ---
if [[ "$(systemd-detect-virt)" == "openvz" ]]; then
  echo -e "${RED}OpenVZ is not supported by this script.${NC}"
  exit 1
fi

# --- Hostname Fixing for DNS Issues ---
LOCAL_IP=$(hostname -I | awk '{print $1}')
HOSTNAME_CURRENT=$(hostname)
HOSTNAME_REGISTERED=$(awk '/'"$HOSTNAME_CURRENT"'/{print $2}' /etc/hosts)

if [[ "$HOSTNAME_CURRENT" != "$HOSTNAME_REGISTERED" ]]; then
  echo "$LOCAL_IP $HOSTNAME_CURRENT" >> /etc/hosts
fi

# --- Utility: Convert Seconds to Human Time Format ---
secs_to_human() {
  echo "Installation time : $(( $1 / 3600 )) hours $(( ($1 / 60) % 60 )) minutes $(( $1 % 60 )) seconds"
}

# --- Directory Initialization ---
rm -rf /etc/rmbl
mkdir -p /etc/rmbl/theme
mkdir -p /var/lib > /dev/null 2>&1
echo "IP=" > /var/lib/ipvps.conf

# --- Clear Screen & Prompt for Author Name ---
clear
echo -e "${BLUE}│ ${BGCOLOR}           MASUKKAN NAMA KAMU         ${NC}${BLUE} │${NC}"
echo ""

# --- Read and Validate Author Name ---
while true; do
  read -rp "Masukan Nama Kamu Disini tanpa spasi: " name
  if [[ $name =~ ^[a-zA-Z0-9_.-]+$ ]]; then
    break
  else
    echo -e "${RED}Nama tidak valid. Hanya boleh huruf, angka, titik, garis bawah, atau minus.${NC}"
  fi
done

# --- Save Author Name ---
echo "$name" > /etc/profil

# --- Confirmation Display ---
clear
AUTHOR_NAME=$(cat /etc/profil)
echo -e "${GREEN}Nama berhasil disimpan sebagai: $AUTHOR_NAME${NC}"

function domain() {
    clear
    tput civis
    echo -e "${BIBlue}┌───────────────────────────────────────────┐${NC}"
    echo -e "${BIBlue}│       \033[1;37mKonfigurasi Domain Server Kamu       ${BIBlue}│${NC}"
    echo -e "${BIBlue}└───────────────────────────────────────────┘${NC}"
    echo ""

    # === Input domain utama ===
    local dnss=""
    until [[ "$dnss" =~ ^[a-zA-Z0-9_.-]+$ ]]; do
        read -rp "🌐 Masukkan domain kamu: " -e dnss
    done

    # === Input NS domain (optional tapi disarankan) ===
    local nss=""
    until [[ "$nss" =~ ^[a-zA-Z0-9_.-]+$ ]]; do
        read -rp "🛰️ Masukkan NS Domain (contoh: ns1.${dnss}): " -e nss
    done

    # === Inisialisasi direktori dan file konfigurasi ===
    rm -rf /etc/xray /etc/v2ray /etc/domain /etc/per /root/subdomainx
    mkdir -p /etc/xray /etc/v2ray /etc/domain /etc/per
    touch /etc/xray/{domain,slwdomain,scdomain}
    touch /etc/v2ray/{domain,scdomain}
    touch /etc/per/{id,token}
    touch /etc/domain/{nsdomain,subdomain}

    # === Simpan domain dan NS ke lokasi masing-masing ===
    echo "$dnss" | tee /root/domain /root/scdomain /etc/xray/domain /etc/xray/scdomain /etc/v2ray/domain /etc/v2ray/scdomain >/dev/null
    echo "$nss" > /etc/domain/nsdomain
    echo "$dnss" > /etc/domain/subdomain
    echo "IP=$dnss" > /var/lib/ipvps.conf

    # === Progres visual update konfigurasi ===
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
        [[ -e "$HOME/fim" ]] && rm "$HOME/fim" && break
        echo -e "]"
        tput cuu1 && tput dl1
        echo -ne "🔧 Mengupdate konfigurasi domain... ["
    done
    echo -e "] ✅ Selesai!"
    tput cnorm
    sleep 1
    clear
}


THEME_DIR="/etc/rmbl/theme"
mkdir -p "$THEME_DIR"

# Associative array untuk warna tema
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

# Menulis file konfigurasi masing-masing tema
for theme in "${!THEMES[@]}"; do
  IFS="|" read -r bg text <<< "${THEMES[$theme]}"
  cat <<EOF > "$THEME_DIR/$theme"
BG : $bg
TEXT : $text
EOF
done

# Set default theme
echo "lightcyan" > "$THEME_DIR/color.conf"

function xie1() {
  clear
  cd
  echo "🔧 Menonaktifkan IPv6..."
  sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
  sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1

  echo "📦 Menjalankan tools.sh..."
  wget -q "${repo}tools.sh"
  chmod +x tools.sh
  bash tools.sh

  echo "🕒 Mengatur zona waktu dan menginstal dependensi..."
  ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
  apt install -y git curl python >/dev/null 2>&1

  clear
}

function xie2() {
  declare -A INSTALLERS=(
    ["SSH & OVPN"]="${repo}install/ssh-vpn.sh"
    ["XRAY"]="${repo}install/ins-xray.sh"
    ["WebSocket SSH"]="${repo}sshws/insshws.sh"
    ["Backup Menu"]="${repo}install/set-br.sh"
    ["OHP"]="${repo}sshws/ohp.sh"
    ["Extra Menu"]="${repo}update.sh"
    ["SlowDNS"]="${repo}slowdns/installsl.sh"
    ["UDP Custom"]="${repo}install/udp-custom.sh"
    ["Limit XRAY"]="${repo}bin/limit.sh"
    ["Trojan-GO"]="${repo}install/ins-trgo.sh"
  )

  for name in "${!INSTALLERS[@]}"; do
    echo -e "${BIBlue}│ ${BGCOLOR}  INSTALASI: ${name} ${NC}${BIBlue} │${NC}"
    wget -q "${INSTALLERS[$name]}" -O temp_install.sh
    chmod +x temp_install.sh
    bash temp_install.sh
    rm -f temp_install.sh
    clear
  done

  echo -e "${BIBlue}│ ${BGCOLOR}  INSTALASI: NOOBZVPNS ${NC}${BIBlue} │${NC}"
  wget -q "${repo}noobz/noobzvpns.zip"
  unzip -o noobzvpns.zip -d noobzvpns >/dev/null 2>&1
  chmod +x noobzvpns/*
  bash noobzvpns/install.sh
  rm -rf noobzvpns noobzvpns.zip
  systemctl restart noobzvpns
  clear
}


function xie3() {
  clear

  # === Konfigurasi Telegram ===
  local CHATID="-1002305290411"
  local TOKEN="7762568765:AAHj5g7akuzr6RYRnEdRnMeVxaGf-rj1wME"
  local URL="https://api.telegram.org/bot${TOKEN}/sendMessage"
  local TIMEOUT=10

  # === Informasi Sistem ===
  local DOMAIN=$(< /etc/xray/domain)
  local ISP=$(< /etc/xray/isp)
  local CITY=$(< /etc/xray/city)
  local OS_INFO=$(grep -w PRETTY_NAME /etc/os-release | sed -e 's/^.*=//' -e 's/"//g')
  local RAM_TOTAL=$(free -m | awk 'NR==2 {print $2}')
  local TIME=$(date '+%d %b %Y')
  local MYIP=$(curl -sS ipv4.icanhazip.com)

  # === Validasi dan Lisensi ===
  local IZIN=$(curl -sS https://raw.githubusercontent.com/wibuxie/iz/main/ip | grep "$MYIP" | awk '{print $3}')
  local USRSC=$(curl -sS https://raw.githubusercontent.com/wibuxie/iz/main/ip | grep "$MYIP" | awk '{print $2}')
  local EXPSC="$IZIN"

  # === Format Pesan Telegram ===
  local TEXT="
<b>INSTALLASI BERHASIL - AUTOSCRIPT PREMIUM </b>
━━━━━━━━━━━━━━━━━━━━
<b>📦 Informasi Sistem:</b>
<code>📡 ID :</b> $USRSC</code>
<code>📆 Tanggal :</b> $TIME</code>
<code>📁 Expiry :</b> $EXPSC</code>
<code>🌐 Domain :</b> $DOMAIN</code>
<code>🏢 ISP :</b> $ISP</code>
<code>📍 Kota :</b> $CITY</code>
<code>🧠 RAM :</b> ${RAM_TOTAL} MB</code>
<code>🖥️ OS :</b> $OS_INFO</code>
<code>🔎 IP Publik :</b> $MYIP</code>
━━━━━━━━━━━━━━━━━━━━
<i>🔔 Notifikasi otomatis via XIESTORE Script</i>"


  local BUTTONS='&reply_markup={"inline_keyboard":[[{"text":"ᴏʀᴅᴇʀ","url":"https://t.me/superxiez"},{"text":"JOIN","url":"https://t.me/xiestorez"}]]}'

  # === Kirim Notifikasi ===
  curl -s --max-time $TIMEOUT \
    -d "chat_id=$CHATID&disable_web_page_preview=true&parse_mode=html&text=$TEXT$BUTTONS" \
    "$URL" > /dev/null
}


# === Eksekusi Tahap Awal ===
clear
xie1
xie2

# === Konfigurasi .profile untuk menu otomatis ===
cat > /root/.profile <<EOF
if [ "\$BASH" ]; then
  [ -f ~/.bashrc ] && . ~/.bashrc
fi
mesg n || true
clear
menu
EOF
chmod 644 /root/.profile

# === Pembersihan File Lama ===
rm -f /root/log-install.txt /etc/afak.conf /root/{setup.sh,slhost.sh,ssh-vpn.sh,ins-xray.sh,insshws.sh,set-br.sh,ohp.sh,update.sh,slowdns.sh} >/dev/null 2>&1

# === Inisialisasi Log User Jika Belum Ada ===
[[ ! -f "/etc/log-create-user.log" ]] && echo "Log All Account " > /etc/log-create-user.log

# === Informasi Versi Script dan Zona Waktu ===
history -c
serverV=$(curl -sS "${repo}versi")
echo "$serverV" > /opt/.ver
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# === Konversi AM/PM Berdasarkan Nilai File ===
aureb=$(< /home/re_otm)
gg=$([ "$aureb" -gt 11 ] && echo "PM" || echo "AM")

# === Informasi Sistem ===
curl -sS ifconfig.me > /etc/myipvps
curl -s "ipinfo.io/city" > /etc/xray/city
curl -s "ipinfo.io/org" | cut -d " " -f 2-10 > /etc/xray/isp

# === Setup Direktori dan File Pendukung ===
mkdir -p /etc/noobz
echo "" > /etc/xray/noob

# === Logging Waktu Install ===
secs_to_human "$(($(date +%s) - ${start}))" | tee -a log-install.txt
sleep 3
echo ""

# === Kirim Info Telegram dan Selesai ===
cd
xie3
rm -rf *

echo -e "${BIBlue}│ ${BGCOLOR} INSTALL SCRIPT SELESAI.. ${NC}${BIBlue} │${NC}"
echo ""
sleep 4

# === Prompt Reboot ===
read -rp "[ ${yell}WARNING${NC} ] Do you want to reboot now? (y/n): " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  reboot
else
  exit 0
fi
