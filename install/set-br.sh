#!/bin/bash

# Repository utama
repo="https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/"

# Install rclone tanpa interaksi
apt-get install -y rclone

# Konfigurasi rclone
mkdir -p /root/.config/rclone
wget -qO /root/.config/rclone/rclone.conf "${repo}install/rclone.conf"

# Install wonder
git clone https://github.com/Fuuhou/wonder.git && cd wonder
make install
cd .. && rm -rf wonder

# Download & beri izin eksekusi pada beberapa skrip sekaligus
cd /usr/bin
for file in backup restore cleaner xp; do
    wget -qO "$file" "${repo}menu/${file}.sh" && chmod +x "$file"
done
cd

# Tambahkan cron job hanya jika belum ada
[[ ! -f "/etc/cron.d/cleaner" ]] && echo -e "SHELL=/bin/sh\nPATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin\n0 */2 * * * root /usr/bin/cleaner" > /etc/cron.d/cleaner
[[ ! -f "/etc/cron.d/xp_otm" ]] && echo -e "SHELL=/bin/sh\nPATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin\n0 */1 * * * root /usr/bin/xp" > /etc/cron.d/xp_otm
[[ ! -f "/etc/cron.d/bckp_otm" ]] && echo -e "SHELL=/bin/sh\nPATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin\n15 1 * * * root /usr/bin/bottelegram" > /etc/cron.d/bckp_otm

# Set ulang otomatis setiap 7 hari
echo "7" > /home/re_otm

# Restart cron
service cron restart > /dev/null 2>&1

# Install limit & hapus skrip sementara
wget -qO limit.sh "${repo}bin/limit.sh" && chmod +x limit.sh && bash limit.sh
rm -f /root/set-br.sh /root/limit.sh
