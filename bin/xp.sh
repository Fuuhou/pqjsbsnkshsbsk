#!/bin/bash

KEY=$(cat /etc/per/token)
NOTIFICATION_LOG_DIR="/etc/xray/notifications"

# Bersihkan file sementara
rm -f trial*

# Mengatur cache
echo 1 > /proc/sys/vm/drop_caches

# Fungsi untuk mengirim notifikasi ke Telegram
function send_telegram_notification() {
    local telegram_id=$1
    local message=$2
    curl -s -X POST \
        "https://api.telegram.org/bot${KEY}/sendMessage" \
        -d chat_id="${telegram_id}" \
        -d text="${message}" \
        -d parse_mode="HTML" >/dev/null
}

# Fungsi untuk mencatat notifikasi harian agar tidak terkirim lebih dari 1 kali per hari
function check_daily_notification() {
    local service=$1
    local user=$2
    local telegram_id=$3
    local days_left=$4
    
    mkdir -p "${NOTIFICATION_LOG_DIR}"
    local log_file="${NOTIFICATION_LOG_DIR}/${service}_${user}.log"
    local today
    today=$(date +"%Y-%m-%d")
    
    if [[ ! -f "${log_file}" ]] || ! grep -q "${today}" "${log_file}"; then
        local message="⚠️ <b>PEMBERITAHUAN MASA AKTIF</b> ⚠️
--------------------------------------
Layanan: <b>${service^^}</b>
Username: <code>${user}</code>
Sisa masa aktif: <b>${days_left} hari</b>
--------------------------------------
Perpanjang layanan sebelum kadaluarsa!"
        send_telegram_notification "${telegram_id}" "${message}"
        echo "${today}" >> "${log_file}"
    fi
}

# Fungsi untuk mengirim notifikasi bahwa akun sudah kadaluarsa dan dihapus
function send_expired_notification() {
    local service=$1
    local user=$2
    local telegram_id=$3
    local exp=$4
    
    local message="❌ <b>Pemberitahuan Kadaluarsa</b> ❌
--------------------------------------
Layanan: <b>${service^^}</b>
Username: <code>${user}</code>
Tanggal Kadaluarsa: <b>${exp}</b>
--------------------------------------
Akun telah kadaluarsa dan dihapus!"
    send_telegram_notification "${telegram_id}" "${message}"
}

#############################
# Pengecekan masa aktif akun
#############################

# Fungsi cek masa aktif SSH
function check_expiring_ssh() {
    local users
    users=($(awk -F'[{}]' '/^#ssh{/ {print $2"%"$3}' /etc/xray/ssh | sort -u))
    local now
    now=$(date +"%Y-%m-%d")

    for user_data in "${users[@]}"; do
        IFS='%' read -r telegram_id user <<< "${user_data}"
        local user_info
        user_info=$(grep -E "^#ssh\{${telegram_id}\} ${user} " /etc/xray/ssh)
        local exp
        exp=$(echo "$user_info" | awk '{print $3}')
        
        local d1 d2 days_left
        d1=$(date -d "$exp" +%s)
        d2=$(date -d "$now" +%s)
        days_left=$(( (d1 - d2) / 86400 ))
        
        if [[ "$days_left" -le 3 && "$days_left" -gt 0 ]]; then
            check_daily_notification "ssh" "$user" "$telegram_id" "$days_left"
        fi
    done
}

# Fungsi cek masa aktif VMESS
function check_expiring_vmess() {
    local users
    users=($(awk -F'[{}]' '/^#vmg{/ {print $2"%"$3}' /etc/xray/config.json | sort -u))
    local now
    now=$(date +"%Y-%m-%d")

    for user_data in "${users[@]}"; do
        IFS='%' read -r telegram_id user <<< "${user_data}"
        local user_info
        user_info=$(grep -E "^#vmg\{${telegram_id}\} ${user} " /etc/xray/config.json)
        local exp
        exp=$(echo "$user_info" | awk '{print $3}')
        
        local d1 d2 days_left
        d1=$(date -d "$exp" +%s)
        d2=$(date -d "$now" +%s)
        days_left=$(( (d1 - d2) / 86400 ))
        
        if [[ "$days_left" -le 3 && "$days_left" -gt 0 ]]; then
            check_daily_notification "vmess" "$user" "$telegram_id" "$days_left"
        fi
    done
}

