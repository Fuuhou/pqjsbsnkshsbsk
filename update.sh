#!/bin/bash

repo="https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/"

echo -e "[INFO] Downloading Files"

declare -a files=(
    "menu/menu.sh"
    "menu/restore.sh"
    "menu/backup.sh"
    "menu/m-bot.sh"
    "menu/m-theme.sh"
    "menu/m-vmess.sh"
    "menu/m-vless.sh"
    "menu/m-trojan.sh"
    "menu/m-system.sh"
    "menu/m-sshovpn.sh"
    "menu/running.sh"
    "menu/m-backup.sh"
    "menu/bckpbot.sh"
    "menu/tendang.sh"
    "menu/bottelegram.sh"
    "menu/xraylimit.sh"
    "menu/trialvmess.sh"
    "menu/trialtrojan.sh"
    "menu/trialvless.sh"
    "menu/trialssh.sh"
    "menu/m-bbr.sh"
    "menu/m-update.sh"
    "install/speedtest.py"
)

for file in "${files[@]}"; do
    filename=$(basename "$file")
    wget -q -O "/usr/bin/$filename" "${repo}$file"
    chmod +x "/usr/bin/$filename"
done

echo -e "[INFO] Download Files Successfully"
exit
