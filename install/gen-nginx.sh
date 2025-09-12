#!/bin/bash

# Pastikan domain ada
DOMAIN_FILE="/etc/xray/domain"
if [ ! -f "$DOMAIN_FILE" ]; then
    echo "❌ File domain tidak ditemukan di $DOMAIN_FILE"
    exit 1
fi

DOMAINZ=$(cat $DOMAIN_FILE | tr -d '\r\n')


# Buat konfigurasi nginx.conf lengkap
cat > /etc/nginx/nginx.conf <<EOF
user www-data;
worker_processes 1;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
    accept_mutex on;
}

stream {
    map \$ssl_preread_server_name \$backend {
        default            127.0.0.1:8443;
        $DOMAINZ            127.0.0.1:22222;
    }

    server {
        listen 443 reuseport;
        proxy_pass \$backend;
        ssl_preread on;
    }
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    server_tokens off;
    client_max_body_size 10m;

    client_body_buffer_size 16k;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 8k;

    keepalive_timeout 30s;
    keepalive_requests 1000;
    client_body_timeout 12;
    client_header_timeout 12;
    send_timeout 10;

    open_file_cache max=5000 inactive=30s;
    open_file_cache_valid 60s;
    open_file_cache_min_uses 2;
    open_file_cache_errors off;

    gzip on;
    gzip_comp_level 3;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    access_log off;
    error_log /var/log/nginx/error.log crit;

    add_header X-Frame-Options SAMEORIGIN always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;

    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1d;
    ssl_session_tickets off;
    ssl_prefer_server_ciphers on;
    ssl_protocols TLSv1.2 TLSv1.3;

    proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=STATIC:10m inactive=1h max_size=100m;
    proxy_temp_path /var/cache/nginx/tmp;

    map \$sent_http_content_type \$expires {
        default                    off;
        text/html                  1h;
        text/css                   1y;
        application/javascript     1y;
        ~image/                    1M;
    }

    set_real_ip_from 173.245.48.0/20;
    set_real_ip_from 103.21.244.0/22;
    set_real_ip_from 103.22.200.0/22;
    set_real_ip_from 103.31.4.0/22;
    set_real_ip_from 141.101.64.0/18;
    set_real_ip_from 108.162.192.0/18;
    set_real_ip_from 190.93.240.0/20;
    set_real_ip_from 188.114.96.0/20;
    set_real_ip_from 197.234.240.0/22;
    set_real_ip_from 198.41.128.0/17;
    set_real_ip_from 162.158.0.0/15;
    set_real_ip_from 104.16.0.0/13;
    set_real_ip_from 172.64.0.0/13;
    real_ip_header CF-Connecting-IP;

    resolver 1.1.1.1 8.8.8.8 valid=300s;
    resolver_timeout 5s;

    include /etc/nginx/conf.d/*.conf;
}
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

systemctl restart xray
systemctl reload nginx

echo "✅ nginx.conf berhasil digenerate dengan domain: $DOMAINZ"