# Fungsi cek masa aktif VLESS
function check_expiring_vless() {
    local users
    users=($(awk -F'[{}]' '/^#vlg{/ {print $2"%"$3}' /etc/xray/config.json | sort -u))
    local now
    now=$(date +"%Y-%m-%d")

    for user_data in "${users[@]}"; do
        IFS='%' read -r telegram_id user <<< "${user_data}"
        local user_info
        user_info=$(grep -E "^#vlg\{${telegram_id}\} ${user} " /etc/xray/config.json)
        local exp
        exp=$(echo "$user_info" | awk '{print $3}')
        
        local d1 d2 days_left
        d1=$(date -d "$exp" +%s)
        d2=$(date -d "$now" +%s)
        days_left=$(( (d1 - d2) / 86400 ))
        
        if [[ "$days_left" -le 3 && "$days_left" -gt 0 ]]; then
            check_daily_notification "vless" "$user" "$telegram_id" "$days_left"
        fi
    done
}

# Fungsi cek masa aktif Trojan
function check_expiring_trojan() {
    local users
    users=($(awk -F'[{}]' '/^#trg{/ {print $2"%"$3}' /etc/xray/config.json | sort -u))
    local now
    now=$(date +"%Y-%m-%d")

    for user_data in "${users[@]}"; do
        IFS='%' read -r telegram_id user <<< "${user_data}"
        local user_info
        user_info=$(grep -E "^#trg\{${telegram_id}\} ${user} " /etc/xray/config.json)
        local exp
        exp=$(echo "$user_info" | awk '{print $3}')
        
        local d1 d2 days_left
        d1=$(date -d "$exp" +%s)
        d2=$(date -d "$now" +%s)
        days_left=$(( (d1 - d2) / 86400 ))
        
        if [[ "$days_left" -le 3 && "$days_left" -gt 0 ]]; then
            check_daily_notification "trojan" "$user" "$telegram_id" "$days_left"
        fi
    done
}

########################################
# Penghapusan pengguna yang sudah kadaluarsa
########################################

# HAPUS PENGGUNA SSH (DENGAN telegram_id)
function delete_expired_ssh_users_TG() {
    local users
    users=($(awk '/^#ssh{/ {print $2}' /etc/xray/ssh | sort -u))
    local now
    now=$(date +"%Y-%m-%d")

    for user in "${users[@]}"; do
        local user_info
        user_info=$(grep -E "^#ssh\{[^}]+\} ${user} " /etc/xray/ssh)
        # Pastikan ada data yang ditemukan
        if [[ -z "$user_info" ]]; then
            continue
        fi
        local telegram_id
        telegram_id=$(echo "$user_info" | awk -F'[{}]' '{print $2}')
        local exp
        exp=$(echo "$user_info" | awk '{print $3}')
        local pass
        pass=$(echo "$user_info" | awk '{print $4}')
        
        local d1 d2 exp_days
        d1=$(date -d "$exp" +%s)
        d2=$(date -d "$now" +%s)
        exp_days=$(( (d1 - d2) / 86400 ))
        
        if [[ "$exp_days" -le 0 ]]; then
            sed -i "/^#ssh{.*} ${user} ${exp} ${pass}/d" /etc/xray/ssh
            if id "$user" >/dev/null 2>&1; then
                userdel "$user" >/dev/null 2>&1
            fi
            rm -f /home/vps/public_html/ssh-"$user".txt /etc/xray/sshx/"$user"IP /etc/xray/sshx/"$user"login >/dev/null 2>&1
            send_expired_notification "ssh" "$user" "$telegram_id" "$exp"
        fi
    done
}

# HAPUS PENGGUNA VMESS (DENGAN telegram_id)
function delete_expired_vmess_users_TG() {
    local users
    users=($(awk '/^#vms{/ {print $2}' /etc/xray/config.json | sort -u))
    local now
    now=$(date +"%Y-%m-%d")

    for user in "${users[@]}"; do
        local user_info
        user_info=$(grep -E "^#vms\{[^}]+\} ${user} " /etc/xray/config.json)
        if [[ -z "$user_info" ]]; then
            continue
        fi
        local telegram_id
        telegram_id=$(echo "$user_info" | awk -F'[{}]' '{print $2}')
        local exp
        exp=$(echo "$user_info" | awk '{print $3}')
        local uuid
        uuid=$(echo "$user_info" | awk '{print $4}')
        
        local d1 d2 exp_days
        d1=$(date -d "$exp" +%s)
        d2=$(date -d "$now" +%s)
        exp_days=$(( (d1 - d2) / 86400 ))
        
        if [[ "$exp_days" -le 0 ]]; then
            echo "### ${user} ${exp} ${uuid}" >> /etc/vmess/akundelete
            sed -i "/^#vms{.*} ${user} ${exp}/,/^},{/d" /etc/xray/config.json
            rm -f /etc/xray/"${user}"-tls.json /etc/xray/"${user}"-none.json /home/vps/public_html/vmess-"${user}".txt /etc/vmess/"${user}"IP /etc/vmess/"${user}"login >/dev/null 2>&1
            send_expired_notification "vmess" "$user" "$telegram_id" "$exp"
        fi
    done
}

