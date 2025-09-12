#!/bin/bash

# Install required tools
apt install jq curl -y

# Set variables
DOMAIN="wixie.biz.id"
sub=$(cat /root/subdomainx)
dns="${sub}.${DOMAIN}"
dns2="*.${sub}.${DOMAIN}"
CF_ID="qoshdhdw81@gmail.com"
CF_KEY="wisjdhbds"
set -euo pipefail

# Get the server's public IP
IP=$(wget -qO- icanhazip.com)

echo "Updating DNS for ${dns}..."

# Get the Zone ID for the domain
ZONE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
    -H "X-Auth-Email: ${CF_ID}" \
    -H "X-Auth-Key: ${CF_KEY}" \
    -H "Content-Type: application/json" | jq -r '.result[0].id')

# Get the DNS record ID for the subdomain
RECORD=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${dns}" \
    -H "X-Auth-Email: ${CF_ID}" \
    -H "X-Auth-Key: ${CF_KEY}" \
    -H "Content-Type: application/json" | jq -r '.result[0].id')

# If the record doesn't exist, create it
if [[ "${#RECORD}" -le 10 ]]; then
    echo "Creating DNS record for ${dns}..."
    RECORD=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
        -H "X-Auth-Email: ${CF_ID}" \
        -H "X-Auth-Key: ${CF_KEY}" \
        -H "Content-Type: application/json" \
        --data '{"type":"A","name":"'${dns}'","content":"'${IP}'","ttl":120,"proxied":false}' | jq -r '.result.id')

    echo "Creating DNS record for ${dns2}..."
    RECORD2=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
        -H "X-Auth-Email: ${CF_ID}" \
        -H "X-Auth-Key: ${CF_KEY}" \
        -H "Content-Type: application/json" \
        --data '{"type":"A","name":"'${dns2}'","content":"'${IP}'","ttl":120,"proxied":false}' | jq -r '.result.id')
fi

# Update the DNS record if it already exists
echo "Updating DNS record for ${dns}..."
RESULT=$(curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
    -H "X-Auth-Email: ${CF_ID}" \
    -H "X-Auth-Key: ${CF_KEY}" \
    -H "Content-Type: application/json" \
    --data '{"type":"A","name":"'${dns}'","content":"'${IP}'","ttl":120,"proxied":false}')

echo "Updating DNS record for ${dns2}..."
RESULT2=$(curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD2}" \
    -H "X-Auth-Email: ${CF_ID}" \
    -H "X-Auth-Key: ${CF_KEY}" \
    -H "Content-Type: application/json" \
    --data '{"type":"A","name":"'${dns2}'","content":"'${IP}'","ttl":120,"proxied":false}')

# Save the domain to files
echo "${dns}" > /root/domain
echo "${dns}" > /etc/xray/domain
echo "${dns}" > /etc/v2ray/domain
echo "IP=${IP}" > /var/lib/ipvps.conf

echo "DNS setup completed successfully."