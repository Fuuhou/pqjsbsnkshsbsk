#!/usr/bin/env bash
set -euo pipefail

repo="https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/"

# Update system dan install rclone
apt update && apt install -y rclone

# Setup rclone config
printf "q\n" | rclone config
mkdir -p /root/.config/rclone
wget -qO /root/.config/rclone/rclone.conf "${repo}install/rclone.conf"

# Install wondershaper
git clone https://github.com/Fuuhou/wonder.git
cd wondershaper
make install
cd ~
rm -rf wondershaper

# Unduh script ke /usr/bin
cd /usr/bin
wget -qO backup "${repo}menu/backup.sh"
wget -qO restore "${repo}menu/restore.sh"
wget -qO cleaner "${repo}install/cleaner.sh"
wget -qO xp "${repo}install/xp.sh"
wget -qO gen-nginx "${repo}install/gen-nginx.sh"
wget -qO watch-nginx "${repo}install/watch-nginx.sh"
wget -qO xray-usage "${repo}install/xray-usage.sh"
chmod +x backup restore cleaner xp gen-nginx watch-nginx xray-usage

# Setup cron job untuk cleaner setiap 13 menit
if [[ ! -f /etc/cron.d/cleaner ]]; then
    cat > /etc/cron.d/cleaner << EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/13 * * * * root /usr/bin/cleaner
EOF
fi

# Setup cron job untuk expired otomatis setiap 1 menit
if [[ ! -f /etc/cron.d/xp_otm ]]; then
    cat > /etc/cron.d/xp_otm << EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/10 * * * * root /usr/bin/xp
EOF
fi

# Simpan nilai otm
echo "7" > /home/re_otm

# Setup cron job untuk backup otomatis jam 2 pagi
if [[ ! -f /etc/cron.d/bckp_otm ]]; then
    cat > /etc/cron.d/bckp_otm << EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 2 * * * root /usr/bin/backup
EOF
fi

# Setup cron job untuk watch-nginx setiap 5 menit
if [[ ! -f /etc/cron.d/auto_watch_nginx ]]; then
    cat > /etc/cron.d/auto_watch_nginx << EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/5 * * * * root /usr/bin/watch-nginx
EOF
fi

# Setup cron job untuk xray-usage setiap 1 menit
if [[ ! -f /etc/cron.d/auto_xray_usage ]]; then
    cat > /etc/cron.d/auto_xray_usage << EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/1 * * * * root /usr/bin/xray-usage
EOF
fi

# Restart cron service
service cron restart > /dev/null 2>&1

# Bersihkan skrip lama
rm -f /root/set-br.sh
