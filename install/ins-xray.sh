#!/bin/bash

# Color Definitions
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'

FALLBACK_URL="https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/install/fallback.html"

# Clear screen and display date
clear
echo -e "\n$(date)\n"

# Set domain
domain_file="/etc/xray/domain"
if [[ -r "$domain_file" ]]; then
  DOMAINZ=$(<"$domain_file")
else
  DOMAINZ="xiestore.biz.id"
fi

# Create necessary directories
mkdir -p /etc/xray /var/log/xray /home/vps/public_html /var/www/html

# Install required packages
echo -e "[ ${GREEN}INFO${NC} ] Installing dependencies..."
apt update && apt install -y \
    iptables iptables-persistent \
    curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 \
    dnsutils lsb-release cron bash-completion ntpdate chrony zip \
    pwgen openssl netcat

# Sync time
echo -e "[ ${GREEN}INFO${NC} ] Synchronizing system time..."
ntpdate pool.ntp.org
timedatectl set-ntp true
timedatectl set-timezone Asia/Jakarta

# Enable and restart time services
echo -e "[ ${GREEN}INFO${NC} ] Enabling NTP services..."
systemctl enable --now chronyd chrony

# Show chrony tracking stats
chronyc sourcestats -v
chronyc tracking -v

# Install Xray
echo -e "[ ${GREEN}INFO${NC} ] Downloading & installing Xray Core..."
XRAY_SOCKET_DIR="/run/xray"
mkdir -p "$XRAY_SOCKET_DIR"
chown www-data:www-data "$XRAY_SOCKET_DIR"
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u www-data --version 1.8.5

# Setup logging
echo -e "[ ${GREEN}INFO${NC} ] Configuring log files..."
chown www-data:www-data /var/log/xray
chmod +x /var/log/xray
touch /var/log/xray/{access.log,error.log,access2.log,error2.log}

# Install & configure SSL (ACME)
echo -e "[ ${GREEN}INFO${NC} ] Installing SSL certificates..."
systemctl stop nginx
mkdir -p /root/.acme.sh
curl -sL https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/install/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d "$domain" --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d "$domain" --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc

# SSL Renewal Script
SSL_RENEW_SCRIPT="/usr/local/bin/ssl_renew.sh"
echo '#!/bin/bash
/etc/init.d/nginx stop
"/root/.acme.sh/acme.sh" --cron --home "/root/.acme.sh" &> /root/renew_ssl.log
/etc/init.d/nginx start
/etc/init.d/nginx status
' > "$SSL_RENEW_SCRIPT"
chmod +x "$SSL_RENEW_SCRIPT"

# Set up cron job for SSL renewal
if ! crontab -l | grep -q 'ssl_renew.sh'; then
    (crontab -l; echo "15 03 * * 0 $SSL_RENEW_SCRIPT") | crontab -
fi

curl -fsSL "$FALLBACK_URL" -o /var/www/html/fallback.html

# set uuid
uuid=$(cat /proc/sys/kernel/random/uuid)

# xray config
cat > /etc/xray/config.json << END
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 10085,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    },
    {
      "listen": "127.0.0.1",
      "port": 14016,
      "protocol": "vless",
      "settings": {
        "decryption": "none",
        "clients": [
          {
            "id": "${uuid}"
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "/vless",
          "headers": {
            "Host": ""
          }
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": 23456,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "alterId": 0
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "/vmess",
          "headers": {
            "Host": ""
          }
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": 25432,
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "${uuid}"
          }
        ],
        "udp": true
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "/trojan",
          "headers": {
            "Host": ""
          }
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": 24456,
      "protocol": "vless",
      "settings": {
        "decryption": "none",
        "clients": [
          {
            "id": "${uuid}"
          }
        ]
      },
      "streamSettings": {
        "network": "grpc",
        "security": "none",
        "grpcSettings": {
          "serviceName": "vless-grpc",
          "multiMode": true
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": 31234,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "alterId": 0
          }
        ]
      },
      "streamSettings": {
        "network": "grpc",
        "security": "none",
        "grpcSettings": {
          "serviceName": "vmess-grpc",
          "multiMode": true
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": 33456,
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "${uuid}"
          }
        ],
        "udp": true
      },
      "streamSettings": {
        "network": "grpc",
        "security": "none",
        "grpcSettings": {
          "serviceName": "trojan-grpc",
          "multiMode": true
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      },
      {
        "inboundTag": ["api"],
        "outboundTag": "api",
        "type": "field"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": ["bittorrent"]
      }
    ]
  },
  "stats": {},
  "api": {
    "services": ["StatsService"],
    "tag": "api"
  },
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true,
      "statsOutboundUplink": true,
      "statsOutboundDownlink": true
    }
  }
}
END

