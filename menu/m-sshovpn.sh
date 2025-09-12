#!/bin/bash

# Load konfigurasi tema
color_now=$(cat /etc/rmbl/theme/color.conf)
NC="\e[0m"
RED="\033[0;31m"
COLOR1=$(grep -w "TEXT" /etc/rmbl/theme/"$color_now" | cut -d: -f2 | sed 's/ //g')
COLBG1=$(grep -w "BG" /etc/rmbl/theme/"$color_now" | cut -d: -f2 | sed 's/ //g')
WH='\033[1;37m'

# Informasi sistem
IP=$(cat /etc/myipvps)
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
LABEL=$(cat /etc/profil)
DOMAINZ=$(cat /etc/xray/domain)
SLOWDNS_DOMAIN=$(cat /etc/domain/nsdomain)
SLOWDNS_KEY=$(cat /etc/slowdns/server.pub)
TIME2="$(LC_TIME=id_ID.UTF-8 date '+%A, %d %B %Y - %H:%M WIB')"

# Telegram bot utama
TEXT1=$(cat /etc/notifsatu)
TEXT2=$(cat /etc/notifdua)
TIMES="10"
KEY=$(cat /etc/per/token)
CHAT_ID=$(cat /etc/per/id)
BOT_TOKEN=$(cat /etc/per/token)
URL="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage"

CHAT_ID2=$(cat /etc/perlogin/id)
BOT_TOKEN2=$(cat /etc/perlogin/token)
URL2="https://api.telegram.org/bot${BOT_TOKEN2}/sendMessage"

# Pastikan direktori akun SSH tersedia
mkdir -p /etc/xray/sshx/akun

function add_ssh(){
clear

logfile="/etc/xray/sshx/akun/log-create-${Login}.log"

# Fungsi cetak log sekaligus
print_log() {
  echo -e "$1" | tee -a "$logfile"
}

# Validasi username
while true; do
    read -rp "Username : " Login

    # Validasi format
    if [[ ! $Login =~ ^[a-zA-Z0-9_.-]+$ ]]; then
        echo -e "\n❌ Format tidak valid. Gunakan hanya huruf, angka, titik, underscore, atau dash."
        continue
    fi

    # Cek apakah username sudah ada
    if grep -qw "$Login" /etc/xray/ssh; then
        echo -e "\n⚠️ Username sudah terdaftar. Silakan coba nama lain.\n"
        continue
    fi

    # Jika lolos semua
    break
done

# === Validasi Password: hanya alfanumerik, panjang bebas, tanpa spasi/simbol ===
while true; do
    read -rp "Password : " Pass
    if [[ $Pass =~ ^[a-zA-Z0-9]+$ ]]; then
        break
    else
        echo -e "❌ Password hanya boleh huruf dan angka, tanpa spasi atau simbol.\n"
    fi
done

# === Validasi Masa Aktif (harus angka) ===
while true; do
    read -rp "Expired (hari): " plus_hari
    if [[ $plus_hari =~ ^[0-9]+$ ]]; then
        break
    else
        echo -e "❌ Input masa aktif hanya boleh angka.\n"
    fi
done

# === Validasi Limit IP User (angka saja) ===
while true; do
    read -rp "Limit User (IP): " iplim
    if [[ $iplim =~ ^[0-9]+$ ]]; then
        break
    else
        echo -e "❌ Input limit hanya boleh angka.\n"
    fi
done

# Input Telegram ID
read -p "Masukkan Telegram ID (Kosong jika ingin dilewati): " telegram_id

# ✅ Validasi Telegram ID dengan fallback ke CHAT_ID
if [[ -n "$telegram_id" && "$telegram_id" =~ ^[0-9]+$ ]]; then
    USER_ID="$telegram_id"
elif [[ -z "$telegram_id" ]]; then
    #echo "ℹ️ Telegram ID tidak diberikan. Menggunakan CHAT_ID sebagai default."
    USER_ID="$CHAT_ID"
else
    #echo "⚠️ Telegram ID tidak valid. Menggunakan CHAT_ID sebagai default."
    USER_ID="$CHAT_ID"
fi


# Buat direktori jika belum ada
mkdir -p /etc/xray/sshx

# Simpan limit IP
echo "${iplim:-0}" > "/etc/xray/sshx/${Login}IP"

# Buat user SSH
expi=$(date -d "$plus_hari days" +"%Y-%m-%d")
useradd -e "$expi" -s /bin/false -M "$Login"
echo -e "$Pass\n$Pass\n" | passwd "$Login" &> /dev/null

# Simpan ke file database
echo "### $Login $expi $Pass" >> /etc/xray/ssh


MSG1=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
<b>INFORMASI AKUN SSH</b>
━━━━━━━━━━━━━━━━━━━━
<b>Hostname :</b> <code>$DOMAINZ</code>
<b>Username :</b> <code>$Login</code>
<b>Password :</b> <code>$Pass</code>
<b>Login Max :</b> ${iplim} IP
<b>Expired :</b> $expi
━━━━━━━━━━━━━━━━━━━━
<b>SSH WS :</b> <code>$DOMAINZ:80@$Login:$Pass</code>
<b>SSH UDP :</b> <code>$DOMAINZ:1-65535@$Login:$Pass</code>
━━━━━━━━━━━━━━━━━━━━
<b>ISP :</b> $ISP
<b>Kota :</b> $CITY
<b>OpenSSH :</b> 22
<b>Dropbear :</b> 143, 109
<b>SSH WS :</b> 80
<b>SSL/TLS :</b> 8443, 8880
<b>OVPN WS SSL :</b> 2086
<b>OVPN SSL :</b> 990
<b>OVPN TCP :</b> 1194
<b>OVPN UDP :</b> 2200
<b>BadVPN UDP :</b> 7100 - 7300
<b>Host SlowDNS :</b> <code>$SLOWDNS_DOMAIN</code>
<b>Port SlowDNS :</b> 80, 53, 443
<b>Public Key :</b> <code>$SLOWDNS_KEY</code>
━━━━━━━━━━━━━━━━━━━━
<b>Payload WS/WSS :</b>
<code>GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: ws[crlf][crlf]</code>

<b>Payload SSL/TLS :</b>
<code>CONNECT [host] [port] HTTP/1.1[crlf]Host: [host][crlf]User-Agent: [ua][crlf]Connection: Keep-Alive[crlf]Upgrade: websocket[crlf][crlf]</code>
━━━━━━━━━━━━━━━━━━━━
EOF
)

