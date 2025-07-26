#!/bin/bash
set -euo pipefail

# Install dependensi jika belum terpasang
apt install -y jq curl

# Konfigurasi Cloudflare dan domain
DOMAIN="freeserver.web.id"
sub=$(cat /root/subdomainx)
dns="${sub}.freeserver.web.id"
dns2="*.${sub}.freeserver.web.id"
CF_ID="freeserver@haren.uk"
CF_KEY="e38c62cb4318775a1f51f0833c308b0122b2e"

# Dapatkan IP server
IP=$(wget -qO- icanhazip.com)
echo "Updating DNS for ${dns}..."

# Ambil zone ID dari Cloudflare
ZONE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
  -H "X-Auth-Email: ${CF_ID}" \
  -H "X-Auth-Key: ${CF_KEY}" \
  -H "Content-Type: application/json" | jq -r '.result[0].id')

# Cek apakah sudah ada DNS record untuk dns dan dns2
RECORD=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${dns}" \
  -H "X-Auth-Email: ${CF_ID}" \
  -H "X-Auth-Key: ${CF_KEY}" \
  -H "Content-Type: application/json" | jq -r '.result[0].id')
RECORD2=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${dns2}" \
  -H "X-Auth-Email: ${CF_ID}" \
  -H "X-Auth-Key: ${CF_KEY}" \
  -H "Content-Type: application/json" | jq -r '.result[0].id')

# Jika DNS record untuk dns belum ada, buat baru
if [[ "${#RECORD}" -le 10 ]]; then
  RECORD=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
    -H "X-Auth-Email: ${CF_ID}" \
    -H "X-Auth-Key: ${CF_KEY}" \
    -H "Content-Type: application/json" \
    --data '{"type":"A","name":"'"${dns}"'","content":"'"${IP}"'","ttl":120,"proxied":false}' | jq -r '.result.id')
fi

# Jika DNS record untuk dns2 belum ada, buat baru
if [[ "${#RECORD2}" -le 10 ]]; then
  RECORD2=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
    -H "X-Auth-Email: ${CF_ID}" \
    -H "X-Auth-Key: ${CF_KEY}" \
    -H "Content-Type: application/json" \
    --data '{"type":"A","name":"'"${dns2}"'","content":"'"${IP}"'","ttl":120,"proxied":false}' | jq -r '.result.id')
fi

# Update kedua record dengan IP terbaru
RESULT=$(curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
  -H "X-Auth-Email: ${CF_ID}" \
  -H "X-Auth-Key: ${CF_KEY}" \
  -H "Content-Type: application/json" \
  --data '{"type":"A","name":"'"${dns}"'","content":"'"${IP}"'","ttl":120,"proxied":false}')

RESULT2=$(curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD2}" \
  -H "X-Auth-Email: ${CF_ID}" \
  -H "X-Auth-Key: ${CF_KEY}" \
  -H "Content-Type: application/json" \
  --data '{"type":"A","name":"'"${dns2}"'","content":"'"${IP}"'","ttl":120,"proxied":false}')

# Simpan domain ke beberapa file konfigurasi
echo "$dns" > /root/domain
echo "$dns" > /etc/xray/domain
echo "$dns" > /etc/v2ray/domain
echo "IP=$dns" > /var/lib/ipvps.conf

# Kembali ke direktori home
cd