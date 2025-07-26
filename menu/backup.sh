#!/bin/bash

# Ambil informasi server
biji=$(date +"%Y-%m-%d")
colornow=$(cat /etc/rmbl/theme/color.conf)
export NC="\e[0m"
export YELLOW='\033[0;33m'
export RED="\033[0;31m"
export COLOR1="$(cat /etc/rmbl/theme/$colornow | grep -w "TEXT" | cut -d: -f2 | sed 's/ //g')"
export COLBG1="$(cat /etc/rmbl/theme/$colornow | grep -w "BG" | cut -d: -f2 | sed 's/ //g')"
WH='\033[1;37m'

# Ambil informasi IP & tanggal server
IP=$(curl -sS ipv4.icanhazip.com)
date=$(date +"%Y-%m-%d")

# Password untuk ZIP (dapat diganti atau dibuat random)
ZIP_PASSWORD="XieBackup_$date"

# Proses Backup
echo "🔄 Mohon tunggu, proses backup sedang berlangsung..."
rm -rf /root/backup
mkdir -p /root/backup

# Copy semua file penting ke folder backup
cp -r /etc/passwd /root/backup/ &> /dev/null
cp -r /etc/group /root/backup/ &> /dev/null
cp -r /etc/shadow /root/backup/ &> /dev/null
cp -r /etc/gshadow /root/backup/ &> /dev/null
cp -r /usr/bin/idchat /root/backup/ &> /dev/null
cp -r /usr/bin/token /root/backup/ &> /dev/null
cp -r /etc/per /root/backup/per &> /dev/null
cp -r /etc/perlogin /root/backup/perlogin &> /dev/null
cp -r /etc/xray /root/backup/xray &> /dev/null
cp -r /home/vps/public_html /root/backup/public_html &> /dev/null
cp -r /etc/vmess /root/backup/vmess &> /dev/null
cp -r /etc/vless /root/backup/vless &> /dev/null
cp -r /etc/trojan /root/backup/trojan &> /dev/null
cp -r /etc/issue.net /root/backup/issue &> /dev/null

# Membuat ZIP dengan password
echo "🔐 Membuat file backup dengan password..."
cd /root
zip -P "$ZIP_PASSWORD" -r "$IP-$date.zip" backup > /dev/null 2>&1

# Upload backup ke Google Drive menggunakan rclone
rclone copy "/root/$IP-$date.zip" dr:backup/

# Ambil link download dari rclone
url=$(rclone link "dr:backup/$IP-$date.zip")
id=$(echo "$url" | grep '^https' | cut -d'=' -f2)
link="https://drive.google.com/u/4/uc?id=${id}&export=download"

# Membersihkan file sementara
rm -rf /root/backup
rm -f "/root/$IP-$date.zip"

# Tampilkan hasil backup
clear
echo -e "
📌 **Backup Completed!**
==================================
🖥 **IP VPS**       : $IP
🔗 **Backup Link**  : $link
🔑 **ZIP Password** : $ZIP_PASSWORD
📅 **Date**         : $date
==================================
"
echo "⚠️ **Silakan simpan link & password di tempat aman!** ⚠️"
echo -e ""
read -n 1 -s -r -p "🔄 Press any key to return to the menu..."
menu