user2=$(echo "$Login" | cut -c 1-3)

MSG2=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
<b>NOTIFIKASI SERVER</b>
━━━━━━━━━━━━━━━━━━━━
<b>Detail :</b> Buat baru SSH
<b>Label :</b> ${LABEL}
<b>ISP :</b> ${ISP}
<b>Kota :</b> ${CITY}
<b>Username :</b> ${user2}xxx
<b>Durasi :</b> ${plus_hari} Hari
━━━━━━━━━━━━━━━━━━━━
<i>${TIME2}</i>
EOF
)

# Buat ulang /etc/kirim dengan dua pengiriman
cat <<EOF > /etc/kirim
#!/bin/bash

curl -s --max-time "${TIMES}" \\
  -d "chat_id=${USER_ID}" \\
  -d "disable_web_page_preview=1" \\
  -d "text=${MSG1}" \\
  -d "parse_mode=html" \\
  "https://api.telegram.org/bot${KEY}/sendMessage" >/dev/null

sleep 2

curl -s --max-time "${TIMES}" \\
  -d "chat_id=${CHAT_ID2}" \\
  -d "disable_web_page_preview=1" \\
  -d "text=${MSG2}" \\
  -d "parse_mode=html" \\
  "https://api.telegram.org/bot${KEY2}/sendMessage" >/dev/null
EOF

chmod +x /etc/kirim

# Jalankan notifikasi
bash /etc/kirim

clear

# Gabungkan semua isi log dalam satu variabel
info_log=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
INFORMASI AKUN SSH
━━━━━━━━━━━━━━━━━━━━
Hostname : $DOMAINZ
Username : $Login
Password : $Pass
Login Max : ${iplim} IP
Expired : $expi
━━━━━━━━━━━━━━━━━━━━
SSH WS : $DOMAINZ:80@$Login:$Pass
SSH UDP : $DOMAINZ:1-65535@$Login:$Pass
━━━━━━━━━━━━━━━━━━━━
ISP : $ISP
Kota : $CITY
OpenSSH : 22
Dropbear : 143, 109
SSH WS : 80
SSL/TLS : 443
OVPN WS SSL : 2086
OVPN SSL : 990
OVPN TCP : 1194
OVPN UDP : 2200
BadVPN UDP : 7100 - 7300
Host SlowDNS : $SLOWDNS_DOMAIN
Port SlowDNS : 80, 443, 53
Public Key : $SLOWDNS_KEY
━━━━━━━━━━━━━━━━━━━━
Payload WS/WSS :
GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: ws[crlf][crlf]

Payload SSL/TLS :
CONNECT [host] [port] HTTP/1.1[crlf]Host: [host][crlf]User-Agent: [ua][crlf]Connection: Keep-Alive[crlf]Upgrade: websocket[crlf][crlf]
━━━━━━━━━━━━━━━━━━━━
EOF
)

# Cetak seluruh log sekaligus
print_log "${info_log}"

read -n 1 -s -r -p "Press any key to back on menu"
menu
}