rm -rf /etc/systemd/system/xray.service.d
rm -rf /etc/systemd/system/xray@.service
cat <<EOF> /etc/systemd/system/xray.service
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=www-data
Group=www-data
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /etc/xray/config.json
ExecStartPre=/bin/sleep 2   # Tambahkan waktu tunggu sebelum start
TimeoutSec=300              # Timeout dalam 5 menit
Restart=always
RestartSec=5                # Waktu tunggu 5 detik sebelum restart service
RestartPreventExitStatus=23 # Jangan restart jika exit code 23
LimitNPROC=10000            # Batasi jumlah proses
LimitNOFILE=1000000         # Batasi file descriptor
LimitMEMLOCK=infinity       # Izinkan akses memori tak terbatas
LimitSTACK=8388608          # Batasi ukuran stack untuk aplikasi
Environment=XRAY_LOG_DIR=/var/log/xray   # Menambahkan variabel lingkungan untuk log
EnvironmentFile=/etc/xray/xray.env   # Menambahkan file environment jika ada

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/runn.service <<EOF
[Unit]
Description=XieTunnel
After=network.target

[Service]
Type=simple
ExecStartPre=-/usr/bin/mkdir -p /var/run/xray
ExecStart=/usr/bin/chown www-data:www-data /var/run/xray
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/nginx/conf.d/xray.conf <<EOF
# Redirect HTTP ke HTTPS
server {
    listen 80;
    server_name *.$DOMAINZ;
    return 301 https://\$host\$request_uri;
}

# HTTPS via NGINX Stream → Xray backend
server {
    listen 8443 ssl http2;
    server_name *.$DOMAINZ;

    # SSL Configuration
    ssl_certificate /etc/xray/xray.crt;
    ssl_certificate_key /etc/xray/xray.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1d;
    ssl_session_tickets off;

    # WebSocket: VLESS
    location = /vless {
        proxy_pass http://127.0.0.1:14016;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_read_timeout 86400;

        proxy_intercept_errors on;
        error_page 502 =200 /fallback.html;
    }

    # WebSocket: VMess
    location = /vmess {
        proxy_pass http://127.0.0.1:23456;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_read_timeout 86400;

        proxy_intercept_errors on;
        error_page 502 =200 /fallback.html;
    }

    # WebSocket: Trojan
    location = /trojan {
        proxy_pass http://127.0.0.1:25432;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_read_timeout 86400;

        proxy_intercept_errors on;
        error_page 502 =200 /fallback.html;
    }

    # gRPC: VLESS
    location ^~ /vless-grpc {
        grpc_pass grpc://127.0.0.1:24456;
        grpc_set_header X-Real-IP \$remote_addr;
        grpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        grpc_set_header Host \$host;
        grpc_read_timeout 86400;
    }

    # gRPC: VMess
    location ^~ /vmess-grpc {
        grpc_pass grpc://127.0.0.1:31234;
        grpc_set_header X-Real-IP \$remote_addr;
        grpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        grpc_set_header Host \$host;
        grpc_read_timeout 86400;
    }

    # gRPC: Trojan
    location ^~ /trojan-grpc {
        grpc_pass grpc://127.0.0.1:33456;
        grpc_set_header X-Real-IP \$remote_addr;
        grpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        grpc_set_header Host \$host;
        grpc_read_timeout 86400;
    }

    # Fallback page saat Xray mati (502)
    location = /fallback.html {
        root /var/www/html;
    }

    # Default: unknown path = 404
    location / {
        return 404;
    }
}
EOF

cat > /etc/systemd/system/watch-nginx.service <<EOF
[Unit]
Description=Watch /etc/xray/domain for changes and reload NGINX
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/watch-nginx
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF


echo -e "$yell[SERVICE]$NC Restart All service"
systemctl daemon-reload
sleep 0.5
echo -e "[ ${green}OK${NC} ] Enable & restart xray "
systemctl daemon-reload
systemctl enable xray
systemctl restart xray
systemctl restart nginx
systemctl enable runn
systemctl restart runn
systemctl enable watch-nginx
systemctl restart watch-nginx

sleep 0.5
yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
yellow "xray/Vmess"
yellow "xray/Vless"

mv /root/domain /etc/xray/
if [ -f /root/scdomain ];then
rm /root/scdomain > /dev/null 2>&1
fi
clear
rm -f ins-xray.sh
