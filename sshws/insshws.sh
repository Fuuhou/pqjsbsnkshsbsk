#!/bin/bash

# Set repository URL
REPO="https://raw.githubusercontent.com/wibuxie/autoscript/main/"

# === Install WebSocket for Dropbear ===
wget -O /usr/local/bin/ws-dropbear "${REPO}sshws/ws-dropbear"
chmod +x /usr/local/bin/ws-dropbear

# Create systemd service for Dropbear WebSocket
cat > /etc/systemd/system/ws-dropbear.service << EOF
[Unit]
Description=Dropbear WebSocket Service
Documentation=https://t.me/xiestorez
After=network.target nss-lookup.target

[Service]
Type=simple
ExecStart=/usr/bin/python -O /usr/local/bin/ws-dropbear
Restart=on-failure
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

# Enable and start Dropbear service
systemctl daemon-reload
systemctl enable ws-dropbear.service
systemctl restart ws-dropbear.service

# === Install WebSocket for OpenVPN ===
wget -O /usr/local/bin/ws-ovpn "${REPO}sshws/ws-ovpn.py"
chmod +x /usr/local/bin/ws-ovpn

# Create systemd service for OpenVPN WebSocket
cat > /etc/systemd/system/ws-ovpn.service << EOF
[Unit]
Description=OpenVPN WebSocket Service
Documentation=https://t.me/xiestorez
After=network.target nss-lookup.target

[Service]
Type=simple
ExecStart=/usr/bin/python -O /usr/local/bin/ws-ovpn 2086
Restart=on-failure
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

# Enable and start OpenVPN service
systemctl daemon-reload
systemctl enable ws-ovpn.service
systemctl restart ws-ovpn.service

# === Install WebSocket for Stunnel ===
wget -O /usr/local/bin/ws-stunnel "${REPO}sshws/ws-stunnel"
chmod +x /usr/local/bin/ws-stunnel

# Create systemd service for Stunnel WebSocket
cat > /etc/systemd/system/ws-stunnel.service << EOF
[Unit]
Description=Stunnel WebSocket Service
Documentation=https://t.me/xiestorez
After=network.target nss-lookup.target

[Service]
Type=simple
ExecStart=/usr/bin/python -O /usr/local/bin/ws-stunnel
Restart=on-failure
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

# Enable and start Stunnel service
systemctl daemon-reload
systemctl enable ws-stunnel.service
systemctl restart ws-stunnel.service
