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
AUTHOR=$(cat /etc/profil)
DOMAINZ=$(cat /etc/xray/domain)
SLOWDNS_DOMAIN=$(cat /etc/domain/nsdomain)
SLOWDNS_KEY=$(cat /etc/slowdns/server.pub)
TIME2="$(LC_TIME=id_ID.UTF-8 date '+%A, %d %B %Y - %H:%M WIB')"

# Telegram bot utama
TEXT1=$(cat /etc/notifsatu)
TEXT2=$(cat /etc/notifdua)
TIMES="10"
KEY=$(cat /etc/per/token)
CHAT_ID1=$(cat /etc/per/id)
BOT_TOKEN=$(cat /etc/per/token)
URL="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage"

CHAT_ID2=$(cat /etc/perlogin/id)
BOT_TOKEN2=$(cat /etc/perlogin/token)
URL2="https://api.telegram.org/bot${BOT_TOKEN2}/sendMessage"

# Pastikan direktori akun SSH tersedia
mkdir -p /etc/vless/akun


# Fungsi untuk menambahkan akun vless
function add_vless() {
    clear

    logfile="/etc/vless/akun/log-create-${user}.log"

    # Fungsi cetak log sekaligus
    print_log() {
      echo -e "$1" | tee -a "$logfile"
    }
    # Fungsi untuk memeriksa apakah username sudah ada
    check_username() {
        local user="$1"
        grep -w "$user" /etc/xray/config.json | wc -l
    }

    # Input username dengan validasi (hanya huruf dan angka)
    while true; do
        read -rp "Username (hanya angka dan huruf): " user
        if [[ ! "$user" =~ ^[a-zA-Z0-9]+$ ]]; then
            echo -e "${COLOR1}Username hanya boleh berisi huruf dan angka!${COLOR1}"
            continue
        fi

        user_exists=$(check_username "$user")
        if [[ "$user_exists" -eq 1 ]]; then
            echo -e "${COLOR1}Username sudah ada, silakan gunakan nama lain!${COLOR1}"
            read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
            clear
            add_vless
        else
            break
        fi
    done

    # Generate UUID
    uuid=$(cat /proc/sys/kernel/random/uuid)

    # Input masa aktif dengan validasi (hanya angka)
    while true; do
        read -rp "Masa aktif (hari): " plus_hari
        if [[ ! "$plus_hari" =~ ^[0-9]+$ ]]; then
            echo -e "${COLOR1}Masa aktif harus berupa angka!${COLOR1}"
            continue
        fi
        exp=$(date -d "$plus_hari days" +"%Y-%m-%d")
        break
    done

    # Input limit IP dengan validasi (hanya angka)
    while true; do
        read -rp "Limit User (IP, 0 untuk Unlimited): " iplim
        if [[ ! "$iplim" =~ ^[0-9]+$ ]]; then
            echo -e "${COLOR1}Limit IP harus berupa angka!${COLOR1}"
            continue
        fi
        break
    done

    # Input Telegram ID
    read -rp "Masukkan Telegram ID (Kosong jika ingin dilewati): " telegram_id

    # ✅ Validasi Telegram ID dengan fallback ke CHAT_ID
    if [[ -n "$telegram_id" && "$telegram_id" =~ ^[0-9]+$ ]]; then
        USER_ID="$telegram_id"
    elif [[ -z "$telegram_id" ]]; then
        echo "ℹ️ Telegram ID tidak diberikan. Menggunakan CHAT_ID sebagai default."
        USER_ID="${CHAT_ID1}"
    else
        echo "⚠️ Telegram ID tidak valid. Menggunakan CHAT_ID sebagai default."
        USER_ID="${CHAT_ID1}"
    fi


    # Membuat folder vless jika belum ada
    if [[ ! -d /etc/vless ]]; then
        mkdir -p /etc/vless
    fi

    # Mengatur limit IP
    if [[ "$iplim" == "0" ]]; then
        iplim="999"
    fi

    # Menyimpan limit IP
    echo "${iplim}" > /etc/vless/"${user}"IP

# Tambahkan konfigurasi user vless ke config Xray

CONFIG_FILE="/etc/xray/config.json"

# Add VLESS WS and gRPC configurations to Xray config
sed -i "/#vless$/a\
#vl $user $exp $uuid\\
},{\"id\": \"$uuid\",\"email\": \"$user\"}" /etc/xray/config.json

sed -i "/#vlessgrpc$/a\
#vlg $user $exp\\
},{\"id\": \"$uuid\",\"email\": \"$user\"}" /etc/xray/config.json

# VLESS WS and gRPC links
vlesslink_tls="vless://${uuid}@${DOMAINZ}:443?path=/vless&security=tls&encryption=none&host=${DOMAINZ}&type=ws&sni=${DOMAINZ}#${user}"
vlesslink_nontls="vless://${uuid}@${DOMAINZ}:80?path=/vless&security=none&encryption=none&host=${DOMAINZ}&type=ws#${user}"
vlesslink_grpc="vless://${uuid}@${DOMAINZ}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=${DOMAINZ}#${user}"

# URL-encoded VLESS links
vlesslink_tls_enc="vless://${uuid}@${DOMAINZ}:443?path=/vless%26security=tls%26encryption=none%26host=${DOMAINZ}%26type=ws%26sni=${DOMAINZ}#${user}"
vlesslink_nontls_enc="vless://${uuid}@${DOMAINZ}:80?path=/vless%26security=none%26encryption=none%26host=${DOMAINZ}%26type=ws#${user}"
vlesslink_grpc_enc="vless://${uuid}@${DOMAINZ}:443?mode=gun%26security=tls%26encryption=none%26type=grpc%26serviceName=vless-grpc%26sni=${DOMAINZ}#${user}"


MSG1=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
<b>INFORMASI AKUN VLESS</b>
━━━━━━━━━━━━━━━━━━━━
<b>Username :</b> <code>${user}</code>
<b>Domain :</b> <code>${DOMAINZ}</code>
<b>Login Max :</b> ${iplim} IP
<b>Expired :</b> ${exp}
━━━━━━━━━━━━━━━━━━━━
<b>ISP :</b> ${ISP}
<b>CITY :</b> ${CITY}
<b>Port N-TLS :</b> 80
<b>Port TLS/GRPC :</b> 443
<b>UUID :</b> <code>${uuid}</code>
<b>AlterId :</b> 0
<b>Security :</b> auto
<b>Network :</b> WS or gRPC
<b>Path WS :</b> <code>/vless</code>
<b>Path GRPC :</b> <code>vless-grpc</code>
━━━━━━━━━━━━━━━━━━━━
<b>Link N-TLS :</b>
<pre>${vlesslink_nontls_enc}</pre>
━━━━━━━━━━━━━━━━━━━━
<b>Link TLS :</b>
<pre>${vlesslink_tls_enc}</pre>
━━━━━━━━━━━━━━━━━━━━
<b>Link GRPC :</b>
<pre>${vlesslink_grpc_enc}</pre>
━━━━━━━━━━━━━━━━━━━━
EOF
)