function trial_ssh(){
clear

logfile="/etc/xray/sshx/akun/log-create-${Login}.log"

# Fungsi cetak log sekaligus
print_log() {
  echo -e "$1" | tee -a "$logfile"
}

# ⏰ Input waktu kedaluwarsa akun trial (dalam menit)
while true; do
    read -p "Expired (Minutes): " timer
    if [[ $timer =~ ^[0-9]+$ ]]; then
        break
    else
        echo "Input tidak valid. Masukkan angka saja."
    fi
done

# Input Telegram ID
read -p "Masukkan Telegram ID (Kosong jika ingin dilewati): " telegram_id

# ✅ Validasi Telegram ID dengan fallback ke CHAT_ID
if [[ -n "$telegram_id" && "$telegram_id" =~ ^[0-9]+$ ]]; then
    USER_ID="$telegram_id"
elif [[ -z "$telegram_id" ]]; then
    #echo "ℹ️ Telegram ID tidak diberikan. Menggunakan CHAT_ID sebagai default."
    USER_ID="$CHAT_ID"
else
    #echo "⚠️ Telegram ID tidak valid. Menggunakan CHAT_ID sebagai default."
    USER_ID="$CHAT_ID"
fi


# 🔐 Generate akun trial
Login="Tes-$(tr -dc 'X-Z0-9' < /dev/urandom | head -c4)"
hari=1
Pass=1
iplim=1

# 📁 Buat direktori konfigurasi jika belum ada
mkdir -p /etc/xray/sshx /etc/xray/sshx/akun

# 💾 Simpan batas login IP
echo "$iplim" > "/etc/xray/sshx/${Login}IP"

# 📆 Tentukan tanggal expired akun (format YYYY-MM-DD)
expi=$(date -d "+$hari days" +"%Y-%m-%d")

# 👤 Tambahkan user SSH dengan password 1 hari
useradd -e "$expi" -s /bin/false -M "$Login"
echo -e "$Pass\n$Pass" | passwd "$Login" &>/dev/null

# 📝 Catat ke dalam file akun SSH
echo "### $Login $expi $Pass" >> /etc/xray/ssh

# 🗓️ Tambahkan cron job untuk hapus akun secara otomatis setelah waktu trial
cat > "/etc/cron.d/expire-trial-${Login}" <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/${timer} * * * * root id "$Login" >/dev/null 2>&1 && \
userdel -f "$Login" && \
rm -f "/etc/xray/sshx/${Login}" "/etc/xray/sshx/${Login}IP" && \
sed -i "/^### $Login /d" /etc/xray/ssh && \
rm -f "/etc/xray/sshx/akun/log-create-${Login}.log" && \
rm -f "/etc/cron.d/expire-trial-${Login}"
EOF


MSG1=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
<b>INFORMASI TRIAL SSH</b>
━━━━━━━━━━━━━━━━━━━━
<b>Hostname :</b> <code>$DOMAINZ</code>
<b>Username :</b> <code>$Login</code>
<b>Password :</b> <code>$Pass</code>
<b>Login Max :</b> ${iplim} IP
<b>Expired :</b> $timer Menit
━━━━━━━━━━━━━━━━━━━━
<b>SSH WS :</b> <code>$DOMAINZ:80@$Login:$Pass</code>
<b>SSH UDP :</b> <code>$DOMAINZ:1-65535@$Login:$Pass</code>
━━━━━━━━━━━━━━━━━━━━
<b>ISP :</b> $ISP
<b>Kota :</b> $CITY
<b>OpenSSH :</b> 22
<b>Dropbear :</b> 143, 109
<b>SSH WS :</b> 80
<b>SSL/TLS :</b> 8443, 8880
<b>OVPN WS SSL :</b> 2086
<b>OVPN SSL :</b> 990
<b>OVPN TCP :</b> 1194
<b>OVPN UDP :</b> 2200
<b>BadVPN UDP :</b> 7100 - 7300
<b>Host SlowDNS :</b> <code>$SLOWDNS_DOMAIN</code>
<b>Port SlowDNS :</b> 80, 53, 443
<b>Public Key :</b> <code>$SLOWDNS_KEY</code>
━━━━━━━━━━━━━━━━━━━━
<b>Payload WS :</b>
<code>GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: ws[crlf][crlf]</code>

<b>Payload SSL/TLS :</b>
<code>CONNECT [host] [port] HTTP/1.1[crlf]Host: [host][crlf]User-Agent: [ua][crlf]Connection: Keep-Alive[crlf]Upgrade: websocket[crlf][crlf]</code>
━━━━━━━━━━━━━━━━━━━━
EOF
)

user2=$(echo "$Login" | cut -c 1-4)

MSG2=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
<b>NOTIFIKASI SERVER</b>
━━━━━━━━━━━━━━━━━━━━
<b>Detail :</b> Buat trial SSH
<b>Label :</b> ${LABEL}
<b>ISP :</b> ${ISP}
<b>Kota :</b> ${CITY}
<b>Username :</b> ${user2}xxx
<b>Durasi :</b> ${timer} Menit
━━━━━━━━━━━━━━━━━━━━
<i>${TIME2}</i>
EOF
)

# Buat ulang /etc/kirim dengan dua pengiriman
cat <<EOF > /etc/kirim
#!/bin/bash

curl -s --max-time "${TIMES}" \\
  -d "chat_id=${USER_ID}" \\
  -d "disable_web_page_preview=1" \\
  -d "text=${MSG1}" \\
  -d "parse_mode=html" \\
  "https://api.telegram.org/bot${KEY}/sendMessage" >/dev/null

sleep 2

curl -s --max-time "${TIMES}" \\
  -d "chat_id=${CHAT_ID2}" \\
  -d "disable_web_page_preview=1" \\
  -d "text=${MSG2}" \\
  -d "parse_mode=html" \\
  "https://api.telegram.org/bot${KEY2}/sendMessage" >/dev/null
EOF

chmod +x /etc/kirim

# Jalankan notifikasi
bash /etc/kirim

clear

# Gabungkan semua isi log dalam satu variabel
info_log=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
INFORMASI TRIAL SSH
━━━━━━━━━━━━━━━━━━━━
Hostname : $DOMAINZ
Username : $Login
Password : $Pass
Login Max : ${iplim} IP
Expired : $timer Menit
━━━━━━━━━━━━━━━━━━━━
SSH WS : $DOMAINZ:80@$Login:$Pass
SSH UDP : $DOMAINZ:1-65535@$Login:$Pass
━━━━━━━━━━━━━━━━━━━━
ISP : $ISP
Kota : $CITY
OpenSSH : 22
Dropbear : 143, 109
SSH WS : 80
SSL/TLS : 8443, 8880
OVPN WS SSL : 2086
OVPN SSL : 990
OVPN TCP : 1194
OVPN UDP : 2200
BadVPN UDP : 7100 - 7300
Host SlowDNS : $SLOWDNS_DOMAIN
Port SlowDNS : 80, 443, 53
Public Key : $SLOWDNS_KEY
━━━━━━━━━━━━━━━━━━━━
Payload WS :
GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: ws[crlf][crlf]

