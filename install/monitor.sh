#!/bin/bash
set -euo pipefail

# =================== KONFIGURASI =================== #
LOGFILE="/var/log/service_monitor.log"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

# Daftar service yang ingin dipantau
services=(
  "ssh"
  "xray"
  "stunnel4"
  "dropbear"
  "udp-custom"
)

# =================== CEK & RESTART =================== #
for svc in "${services[@]}"; do
    if systemctl list-unit-files | grep -qw "$svc"; then
        status=$(systemctl is-active "$svc" 2>/dev/null)
        if [[ "$status" != "active" ]]; then
            echo "[$DATE] $svc status: $status → mencoba restart..." | tee -a "$LOGFILE"
            systemctl restart "$svc"
            sleep 2
            # Cek ulang setelah restart
            status_after=$(systemctl is-active "$svc" 2>/dev/null)
            if [[ "$status_after" == "active" ]]; then
                echo "[$DATE] $svc berhasil direstart (Online ✅)" | tee -a "$LOGFILE"
            else
                echo "[$DATE] $svc gagal direstart (Offline ❌)" | tee -a "$LOGFILE"
            fi
        else
            echo "[$DATE] $svc status: Active (OK)" >> "$LOGFILE"
        fi
    else
        echo "[$DATE] $svc tidak ditemukan di systemd (Not Installed ⚠️)" | tee -a "$LOGFILE"
    fi
done