#user2=$(echo "$user" | cut -c 1-3)

MSG2=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
<b>NOTIFIKASI</b>
━━━━━━━━━━━━━━━━━━━━
<b>Detail :</b> Buat baru VLess
<b>ISP :</b> ${ISP}
<b>Kota :</b> ${CITY}
<b>Username :</b> ${user}
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
INFORMASI AKUN VLESS
━━━━━━━━━━━━━━━━━━━━
Username : ${user}
Domain : ${DOMAINZ}
Login Max : ${iplim} IP
Expired : ${exp}
━━━━━━━━━━━━━━━━━━━━
ISP : ${ISP}
CITY : ${CITY}
Port N-TLS : 80
Port TLS/GRPC : 443
UUID : ${uuid}
AlterId : 0
Security : auto
Network : WS or gRPC
Path TLS : /vless
Path GRPC : vless-grpc
━━━━━━━━━━━━━━━━━━━━
Link N-TLS :
${vlesslink_nontls}
━━━━━━━━━━━━━━━━━━━━
Link TLS :
${vlesslink_tls}
━━━━━━━━━━━━━━━━━━━━
Link GRPC :
${vlesslink_grpc}
━━━━━━━━━━━━━━━━━━━━
EOF
)

# Cetak seluruh log sekaligus
print_log "${info_log}"

systemctl restart xray > /dev/null 2>&1
read -n 1 -s -r -p "Press any key to back on menu"
m-vless
}


function trial_vless() {
    clear

    logfile="/etc/vless/akun/log-create-${user}.log"

    # Fungsi cetak log sekaligus
    print_log() {
      echo -e "$1" | tee -a "$logfile"
    }

    # 🔢 Validasi input angka untuk expired (menit)
    local timer=""
    while true; do
        read -p "Expired (Minutes): " timer
        [[ "$timer" =~ ^[0-9]+$ ]] && break
        echo "⚠️ Masukkan angka saja!"
    done

    # Input Telegram ID
    read -rp "Masukkan Telegram ID (Kosong jika ingin dilewati): " telegram_id
    
    # ✅ Validasi Telegram ID dengan fallback ke CHAT_ID
    if [[ -n "$telegram_id" && "$telegram_id" =~ ^[0-9]+$ ]]; then
        USER_ID="$telegram_id"
    elif [[ -z "$telegram_id" ]]; then
        #echo "ℹ️ Telegram ID tidak diberikan. Menggunakan CHAT_ID sebagai default."
        USER_ID="${CHAT_ID1}"
    else
        #echo "⚠️ Telegram ID tidak valid. Menggunakan CHAT_ID sebagai default."
        USER_ID="${CHAT_ID1}"
    fi
    
    # 📦 Inisialisasi akun trial
    local user="Tes-$(tr -dc 'X-Z0-9' </dev/urandom | head -c4)"
    local uuid=$(cat /proc/sys/kernel/random/uuid)
    local plus_hari=1
    local iplim=1

    # 🗂️ Pastikan direktori konfigurasi tersedia
    mkdir -p /etc/vless

    # 🌐 Atur batasan IP
    echo "$iplim" > "/etc/vless/${user}IP"

    # 📆 Hitung tanggal expired
    local exp=$(date -d "$plus_hari days" +"%Y-%m-%d")

# Tambahkan konfigurasi user vless ke config Xray

CONFIG_FILE="/etc/xray/config.json"

# Add VLESS WS and gRPC configurations to Xray config
sed -i "/#vless$/a\
#vl $user $exp $uuid\\
},{\"id\": \"$uuid\",\"email\": \"$user\"}" /etc/xray/config.json

sed -i "/#vlessgrpc$/a\
#vlg $user $exp\\
},{\"id\": \"$uuid\",\"email\": \"$user\"}" /etc/xray/config.json

# VLESS WS and gRPC links
vlesslink_tls="vless://${uuid}@${DOMAINZ}:443?path=/vless&security=tls&encryption=none&host=${DOMAINZ}&type=ws&sni=${DOMAINZ}#${user}"
vlesslink_nontls="vless://${uuid}@${DOMAINZ}:80?path=/vless&security=none&encryption=none&host=${DOMAINZ}&type=ws#${user}"
vlesslink_grpc="vless://${uuid}@${DOMAINZ}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=${DOMAINZ}#${user}"

# URL-encoded VLESS links
vlesslink_tls_enc="vless://${uuid}@${DOMAINZ}:443?path=/vless%26security=tls%26encryption=none%26host=${DOMAINZ}%26type=ws%26sni=${DOMAINZ}#${user}"
vlesslink_nontls_enc="vless://${uuid}@${DOMAINZ}:80?path=/vless%26security=none%26encryption=none%26host=${DOMAINZ}%26type=ws#${user}"
vlesslink_grpc_enc="vless://${uuid}@${DOMAINZ}:443?mode=gun%26security=tls%26encryption=none%26type=grpc%26serviceName=vless-grpc%26sni=${DOMAINZ}#${user}"


# 🗓️ Tambahkan cron job untuk hapus akun trial + bersihkan config
cat > "/etc/cron.d/expire-trial-${user}" <<EOF
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin

*/$timer * * * * root \
    rm -f /etc/vless/${user}IP /etc/cron.d/expire-trial-${user} && \
    sed -i "/#vl $user/d" /etc/xray/config.json && \
    sed -i "/#vlg $user/d" /etc/xray/config.json && \
    systemctl restart xray > /dev/null 2>&1
EOF


MSG1=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
<b>INFORMASI TRIAL VLESS</b>
━━━━━━━━━━━━━━━━━━━━
<b>Username :</b> <code>${user}</code>
<b>Domain :</b> <code>${DOMAINZ}</code>
<b>Login Max :</b> ${iplim} IP
<b>Expired :</b> ${timer}
━━━━━━━━━━━━━━━━━━━━
<b>ISP :</b> ${ISP}
<b>CITY :</b> ${CITY}
<b>Port N-TLS :</b> 80
<b>Port TLS/GRPC :</b> 443
<b>UUID :</b> <code>${uuid}</code>
<b>AlterId :</b> 0
<b>Security :</b> auto
<b>Network :</b> WS or gRPC
<b>Path TLS :</b> <code>/vless</code>
<b>Path GRPC :</b> <code>vless-grpc</code>
━━━━━━━━━━━━━━━━━━━━
<b>Link N-TLS :</b>
<pre>${vlesslink_nontls_enc}</pre>
━━━━━━━━━━━━━━━━━━━━
<b>Link TLS :</b>
<pre>${vlesslink_tls_enc}</pre>
━━━━━━━━━━━━━━━━━━━━
<b>Link GRPC :</b>
<pre>${vlesslink_grpc_enc}</pre>
━━━━━━━━━━━━━━━━━━━━
EOF
)