Payload SSL/TLS :
CONNECT [host] [port] HTTP/1.1[crlf]Host: [host][crlf]User-Agent: [ua][crlf]Connection: Keep-Alive[crlf]Upgrade: websocket[crlf][crlf]
━━━━━━━━━━━━━━━━━━━━
EOF
)

# Cetak seluruh log sekaligus
print_log "${info_log}"

read -n 1 -s -r -p "Press any key to back on menu"
menu
}


function renew_ssh(){
clear

# 📦 Ambil jumlah user dari database
NUMBER_OF_CLIENTS=$(grep -cE "^### " "/etc/xray/ssh")

# ❌ Jika tidak ada user
if [[ "$NUMBER_OF_CLIENTS" -eq 0 ]]; then
    clear
    echo -e "🚫 Tidak ada user yang terdaftar."
    read -n 1 -s -r -p "🔙 Tekan tombol apa saja untuk kembali ke menu..."
    m-sshovpn
    exit
fi

clear

# 📋 Tampilkan daftar user
echo "📦 Daftar user yang tersedia:"
echo "-----------------------------------"
grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 2
echo ""

# 👤 Input username
read -rp "🔍 Masukkan username yang ingin di-renew: " User

# ❌ Cek apakah user ada
cek_user=$(grep -wE "^### $User" /etc/xray/ssh)
if [[ -z "$cek_user" ]]; then
    echo -e "\n🚫 ${COLOR1}User tidak ditemukan!${NC}"
    read -n 1 -s -r -p "🔙 Tekan tombol apa saja untuk kembali ke menu..."
    m-sshovpn
    exit
fi

# 📲 Input Telegram ID (optional)
read -p "📨 Masukkan Telegram ID (biarkan kosong untuk melewati): " telegram_id

# ✅ Validasi Telegram ID dengan fallback
if [[ -n "$telegram_id" && "$telegram_id" =~ ^[0-9]+$ ]]; then
    USER_ID="$telegram_id"
elif [[ -z "$telegram_id" ]]; then
    #echo "ℹ️ Telegram ID tidak diberikan. Menggunakan CHAT_ID sebagai default."
    USER_ID="$CHAT_ID"
else
    #echo "⚠️ Telegram ID tidak valid. Menggunakan CHAT_ID sebagai default."
    USER_ID="$CHAT_ID"
fi

# 🔄 Ambil informasi lama
exp=$(echo "$cek_user" | awk '{print $3}')
Pass=$(echo "$cek_user" | awk '{print $4}')

# 🕒 Input jumlah hari tambahan
while true; do
    read -rp "➕ Tambah berapa hari: " Days
    if [[ "$Days" =~ ^[0-9]+$ ]]; then
        break
    else
        echo "❌ Input tidak valid. Harus berupa angka!"
    fi
done

# 📆 Hitung masa berlaku baru
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
sisa_hari=$(( (d1 - d2) / 86400 ))
total_hari=$(( sisa_hari + Days ))
exp_baru=$(date -d "$total_hari days" +"%Y-%m-%d")

# 🔐 Eksekusi update user
passwd -u "$User"
usermod -e "$exp_baru" "$User"
echo -e "$Pass\n$Pass" | passwd "$User" &> /dev/null

# 📝 Update database SSH
sed -i "s/^### $User $exp/### $User $exp_baru/" /etc/xray/ssh


MSG1=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
<b>TAMBAH MASA AKTIF</b>
━━━━━━━━━━━━━━━━━━━━
<b>Protokol :</b> <code>SSH</code>
<b>Domain :</b> <code>${DOMAINZ}</code>
<b>ISP :</b> <code>${ISP}</code>
<b>Kota :</b> <code>${CITY}</code>
<b>Username :</b> <code>${User}</code>
<b>Durasi :</b> <code>${Days} Hari</code>
<b>Expired Baru :</b> <code>${exp_baru}</code>
━━━━━━━━━━━━━━━━━━━━
EOF
)

user2=$(echo "$Login" | cut -c 1-)
MSG2=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
<b>NOTIFIKASI SERVER</b>
━━━━━━━━━━━━━━━━━━━━
<b>Detail :</b> Tambah masa aktif SSH
<b>Label :</b> ${LABEL}
<b>ISP :</b> ${ISP}
<b>Kota :</b> ${CITY}
<b>Username :</b> ${user2}xxx
<b>Durasi :</b> ${Days} Hari
━━━━━━━━━━━━━━━━━━━━
<i>${TIME2}</i>
EOF
)

# Buat ulang /etc/kirim dengan dua pengiriman
cat <<EOF > /etc/kirim
#!/bin/bash

curl -s --max-time "${TIMES}" \\
  -d "chat_id=${USER_ID}" \\
  -d "disable_web_page_preview=1" \\
  -d "text=${MSG1}" \\
  -d "parse_mode=html" \\
  "https://api.telegram.org/bot${KEY}/sendMessage" >/dev/null

sleep 2

curl -s --max-time "${TIMES}" \\
  -d "chat_id=${CHAT_ID2}" \\
  -d "disable_web_page_preview=1" \\
  -d "text=${MSG2}" \\
  -d "parse_mode=html" \\
  "https://api.telegram.org/bot${KEY2}/sendMessage" >/dev/null
EOF

chmod +x /etc/kirim

# Jalankan notifikasi
bash /etc/kirim

clear

# Gabungkan semua isi log dalam satu variabel
info=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
TAMBAH MASA AKTIF
━━━━━━━━━━━━━━━━━━━━
Protokol : SSH
Domain : ${DOMAINZ}
ISP : ${ISP}
Kota : ${CITY}
Username : ${User}
Durasi : ${Days} Hari
Expired Baru : ${exp_baru}
━━━━━━━━━━━━━━━━━━━━
EOF
)

