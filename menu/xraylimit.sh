#!/bin/bash

# Bersihkan layar
clear

# Cek jumlah proses bash dari script ini, jika lebih dari 20, matikan semua
SCRIPT_NAME="$(basename "$0")"
if [[ $(pgrep -fc "bash $SCRIPT_NAME") -gt 20 ]]; then
    pkill -f "bash $SCRIPT_NAME"
fi

# Membaca data dari file konfigurasi
CHAT_ID2=$(cat /etc/perlogin/id)
KEY=$(cat /etc/perlogin/token)
URL="https://api.telegram.org/bot${KEY}/sendMessage"
DOMAINZ=$(cat /etc/xray/domain)
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
DATE=$(date +"%Y-%m-%d")
TIME=$(date +"%H:%M:%S")
LOCK_MINUTES=$(cat /etc/waktulock 2>/dev/null || echo "")
TIMES="10"

# Inisialisasi nilai default jika variabel kosong
if [[ -z "$LOCK_MINUTES" ]]; then
    LOCK_MINUTES=10
    echo "$LOCK_MINUTES" > /etc/waktulock
fi

timenow=$(date +"%H:%M:%S")

# Fungsi: Mengubah waktu format HH:MM:SS menjadi total detik
tim2sec() {
    local time="$1"
    IFS=: read -r hh mm ss <<< "$time"
    hh=${hh#0}; mm=${mm#0}; ss=${ss#0}
    hh=${hh:-0}; mm=${mm:-0}; ss=${ss:-0}
    echo $((hh * 3600 + mm * 60 + ss))
}


# Fungsi utama untuk memeriksa multi login VMess
vmess() {
    # Inisialisasi direktori dan file
    mkdir -p /etc/limit/vmess /etc/vmess/{backup,ip_logs} || return 1
    find /etc/vmess/ip_logs -type f -mtime +7 -delete 2>/dev/null
    rm -f /tmp/vmess 2>/dev/null

    # Dapatkan daftar user yang aktif
    users=($(grep "^#vmg" /etc/xray/config.json | awk '{print $2}' | sort -u)) || return 1

    for user in "${users[@]}"; do
        # Bersihkan variabel untuk setiap iterasi
        unset ip_map
        declare -A ip_map
        ip_count=0

        # Dapatkan entri log terbaru (150 baris terakhir)
        log_entries=$(grep -w "email: ${user}" /var/log/xray/access.log | tail -n 150) || continue

        # Proses setiap entri log
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue

            # Ekstrak informasi dari log
            timestamp=$(echo "$line" | awk '{print $2}' | sed 's/\//-/g; s/:/ /')
            ip=$(echo "$line" | awk '{print $3}' | cut -d':' -f1)
            [[ -z "$ip" || -z "$timestamp" ]] && continue

            # Konversi waktu dan hitung selisih
            now=$(date +%s)
            login_time=$(tim2sec "$timestamp")
            [[ "$login_time" -eq 0 ]] && continue
            diff_time=$((now - login_time))

            # Filter IP yang sama/mirip (CIDR /24 untuk IPv4)
            ip_base=$(echo "$ip" | awk -F. '{print $1"."$2"."$3".0/24"}')
            
            # Skip jika IP sudah tercatat atau waktu login terlalu dekat
            if [[ $diff_time -lt 60 ]] && [[ -z "${ip_map[$ip_base]}" ]]; then
                ip_map["$ip_base"]="$timestamp"
                echo "$user $timestamp $ip" >> /tmp/vmess
            fi
        done <<< "$log_entries"

        # Simpan log IP dengan format yang lebih baik
        ip_count=${#ip_map[@]}
        if [[ $ip_count -gt 0 ]]; then
            {
                for ip_base in "${!ip_map[@]}"; do
                    echo "${ip_map[$ip_base]} ${ip_base}"
                done
            } > "/etc/vmess/ip_logs/${user}_$(date +%Y%m%d)"
        fi

        # Baca limit IP dari file atau gunakan default
        ip_limit_file="/etc/vmess/${user}IP"
        [[ ! -f "$ip_limit_file" ]] && echo "2" > "$ip_limit_file"
        ip_limit=$(cat "$ip_limit_file" 2>/dev/null || echo "2")

        # Proses jika melebihi limit
        if (( ip_count > ip_limit )); then
            # Dapatkan info user dari config
            user_info=$(grep -wE "^#vmg $user" /etc/xray/config.json | head -n1)
            [[ -z "$user_info" ]] && continue

            exp=$(echo "$user_info" | awk '{print $3}')
            uuid=$(echo "$user_info" | awk '{print $4}')
            lock_file="/etc/vmess/listlock"
            lock_entry="### $user $exp $uuid"

            # Cek apakah user sudah di-lock sebelumnya
            if ! grep -qF "$lock_entry" "$lock_file" 2>/dev/null; then
                echo "$lock_entry" >> "$lock_file"
                echo "$(date +%s)" > "/etc/vmess/locktime_${user}"

                # Backup konfigurasi user
                mkdir -p "/etc/vmess/backup/${user}"
                grep -A100 -B1 "\"email\": \"${user}\"" /etc/xray/config.json > "/etc/vmess/backup/${user}/config_backup.json" 2>/dev/null

                # Hapus konfigurasi dari config.json
                sed -i "/\"email\": \"${user}\"/,/^},{/d" /etc/xray/config.json
                systemctl restart xray
                passwd -l "$user" 2>/dev/null

                # Notifikasi Telegram (jika diaktifkan)
                if [[ -n "$CHAT_ID2" && -n "$URL" ]]; then
                    login_list=$(awk '{printf "%s » %s\n", $2, $3}' "/etc/vmess/ip_logs/${user}_$(date +%Y%m%d)" | head -n 10)
                    total_login=$ip_count
                    sisa=$((total_login - 10))
                    extra_msg=""
                    [[ $sisa -gt 0 ]] && extra_msg="\nDan $sisa IP login lainnya..."

                    TEXT2="
━━━━━━━━━━━━━━━━━━━━
<b>NOTIFIKASI MULTILOGIN</b>
━━━━━━━━━━━━━━━━━━━━
<b>Protokol :</b> VMess
<b>ISP :</b> ${ISP}
<b>Kota :</b> ${CITY}
<b>Username :</b> ${user}
<b>Jumlah Login :</b> ${ip_count} IP
━━━━━━━━━━━━━━━━━━━━
<b>Waktu ≈ IP</b>
<pre>${login_list}</pre>
${extra_msg}
━━━━━━━━━━━━━━━━━━━━
<i>Auto-unlock dalam ${LOCK_MINUTES} menit.</i>
"
                    curl -s --max-time 10 -d "chat_id=${CHAT_ID2}&disable_web_page_preview=1&text=$(echo "$TEXT2" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')&parse_mode=html" "$URL" > /dev/null
                fi

                # Setup auto-unlock
                setup_auto_unlock_vmess "$user" "$exp" "$uuid"
            fi
        fi
    done

    # Bersihkan file temporary
    rm -f /tmp/vmess 2>/dev/null
}

# Fungsi untuk setup auto-unlock
setup_auto_unlock_vmess() {
    local user="$1"
    local exp="$2"
    local uuid="$3"
    
    cat > "/etc/cron.d/vmess_lock_${user}" <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/1 * * * * root /usr/local/bin/vmess_unlock.sh "${user}" "${exp}" "${uuid}"
EOF

    # Buat script unlock terpisah
    cat > "/usr/local/bin/vmess_unlock.sh" <<'EOF'
#!/bin/bash
user="$1"
exp="$2"
uuid="$3"

if [ -f "/etc/vmess/locktime_${user}" ]; then
    lock_ts=$(cat "/etc/vmess/locktime_${user}")
    now_ts=$(date +%s)
    if [ $(( (now_ts - lock_ts) / 60 )) -ge 10 ]; then
        # Unlock user
        passwd -u "$user" 2>/dev/null
        
        # Restore konfigurasi
        if [ -f "/etc/vmess/backup/${user}/config_backup.json" ]; then
            sed -i "/#vmess\$/r /etc/vmess/backup/${user}/config_backup.json" /etc/xray/config.json
            systemctl restart xray
        fi
        
        # Bersihkan file lock
        rm -f "/etc/vmess/locktime_${user}" "/etc/cron.d/vmess_lock_${user}"
        sed -i "/### $user $exp $uuid/d" /etc/vmess/listlock
        rm -rf "/etc/vmess/backup/${user}"
    fi
fi
EOF

    chmod +x "/usr/local/bin/vmess_unlock.sh"
    systemctl restart cron
}


# Fungsi utama untuk memeriksa multi login VLess
vless() {
    # Inisialisasi direktori dan file
    mkdir -p /etc/limit/vless /etc/vless/{backup,ip_logs} || return 1
    find /etc/vless/ip_logs -type f -mtime +7 -delete 2>/dev/null
    rm -f /tmp/vless 2>/dev/null

    # Dapatkan daftar user yang aktif
    users=($(grep "^#vlg" /etc/xray/config.json | awk '{print $2}' | sort -u)) || return 1

    for user in "${users[@]}"; do
        # Bersihkan variabel untuk setiap iterasi
        unset ip_map
        declare -A ip_map
        ip_count=0

        # Dapatkan entri log terbaru (150 baris terakhir)
        log_entries=$(grep -w "email: ${user}" /var/log/xray/access.log | tail -n 150) || continue

        # Proses setiap entri log
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue

            # Ekstrak informasi dari log
            timestamp=$(echo "$line" | awk '{print $2}' | sed 's/\//-/g; s/:/ /')
            ip=$(echo "$line" | awk '{print $3}' | cut -d':' -f1)
            [[ -z "$ip" || -z "$timestamp" ]] && continue

            # Konversi waktu dan hitung selisih
            now=$(date +%s)
            login_time=$(tim2sec "$timestamp")
            [[ "$login_time" -eq 0 ]] && continue
            diff_time=$((now - login_time))

            # Filter IP yang sama/mirip (CIDR /24 untuk IPv4)
            ip_base=$(echo "$ip" | awk -F. '{print $1"."$2"."$3".0/24"}')
            
            # Skip jika IP sudah tercatat atau waktu login terlalu dekat
            if [[ $diff_time -lt 60 ]] && [[ -z "${ip_map[$ip_base]}" ]]; then
                ip_map["$ip_base"]="$timestamp"
                echo "$user $timestamp $ip" >> /tmp/vless
            fi
        done <<< "$log_entries"

        # Simpan log IP dengan format yang lebih baik
        ip_count=${#ip_map[@]}
        if [[ $ip_count -gt 0 ]]; then
            {
                for ip_base in "${!ip_map[@]}"; do
                    echo "${ip_map[$ip_base]} ${ip_base}"
                done
            } > "/etc/vless/ip_logs/${user}_$(date +%Y%m%d)"
        fi

        # Baca limit IP dari file atau gunakan default
        ip_limit_file="/etc/vless/${user}IP"
        [[ ! -f "$ip_limit_file" ]] && echo "2" > "$ip_limit_file"
        ip_limit=$(cat "$ip_limit_file" 2>/dev/null || echo "2")

        # Proses jika melebihi limit
        if (( ip_count > ip_limit )); then
            # Dapatkan info user dari config
            user_info=$(grep -wE "^#vlg $user" /etc/xray/config.json | head -n1)
            [[ -z "$user_info" ]] && continue

            exp=$(echo "$user_info" | awk '{print $3}')
            uuid=$(echo "$user_info" | awk '{print $4}')
            lock_file="/etc/vless/listlock"
            lock_entry="### $user $exp $uuid"

            # Cek apakah user sudah di-lock sebelumnya
            if ! grep -qF "$lock_entry" "$lock_file" 2>/dev/null; then
                echo "$lock_entry" >> "$lock_file"
                echo "$(date +%s)" > "/etc/vless/locktime_${user}"

                # Backup konfigurasi user
                mkdir -p "/etc/vless/backup/${user}"
                grep -A100 -B1 "\"email\": \"${user}\"" /etc/xray/config.json > "/etc/vless/backup/${user}/config_backup.json" 2>/dev/null

                # Hapus konfigurasi dari config.json
                sed -i "/\"email\": \"${user}\"/,/^},{/d" /etc/xray/config.json
                systemctl restart xray
                passwd -l "$user" 2>/dev/null

                # Notifikasi Telegram (jika diaktifkan)
                if [[ -n "$CHAT_ID2" && -n "$URL" ]]; then
                    login_list=$(awk '{printf "%s » %s\n", $2, $3}' "/etc/vless/ip_logs/${user}_$(date +%Y%m%d)" | head -n 10)
                    total_login=$ip_count
                    sisa=$((total_login - 10))
                    extra_msg=""
                    [[ $sisa -gt 0 ]] && extra_msg="\nDan $sisa IP login lainnya..."

                    TEXT2="
━━━━━━━━━━━━━━━━━━━━
<b>NOTIFIKASI MULTILOGIN</b>
━━━━━━━━━━━━━━━━━━━━
<b>Protokol :</b> VLess
<b>ISP :</b> ${ISP}
<b>Kota :</b> ${CITY}
<b>Username :</b> ${user}
<b>Jumlah Login :</b> ${ip_count} IP
━━━━━━━━━━━━━━━━━━━━
<b>Waktu ≈ IP</b>
<pre>${login_list}</pre>
${extra_msg}
━━━━━━━━━━━━━━━━━━━━
<i>Auto-unlock dalam ${LOCK_MINUTES} menit.</i>
"
                    curl -s --max-time 10 -d "chat_id=${CHAT_ID2}&disable_web_page_preview=1&text=$(echo "$TEXT2" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')&parse_mode=html" "$URL" > /dev/null
                fi

                # Setup auto-unlock
                setup_auto_unlock_vless "$user" "$exp" "$uuid"
            fi
        fi
    done

    # Bersihkan file temporary
    rm -f /tmp/vless 2>/dev/null
}

# Fungsi untuk setup auto-unlock
setup_auto_unlock_vless() {
    local user="$1"
    local exp="$2"
    local uuid="$3"
    
    cat > "/etc/cron.d/vless_lock_${user}" <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/1 * * * * root /usr/local/bin/vless_unlock.sh "${user}" "${exp}" "${uuid}"
EOF

    # Buat script unlock terpisah
    cat > "/usr/local/bin/vless_unlock.sh" <<'EOF'
#!/bin/bash
user="$1"
exp="$2"
uuid="$3"

if [ -f "/etc/vless/locktime_${user}" ]; then
    lock_ts=$(cat "/etc/vless/locktime_${user}")
    now_ts=$(date +%s)
    if [ $(( (now_ts - lock_ts) / 60 )) -ge 10 ]; then
        # Unlock user
        passwd -u "$user" 2>/dev/null
        
        # Restore konfigurasi
        if [ -f "/etc/vless/backup/${user}/config_backup.json" ]; then
            sed -i "/#vless\$/r /etc/vless/backup/${user}/config_backup.json" /etc/xray/config.json
            systemctl restart xray
        fi
        
        # Bersihkan file lock
        rm -f "/etc/vless/locktime_${user}" "/etc/cron.d/vless_lock_${user}"
        sed -i "/### $user $exp $uuid/d" /etc/vless/listlock
        rm -rf "/etc/vless/backup/${user}"
    fi
fi
EOF

    chmod +x "/usr/local/bin/vless_unlock.sh"
    systemctl restart cron
}


# Fungsi utama untuk memeriksa multi login trojan
trojan() {
    # Inisialisasi direktori dan file
    mkdir -p /etc/limit/trojan /etc/trojan/{backup,ip_logs} || return 1
    find /etc/trojan/ip_logs -type f -mtime +7 -delete 2>/dev/null
    rm -f /tmp/trojan 2>/dev/null

    # Dapatkan daftar user yang aktif
    users=($(grep "^#trg" /etc/xray/config.json | awk '{print $2}' | sort -u)) || return 1

    for user in "${users[@]}"; do
        # Bersihkan variabel untuk setiap iterasi
        unset ip_map
        declare -A ip_map
        ip_count=0

        # Dapatkan entri log terbaru (150 baris terakhir)
        log_entries=$(grep -w "email: ${user}" /var/log/xray/access.log | tail -n 150) || continue

        # Proses setiap entri log
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue

            # Ekstrak informasi dari log
            timestamp=$(echo "$line" | awk '{print $2}' | sed 's/\//-/g; s/:/ /')
            ip=$(echo "$line" | awk '{print $3}' | cut -d':' -f1)
            [[ -z "$ip" || -z "$timestamp" ]] && continue

            # Konversi waktu dan hitung selisih
            now=$(date +%s)
            login_time=$(tim2sec "$timestamp")
            [[ "$login_time" -eq 0 ]] && continue
            diff_time=$((now - login_time))

            # Filter IP yang sama/mirip (CIDR /24 untuk IPv4)
            ip_base=$(echo "$ip" | awk -F. '{print $1"."$2"."$3".0/24"}')
            
            # Skip jika IP sudah tercatat atau waktu login terlalu dekat
            if [[ $diff_time -lt 60 ]] && [[ -z "${ip_map[$ip_base]}" ]]; then
                ip_map["$ip_base"]="$timestamp"
                echo "$user $timestamp $ip" >> /tmp/trojan
            fi
        done <<< "$log_entries"

        # Simpan log IP dengan format yang lebih baik
        ip_count=${#ip_map[@]}
        if [[ $ip_count -gt 0 ]]; then
            {
                for ip_base in "${!ip_map[@]}"; do
                    echo "${ip_map[$ip_base]} ${ip_base}"
                done
            } > "/etc/trojan/ip_logs/${user}_$(date +%Y%m%d)"
        fi

        # Baca limit IP dari file atau gunakan default
        ip_limit_file="/etc/trojan/${user}IP"
        [[ ! -f "$ip_limit_file" ]] && echo "2" > "$ip_limit_file"
        ip_limit=$(cat "$ip_limit_file" 2>/dev/null || echo "2")

        # Proses jika melebihi limit
        if (( ip_count > ip_limit )); then
            # Dapatkan info user dari config
            user_info=$(grep -wE "^#trg $user" /etc/xray/config.json | head -n1)
            [[ -z "$user_info" ]] && continue

            exp=$(echo "$user_info" | awk '{print $3}')
            uuid=$(echo "$user_info" | awk '{print $4}')
            lock_file="/etc/trojan/listlock"
            lock_entry="### $user $exp $uuid"

            # Cek apakah user sudah di-lock sebelumnya
            if ! grep -qF "$lock_entry" "$lock_file" 2>/dev/null; then
                echo "$lock_entry" >> "$lock_file"
                echo "$(date +%s)" > "/etc/trojan/locktime_${user}"

                # Backup konfigurasi user
                mkdir -p "/etc/trojan/backup/${user}"
                grep -A100 -B1 "\"email\": \"${user}\"" /etc/xray/config.json > "/etc/trojan/backup/${user}/config_backup.json" 2>/dev/null

                # Hapus konfigurasi dari config.json
                sed -i "/\"email\": \"${user}\"/,/^},{/d" /etc/xray/config.json
                systemctl restart xray
                passwd -l "$user" 2>/dev/null

                # Notifikasi Telegram (jika diaktifkan)
                if [[ -n "$CHAT_ID2" && -n "$URL" ]]; then
                    login_list=$(awk '{printf "%s » %s\n", $2, $3}' "/etc/trojan/ip_logs/${user}_$(date +%Y%m%d)" | head -n 10)
                    total_login=$ip_count
                    sisa=$((total_login - 10))
                    extra_msg=""
                    [[ $sisa -gt 0 ]] && extra_msg="\nDan $sisa IP login lainnya..."

                    TEXT2="
━━━━━━━━━━━━━━━━━━━━
<b>NOTIFIKASI MULTILOGIN</b>
━━━━━━━━━━━━━━━━━━━━
<b>Protokol :</b> Trojan
<b>ISP :</b> ${ISP}
<b>Kota :</b> ${CITY}
<b>Username :</b> ${user}
<b>Jumlah Login :</b> ${ip_count} IP
━━━━━━━━━━━━━━━━━━━━
<b>Waktu ≈ IP</b>
<pre>${login_list}</pre>
${extra_msg}
━━━━━━━━━━━━━━━━━━━━
<i>Auto-unlock dalam ${LOCK_MINUTES} menit.</i>
"
                    curl -s --max-time 10 -d "chat_id=${CHAT_ID2}&disable_web_page_preview=1&text=$(echo "$TEXT2" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')&parse_mode=html" "$URL" > /dev/null
                fi

                # Setup auto-unlock
                setup_auto_unlock_trojan "$user" "$exp" "$uuid"
            fi
        fi
    done

    # Bersihkan file temporary
    rm -f /tmp/trojan 2>/dev/null
}

# Fungsi untuk setup auto-unlock
setup_auto_unlock_trojan() {
    local user="$1"
    local exp="$2"
    local uuid="$3"
    
    cat > "/etc/cron.d/trojan_lock_${user}" <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/1 * * * * root /usr/local/bin/trojan_unlock.sh "${user}" "${exp}" "${uuid}"
EOF

    # Buat script unlock terpisah
    cat > "/usr/local/bin/trojan_unlock.sh" <<'EOF'
#!/bin/bash
user="$1"
exp="$2"
uuid="$3"

if [ -f "/etc/trojan/locktime_${user}" ]; then
    lock_ts=$(cat "/etc/trojan/locktime_${user}")
    now_ts=$(date +%s)
    if [ $(( (now_ts - lock_ts) / 60 )) -ge 10 ]; then
        # Unlock user
        passwd -u "$user" 2>/dev/null
        
        # Restore konfigurasi
        if [ -f "/etc/trojan/backup/${user}/config_backup.json" ]; then
            sed -i "/#trojan\$/r /etc/trojan/backup/${user}/config_backup.json" /etc/xray/config.json
            systemctl restart xray
        fi
        
        # Bersihkan file lock
        rm -f "/etc/trojan/locktime_${user}" "/etc/cron.d/trojan_lock_${user}"
        sed -i "/### $user $exp $uuid/d" /etc/trojan/listlock
        rm -rf "/etc/trojan/backup/${user}"
    fi
fi
EOF

    chmod +x "/usr/local/bin/trojan_unlock.sh"
    systemctl restart cron
}


vmess
vless
trojan