#user2=$(echo "$user" | cut -c 1-4)

MSG2=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
<b>NOTIFIKASI</b>
━━━━━━━━━━━━━━━━━━━━
<b>Detail :</b> Buat trial VLess
<b>ISP :</b> ${ISP}
<b>Kota :</b> ${CITY}
<b>Username :</b> <code>${user}
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
INFORMASI TRIAL VLESS
━━━━━━━━━━━━━━━━━━━━
Username : ${user}
Domain : ${DOMAINZ}
Login Max : ${iplim} IP
Expired : ${timer}
━━━━━━━━━━━━━━━━━━━━
ISP : ${ISP}
CITY : ${CITY}
Port N-TLS : 80
Port TLS/GRPC : 443
UUID : ${uuid}
AlterId : 0
Security : auto
Network : WS or gRPC
Path TLS : /vless
Path GRPC : vless-grpc
━━━━━━━━━━━━━━━━━━━━
Link N-TLS :
${vlesslink_nontls}
━━━━━━━━━━━━━━━━━━━━
Link TLS :
${vlesslink_tls}
━━━━━━━━━━━━━━━━━━━━
Link GRPC :
${vlesslink_grpc}
━━━━━━━━━━━━━━━━━━━━
EOF
)

# Cetak seluruh log sekaligus
print_log "${info_log}"

systemctl restart xray > /dev/null 2>&1
read -n 1 -s -r -p "Press any key to back on menu"
m-vless
}

function renew_vless(){
# 📋 Tampilkan daftar user yang tersedia
clear
echo "📦 Daftar user yang tersedia:"
echo "-----------------------------------"
grep -E "^#vl " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | awk '{printf "🔹 %s (Expired: %s)\n", $1, $2}'
echo ""
read -rp "🧾 Masukkan username yang ingin diperpanjang (atau ketik 0 untuk kembali): " user

# ⏪ Jika input adalah 0, kembali ke menu
if [[ "$user" == "0" ]]; then
    m-vless
    exit
fi

# 🔍 Periksa apakah username ada
cek_user=$(grep -wE "^#vl $user" "/etc/xray/config.json")
if [[ -z "$cek_user" ]]; then
    echo "🚫 User '$user' tidak ditemukan!"
    read -n 1 -s -r -p "🔙 Tekan tombol apa saja untuk kembali ke menu..."
    m-vless
    exit
fi

# 🕒 Input jumlah hari tambahan
while true; do
    read -rp "➕ Tambah berapa hari: " plus_hari
    [[ "$plus_hari" =~ ^[0-9]+$ ]] && break
    echo "❌ Input tidak valid. Harus berupa angka!"
done

# 📨 Input Telegram ID (optional)
read -p "📨 Masukkan Telegram ID (biarkan kosong untuk melewati): " telegram_id
if [[ -n "$telegram_id" && "$telegram_id" =~ ^[0-9]+$ ]]; then
    USER_ID="$telegram_id"
else
    USER_ID="${CHAT_ID1}"
fi

# 📅 Hitung dan perbarui masa berlaku
exp=$(echo "$cek_user" | awk '{print $3}')
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
sisa_hari=$(( (d1 - d2) / 86400 ))
total_hari=$(( sisa_hari + plus_hari ))
exp_baru=$(date -d "$total_hari days" +"%Y-%m-%d")

# 🛠️ Update konfigurasi di config.json
sed -i "s/#vl $user $exp/#vl $user $exp_baru/" /etc/xray/config.json
sed -i "s/#vlg $user $exp/#vlg $user $exp_baru/" /etc/xray/config.json


MSG1=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
<b>TAMBAH MASA AKTIF</b>
━━━━━━━━━━━━━━━━━━━━
<b>Protokol :</b> VLess
<b>Domain :</b> ${DOMAINZ}
<b>ISP :</b> ${ISP}
<b>Kota :</b> ${CITY}
<b>Username :</b> ${user}
<b>Durasi :</b> ${plus_hari} Hari
<b>Expired Baru :</b> ${exp_baru}
━━━━━━━━━━━━━━━━━━━━
EOF
)

#user2=$(echo "${user}" | cut -c 1-3)
MSG2=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
<b>NOTIFIKASI</b>
━━━━━━━━━━━━━━━━━━━━
<b>Detail :</b> Tambah masa aktif VLess
<b>ISP :</b> ${ISP}
<b>Kota :</b> ${CITY}
<b>Username :</b> ${user}
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
info=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
TAMBAH MASA AKTIF
━━━━━━━━━━━━━━━━━━━━
Protokol : VLess
Domain : ${DOMAINZ}
ISP : ${ISP}
Kota : ${CITY}
Username : ${user}
Durasi : ${plus_hari} Hari
Expired Baru : ${exp_baru}
━━━━━━━━━━━━━━━━━━━━
EOF
)

# Tampilkan log
echo -e "${info}"

systemctl restart xray > /dev/null 2>&1
read -n 1 -s -r -p "Press any key to back on menu"
m-vless
}


function limit_vless(){
clear
# 🔎 Hitung jumlah user yang tersedia
NUMBER_OF_CLIENTS=$(grep -cE "^#vl " "/etc/xray/config.json")

# 🚫 Cek jika tidak ada user
if [[ "$NUMBER_OF_CLIENTS" -eq 0 ]]; then
    clear
    echo "🚫 Tidak ada user!"
    read -n 1 -s -r -p "🔙 Tekan tombol apa saja untuk kembali ke menu..."
    m-vless
    exit
fi

clear
echo "📦 Daftar user yang tersedia:"
echo "-----------------------------------"
echo "     No  |  Username  |  Expired"
grep -E "^#vl " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | nl -s ') '

echo ""
echo "🔁 Pilih user untuk ubah limit IP dan kuota"
echo "➡️  Ketik [0] untuk kembali ke menu"

# 🎯 Input pilihan user
while true; do
    read -rp "Pilih nomor [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
    if [[ "$CLIENT_NUMBER" == "0" ]]; then
        m-vless
        exit
    elif [[ "$CLIENT_NUMBER" =~ ^[0-9]+$ ]] && (( CLIENT_NUMBER >= 1 && CLIENT_NUMBER <= NUMBER_OF_CLIENTS )); then
        break
    else
        echo "❌ Input tidak valid!"
    fi
done

clear

# 📥 Input limit IP dan kuota
while true; do
    read -p "🔐 Limit User (IP) [0 untuk Unlimited]: " iplim
    [[ "$iplim" =~ ^[0-9]+$ ]] && break
    echo "❌ Masukkan angka saja!"
done

# Input Telegram ID
read -p "Masukkan Telegram ID (Kosong jika ingin dilewati): " telegram_id

# ✅ Validasi Telegram ID dengan fallback ke CHAT_ID
if [[ -n "$telegram_id" && "$telegram_id" =~ ^[0-9]+$ ]]; then
    USER_ID="$telegram_id"
elif [[ -z "$telegram_id" ]]; then
    USER_ID="${CHAT_ID1}"
else
    USER_ID="${CHAT_ID1}"
fi

# 📂 Pastikan direktori vless tersedia
mkdir -p /etc/vless

# 🔄 Konversi nilai unlimited
[[ "$iplim" == "0" ]] && iplim="999"

# 🔎 Ambil username dari nomor input
user=$(grep -E "^#vl " "/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}p")

# 💾 Simpan konfigurasi IP dan kuota
echo "$iplim" > "/etc/vless/${user}IP"


MSG1=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
<b>SETTING LIMIT</b>
━━━━━━━━━━━━━━━━━━━━
<b>Protokol :</b> VLess
<b>Domain :</b> ${DOMAINZ}
<b>ISP :</b> ${ISP}
<b>Kota :</b> ${CITY}
<b>Username :</b> ${user}
<b>Login Max Baru :</b> ${iplim} IP
━━━━━━━━━━━━━━━━━━━━
EOF
)