# Tampilkan log
echo -e "${info}"

read -n 1 -s -r -p "Press any key to back on menu"
menu
}


function hapus_ssh(){
clear

# 🔢 Hitung jumlah user SSH
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/ssh")

# ❌ Jika tidak ada user
if [[ $NUMBER_OF_CLIENTS -eq 0 ]]; then
    clear
    echo -e "${COLOR1}Tidak ada user yang terdaftar!${NC}\n"
    
    read -n 1 -s -r -p "Tekan tombol apa saja untuk kembali ke menu..."
    m-sshovpn
    exit
fi

echo -e "${COLOR1}Silakan pilih user yang ingin dihapus:${NC}"

# 📋 Tampilkan daftar user
grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 2-3 | nl -s ') '

# 🔁 Input pilihan user
while true; do
    read -rp "Pilih nomor user [1-$NUMBER_OF_CLIENTS, 0 untuk kembali]: " CLIENT_NUMBER
    if [[ "$CLIENT_NUMBER" == "0" ]]; then
        m-sshovpn
        exit
    elif [[ "$CLIENT_NUMBER" =~ ^[0-9]+$ ]] && (( CLIENT_NUMBER >= 1 && CLIENT_NUMBER <= NUMBER_OF_CLIENTS )); then
        break
    else
        echo "Input tidak valid!"
    fi
done

# 🔍 Ambil detail user berdasarkan input
User=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}p")
Exp=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}p")
Pass=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}p")

# 🧹 Hapus data user dari database dan file terkait
sed -i "/^### $User $Exp $Pass/d" /etc/xray/ssh
rm -f /etc/xray/sshx/${User}IP
rm -f /etc/xray/sshx/${User}login
rm -f /etc/xray/sshx/akun/log-create-${User}.log

# ❌ Hapus akun dari sistem jika ada
if getent passwd "$User" > /dev/null 2>&1; then
    userdel "$User" > /dev/null 2>&1
    echo -e "${COLOR1}User ${WH}$User${COLOR1} berhasil dihapus.${NC}"
else
    echo -e "${COLOR1}Gagal: User ${WH}$User${COLOR1} tidak ditemukan di sistem.${NC}"
fi

# 📤 Kirim notifikasi Telegram
MSG1=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
<b>HAPUS AKUN VPN</b>
━━━━━━━━━━━━━━━━━━━━
<b>Domain :</b> <code>${DOMAINZ}</code>
<b>ISP :</b> <code>${ISP}</code>
<b>Kota :</b> <code>${CITY}</code>
<b>Username :</b> <code>${User}</code>
<b>Expired :</b> <code>${Exp}</code>
━━━━━━━━━━━━━━━━━━━━
EOF
)

curl -s --max-time "${TIMES}" \
     -d "chat_id=${CHAT_ID2}&disable_web_page_preview=1&text=${MSG}&parse_mode=html" \
     "${URL}" > /dev/null

# ✅ Kembali ke menu
read -n 1 -s -r -p "Tekan tombol apa saja untuk kembali ke menu..."
m-sshovpn
}


function check_ssh(){
clear

NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/ssh")

# 🔍 Cek apakah ada user
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
    clear
    echo -e "Tidak ada user terdaftar!\n"
    read -n 1 -s -r -p "Tekan sembarang tombol untuk kembali ke menu..."
    m-sshovpn
    exit
fi

# 🧾 Tampilkan daftar user
clear
echo -e "Silakan pilih user yang ingin dicek:\n"

grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 2-3 | nl -s ') '

# 🔢 Pilih user berdasarkan nomor
while true; do
    read -rp "Pilih user [1-${NUMBER_OF_CLIENTS}] atau [0] untuk kembali: " CLIENT_NUMBER
    if [[ $CLIENT_NUMBER == "0" ]]; then
        m-sshovpn
        exit
    elif [[ $CLIENT_NUMBER =~ ^[0-9]+$ ]] && (( CLIENT_NUMBER >= 1 && CLIENT_NUMBER <= NUMBER_OF_CLIENTS )); then
        break
    else
        echo "Input tidak valid!"
    fi
done

# 🎯 Ambil username dari daftar
Login=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}p")

# 📄 Tampilkan dan salin log akun
if [[ -f /etc/xray/sshx/akun/log-create-${Login}.log ]]; then
    cat "/etc/xray/sshx/akun/log-create-${Login}.log"
    cp "/etc/xray/sshx/akun/log-create-${Login}.log" /etc/notiftiga
else
    echo "Log tidak ditemukan untuk user: $Login"
    read -n 1 -s -r -p "Tekan sembarang tombol untuk kembali ke menu..."
    m-sshovpn
    exit
fi

# 📤 Kirim ke Telegram
MSG1=$(cat /etc/notiftiga)
curl -s --max-time "${TIMES}" -d "chat_id=${CHAT_ID2}&disable_web_page_preview=1&text=${MSG}&parse_mode=html" "${URL}" >/dev/null

read -n 1 -s -r -p "Tekan sembarang tombol untuk kembali ke menu..."
menu
}


