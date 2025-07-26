#!/bin/bash

# Konfigurasi dasar
repo="https://raw.githubusercontent.com/Fuuhou/izin/main/"
date=$(date +"%Y-%m-%d")
time=$(date +'%H:%M:%S')
IP=$(curl -sS ipv4.icanhazip.com)
domain=$(cat /etc/xray/domain)
token=$(cat /usr/bin/token)
id_chat=$(cat /usr/bin/idchat)
backup_dir="/root/backup"
zip_password="Kogahara123"

clear
echo "[INFO] Memproses backup, harap tunggu..."

# Buat folder backup
mkdir -p $backup_dir

# Unduh file penting dari repo
wget -qO "$backup_dir/ipmini" "${repo}ip"

# File/folder yang akan dibackup
backup_files=(
    "/etc/passwd"
    "/etc/group"
    "/etc/shadow"
    "/etc/gshadow"
    "/usr/bin/idchat"
    "/usr/bin/token"
    "/etc/per/id"
    "/etc/per/token"
    "/etc/perlogin/id"
    "/etc/perlogin/token"
    "/etc/xray/config.json"
    "/etc/xray/ssh"
    "/home/vps/public_html"
    "/etc/xray/sshx"
    "/etc/vmess"
    "/etc/vless"
    "/etc/trojan"
    "/etc/issue.net"
)

# Salin file/folder ke direktori backup
for file in "${backup_files[@]}"; do
    [[ -e "$file" ]] && rsync -a "$file" "$backup_dir/"
done

# Buat ZIP dengan password
cd /root
zip -r -P "$zip_password" "$IP-$date.zip" backup > /dev/null 2>&1

# Unggah ke Google Drive menggunakan rclone
rclone copyto "/root/$IP-$date.zip" "dr:backup/$IP-$date.zip"

# Ambil link file dari rclone
url=$(rclone link "dr:backup/$IP-$date.zip")
id=$(echo $url | grep -o 'id=[^&]*' | cut -d'=' -f2)
link="https://drive.google.com/u/4/uc?id=${id}&export=download"

# Kirim ke Telegram
curl -F chat_id="$id_chat" -F document=@"$IP-$date.zip" \
     -F caption="✅ Backup Sukses! 🔐
📅 Tanggal : $date
⏰ Waktu   : $time WIB
🌐 Domain  : $domain
📌 IP VPS  : $IP
📥 Link GDrive : $link
🔑 Password ZIP : $zip_password" \
     https://api.telegram.org/bot$token/sendDocument &> /dev/null

# Bersihkan file sementara
rm -rf $backup_dir /root/$IP-$date.zip

echo "[INFO] Backup selesai. Periksa bot Telegram Anda!"
read -n 1 -s -r -p "Tekan tombol apa saja untuk kembali ke menu"
menu