curl -s --max-time "${TIMES}" \\
  -d "chat_id=${USER_ID}" \\
  -d "disable_web_page_preview=1" \\
  -d "text=${MSG1}" \\
  -d "parse_mode=html" \\
  "https://api.telegram.org/bot${KEY}/sendMessage" >/dev/null

clear

# Gabungkan semua isi log dalam satu variabel
info=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
SETTING LIMIT
━━━━━━━━━━━━━━━━━━━━
Protokol : VLess
Domain : ${DOMAINZ}
ISP : ${ISP}
Kota : ${CITY}
Username : ${user}
Login Max Baru : ${iplim} IP
━━━━━━━━━━━━━━━━━━━━
EOF
)

# Tampilkan log
echo -e "${info}"

read -n 1 -s -r -p "Press any key to back on menu"
m-vless
}


function delete_vless(){
clear
# 🚀 Ambil jumlah akun yang terdaftar
NUMBER_OF_CLIENTS=$(grep -cE "^#vl " "/etc/xray/config.json")

# 🚫 Jika tidak ada akun
if [[ "$NUMBER_OF_CLIENTS" -eq 0 ]]; then
    echo -e "\n❌ Tidak ada user terdaftar!"
    read -n 1 -s -r -p "🔙 Tekan tombol apa saja untuk kembali ke menu..."
    m-vless
    exit
fi

clear
echo "📦 Daftar user yang tersedia:"
echo "-----------------------------------"
echo "     No | Username | Expired Date"
grep -E "^#vl " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | nl -s ') '
echo ""
echo "➡️  Ketik nomor user yang ingin dihapus"
echo "↩️  Ketik [0] untuk kembali ke menu"

# 🎯 Input pilihan user
while true; do
    read -rp "Pilih nomor [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
    if [[ "$CLIENT_NUMBER" == "0" ]]; then
        m-vless
        exit
    elif [[ "$CLIENT_NUMBER" =~ ^[0-9]+$ ]] && (( CLIENT_NUMBER >= 1 && CLIENT_NUMBER <= NUMBER_OF_CLIENTS )); then
        break
    else
        echo "❌ Input tidak valid!"
    fi
done

# 🔎 Ambil detail user berdasarkan nomor
user=$(grep -E "^#vl " "/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}p")
exp=$(grep -E "^#vl " "/etc/xray/config.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}p")
uuid=$(grep -E "^#vl " "/etc/xray/config.json" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}p")

# 📂 Simpan info akun yang dihapus
mkdir -p /etc/vless
echo "### $user $exp $uuid" >> /etc/vless/akundelete

# 🧹 Hapus konfigurasi dari Xray
sed -i "/^#vl $user $exp/,/^},{/d" /etc/xray/config.json
sed -i "/^#vlg $user $exp/,/^},{/d" /etc/xray/config.json

# 🗑️ Hapus file terkait user
rm -f /etc/vless/"${user}"IP
rm -f /etc/vless/"${user}"login
rm -f /etc/vless/akun/log-create-"${user}".log

# 🔄 Restart Xray agar perubahan berlaku
systemctl restart xray > /dev/null 2>&1

clear

MSG1=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
<b>HAPUS AKUN</b>
━━━━━━━━━━━━━━━━━━━━
<b>Protokol :</b> VLess
<b>Domain :</b> ${DOMAINZ}
<b>ISP :</b> ${ISP}
<b>Kota :</b> ${CITY}
<b>Username :</b> ${user}
<b>Expired :</b> ${exp}
━━━━━━━━━━━━━━━━━━━━
EOF
)

curl -s --max-time "${TIMES}" \\
  -d "chat_id=${USER_ID}" \\
  -d "disable_web_page_preview=1" \\
  -d "text=${MSG1}" \\
  -d "parse_mode=html" \\
  "https://api.telegram.org/bot${KEY}/sendMessage" >/dev/null

clear

# Gabungkan semua isi log dalam satu variabel
info=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
HAPUS AKUN
━━━━━━━━━━━━━━━━━━━━
Protokol : VLess
Domain : ${DOMAINZ}
ISP : ${ISP}
Kota : ${CITY}
Username : ${user}
Expired : ${exp}
━━━━━━━━━━━━━━━━━━━━
EOF
)

# Tampilkan log
echo -e "${info}"

read -n 1 -s -r -p "Press any key to back on menu"
m-vless
}


