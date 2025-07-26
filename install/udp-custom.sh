#!/bin/bash

# Set working directory
cd || exit
rm -rf /etc/udp
mkdir -p /etc/udp

# Change timezone to GMT+7
echo "[INFO] Setting timezone to GMT+7..."
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# Define repository URL
REPO="https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/udp"

# Download and set up udp-custom
echo "[INFO] Downloading udp-custom binary..."
wget -q --show-progress -O /etc/udp/udp-custom "${REPO}/udp-custom-linux-amd64"

# Check if download was successful
if [[ ! -f /etc/udp/udp-custom ]]; then
    echo "[ERROR] Failed to download udp-custom!"
    exit 1
fi

# Set execute permission
chmod +x /etc/udp/udp-custom

# Download configuration file
echo "[INFO] Downloading default configuration..."
wget -q --show-progress -O /etc/udp/config.json "${REPO}/config.json"

# Check if config was downloaded successfully
if [[ ! -f /etc/udp/config.json ]]; then
    echo "[ERROR] Failed to download config.json!"
    exit 1
fi

# Set file permissions
chmod 644 /etc/udp/config.json

# Create systemd service file
echo "[INFO] Setting up systemd service for udp-custom..."

cat <<EOF > /etc/systemd/system/udp-custom.service
[Unit]
Description=UDP Custom by ePro Dev. Team
After=network.target

[Service]
User=root
Type=simple
ExecStart=/etc/udp/udp-custom server ${1:+-exclude $1}
WorkingDirectory=/etc/udp/
Restart=always
RestartSec=2s
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start service
echo "[INFO] Starting and enabling udp-custom service..."
systemctl daemon-reload
systemctl enable udp-custom --now

# Check if service started successfully
if systemctl is-active --quiet udp-custom; then
    echo "[SUCCESS] UDP-Custom service is running!"
else
    echo "[ERROR] Failed to start udp-custom service!"
    exit 1
fi
