#!/bin/bash

# === Konfigurasi Tema Warna ===
repo="https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/"
colornow=$(< /etc/rmbl/theme/color.conf)
NC="\e[0m"
RED="\033[0;31m"
COLOR1=$(grep -w "TEXT" /etc/rmbl/theme/"$colornow" | cut -d: -f2 | xargs)
COLBG1=$(grep -w "BG" /etc/rmbl/theme/"$colornow" | cut -d: -f2 | xargs)
WH='\033[1;37m'

# === Header Output ===
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1 ${NC} ${COLBG1}                 ${WH}⇱ UPDATE ⇲                    ${NC} $COLOR1"
echo -e "$COLOR1 ${NC} ${COLBG1}             ${WH}⇱ SCRIPT TERBARU ⇲                ${NC} $COLOR1"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"

# === Daftar file yang dihapus (di dua lokasi) ===
FILE_LIST=(
  restore m-trgo backup menu addnoobz cek-noobz m-noobz m-vmess m-vless m-trojan
  m-system m-sshovpn m-ssws running m-update m-backup m-theme m-ip m-bot update
  ws-dropbear bckpbot tendang bottelegram cleaner m-allxray xraylimit xp trialvmess
  trialvless trialtrojan trialssh
)

# === Penghapusan file di direktori utama ===
for file in "${FILE_LIST[@]}"; do
  rm -rf "$file" >/dev/null 2>&1
done

# === Penghapusan file di /usr/bin ===
cd /usr/bin
for file in "${FILE_LIST[@]}"; do
  rm -rf "$file" >/dev/null 2>&1
done


function fun_bar() {
  local cmd1="$1"
  local cmd2="$2"
  local flag_file="$HOME/fim"

  # Jalankan proses di background
  {
    [[ -e "$flag_file" ]] && rm -f "$flag_file"
    $cmd1 -y >/dev/null 2>&1
    $cmd2 -y >/dev/null 2>&1
    touch "$flag_file"
  } >/dev/null 2>&1 &

  # Progres visual loading
  tput civis
  echo -ne "  \033[0;33mPlease Wait Loading \033[1;37m- \033[0;33m["

  while true; do
    for ((i = 0; i < 20; i++)); do
      echo -ne "\033[0;32m#"
      sleep 0.05
    done

    if [[ -e "$flag_file" ]]; then
      rm -f "$flag_file"
      break
    fi

    echo -e "]"
    sleep 1
    tput cuu1 && tput dl1
    echo -ne "  \033[0;33mPlease Wait Loading \033[1;37m- \033[0;33m["
  done

  echo -e "] \033[1;32m✓ Done!\033[0m"
  tput cnorm
}

function res1() {
  local scripts=(
    "menu/menu.sh:/usr/bin/menu"
    "menu/restore.sh:/usr/bin/restore"
    "menu/backup.sh:/usr/bin/backup"
    "menu/m-bot.sh:/usr/bin/m-bot"
    "menu/m-theme.sh:/usr/bin/m-theme"
    "menu/m-vmess.sh:/usr/bin/m-vmess"
    "menu/m-vless.sh:/usr/bin/m-vless"
    "menu/m-trojan.sh:/usr/bin/m-trojan"
    "menu/m-system.sh:/usr/bin/m-system"
    "menu/m-sshovpn.sh:/usr/bin/m-sshovpn"
    "menu/running.sh:/usr/bin/running"
    "menu/m-backup.sh:/usr/bin/m-backup"
    "speedtest_cli.py:/usr/bin/speedtest"
    "menu/bckpbot.sh:/usr/bin/bckpbot"
    "menu/tendang.sh:/usr/bin/tendang"
    "menu/bottelegram.sh:/usr/bin/bottelegram"
    "menu/xraylimit.sh:/usr/bin/xraylimit"
    "menu/trialvmess.sh:/usr/bin/trialvmess"
    "menu/trialtrojan.sh:/usr/bin/trialvless"
    "menu/trialvless.sh:/usr/bin/trialtrojan"
    "menu/trialssh.sh:/usr/bin/trialssh"
  )

  for entry in "${scripts[@]}"; do
    IFS=":" read -r src dest <<< "$entry"
    wget -q -O "$dest" "${repo}$src" && chmod +x "$dest"
  done

  # Bersihkan direktori home user secara aman
  cd && rm -rf * 2>/dev/null
  clear
}

echo -e "\n  \033[1;91m Memperbarui Skrip...\033[1;37m"
fun_bar 'res1'
echo -e ""
menu
