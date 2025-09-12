#!/bin/bash
set -euo pipefail

clear

# 🧹 Bersihkan semua file log, error, dan mail di /var/log
for pattern in '*.log' '*.err' 'mail.*'; do
    find /var/log/ -name "$pattern" | while read -r log; do
        echo "$log cleared"
        : > "$log"  # Lebih aman daripada echo > file
    done
done

# 🔒 Bersihkan log sistem inti
for syslog in /var/log/syslog /var/log/btmp /var/log/messages /var/log/debug; do
    : > "$syslog"
done

# 📅 Tampilkan waktu pembersihan
timestamp=$(date)
echo -e "\n✅ Successfully cleaned log at $timestamp"

sleep 0.5
clear
echo ""
