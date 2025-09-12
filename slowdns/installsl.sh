#!/bin/bash
set -euo pipefail

# === Fungsi untuk membuat domain NS di Cloudflare ===
ns_domain_cloudflare() {
    DOMAIN="xiestore.biz.id"
    DOMAIN_PATH=$(cat /etc/xray/domain)
    SUB=$(tr -dc a-z0-9 </dev/urandom | head -c7)
    SUB_DOMAIN="${SUB}.${DOMAIN}"
    NS_DOMAIN="ns.${SUB_DOMAIN}"

    CF_ID="freeserver@haren.uk"
    CF_KEY="e38c62cb4318775a1f51f0833c308b0122b2e"

    IP=$(wget -qO- ipinfo.io/ip)
    echo "🔄 Updating DNS NS record for ${NS_DOMAIN}..."

    # Ambil Zone ID dari Cloudflare
    ZONE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
        -H "X-Auth-Email: ${CF_ID}" \
        -H "X-Auth-Key: ${CF_KEY}" \
        -H "Content-Type: application/json" \
        | jq -r .result[0].id)

    # Cek apakah DNS record sudah ada
    RECORD=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${NS_DOMAIN}" \
        -H "X-Auth-Email: ${CF_ID}" \
        -H "X-Auth-Key: ${CF_KEY}" \
        -H "Content-Type: application/json" \
        | jq -r .result[0].id)

    # Jika belum ada, buat baru
    if [[ "${#RECORD}" -le 10 ]]; then
        RECORD=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
            -H "X-Auth-Email: ${CF_ID}" \
            -H "X-Auth-Key: ${CF_KEY}" \
            -H "Content-Type: application/json" \
            --data "{\"type\":\"NS\",\"name\":\"${NS_DOMAIN}\",\"content\":\"${DOMAIN_PATH}\",\"proxied\":false}" \
            | jq -r .result.id)
    fi

    # Update record jika sudah ada
    curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
        -H "X-Auth-Email: ${CF_ID}" \
        -H "X-Auth-Key: ${CF_KEY}" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"NS\",\"name\":\"${NS_DOMAIN}\",\"content\":\"${DOMAIN_PATH}\",\"proxied\":false}"

    echo "${NS_DOMAIN}" > /etc/xray/dns
}

# === Setup DnsTT untuk SlowDNS ===
setup_dnstt() {
    cd
    mkdir -p /etc/slowdns

    # Unduh server dan client binary
    wget -qO dnstt-server "https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/slowdns/dnstt-server"
    wget -qO dnstt-client "https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/slowdns/dnstt-client"
    chmod +x dnstt-server dnstt-client

    # Generate key pair
    ./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
    chmod +x server.key server.pub

    # Pindahkan semua file ke direktori tujuan
    mv dnstt-server dnstt-client server.key server.pub /etc/slowdns

    # Unduh file systemd untuk client dan server
    wget -qO /etc/systemd/system/client.service "https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/slowdns/client"
    wget -qO /etc/systemd/system/server.service "https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/slowdns/server"

    # Ganti placeholder dengan NS domain yang baru
    sed -i "s/xxxx/${NS_DOMAIN}/g" /etc/systemd/system/client.service
    sed -i "s/xxxx/${NS_DOMAIN}/g" /etc/systemd/system/server.service
}

# === Eksekusi fungsi utama ===
#ns_domain_cloudflare
setup_dnstt

# Restart layanan systemd
systemctl restart client
systemctl restart server

exit 0