function delete_lock_ssh(){
clear

# 📋 Tabel Header
printf "%-17s %-20s %-10s\n" "USERNAME" "EXP DATE" "STATUS"

# 🔍 Loop Semua Akun
while IFS=: read -r AKUN _ ID _ _ _ _; do
    if [[ $ID -ge 1000 && $AKUN != "nobody" ]]; then
        exp=$(chage -l "$AKUN" | grep "Account expires" | awk -F": " '{print $2}')
        status=$(passwd -S "$AKUN" | awk '{print $2}')
        if [[ "$status" == "L" ]]; then
            STATUS="LOCKED"
        else
            STATUS="UNLOCKED"
        fi
        printf "%-17s %-20s %-10s\n" "$AKUN" "$exp" "$STATUS"
    fi
done < /etc/passwd

# 📊 Total User
JUMLAH=$(awk -F: '$3 >= 1000 && $1 != "nobody"' /etc/passwd | wc -l)
echo -e "\nTotal akun pengguna: $JUMLAH"

# ❌ Hapus User
echo ""
read -rp "Masukkan Username SSH yang akan dihapus: " Pengguna
if getent passwd "$Pengguna" > /dev/null 2>&1; then
    userdel "$Pengguna" > /dev/null 2>&1
    echo -e "✅ User '$Pengguna' berhasil dihapus."
else
    echo -e "⚠️  Gagal: User '$Pengguna' tidak ditemukan."
fi

# 🧹 Hapus dari file xray
sed -i "/^### $Pengguna/d" /etc/xray/ssh

# 🔙 Kembali ke menu
read -n 1 -s -r -p "Tekan tombol apa saja untuk kembali ke menu..."
m-sshovpn
}


function login_ssh(){
clear

# 🧹 Bersihkan log sementara
rm -f /tmp/ssh2
sleep 2

# 📄 Tentukan log file
LOG="/var/log/auth.log"
[ ! -e "$LOG" ] && { echo "Log tidak ditemukan: $LOG"; exit 1; }

# 🔍 Ambil user home
awk -F: '/\/home\// {print $1}' /etc/passwd > /etc/user.txt
mapfile -t username < /etc/user.txt
declare -a jumlah pid

# 🔎 Cek login via Dropbear
grep -i 'dropbear' "$LOG" | grep -i "Password auth succeeded" > /tmp/log-db.txt
mapfile -t proc < <(ps aux | grep -i dropbear | awk '{print $2}')

for PID in "${proc[@]}"; do
    grep "dropbear\[$PID\]" /tmp/log-db.txt > /tmp/log-db-pid.txt
    NUM=$(wc -l < /tmp/log-db-pid.txt)
    USER=$(awk '{print $10}' /tmp/log-db-pid.txt | tr -d "'")
    IP=$(awk '{print $12}' /tmp/log-db-pid.txt)
    
    if [[ $NUM -eq 1 ]]; then
        TIME=$(date +'%H:%M:%S')
        echo "$USER $TIME : $IP" >> /tmp/ssh2
        for i in "${!username[@]}"; do
            if [[ "${username[$i]}" == "$USER" ]]; then
                (( jumlah[i]++ ))
                pid[i]+=" $PID"
            fi
        done
    fi
done

# 🔎 Cek login via OpenSSH
grep -i "sshd" "$LOG" | grep -i "Accepted password for" > /tmp/log-db.txt
mapfile -t sshpids < <(ps aux | grep "\[priv\]" | awk '{print $2}')

for PID in "${sshpids[@]}"; do
    grep "sshd\[$PID\]" /tmp/log-db.txt > /tmp/log-db-pid.txt
    NUM=$(wc -l < /tmp/log-db-pid.txt)
    USER=$(awk '{print $9}' /tmp/log-db-pid.txt)
    IP=$(awk '{print $11}' /tmp/log-db-pid.txt)
    
    if [[ $NUM -eq 1 ]]; then
        TIME=$(date +'%H:%M:%S')
        echo "$USER $TIME : $IP" >> /tmp/ssh2
        for i in "${!username[@]}"; do
            if [[ "${username[$i]}" == "$USER" ]]; then
                (( jumlah[i]++ ))
                pid[i]+=" $PID"
            fi
        done
    fi
done

# 📋 Tampilkan hasil login SSH
for i in "${!username[@]}"; do
    IP_LIST=$(grep -w "${username[$i]}" /tmp/ssh2 | awk '{print $3}')
    if [[ -n "$IP_LIST" ]]; then
        echo -e "👤 USER : ${username[$i]}"
        echo -e "┌───────────────┬────────────┐"
        echo -e "│ IP ADDRESS    │ METHOD     │"
        echo -e "├───────────────┼────────────┤"
        while read -r ip; do
            [[ -n "$ip" ]] && printf "│ %-13s │ %-10s │\n" "$ip" "SSH"
        done <<< "$IP_LIST"
        echo -e "└───────────────┴────────────┘"
        echo ""
    fi
done

# 🔎 Cek login OpenVPN TCP
if [[ -f "/etc/openvpn/server/openvpn-tcp.log" ]]; then
    TCP_LOGINS=$(grep "^CLIENT_LIST" /etc/openvpn/server/openvpn-tcp.log | cut -d',' -f2,3,8)
    if [[ -n "$TCP_LOGINS" ]]; then
        USERS=$(echo "$TCP_LOGINS" | awk -F',' '{print $1}' | sort -u)
        for u in $USERS; do
            echo -e "👤 USER : $u"
            echo -e "┌───────────────┬────────────┐"
            echo -e "│ IP ADDRESS    │ METHOD     │"
            echo -e "├───────────────┼────────────┤"
            echo "$TCP_LOGINS" | grep -w "$u" | while IFS=',' read -r user realip _ rest; do
                printf "│ %-13s │ %-10s │\n" "$realip" "OpenVPN-TCP"
            done
            echo -e "└───────────────┴────────────┘"
            echo ""
        done
    fi
fi

# 🔎 Cek login OpenVPN UDP
if [[ -f "/etc/openvpn/server/openvpn-udp.log" ]]; then
    UDP_LOGINS=$(grep "^CLIENT_LIST" /etc/openvpn/server/openvpn-udp.log | cut -d',' -f2,3,8)
    if [[ -n "$UDP_LOGINS" ]]; then
        USERS=$(echo "$UDP_LOGINS" | awk -F',' '{print $1}' | sort -u)
        for u in $USERS; do
            echo -e "👤 USER : $u"
            echo -e "┌───────────────┬────────────┐"
            echo -e "│ IP ADDRESS    │ METHOD     │"
            echo -e "├───────────────┼────────────┤"
            echo "$UDP_LOGINS" | grep -w "$u" | while IFS=',' read -r user realip _ rest; do
                printf "│ %-13s │ %-10s │\n" "$realip" "OpenVPN-UDP"
            done
            echo -e "└───────────────┴────────────┘"
            echo ""
        done
    fi
fi

# ⏪ Kembali ke menu
read -n 1 -s -r -p "Tekan tombol apa saja untuk kembali ke menu..."
menu
}