# HAPUS PENGGUNA VLESS (DENGAN telegram_id)
function delete_expired_vless_users_TG() {
    local users
    users=($(awk '/^#vls{/ {print $2}' /etc/xray/config.json | sort -u))
    local now
    now=$(date +"%Y-%m-%d")

    for user in "${users[@]}"; do
        local user_info
        user_info=$(grep -E "^#vls\{[^}]+\} ${user} " /etc/xray/config.json)
        if [[ -z "$user_info" ]]; then
            continue
        fi
        local telegram_id
        telegram_id=$(echo "$user_info" | awk -F'[{}]' '{print $2}')
        local exp
        exp=$(echo "$user_info" | awk '{print $3}')
        local uuid
        uuid=$(echo "$user_info" | awk '{print $4}')
        
        local d1 d2 exp_days
        d1=$(date -d "$exp" +%s)
        d2=$(date -d "$now" +%s)
        exp_days=$(( (d1 - d2) / 86400 ))
        
        if [[ "$exp_days" -le 0 ]]; then
            echo "### ${user} ${exp} ${uuid}" >> /etc/vless/akundelete
            sed -i "/^#vls{.*} ${user} ${exp}/,/^},{/d" /etc/xray/config.json
            rm -f /home/vps/public_html/vless-"${user}".txt /etc/vless/"${user}"IP /etc/vless/"${user}"login >/dev/null 2>&1
            send_expired_notification "vless" "$user" "$telegram_id" "$exp"
        fi
    done
}

# HAPUS PENGGUNA TROJAN (DENGAN telegram_id)
function delete_expired_trojan_users_TG() {
    local users
    users=($(awk '/^#trs{/ {print $2}' /etc/xray/config.json | sort -u))
    local now
    now=$(date +"%Y-%m-%d")

    for user in "${users[@]}"; do
        local user_info
        user_info=$(grep -E "^#trs\{[^}]+\} ${user} " /etc/xray/config.json)
        if [[ -z "$user_info" ]]; then
            continue
        fi
        local telegram_id
        telegram_id=$(echo "$user_info" | awk -F'[{}]' '{print $2}')
        local exp
        exp=$(echo "$user_info" | awk '{print $3}')
        local uuid
        uuid=$(echo "$user_info" | awk '{print $4}')
        
        local d1 d2 exp_days
        d1=$(date -d "$exp" +%s)
        d2=$(date -d "$now" +%s)
        exp_days=$(( (d1 - d2) / 86400 ))
        
        if [[ "$exp_days" -le 0 ]]; then
            echo "### ${user} ${exp} ${uuid}" >> /etc/trojan/akundelete
            sed -i "/^#trs{.*} ${user} ${exp}/,/^},{/d" /etc/xray/config.json
            rm -f /home/vps/public_html/trojan-"${user}".txt /etc/trojan/"${user}"IP /etc/trojan/"${user}"login >/dev/null 2>&1
            send_expired_notification "trojan" "$user" "$telegram_id" "$exp"
        fi
    done
}

# Fungsi untuk menghapus pengguna yang sudah kadaluarsa dari SSH
function delete_expired_ssh_users() {
    local users=($(awk '/^###/ {print $2}' /etc/xray/ssh | sort -u))
    local now=$(date +"%Y-%m-%d")

    for user in "${users[@]}"; do
        local user_info=$(grep -w "^### $user" /etc/xray/ssh)
        local pass=$(echo "$user_info" | awk '{print $4}')
        local exp=$(echo "$user_info" | awk '{print $3}')
        
        local d1=$(date -d "$exp" +%s)
        local d2=$(date -d "$now" +%s)
        local exp_days=$(( (d1 - d2) / 86400 ))

        if [[ "$exp_days" -le 0 ]]; then
            sed -i "/^### $user $exp $pass/d" /etc/xray/ssh
            if id "$user" >/dev/null 2>&1; then
                userdel "$user" >/dev/null 2>&1
            fi
            rm -f /home/vps/public_html/ssh-"$user".txt /etc/xray/sshx/"$user"IP /etc/xray/sshx/"$user"login >/dev/null 2>&1
        fi
    done
}

