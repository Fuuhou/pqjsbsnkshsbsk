#!/bin/bash

DOMAIN_FILE="/etc/xray/domain"
NGINX_GEN_SCRIPT="/usr/local/bin/gen-nginx"

echo "🔄 Monitoring perubahan pada: $DOMAIN_FILE"

inotifywait -m -e modify "$DOMAIN_FILE" | while read path _ event; do
    echo "✅ Domain file berubah, regenerasi konfigurasi NGINX..."
    bash "$NGINX_GEN_SCRIPT"
    systemctl reload nginx
    echo "✅ NGINX reloaded pada $(date)"
done