function limit_ssh(){
clear

# Hitung jumlah user SSH dari file konfigurasi
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/ssh")

# Jika tidak ada user, tampilkan pesan dan kembali ke menu
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
    clear
    echo "Tidak ada user!"
    read -n 1 -s -r -p "Press any key to back to menu"
    m-sshovpn
    exit 0
fi

# Tampilkan daftar user
clear
echo "Select the existing client you want to change IP limit"
echo "Ketik [0] untuk kembali ke menu"

# Tampilkan daftar user dengan nomor
grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 2-3 | nl -s ') '

# Loop hingga user memilih client yang valid
until [[ ${CLIENT_NUMBER} =~ ^[0-9]+$ && ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
    read -rp "Select one client [1-${NUMBER_OF_CLIENTS} or 0 to cancel]: " CLIENT_NUMBER
    if [[ ${CLIENT_NUMBER} == '0' ]]; then
        m-sshovpn
        exit 0
    fi
done

# Validasi input IP limit
until [[ ${iplim} =~ ^[0-9]+$ ]]; do
    read -rp "Limit User (IP) Baru: " iplim
done

# Pastikan direktori penyimpanan limit IP ada
mkdir -p /etc/xray/sshx

# Ambil username dan expiry dari daftar berdasarkan pilihan user
user=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}p")
exp=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}p")

# Simpan IP limit ke file
echo "${iplim}" > /etc/xray/sshx/${user}IP

MSG1=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
<b>SETTING LIMIT LOGIN</b>
━━━━━━━━━━━━━━━━━━━━
<b>Domain :</b> <code>${DOMAINZ}</code>
<b>ISP :</b> <code>${ISP}</code>
<b>Kota :</b> <code>${CITY}</code>
<b>Username :</b> <code>${user}</code>
<b>Limit Baru :</b> <code>${iplim} IP</code>
<b>Expired :</b> <code>${exp}</code>
━━━━━━━━━━━━━━━━━━━━
EOF
)

curl -s --max-time ${TIMES} -d "chat_id=${CHAT_ID2}&disable_web_page_preview=1&text=${MSG}&parse_mode=html" ${URL} >/dev/null

clear

info=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
SETTING LIMIT LOGIN
━━━━━━━━━━━━━━━━━━━━
Domain : ${DOMAINZ}
ISP : ${ISP}
Kota : ${CITY}
Username : ${user}
Limit Baru : ${iplim} IP
Expired : ${exp}
━━━━━━━━━━━━━━━━━━━━
EOF
)

# Tampilkan log
echo -e "${info}"

read -n 1 -s -r -p "Press any key to back to menu"
menu
}


function scan_ssh(){
clear

LOCK_FILE="/etc/typessh"
CRON_FILE="/etc/cron.d/tendang"

# Fungsi menampilkan status autolock
show_status() {
    if [[ -f "$LOCK_FILE" && $(<"$LOCK_FILE") == "lock" ]]; then
        echo -e "🔒 Status Auto Lock: \033[1;32mON\033[0m"
    else
        echo -e "🔓 Status Auto Lock: \033[1;31mOFF\033[0m"
    fi
}

# Tampilkan status awal
clear

show_status
echo -e "1) Aktifkan Auto Lock"
echo -e "2) Nonaktifkan Auto Lock"
echo -e "3) Keluar"
echo -ne "\nPilih opsi [1-3]: "
read opsi

case $opsi in
    1)
        echo "lock" > "$LOCK_FILE"
        echo -e "\n✅ Auto Lock telah diaktifkan."
        echo -e "Jika user melanggar, akun akan dikunci otomatis."

        # Minta input interval waktu scan (menit)
        while true; do
            read -rp "🕒 Masukkan interval scan (dalam menit): " notif2
            if [[ $notif2 =~ ^[0-9]+$ ]]; then
                break
            else
                echo "⚠️ Masukkan hanya angka."
            fi
        done

        # Tulis cron job untuk eksekusi tendang
        cat > "$CRON_FILE" <<EOF
# Autokill SSH User
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/$notif2 * * * * root /usr/bin/tendang
EOF
        echo -e "✅ Cron Auto Lock diatur setiap $notif2 menit."
        ;;

    2)
        # Nonaktifkan autolock
        rm -f "$LOCK_FILE"
        rm -f "$CRON_FILE"
        echo -e "\n❌ Auto Lock telah dinonaktifkan."
        ;;

    3)
        menu
        ;;

    *)
        echo -e "\n❌ Opsi tidak valid."
        ;;
esac

read -n 1 -s -r -p "Press any key to back to menu"
menu
}