# Fungsi untuk menghapus pengguna yang sudah kadaluarsa dari Vmess
function delete_expired_vmess_users() {
    local users=($(awk '/^#vmg/ {print $2}' /etc/xray/config.json | sort -u))
    local now=$(date +"%Y-%m-%d")

    for user in "${users[@]}"; do
        local user_info=$(grep -w "^#vmg $user" /etc/xray/config.json)
        local exp=$(echo "$user_info" | awk '{print $3}')
        local uuid=$(echo "$user_info" | awk '{print $4}')
        
        local d1=$(date -d "$exp" +%s)
        local d2=$(date -d "$now" +%s)
        local exp_days=$(( (d1 - d2) / 86400 ))

        if [[ "$exp_days" -le 0 ]]; then
            echo "### $user $exp $uuid" >> /etc/vmess/akundelete
            sed -i "/^#vmg $user $exp/,/^},{/d" /etc/xray/config.json
            rm -f /etc/xray/"$user"-tls.json /etc/xray/"$user"-none.json /home/vps/public_html/vmess-"$user".txt /etc/vmess/"$user"IP /etc/vmess/"$user"login >/dev/null 2>&1
        fi
    done
}

# Fungsi untuk menghapus pengguna yang sudah kadaluarsa dari Vless
function delete_expired_vless_users() {
    local users=($(awk '/^#vlg/ {print $2}' /etc/xray/config.json | sort -u))
    local now=$(date +"%Y-%m-%d")

    for user in "${users[@]}"; do
        local user_info=$(grep -w "^#vlg $user" /etc/xray/config.json)
        local exp=$(echo "$user_info" | awk '{print $3}')
        local uuid=$(echo "$user_info" | awk '{print $4}')
        
        local d1=$(date -d "$exp" +%s)
        local d2=$(date -d "$now" +%s)
        local exp_days=$(( (d1 - d2) / 86400 ))

        if [[ "$exp_days" -le 0 ]]; then
            echo "### $user $exp $uuid" >> /etc/vless/akundelete
            sed -i "/^#vlg $user $exp/,/^},{/d" /etc/xray/config.json
            rm -f /home/vps/public_html/vless-"$user".txt /etc/vless/"$user"IP /etc/vless/"$user"login >/dev/null 2>&1
        fi
    done
}

# Fungsi untuk menghapus pengguna yang sudah kadaluarsa dari Trojan
function delete_expired_trojan_users() {
    local users=($(awk '/^#trg/ {print $2}' /etc/xray/config.json | sort -u))
    local now=$(date +"%Y-%m-%d")

    for user in "${users[@]}"; do
        local user_info=$(grep -w "^#trg $user" /etc/xray/config.json)
        local exp=$(echo "$user_info" | awk '{print $3}')
        local uuid=$(echo "$user_info" | awk '{print $4}')
        
        local d1=$(date -d "$exp" +%s)
        local d2=$(date -d "$now" +%s)
        local exp_days=$(( (d1 - d2) / 86400 ))

        if [[ "$exp_days" -le 0 ]]; then
            echo "### $user $exp $uuid" >> /etc/trojan/akundelete
            sed -i "/^#trg $user $exp/,/^},{/d" /etc/xray/config.json
            rm -f /home/vps/public_html/trojan-"$user".txt /etc/trojan/"$user"IP /etc/trojan/"$user"login >/dev/null 2>&1
        fi
    done
}


####################
# Fungsi Utama (Main)
####################
function main() {
    local restart_needed=0  # Flag untuk menandai apakah Xray perlu direstart

    # Hapus pengguna yang sudah kadaluarsa dan kirim notifikasi expired
    delete_expired_ssh_users_TG && restart_needed=1
    delete_expired_vmess_users_TG && restart_needed=1
    delete_expired_vless_users_TG && restart_needed=1
    delete_expired_trojan_users_TG && restart_needed=1
    delete_expired_ssh_users && restart_needed=1
    delete_expired_vmess_users && restart_needed=1
    delete_expired_vless_users && restart_needed=1
    delete_expired_trojan_users && restart_needed=1

    # Cek akun yang mendekati masa kedaluwarsa (sisa hari ≤3) dan kirim notifikasi peringatan
    check_expiring_ssh
    check_expiring_vmess
    check_expiring_vless
    check_expiring_trojan

    # Menghapus pengguna yang sudah kadaluarsa di sistem
    local today=$(date +%s)
    local expire_list=$(awk -F: -v today="$today" '$8 != "" { if ($8 * 86400 < today) print $1 }' /etc/shadow)
    
    for username in $expire_list; do
        userdel --force "$username"
        restart_needed=1  # Set flag karena ada akun yang dihapus
    done

    # Restart Xray hanya jika diperlukan
    if [[ $restart_needed -eq 1 ]]; then
        echo "Restarting Xray service..."
        systemctl restart xray
    else
        echo "No expired users removed. Xray restart not needed."
    fi
}

# Jalankan fungsi utama
main