# Fungsi untuk mengkonversi waktu dalam format detik (tim2sec)
tim2sec() {
  local mult=1
  local arg="$1"
  local inu=0
  
  while [ ${#arg} -gt 0 ]; do
    local prev="${arg%:*}"
    
    if [ "$prev" = "$arg" ]; then
      local curr="${arg#0}"
      prev=""
    else
      local curr="${arg##*:}"
      curr="${curr#0}"
    fi
    
    curr="${curr%.*}"
    inu=$((inu + curr * mult))
    mult=$((mult * 60))
    arg="$prev"
  done
  
  echo "$inu"
}

# Fungsi untuk mengkonversi bytes ke satuan yang lebih besar (human_readable)
human_readable() {
  local bytes=$1
    local unit=('B' 'KB' 'MB' 'GB' 'TB')
    for u in "${unit[@]}"; do
      if (( bytes < 1024 )); then
        printf "%.2f %s" "$bytes" "$u"
        return
      fi
      bytes=$((bytes / 1024))
    done
    printf "%.2f %s" "$bytes" "PB"
}


function check_xray() {
  clear
  local log_file='/var/log/xray/access.log'
  local config_file='/etc/xray/config.json'
  local log_thresh=5
  local login_window=40
  local tmpdir

  # buat tmpdir dan register cleanup otomatis
  tmpdir=$(mktemp -d 2>/dev/null) || { echo "❌ Gagal membuat direktori temporer"; return 1; }
  trap 'rm -rf "$tmpdir"' EXIT

  # fungsi konversi waktu ke detik epoch, fallback ke sekarang
  to_epoch() {
    date -d "$1" +%s 2>/dev/null || date +%s
  }

  echo "🚀 Mulai pengecekan Xray..."

  # 1) Restart Xray jika log terlalu sedikit
  local line_count
  line_count=$(wc -l < "$log_file")
  if (( line_count <= log_thresh )); then
    echo "🔄 Baris log ($line_count) ≤ $log_thresh → restart Xray..."
    if systemctl restart xray; then
      echo "✅ Xray berhasil di–restart"
    else
      echo "❌ Gagal me–restart Xray"
    fi
  fi

  # 2) Ambil daftar user per protokol
  mapfile -t vmess_users < <(grep '^#vm ' "$config_file" | awk '{print $2}' | sort -u)
  mapfile -t vless_users < <(grep '^#vl ' "$config_file" | awk '{print $2}' | sort -u)
  mapfile -t trojan_users< <(grep '^#tr ' "$config_file" | awk '{print $2}' | sort -u)

  # 3) Proses setiap protokol
  for proto in vmess vless trojan; do
    local users_var="${proto}_users[@]"
    local users=( "${!users_var}" )
    local summary="$tmpdir/${proto}_summary.txt"

    echo
    echo "🔍 Mengecek aktivitas ${proto^^}..."
    > "$summary"

    for user in "${users[@]}"; do
      # kumpulkan IP unik dalam 'login_window' detik terakhir
      local now epoch_client delta raw_ip parsed_ip
      local -a ips=()
      now=$(date +%s)

      # ambil 100 baris terakhir terkait user
      while read -r time_str _ raw; do
        (( ! time_str )) && continue
        epoch_client=$(to_epoch "$time_str")
        delta=$(( now - epoch_client ))
        if (( delta <= login_window )); then
          raw_ip="${raw#tcp://}"
          parsed_ip="${raw_ip%%.*}.${raw_ip#*.}.${raw_ip#*.*.*}"
          parsed_ip="${raw_ip%.*}"      # ip /24
          # tambahkan hanya jika belum ada
          [[ " ${ips[*]} " != *" $parsed_ip "* ]] && ips+=( "$parsed_ip" )
        fi
      done < <(grep -w "email: $user" "$log_file" | tail -n 100)

      if (( ${#ips[@]} > 0 )); then
        # hitung trafik upload & download
        local up down total up_hr down_hr total_hr
        up=$(grep -w "email: $user" "$log_file" \
            | grep -oP '"upload":\K\d+' \
            | paste -sd+ - | bc 2>/dev/null)
        down=$(grep -w "email: $user" "$log_file" \
              | grep -oP '"download":\K\d+' \
              | paste -sd+ - | bc 2>/dev/null)
        up=${up:-0}; down=${down:-0}
        total=$(( up + down ))

        up_hr=$(human_readable "$up")
        down_hr=$(human_readable "$down")
        total_hr=$(human_readable "$total")

        {
          echo "👤 Username : $user"
          echo "🌐 IP Login : ${#ips[@]} (${ips[*]})"
          echo "📤 Upload   : $up_hr"
          echo "📥 Download : $down_hr"
          echo "📦 Total    : $total_hr"
          echo "-------------------------------------"
        } >> "$summary"
      fi
    done

    # tampilkan ringkasan atau peringatan jika kosong
    if [[ -s "$summary" ]]; then
      echo
      echo "===== Ringkasan ${proto^^} ====="
      cat "$summary"
    else
      echo "⚠ Tidak ada aktivitas baru untuk ${proto^^}."
    fi
  done

  echo
  echo "👍 Pengecekan selesai."
  read -n1 -s -r -p "Tekan apa saja untuk kembali ke menu..."
  m-vless
}


function list_vless(){
clear

# 📊 Hitung jumlah akun terdaftar
NUMBER_OF_CLIENTS=$(grep -cE "^#vl " "/etc/xray/config.json")

# 🚫 Jika tidak ada user
if [[ "$NUMBER_OF_CLIENTS" -eq 0 ]]; then
    echo -e "\n❌ Tidak ada user yang tersedia!"
    read -n 1 -s -r -p "🔙 Tekan tombol apa saja untuk kembali ke menu..."
    m-vless
    exit
fi

clear
echo "📦 Daftar user yang tersedia"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " No | Username    | Expired Date"
grep -E "^#vl " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | nl -s ') '
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔁 Ketik [0] untuk kembali ke menu"

# 🎯 Input pilihan user
while true; do
    read -rp "📌 Pilih nomor user [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
    if [[ "$CLIENT_NUMBER" == "0" ]]; then
        m-vless
        exit
    elif [[ "$CLIENT_NUMBER" =~ ^[0-9]+$ ]] && (( CLIENT_NUMBER >= 1 && CLIENT_NUMBER <= NUMBER_OF_CLIENTS )); then
        break
    else
        echo "⚠️ Input tidak valid! Silakan masukkan angka antara 1 dan ${NUMBER_OF_CLIENTS}."
    fi
done

# 🔎 Ambil username berdasarkan nomor input
user=$(grep -E "^#vl " "/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}p")

# 📝 Ambil log pembuatan akun dan simpan ke /etc/notisatu
clear
log_file="/etc/vless/akun/log-create-${user}.log"

if [[ -f "$log_file" ]]; then
    cp "$log_file" /etc/notisatu
    echo -e "✅ Log akun untuk user \033[0;32m'$user'\033[0m telah disalin ke \033[1;33m/etc/notisatu\033[0m"
else
    echo -e "⚠️ Log tidak ditemukan untuk user \033[0;31m'$user'\033[0m"
fi

curl -s --max-time "${TIMES}" \\
  -d "chat_id=${CHAT_ID1}" \\
  -d "disable_web_page_preview=1" \\
  -d "text=${TEXT1}" \\
  -d "parse_mode=html" \\
  "https://api.telegram.org/bot${KEY}/sendMessage" >/dev/null

# 🔙 Kembali ke menu
read -n 1 -s -r -p "🔙 Tekan tombol apa saja untuk kembali ke menu..."
m-vless
}


function login_vless(){
clear

echo -e "🔒 KONFIGURASI SISTEM LOCK MULTI LOGIN"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "📝 Silakan tulis jumlah notifikasi sebelum akun user di-lock:"
echo -e "Contoh: Jika ingin di-lock setelah 3x notifikasi, tulis angka 3."
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 📥 Input jumlah notifikasi
read -rp "Jumlah notifikasi sebelum lock: " -e notif

# 💾 Simpan konfigurasi ke file
notif_file="/etc/vless/notif"
mkdir -p "$(dirname "$notif_file")"
echo "$notif" > "$notif_file"

# 🧹 Bersihkan layar dan tampilkan notifikasi berhasil
clear
echo -e "✅ Konfigurasi berhasil!"
echo -e "🔐 Jumlah notifikasi lock telah diatur ke: \033[0;32m$notif\033[0m"
echo -e "📁 Lokasi file: \033[1;33m$notif_file\033[0m"

# 🔙 Kembali ke menu utama
echo ""
read -n 1 -s -r -p "🔙 Tekan tombol apa saja untuk kembali ke menu..."
m-vless
}


function lock_vless(){
clear

LOCK_FILE="/etc/vless/listlock"
XRAY_CONFIG="/etc/xray/config.json"

# 🗂️ Pastikan file lock ada
[[ ! -e "$LOCK_FILE" ]] && touch "$LOCK_FILE"

# 🔢 Hitung jumlah user yang terkunci
NUMBER_OF_CLIENTS=$(grep -cE "^### " "$LOCK_FILE")

# 🚫 Jika tidak ada user
if [[ "$NUMBER_OF_CLIENTS" -eq 0 ]]; then
    echo -e "\n❌ Tidak ada user yang di-lock!"
    read -n 1 -s -r -p "🔙 Tekan tombol apa saja untuk kembali ke menu..."
    m-vless
    exit
fi

clear
echo -e "🔓 UNLOCK AKUN VLESS TERKUNCI"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "📋 Daftar akun yang terkunci:"
echo -e " No | Username | Expired"
grep -E "^### " "$LOCK_FILE" | cut -d ' ' -f 2-3 | nl -s ') '
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "🔁 Ketik [0] untuk kembali ke menu"
echo -e "🧹 Ketik [999] untuk menghapus SEMUA akun terkunci"

# 🎯 Input pilihan unlock
while true; do
    read -rp "📌 Pilih nomor akun yang ingin di-unlock [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
    case "$CLIENT_NUMBER" in
        0)
            m-vless
            exit
            ;;
        999)
            rm -f "$LOCK_FILE"
            echo -e "🧼 Semua akun telah dihapus dari daftar lock!"
            read -n 1 -s -r -p "🔙 Tekan tombol apa saja untuk kembali..."
            m-vless
            exit
            ;;
        *)
            if [[ "$CLIENT_NUMBER" =~ ^[0-9]+$ ]] && (( CLIENT_NUMBER >= 1 && CLIENT_NUMBER <= NUMBER_OF_CLIENTS )); then
                break
            else
                echo -e "⚠️ Input tidak valid! Silakan masukkan angka yang sesuai."
            fi
            ;;
    esac
done

# 🔍 Ambil data user dari daftar lock
user=$(grep -E "^### " "$LOCK_FILE" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}p")
exp=$(grep -E "^### " "$LOCK_FILE" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}p")
uuid=$(grep -E "^### " "$LOCK_FILE" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}p")

# 🔧 Tambahkan kembali user ke config Xray
sed -i '/#vless$/a\#vl '"$user $exp $uuid"'\
},{"password": "'$uuid'","email": "'$user'"' "$XRAY_CONFIG"
sed -i '/#vlessgrpc$/a\#vlg '"$user $exp"'\
},{"password": "'$uuid'","email": "'$user'"' "$XRAY_CONFIG"

# 🧽 Hapus dari daftar lock
sed -i "/^### $user $exp $uuid/d" "$LOCK_FILE"

# 🔁 Restart Xray
systemctl restart xray

# ✅ Konfirmasi
echo -e "\n✅ Akun \033[0;32m$user\033[0m berhasil di-unlock dan ditambahkan kembali ke Xray."
read -n 1 -s -r -p "🔙 Tekan tombol apa saja untuk kembali ke menu..."
m-vless
}


function restore_vless(){
clear

AKUNDELETE="/etc/vless/akundelete"
XRAY_CONFIG="/etc/xray/config.json"

# 📁 Pastikan file daftar restore tersedia
[[ ! -e "$AKUNDELETE" ]] && touch "$AKUNDELETE"

# 📊 Hitung jumlah akun yang tersedia untuk restore
NUMBER_OF_CLIENTS=$(grep -cE "^### " "$AKUNDELETE")

if [[ "$NUMBER_OF_CLIENTS" -eq 0 ]]; then
    echo -e "\n⚠️ Tidak ada akun expired yang tersedia untuk di-restore!"
    read -n 1 -s -r -p "🔙 Tekan tombol apa saja untuk kembali ke menu..."
    m-vless
    exit
fi

clear
echo -e "♻️ RESTORE AKUN VLESS EXPIRED"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "🔢 Daftar akun yang tersedia untuk dipulihkan:"
echo -e " No | Username | Expired"
grep -E "^### " "$AKUNDELETE" | cut -d ' ' -f 2-3 | nl -s ') '
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "🔁 Ketik [0] untuk kembali ke menu"
echo -e "🧹 Ketik [999] untuk menghapus semua akun expired"

# 🎯 Pilih akun untuk dipulihkan
while true; do
    read -rp "📌 Pilih nomor akun yang ingin di-restore [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
    case "$CLIENT_NUMBER" in
        0)
            m-vless
            exit
            ;;
        999)
            rm -f "$AKUNDELETE"
            echo -e "\n🗑️ Semua akun expired telah dihapus!"
            read -n 1 -s -r -p "🔙 Tekan tombol apa saja untuk kembali..."
            m-vless
            exit
            ;;
        *)
            if [[ "$CLIENT_NUMBER" =~ ^[0-9]+$ ]] && (( CLIENT_NUMBER >= 1 && CLIENT_NUMBER <= NUMBER_OF_CLIENTS )); then
                break
            else
                echo -e "⚠️ Input tidak valid! Silakan pilih angka antara 1 sampai ${NUMBER_OF_CLIENTS}."
            fi
            ;;
    esac
