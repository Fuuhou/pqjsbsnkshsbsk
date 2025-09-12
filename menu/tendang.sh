#!/bin/bash

# =============================================
# CONFIGURATION SECTION
# =============================================

# Clean terminal and excessive processes
clear
rm -f /tmp/ssh*
[[ $(pgrep -fc "bash $(basename "$0")") -gt 20 ]] && pkill -f "bash $(basename "$0")"

# Telegram and timing configuration
TIMEOUT=10
CHAT_ID=$(cat /etc/perlogin/id 2>/dev/null)
BOT_TOKEN=$(cat /etc/perlogin/token 2>/dev/null)
API_URL="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage"

# System information
DOMAINZ=$(cat /etc/xray/domain 2>/dev/null)
ISP=$(cat /etc/xray/isp 2>/dev/null)
CITY=$(cat /etc/xray/city 2>/dev/null)
LOCK_MINUTES=$(cat /etc/waktulockssh 2>/dev/null || echo "10")
DATE_NOW=$(date +'%Y-%m-%d')

# =============================================
# FUNCTION DEFINITIONS
# =============================================

# Function to validate IP address
validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        IFS='.' read -ra octets <<< "$ip"
        for octet in "${octets[@]}"; do
            [[ $octet -gt 255 ]] && return 1
        done
        return 0
    fi
    return 1
}

# Function to clean temporary files
cleanup() {
    rm -f /tmp/log-db*.txt /tmp/log-ssh*.txt /tmp/ssh /etc/user.txt
}

# Function to send telegram notification
send_notification() {
    local user=$1 count=$2 login_list=$3 extra=$4
    
    local message="
━━━━━━━━━━━━━━━━━━━━
<b>NOTIFIKASI MULTILOGIN</b>
━━━━━━━━━━━━━━━━━━━━
<b>Protokol :</b> SSH
<b>Domain :</b> ${DOMAINZ}
<b>ISP :</b> ${ISP}
<b>Kota :</b> ${CITY}
<b>Username :</b> ${user}
<b>Jumlah Login :</b> ${count} IP
━━━━━━━━━━━━━━━━━━━━
<b>Waktu ≈ IP</b>
<pre>${login_list}</pre>
${extra}
━━━━━━━━━━━━━━━━━━━━
<i>Auto-unlock dalam ${LOCK_MINUTES} menit.</i>
"

    curl -s --max-time "${TIMEOUT}" \
        -d "chat_id=${CHAT_ID}&disable_web_page_preview=1" \
        -d "text=$(echo "$message" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')" \
        -d "parse_mode=html" "${API_URL}" >/dev/null
}

# Function to lock user
lock_user() {
    local user=$1 pass=$2 exp=$3
    
    # Add to lock list
    echo "### ${user} ${exp} ${pass}" >> /etc/xray/sshx/listlock
    passwd -l "$user" >/dev/null 2>&1
    
    # Create unlock cron job
    cat > "/etc/cron.d/ssh_${user}" <<EOF
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/${LOCK_MINUTES} * * * * root /usr/bin/xray ssh ${user} ${pass} ${exp} && rm -f /etc/cron.d/ssh_${user}
EOF
    
    # Clean login history
    rm -f "/etc/xray/sshx/${user}login"
}

# Function to detect stable connections
get_stable_connections() {
    # Wait for stable connections (filter out quick disconnects)
    sleep 5
    netstat -tnp | grep -E '(ssh|dropbear)' | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | \
    awk '{if ($1 >= 2) print $2}' > /tmp/stable_ips.txt
}

# =============================================
# MAIN SCRIPT EXECUTION
# =============================================

# Identify log file
if [[ -f /var/log/auth.log ]]; then
    LOG_FILE="/var/log/auth.log"
elif [[ -f /var/log/secure ]]; then
    LOG_FILE="/var/log/secure"
else
    echo "Error: No auth log file found!" >&2
    exit 1
fi

# Restart services quietly
systemctl restart sshd dropbear >/dev/null 2>&1

# Get all home users
grep '/home/' /etc/passwd | cut -d: -f1 > /etc/user.txt
mapfile -t users < /etc/user.txt

# Detect stable connections first
get_stable_connections

# Process Dropbear logins
grep -Ei "dropbear.*Password auth succeeded" "$LOG_FILE" > /tmp/log-db.txt
while read -r line; do
    ip=$(awk '{print $12}' <<< "$line")
    if grep -q "^${ip}$" /tmp/stable_ips.txt; then
        user=$(awk '{print $10}' <<< "$line")
        time=$(date +'%H:%M:%S')
        echo "$user $time : $ip" >> /tmp/ssh
    fi
done < /tmp/log-db.txt

# Process SSH logins
grep -Ei "sshd.*Accepted password for" "$LOG_FILE" > /tmp/log-ssh.txt
while read -r line; do
    ip=$(awk '{print $11}' <<< "$line")
    if grep -q "^${ip}$" /tmp/stable_ips.txt; then
        user=$(awk '{print $9}' <<< "$line")
        time=$(date +'%H:%M:%S')
        echo "$user $time : $ip" >> /tmp/ssh
    fi
done < /tmp/log-ssh.txt

# Process each user
for user in "${users[@]}"; do
    limit=$(cat "/etc/xray/sshx/${user}IP" 2>/dev/null || echo "1")
    count=$(grep -c -w "$user" /tmp/ssh 2>/dev/null)
    
    # Skip if count is below limit
    [[ $count -le $limit ]] && continue
    
    # Log the event
    echo "$(date '+%F %T') - $user - $count" >> "/etc/xray/sshx/${user}login"
    
    # Prepare login list for notification
    login_list=$(grep -w "$user" /tmp/ssh | awk '{print $2" ≈ "$4}' | nl -s '. ')
    max_display=10
    displayed_list=$(head -n $max_display <<< "$login_list")
    others=$((count - max_display))
    
    [[ $others -gt 0 ]] && extra="\nPlus $others other IPs..." || extra=""
    
    # Get user credentials
    creds=$(grep -i "### ${user}" /etc/xray/ssh 2>/dev/null)
    exp=$(awk '{print $3}' <<< "$creds")
    pass=$(awk '{print $4}' <<< "$creds")
    
    # Send notification and lock user
    send_notification "$user" "$count" "$displayed_list" "$extra"
    lock_user "$user" "$pass" "$exp"
done

# Final cleanup
cleanup
exit 0
