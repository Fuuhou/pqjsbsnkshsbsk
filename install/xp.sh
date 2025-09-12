#!/bin/bash
set -euo pipefail

# Konfigurasi Telegram
CHAT_ID=$(cat /etc/perlogin/id)
KEY=$(cat /etc/perlogin/token)
URL="https://api.telegram.org/bot${KEY}/sendMessage"
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
TIMEOUT=10

# Bersihkan file trial dan cache
rm -f /trial*
echo 1 > /proc/sys/vm/drop_caches

# Fungsi untuk mengirim notifikasi Telegram
send_telegram_notification() {
    local user=$1
    local exp=$2
    local proto=$3
    local text="
━━━━━━━━━━━━━━━━━━━━
<b>NOTIFIKASI EXPIRED</b>
━━━━━━━━━━━━━━━━━━━━
<b>Protokol :</b> ${proto}
<b>ISP :</b> ${ISP}
<b>Kota :</b> ${CITY}
<b>Username :</b> ${user}
<b>Expired :</b> ${exp}
━━━━━━━━━━━━━━━━━━━━
<i>Akun Xray akan dihapus jika tidak di-restore dalam 7 hari.</i>
"
    curl -s --max-time "${TIMEOUT}" -d "chat_id=${CHAT_ID}&disable_web_page_preview=1&text=${text}&parse_mode=html" "${URL}" > /dev/null
}

# Fungsi untuk menghapus akun dari file akundelete jika sudah lebih dari 7 hari
hapus_akun_lebih_7_hari() {
    local file=$1
    local current_date=$(date +%s)
    local temp_file=$(mktemp)

    while IFS=' ' read -r line; do
        if [[ "$line" =~ ^###\ ([^ ]+)\ ([^ ]+)\ ([^ ]+) ]]; then
            username="${BASH_REMATCH[1]}"
            exp_date="${BASH_REMATCH[2]}"
            uuid="${BASH_REMATCH[3]}"
            exp_ts=$(date -d "$exp_date" +%s)
            diff_days=$(( (current_date - exp_ts) / 86400 ))

            if (( diff_days <= 7 )); then
                echo "$line" >> "$temp_file"
            fi
        fi
    done < "$file"

    mv "$temp_file" "$file"
}

# Fungsi untuk menghapus akun sistem
hapus_akun_sistem() {
    local today=$(date +%s)
    local temp_file=$(mktemp)

    if [[ -f /etc/shadow ]]; then
        grep -v ':$' /etc/shadow | cut -d: -f1,8 > "$temp_file"
        while IFS=':' read -r username userexp; do
            exp_time=$(( userexp * 86400 ))
            if (( exp_time < today )); then
                userdel --force "$username" 2>/dev/null
            fi
        done < "$temp_file"
        rm -f "$temp_file"
    fi
}

# Fungsi untuk menghapus akun SSH
hapus_akun_ssh() {
    local now=$(date +"%Y-%m-%d")
    for user in $(grep '^###' /etc/xray/ssh | awk '{print $2}' | sort -u); do
        exp=$(grep -w "^### $user" /etc/xray/ssh | awk '{print $3}' | sort -u)
        pass=$(grep -w "^### $user" /etc/xray/ssh | awk '{print $4}' | sort -u)
        if (( $(date -d "$exp" +%s) <= $(date -d "$now" +%s) )); then
            send_telegram_notification "$user" "$exp" "SSH"
            sed -i "/^### $user $exp $pass/d" /etc/xray/ssh
            getent passwd "$user" &> /dev/null && userdel "$user" 2>/dev/null
            rm -f /home/vps/public_html/ssh-${user}.txt \
                  /etc/xray/sshx/${user}IP \
                  /etc/xray/sshx/${user}login
        fi
    done
}

# Fungsi untuk menghapus akun VMess
hapus_akun_vmess() {
    local now=$(date +"%Y-%m-%d")
    for user in $(grep '^#vmg' /etc/xray/config.json | awk '{print $2}' | sort -u); do
        exp=$(grep -w "^#vmg $user" /etc/xray/config.json | awk '{print $3}' | sort -u)
        uuid=$(grep -w "^#vmg $user" /etc/xray/config.json | awk '{print $4}' | sort -u)
        if (( $(date -d "$exp" +%s) <= $(date -d "$now" +%s) )); then
            send_telegram_notification "$user" "$exp" "VMess"
            echo "### $user $exp $uuid" >> /etc/vmess/akundelete
            sed -i "/^#vmg $user $exp/,/^},{/d" /etc/xray/config.json
            sed -i "/^#vm $user $exp/,/^},{/d" /etc/xray/config.json
            rm -f /etc/xray/${user}-tls.json \
                  /etc/xray/${user}-none.json \
                  /home/vps/public_html/vmess-${user}.txt \
                  /etc/vmess/${user}IP \
                  /etc/vmess/${user}quota \
                  /etc/vmess/${user}login
        fi
    done
}

# Fungsi untuk menghapus akun VLess
hapus_akun_vless() {
    local now=$(date +"%Y-%m-%d")
    for user in $(grep '^#vlg' /etc/xray/config.json | awk '{print $2}' | sort -u); do
        exp=$(grep -w "^#vlg $user" /etc/xray/config.json | awk '{print $3}' | sort -u)
        uuid=$(grep -w "^#vlg $user" /etc/xray/config.json | awk '{print $4}' | sort -u)
        if (( $(date -d "$exp" +%s) <= $(date -d "$now" +%s) )); then
            send_telegram_notification "$user" "$exp" "VLess"
            echo "### $user $exp $uuid" >> /etc/vless/akundelete
            sed -i "/^#vlg $user $exp/,/^},{/d" /etc/xray/config.json
            sed -i "/^#vl $user $exp/,/^},{/d" /etc/xray/config.json
            rm -f /home/vps/public_html/vless-${user}.txt \
                  /etc/vless/${user}IP \
                  /etc/vless/${user}quota \
                  /etc/vless/${user}login
        fi
    done
}

# Fungsi untuk menghapus akun Trojan
hapus_akun_trojan() {
    local now=$(date +"%Y-%m-%d")
    for user in $(grep '^#trg' /etc/xray/config.json | awk '{print $2}' | sort -u); do
        exp=$(grep -w "^#trg $user" /etc/xray/config.json | awk '{print $3}' | sort -u)
        uuid=$(grep -w "^#trg $user" /etc/xray/config.json | awk '{print $4}' | sort -u)
        if (( $(date -d "$exp" +%s) <= $(date -d "$now" +%s) )); then
            send_telegram_notification "$user" "$exp" "Trojan"
            echo "### $user $exp $uuid" >> /etc/trojan/akundelete
            sed -i "/^#tr $user $exp/,/^},{/d" /etc/xray/config.json
            sed -i "/^#trg $user $exp/,/^},{/d" /etc/xray/config.json
            rm -f /home/vps/public_html/trojan-${user}.txt \
                  /etc/trojan/${user}IP \
                  /etc/trojan/${user}quota \
                  /etc/trojan/${user}login
        fi
    done
}

# Main execution
touch /etc/vless/akundelete /etc/vmess/akundelete /etc/trojan/akundelete

hapus_akun_ssh
hapus_akun_vmess
hapus_akun_vless
hapus_akun_trojan
hapus_akun_sistem

hapus_akun_lebih_7_hari "/etc/vless/akundelete"
hapus_akun_lebih_7_hari "/etc/vmess/akundelete"
hapus_akun_lebih_7_hari "/etc/trojan/akundelete"

# Restart layanan Xray
systemctl restart xray
