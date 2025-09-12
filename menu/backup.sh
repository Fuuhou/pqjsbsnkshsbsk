#!/bin/bash
set -euo pipefail

# === Tema Terminal ===
colornow=$(< /etc/rmbl/theme/color.conf)
NC="\e[0m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
COLOR1=$(grep -w "TEXT" /etc/rmbl/theme/"$colornow" | cut -d: -f2 | xargs)
COLBG1=$(grep -w "BG" /etc/rmbl/theme/"$colornow" | cut -d: -f2 | xargs)
WH='\033[1;37m'

# === Informasi Dasar ===
clear
IP=$(wget -qO- ipv4.icanhazip.com)
DATE=$(date +"%Y-%m-%d")
BACKUP_DIR="/root/backup"

# === Proses Backup ===
echo "🔄 Mohon tunggu, proses backup sedang berjalan..."

rm -rf "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

declare -A paths=(
  [passwd]="/etc/passwd"
  [group]="/etc/group"
  [idchat]="/usr/bin/idchat"
  [token]="/usr/bin/token"
  [per_id]="/etc/per/id"
  [per_token]="/etc/per/token"
  [login_id]="/etc/perlogin/id"
  [login_token]="/etc/perlogin/token"
  [xray_conf]="/etc/xray/config.json"
  [xray_ssh]="/etc/xray/ssh"
  [sshx]="/etc/xray/sshx"
  [public_html]="/home/vps/public_html"
  [vmess]="/etc/vmess"
  [vless]="/etc/vless"
  [trojan]="/etc/trojan"
  [issue]="/etc/issue.net"
)

# === Salin File dan Direktori Penting ===
for name in "${!paths[@]}"; do
  dest="$BACKUP_DIR/${name}"
  cp -r "${paths[$name]}" "$dest" >/dev/null 2>&1 || true
done

# === Spesial File: Token ke Subfolder ===
cp -r /etc/per/token "$BACKUP_DIR/token2" >/dev/null 2>&1 || true
cp -r /etc/perlogin/id "$BACKUP_DIR/loginid" >/dev/null 2>&1 || true
cp -r /etc/perlogin/token "$BACKUP_DIR/logintoken" >/dev/null 2>&1 || true

# === Arsipkan & Upload ke Google Drive (via rclone) ===
cd /root
ARCHIVE="${IP}-${DATE}.zip"
zip -r "$ARCHIVE" backup >/dev/null 2>&1
rclone copy "/root/$ARCHIVE" "dr:backup/" >/dev/null 2>&1

# === Generate Link Download ===
URL=$(rclone link "dr:backup/$ARCHIVE")
FILEID=$(echo "$URL" | grep '^https' | cut -d'=' -f2)
LINK="https://drive.google.com/u/4/uc?id=${FILEID}&export=download"

# === Bersihkan Lokal ===
rm -rf "$BACKUP_DIR" "/root/$ARCHIVE"
clear

# === Output Informasi ===
echo -e "
📁 Detail Backup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🖥️ IP VPS        : $IP
🔗 Link Backup   : $LINK
📅 Tanggal       : $DATE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 Silakan simpan link di atas untuk restore di masa depan.
"

read -n 1 -s -r -p "Tekan tombol apa saja untuk kembali ke menu..."
menu