function unlock_ssh(){
clear

LISTLOCK="/etc/xray/sshx/listlock"

# Pastikan file listlock ada
[[ ! -e $LISTLOCK ]] && echo "" > $LISTLOCK

# Hitung jumlah user yang terkunci
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "$LISTLOCK")

# Jika tidak ada user terkunci
if [[ $NUMBER_OF_CLIENTS == "0" ]]; then
    echo -e "⚠️  Tidak ada user yang terkunci.\n"
    read -n 1 -s -r -p "Tekan tombol apa saja untuk kembali ke menu..."
    m-sshovpn
    exit 0
fi

# Tampilkan menu unlock
clear
echo " Pilih user yang ingin di-unlock:"
echo "   • Ketik [0] untuk kembali ke menu"
echo "   • Ketik [clear] untuk menghapus semua akun terkunci"
echo ""
echo "     No | Username | Expired"
grep -E "^### " "$LISTLOCK" | cut -d ' ' -f 2-3 | nl -s ') '

# Input pilihan user
while true; do
    read -rp "Pilih user [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER

    case $CLIENT_NUMBER in
        0)
            m-sshovpn
            exit 0
            ;;
        clear)
            rm -f "$LISTLOCK"
            echo -e "\n✅ Semua akun terkunci telah dihapus!"
            sleep 1
            m-sshovpn
            exit 0
            ;;
        *)
            if [[ $CLIENT_NUMBER =~ ^[0-9]+$ && $CLIENT_NUMBER -ge 1 && $CLIENT_NUMBER -le $NUMBER_OF_CLIENTS ]]; then
                break
            else
                echo "⚠️  Input tidak valid, silakan coba lagi."
            fi
            ;;
    esac
done

# Ambil data user berdasarkan input
user=$(grep -E "^### " "$LISTLOCK" | cut -d ' ' -f2 | sed -n "${CLIENT_NUMBER}p")
exp=$(grep -E "^### " "$LISTLOCK" | cut -d ' ' -f3 | sed -n "${CLIENT_NUMBER}p")
pass=$(grep -E "^### " "$LISTLOCK" | cut -d ' ' -f4 | sed -n "${CLIENT_NUMBER}p")

# Unlock akun
passwd -u "$user" &>/dev/null

# Tambahkan kembali ke daftar aktif
echo "### $user $exp $pass" >> /etc/xray/ssh

# Hapus dari listlock
sed -i "/^### $user $exp $pass/d" "$LISTLOCK" &>/dev/null

echo -e "\n✅ Akun '${user}' berhasil di-unlock!"

read -n 1 -s -r -p "Press any key to back to menu"
menu
}


clear

# Buat garis horizontal sepanjang 44 karakter
LINE=$(printf '━%.0s' {1..44})

clear
echo -e "${COLOR1}╭${LINE}╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}${WH}  • SSH PANEL MENU •${NC}"
echo -e "${COLOR1}╰${LINE}╯${NC}\n"

echo -e "${COLOR1}╭${LINE}╮${NC}"
echo -e "${COLOR1}│${NC}  ${WH}[01]${NC} ${COLOR1}• ${WH}ADD AKUN${NC}"
echo -e "${COLOR1}│${NC}  ${WH}[02]${NC} ${COLOR1}• ${WH}TRIAL AKUN${NC}"
echo -e "${COLOR1}│${NC}  ${WH}[03]${NC} ${COLOR1}• ${WH}RENEW AKUN${NC}"
echo -e "${COLOR1}│${NC}  ${WH}[04]${NC} ${COLOR1}• ${WH}DELETE AKUN${NC}"
echo -e "${COLOR1}│${NC}  ${WH}[05]${NC} ${COLOR1}• ${WH}CEK USER ONLINE${NC}"
echo -e "${COLOR1}│${NC}  ${WH}[06]${NC} ${COLOR1}• ${WH}CEK USER CONFIG${NC}"
echo -e "${COLOR1}│${NC}  ${WH}[07]${NC} ${COLOR1}• ${WH}CHANGE IP LIMIT${NC}"
echo -e "${COLOR1}│${NC}  ${WH}[08]${NC} ${COLOR1}• ${WH}SETTING AUTOLOCK${NC}"
echo -e "${COLOR1}│${NC}  ${WH}[09]${NC} ${COLOR1}• ${WH}UNLOCK LOGIN${NC}"
echo -e "${COLOR1}│${NC}  ${WH}[10]${NC} ${COLOR1}• ${WH}DELETE LOCKED${NC}"
echo -e "${COLOR1}│${NC}  ${WH}[00]${NC} ${COLOR1}• ${WH}GO BACK${NC}"
echo -e "${COLOR1}╰${LINE}╯${NC}\n"

# Prompt pemilihan menu
echo -ne " ${WH}Select menu ${COLOR1}: ${WH}" && read opt

# Eksekusi sesuai pilihan
case $opt in
    1|01)    clear; add_ssh           ;;
    2|02)    clear; trial_ssh         ;;
    3|03)    clear; renew_ssh         ;;
    4|04)    clear; hapus_ssh         ;;
    5|05)    clear; login_ssh         ;;
    6|06)    clear; check_ssh         ;;
    7|07)    clear; limit_ssh         ;;
    8|08)    clear; scan_ssh          ;;
    9|09)    clear; unlock_ssh        ;;
   10)       clear; delete_lock_ssh  ;;
    0|00)    clear; menu              ;;
    x|X)     clear; m-sshovpn         ;;
    *)       echo -e "\n${COLOR1}⚠️  Input tidak valid!${NC}"; sleep 1; m-sshovpn ;;
esac
