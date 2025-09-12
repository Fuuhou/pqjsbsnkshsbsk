#!/bin/bash

# Periksa apakah skrip dijalankan sebagai etc
[ "$(id -u)" != "0" ] && { echo >&2 "Perlu dieksekusi sebagai etc"; exit 1; }

# Baca argumen pertama (jika ada)
exclude=$1

# Buat folder udp di direktori etc
mkdir -p /etc/udp

# Ubah zona waktu ke GMT+7
echo "change to time GMT+7"
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# Unduh dan ekstrak udp-custom
echo "downloading udp-custom"
wget -q -O /etc/udp/udp-custom "https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/udp/udp-custom-linux-amd64"
chmod +x /etc/udp/udp-custom

# Unduh konfigurasi default
echo "downloading default config"
wget -q -O /etc/udp/config.json "https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/udp/config.json"
chmod 644 /etc/udp/config.json

# Tambahkan service UDP-custom ke systemd
cat <<EOF > /etc/systemd/system/udp-custom.service
[Unit]
Description=UDP Custom by ePro Dev. Team

[Service]
User=root
Type=simple
ExecStart=/etc/udp/udp-custom server$((exclude && exclude != "" ? " -exclude $exclude" : ""))
WorkingDirectory=/etc/udp/
Restart=always
RestartSec=2s

[Install]
WantedBy=default.target
EOF

# Mulai dan aktifkan service UDP-custom
echo "start service udp-custom"
systemctl start udp-custom &>/dev/null
echo "enable service udp-custom"
systemctl enable udp-custom &>/dev/null