done

# 🔧 Input konfigurasi baru
while [[ ! "$plus_hari" =~ ^[0-9]+$ ]]; do
    read -rp "📅 Masa aktif akun (dalam hari): " plus_hari
done

while [[ ! "$iplim" =~ ^[0-9]+$ ]]; do
    read -rp "🌐 Batas IP (0 untuk unlimited): " iplim
done

# 🔁 Ubah nilai unlimited jika diperlukan
[[ "$iplim" == "0" ]] && iplim="999"

# 🧩 Ambil data akun
user=$(grep -E "^### " "$AKUNDELETE" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}p")
uuid=$(grep -E "^### " "$AKUNDELETE" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}p")
exp=$(date -d "$plus_hari days" +"%Y-%m-%d")

# 🔧 Tambahkan kembali ke config Xray
sed -i "/#vless$/a \
#vl $user $exp $uuid\n\
},{\"password\": \"$uuid\",\"email\": \"$user\"}" "$XRAY_CONFIG"

sed -i "/#vlessgrpc$/a \
#vlg $user $exp\n\
},{\"password\": \"$uuid\",\"email\": \"$user\"}" "$XRAY_CONFIG"

# 💾 Simpan limit IP
echo "$iplim" > "/etc/vless/${user}IP"

# 🧹 Hapus dari daftar expired dan restart
sed -i "/^### ${user} .* ${uuid}/d" "$AKUNDELETE"
systemctl restart xray


