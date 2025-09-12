#!/bin/bash

# Warna teks
RED='\033[0;31m'
NC='\033[0m'       # No Color
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'

# Unduh dan pasang OHP Server
wget -q https://github.com/Fuuhou/ohape/raw/refs/heads/main/ohpserver-linux32.zip
unzip -q ohpserver-linux32.zip
chmod +x ohpserver
sudo cp ohpserver /usr/local/bin/ohpserver
rm -f ohpserver-linux32.zip ohpserver

# Service SSH OHP
cat > /etc/systemd/system/ssh-ohp.service << EOF
[Unit]
Description=SSH OHP Redirection Service
Documentation=https://t.me/xiestorez
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/ohpserver -port 8181 -proxy 127.0.0.1:3128 -tunnel 127.0.0.1:22
Restart=on-failure
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

# Service Dropbear OHP
cat > /etc/systemd/system/dropbear-ohp.service << EOF
[Unit]
Description=Dropbear OHP Redirection Service
Documentation=https://t.me/xiestorez
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/ohpserver -port 8282 -proxy 127.0.0.1:3128 -tunnel 127.0.0.1:109
Restart=on-failure
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

# Service OpenVPN OHP
cat > /etc/systemd/system/openvpn-ohp.service << EOF
[Unit]
Description=OpenVPN OHP Redirection Service
Documentation=https://t.me/xiestorez
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/ohpserver -port 8383 -proxy 127.0.0.1:3128 -tunnel 127.0.0.1:1194
Restart=on-failure
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

# Reload & aktifkan service
systemctl daemon-reload
systemctl enable --now ssh-ohp
systemctl enable --now dropbear-ohp
systemctl enable --now openvpn-ohp

# Konfirmasi
echo -e "\n${GREEN}INSTALLATION COMPLETED!${NC}"
sleep 0.5
echo -e "${CYAN}CHECKING LISTENING PORT...${NC}"

function check_port() {
    local PORT=$1
    local SERVICE=$2
    if ss -tupln | grep -q "ohpserver" | grep -w "$PORT"; then
        echo "${GREEN}${SERVICE} OHP Redirection Running${NC}"
    else
        echo "${RED}${SERVICE} OHP Redirection Not Found, please check manually${NC}"
    fi
    sleep 0.5
}

check_port 8181 "SSH"
check_port 8282 "Dropbear"
check_port 8383 "OpenVPN"
