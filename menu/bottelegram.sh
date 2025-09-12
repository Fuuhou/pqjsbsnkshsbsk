#!/usr/bin/env bash
set -euo pipefail

#####################################
# Konfigurasi & Informasi Sistem
#####################################
read_file() { [[ -f "$1" ]] && cat "$1" || echo "-"; }

IP=$(read_file /etc/myipvps)
ISP=$(read_file /etc/xray/isp)
CITY=$(read_file /etc/xray/city)
DOMAINZ=$(read_file /etc/xray/domain)
TOKEN=$(read_file /etc/perlogin/token)
CHAT_ID2=$(read_file /etc/perlogin/id)
PASS=$(read_file /etc/pass/word)   # password enkripsi
DATE=$(date +"%Y-%m-%d")
TIME=$(date +"%H:%M:%S")

BACKUP_DIR="/root/backup"
TEMP_DIR="/tmp/backup.$$"
ARCHIVE_NAME="${IP}-${DATE}.7z"

#####################################
# Validasi Awal
#####################################
if [[ "$TOKEN" == "-" || "$CHAT_ID2" == "-" ]]; then
    echo "❌ TOKEN atau CHAT_ID tidak ditemukan."
    exit 1
fi

if [[ "$PASS" == "-" ]]; then
    echo "❌ Password enkripsi tidak ditemukan."
    exit 1
fi

command -v 7z >/dev/null 2>&1 || { echo "❌ 7z (p7zip-full) belum terinstal."; exit 1; }
command -v rclone >/dev/null 2>&1 || { echo "❌ rclone belum terinstal."; exit 1; }

#####################################
# Proses Backup
#####################################
echo "🔄 Membuat backup, mohon tunggu..."

mkdir -p "$TEMP_DIR"

# Daftar file/folder yang dibackup
backup_files=(
    "/etc/passwd"
    "/etc/group"
    "/usr/bin/token"
    "/etc/per"
    "/etc/perlogin"
    "/etc/xray"
    "/etc/vmess"
    "/etc/vless"
    "/etc/trojan"
    "/etc/issue.net"
    "/etc/pass/word"
    "/var/lib/xray/usage.db"
    "/etc/chat"
)

# Salin file/folder jika ada
for file in "${backup_files[@]}"; do
    if [[ -e "$file" ]]; then
        cp -r "$file" "$TEMP_DIR/" 2>/dev/null || true
    fi
done

#####################################
# Kompresi & Enkripsi AES-256
#####################################
cd "$(dirname "$TEMP_DIR")"
7z a -t7z -m0=lzma2 -mx=9 -mhe=on -p"$PASS" "$ARCHIVE_NAME" "$(basename "$TEMP_DIR")" >/dev/null

#####################################
# Upload ke Cloud (Google Drive via Rclone)
#####################################
if rclone copy "$ARCHIVE_NAME" dr:backup/ >/dev/null 2>&1; then
    url=$(rclone link "dr:backup/$ARCHIVE_NAME")
    id=$(echo "$url" | grep -oP '(?<=id=)[^&]+')
    LINK="https://drive.google.com/u/4/uc?id=${id}&export=download"
else
    LINK="-"
fi

#####################################
# Kirim ke Telegram
#####################################
CAPTION="
<b>📦 BACKUP FILE</b>
━━━━━━━━━━━━━━━━━━━━
<b>IP :</b> ${IP}
<b>Domain :</b> ${DOMAINZ}
<b>ISP :</b> ${ISP}
<b>City :</b> ${CITY}
<b>Password :</b> <code>${PASS}</code>
<b>Date :</b> ${DATE} - ${TIME} WIB
<b>GDrive Link :</b> ${LINK}
━━━━━━━━━━━━━━━━━━━━
<i>Backup ini terenkripsi AES-256 & dikompresi maksimal.</i>
"

# Kirim file ke Telegram
curl -s -F chat_id="$CHAT_ID2" \
     -F document=@"$ARCHIVE_NAME" \
     -F parse_mode="html" \
     -F caption="$CAPTION" \
     "https://api.telegram.org/bot$TOKEN/sendDocument" >/dev/null || true

#####################################
# Pembersihan File Sementara
#####################################
rm -rf "$TEMP_DIR" "$ARCHIVE_NAME"

echo "✅ Backup selesai & terkirim ke Telegram."
read -n 1 -s -r -p "Press any key to back on menu"
menu