MSG1=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
<b>RESTORE ACCOUNT</b>
━━━━━━━━━━━━━━━━━━━━
<b>Protokol :</b> VLESS
<b>Domain :</b> ${DOMAINZ}
<b>ISP :</b> ${ISP}
<b>Kota :</b> ${CITY}
<b>Username :</b> ${user}
<b>Login Max :</b> ${iplim} IP
<b>Expired :</b> ${exp} GB
━━━━━━━━━━━━━━━━━━━━
EOF
)

#user2=$(echo "${user}" | cut -c 1-3)
MSG2=$(cat <<EOF
━━━━━━━━━━━━━━━━━━━━
<b>NOTIFIKASI</b>
━━━━━━━━━━━━━━━━━━━━
<b>Detail :</b> Restore akun VLess
<b>ISP :</b> ${ISP}
<b>Kota :</b> ${CITY}
<b>Username :</b> ${user}
<b>Login Max :</b> ${iplim} IP
<b>Expired :</b> ${exp} GB
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
RESTORE ACCOUNT
━━━━━━━━━━━━━━━━━━━━
Protokol : VLess
Domain : ${DOMAINZ}
ISP : ${ISP}
Kota : ${CITY}
Username : ${user}
Login Max : ${iplim} IP
Expired : ${exp} GB
━━━━━━━━━━━━━━━━━━━━
EOF
)

# Tampilkan log
echo -e "${info}"

read -n 1 -s -r -p "Press any key to back on menu"
m-vless
}

# Ubah UUID pengguna Xray berdasarkan nomor urutan username
uuid_xray() {
  set -euo pipefail

  # Konfigurasi
  CONFIG_FILE="/etc/xray/config.json"

  # Util: echo ke stderr
  _err() { printf '%s\n' "$*" >&2; }

  # Util: trim spasi
  _trim() { sed -e 's/^[[:space:]]\+//' -e 's/[[:space:]]\+$//'; }

  # Util: cek dependency opsional
  _have() { command -v "$1" >/dev/null 2>&1; }

  # Util: escape untuk ERE
  _escape_ere() {
    # Escapes: . [ ] * ^ $ ( ) + ? { } | /
    sed 's/[.[\*^$()+?{|}\/]/\\&/g' <<<"$1"
  }

  # Util: generate UUID (beberapa fallback)
  _gen_uuid() {
    if _have uuidgen; then
      uuidgen
    elif [ -r /proc/sys/kernel/random/uuid ]; then
      cat /proc/sys/kernel/random/uuid
    elif _have openssl; then
      # Bentuk RFC4122 v4 pakai openssl (best-effort)
      # 16 bytes random => format 8-4-4-4-12 (set variant & version bits)
      bytes=$(openssl rand -hex 16)
      b1=${bytes:0:8}
      b2=${bytes:8:4}
      b3=${bytes:12:4}
      b4=${bytes:16:4}
      b5=${bytes:20:12}
      # set version (4) dan variant (8,b)
      b3="4${b3:1:3}"
      v=${b4:0:1}
      case "$v" in
        8|9|a|b|A|B) ;; # ok
        *) b4="8${b4:1:3}" ;;
      esac
      printf '%s-%s-%s-%s-%s\n' "$b1" "$b2" "$b3" "$b4" "$b5"
    else
      _err "Tidak dapat membuat UUID (butuh uuidgen atau /proc/sys/kernel/random/uuid atau openssl)."
      return 1
    fi
  }

  # Util: validasi UUID v4 (case-insensitive)
  _is_valid_uuid() {
    [[ "${1,,}" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89abAB][0-9a-f]{3}-[0-9a-f]{12}$ ]]
  }

  # Cek file config
  if [ ! -f "$CONFIG_FILE" ]; then
    _err "Config tidak ditemukan: $CONFIG_FILE"
    return 1
  fi
  if [ ! -r "$CONFIG_FILE" ] || [ ! -w "$CONFIG_FILE" ]; then
    _err "Butuh akses baca/tulis ke $CONFIG_FILE (jalankan sebagai root)."
    return 1
  fi

  # Kumpulkan daftar email Xray (unik, urut kemunculan)
  mapfile -t _emails_all < <(grep -oE '"email"[[:space:]]*:[[:space:]]*"[^"]+"' "$CONFIG_FILE" 2>/dev/null | sed -E 's/.*"email"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')
  if [ ${#_emails_all[@]} -eq 0 ]; then
    _err "Tidak ada entri \"email\" ditemukan di $CONFIG_FILE."
    return 1
  fi
  # Unique dengan mempertahankan urutan
  declare -a EMAILS=()
  declare -A SEEN=()
  for e in "${_emails_all[@]}"; do
    if [ -z "${SEEN[$e]+x}" ]; then
      EMAILS+=("$e")
      SEEN["$e"]=1
    fi
  done

  # Tampilkan menu
  printf '\nDaftar username Xray:\n'
  for i in "${!EMAILS[@]}"; do
    printf ' %2d) %s\n' "$((i+1))" "${EMAILS[$i]}"
  done
  printf '\n'

  # Loop pilih nomor
  local choice
  while :; do
    read -r -p "Pilih nomor username yang akan diubah UUID-nya (1-${#EMAILS[@]}) atau q untuk batal: " choice
    choice="$(_trim <<<"$choice")"
    case "$choice" in
      q|Q) printf 'Dibatalkan.\n'; return 0 ;;
    esac
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#EMAILS[@]}" ]; then
      break
    fi
    _err "Input tidak valid. Masukkan angka 1-${#EMAILS[@]} atau q untuk batal."
  done

  local USER_EMAIL="${EMAILS[$((choice-1))]}"
  printf 'Target: %s\n' "$USER_EMAIL"

  # Input UUID
  local NEW_UUID
  while :; do
    read -r -p "Masukkan UUID baru (kosongkan untuk auto-generate): " NEW_UUID || true
    NEW_UUID="$(_trim <<<"$NEW_UUID")"
    if [ -z "$NEW_UUID" ]; then
      NEW_UUID="$(_gen_uuid)"
      NEW_UUID="${NEW_UUID,,}"
      printf 'UUID otomatis: %s\n' "$NEW_UUID"
    fi
    NEW_UUID="${NEW_UUID,,}"
    if _is_valid_uuid "$NEW_UUID"; then
      break
    else
      _err "Format UUID tidak valid. Contoh: 123e4567-e89b-12d3-a456-426614174000"
    fi
  done

  # Konfirmasi
  printf 'Konfirmasi: Ubah semua entri Xray untuk "%s" ke UUID: %s [y/N]: ' "$USER_EMAIL" "$NEW_UUID"
  read -r ans
  ans="$(_trim <<<"$ans")"
  if [[ ! "$ans" =~ ^[Yy]$ ]]; then
    printf 'Dibatalkan.\n'
    return 0
  fi

  # Siapkan file sementara & backup
  local TMPFILE BACKUP
  TMPFILE="$(mktemp)"
  BACKUP="$(mktemp --suffix=.xray-config.bak || mktemp)"
  cp -f -- "$CONFIG_FILE" "$BACKUP"

  # Pastikan backup dibersihkan jika sukses/gagal
  cleanup() {
    rm -f -- "$TMPFILE" 2>/dev/null || true
  }
  trap cleanup EXIT

  # Escape untuk regex
  local USER_RE
  USER_RE="$(_escape_ere "$USER_EMAIL")"

  # Proses update:
  # - Case 1: id dan email dalam satu baris -> ganti langsung.
  # - Case 2: id di baris sebelumnya, email di baris berikutnya -> ganti id pada baris sebelumnya.
  awk -v user_re="$USER_RE" -v newuuid="$NEW_UUID" '
    function repl_id(line,  out) {
      out = line
      gsub(/("id"[[:space:]]*:[[:space:]]*")[^"]+(")/, "\\1" newuuid "\\2", out)
      return out
    }
    {
      line = $0
      if (line ~ /"id"[[:space:]]*:[[:space:]]*"/ && line ~ /"email"[[:space:]]*:[[:space:]]*"/) {
        if (line ~ ("\"email\"[[:space:]]*:[[:space:]]*\"" user_re "\"")) {
          print repl_id(line)
        } else {
          print line
        }
        next
      }
      if (prev_has_id && line ~ ("\"email\"[[:space:]]*:[[:space:]]*\"" user_re "\"")) {
        print repl_id(prev_line)
        print line
        prev_has_id = 0
        next
      }
      if (line ~ /"id"[[:space:]]*:[[:space:]]*"/) {
        prev_line = line
        prev_has_id = 1
        next
      }
      if (prev_has_id) {
        print prev_line
        prev_has_id = 0
      }
      print line
    }
    END {
      if (prev_has_id) print prev_line
    }
  ' "$CONFIG_FILE" >"$TMPFILE"

  # Validasi hasil dasar: file tidak kosong
  if [ ! -s "$TMPFILE" ]; then
    cp -f -- "$BACKUP" "$CONFIG_FILE"
    _err "Gagal memproses file (hasil kosong). Dikembalikan ke backup."
    return 1
  fi

  # Jika jq tersedia, validasi JSON
  if _have jq; then
    if ! jq empty "$TMPFILE" >/dev/null 2>&1; then
      cp -f -- "$BACKUP" "$CONFIG_FILE"
      _err "Konfigurasi tidak valid setelah perubahan (JSON rusak). Dikembalikan ke backup."
      return 1
    fi
  fi

  # Terapkan perubahan
  cp -f -- "$TMPFILE" "$CONFIG_FILE"

  # Restart Xray diam-diam
  if systemctl >/dev/null 2>&1; then
    systemctl restart xray >/dev/null 2>&1 || true
  else
    service xray restart >/dev/null 2>&1 || true
  fi

  # Jika sampai sini, sukses -> hapus backup & tmp
  rm -f -- "$BACKUP" "$TMPFILE" 2>/dev/null || true

  printf 'Selesai: UUID untuk "%s" telah diperbarui dan Xray direstart.\n' "$USER_EMAIL"
  
  read -n 1 -s -r -p "Press any key to back on menu"
m-vless
}


clear

echo -e " $COLOR1╭════════════════════════════════════════════════════╮${NC}"
echo -e " $COLOR1│${NC} ${COLBG1}              ${WH}• VLESS PANEL MENU •               ${NC}"
echo -e " $COLOR1╰════════════════════════════════════════════════════╯${NC}"
echo -e " $COLOR1╭════════════════════════════════════════════════════╮${NC}"
echo -e " $COLOR1│ $NC ${WH}[${COLOR1}01${WH}]${NC} ${COLOR1}• ${WH}ADD AKUN${NC}         ${WH}[${COLOR1}06${WH}]${NC} ${COLOR1}• ${WH}CEK USER CONFIG${NC}"
echo -e " $COLOR1│ $NC ${WH}[${COLOR1}02${WH}]${NC} ${COLOR1}• ${WH}TRIAL AKUN${NC}       ${WH}[${COLOR1}07${WH}]${NC} ${COLOR1}• ${WH}CHANGE USER LIMIT${NC}"
echo -e " $COLOR1│ $NC ${WH}[${COLOR1}03${WH}]${NC} ${COLOR1}• ${WH}RENEW AKUN${NC}       ${WH}[${COLOR1}08${WH}]${NC} ${COLOR1}• ${WH}SETTING LOCK LOGIN${NC}"
echo -e " $COLOR1│ $NC ${WH}[${COLOR1}04${WH}]${NC} ${COLOR1}• ${WH}DELETE AKUN${NC}      ${WH}[${COLOR1}09${WH}]${NC} ${COLOR1}• ${WH}UNLOCK USER LOGIN${NC}"
echo -e " $COLOR1│ $NC ${WH}[${COLOR1}05${WH}]${NC} ${COLOR1}• ${WH}CEK USER LOGIN${NC}   ${WH}[${COLOR1}10${WH}]${NC} ${COLOR1}• ${WH}RESTORE AKUN ${NC}"
echo -e " $COLOR1│ $NC ${WH}[${COLOR1}11${WH}]${NC} ${COLOR1}• ${WH}CHANGE UUID${NC}   ${WH}[${COLOR1}00${WH}]${NC} ${COLOR1}• ${WH}GO BACK ${NC}"
echo -e " $COLOR1╰════════════════════════════════════════════════════╯${NC}"
echo -e ""
echo -ne " ${COLOR1}Select menu ${NC}: ${WH}"; read opt
case $opt in
01 | 1) clear ; add_vless ;;
02 | 2) clear ; trial_vless ;;
03 | 3) clear ; renew_vless ;;
04 | 4) clear ; delete_vless ;;
05 | 5) clear ; check_vless ;;
06 | 6) clear ; list_vless ;;
07 | 7) clear ; limit_vless ;;
08 | 8) clear ; login_vless ;;
09 | 9) clear ; lock_vless ;;
10 | 10) clear ; restore_vless ;;
11 | 11) clear ; uuid_xray ;;
00 | 0) clear ; menu ;;
x) exit ;;
*) echo "" ; sleep 1 ; m-vless ;;
esac
