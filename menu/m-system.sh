#!/bin/bash

colornow=$(cat /etc/rmbl/theme/color.conf)
NC="\e[0m"
RED="\033[0;31m"
COLOR1="$(cat /etc/rmbl/theme/$colornow | grep -w "TEXT" | cut -d: -f2|sed 's/ //g')"
COLBG1="$(cat /etc/rmbl/theme/$colornow | grep -w "BG" | cut -d: -f2|sed 's/ //g')"
WH='\033[1;37m'


function add-host() {
    clear

    # === Jalankan proses latar belakang update (jika ada perintah tambahan) ===
    CMD[0]="$1"
    CMD[1]="$2"
    (
        [[ -e "$HOME/fim" ]] && rm -f "$HOME/fim"
        ${CMD[0]} -y >/dev/null 2>&1
        ${CMD[1]} -y >/dev/null 2>&1
        touch "$HOME/fim"
    ) >/dev/null 2>&1 &

    # === Progress Bar Visual ===
    tput civis
    echo -ne "  \033[0;33mUpdate Domain... \033[1;37m- \033[0;33m["
    while true; do
        for ((i = 0; i < 18; i++)); do
            echo -ne "\033[0;32m#"
            sleep 0.1
        done
        if [[ -e "$HOME/fim" ]]; then
            rm -f "$HOME/fim"
            break
        fi
        echo -e "\033[0;33m]"
        sleep 1
        tput cuu1
        tput dl1
        echo -ne "  \033[0;33mUpdate Domain... \033[1;37m- \033[0;33m["
    done
    echo -e "\033[0;33m]\033[1;37m -\033[1;32m Sukses!\033[1;37m"
    tput cnorm
    clear

    # === Input domain utama ===
    local dnss=""
    until [[ "$dnss" =~ ^[a-zA-Z0-9_.-]+$ ]]; do
        read -rp "🌐 Masukkan domain utama: " -e dnss
    done

    # === Input NS domain ===
    local nss=""
    until [[ "$nss" =~ ^[a-zA-Z0-9_.-]+$ ]]; do
        read -rp "🛰️ Masukkan NS domain (contoh: ns1.${dnss}): " -e nss
    done

    # === Persiapan direktori (jika belum ada) ===
    mkdir -p /etc/xray /etc/v2ray /etc/domain /etc/per /root /var/lib/kyt

    # === Simpan subdomain dan NS domain ke semua lokasi terkait ===
    echo "$dnss" | tee \
        /etc/xray/domain \
        /etc/xray/scdomain \
        /etc/v2ray/domain \
        /etc/v2ray/scdomain \
        /etc/domain/subdomain \
        /root/domain \
        >/dev/null

    echo "$nss" > /etc/domain/nsdomain
    echo "IP=$dnss" > /var/lib/kyt/ipvps.conf

    # === Eksekusi pembaruan sertifikat SSL jika diperlukan ===
    certv2ray

    # === Kembali ke menu utama ===
    echo -e "\n🔁 Kembali ke menu..."
    sleep 1
    menu
}

function auto_reboot() {
    clear

    # Hapus cron lama jika ada
    [[ -f /etc/cron.d/re_otm ]] && rm -f /etc/cron.d/re_otm

    # Buat skrip reboot otomatis jika belum ada
    if [[ ! -f /usr/local/bin/reboot_otomatis ]]; then
        cat > /usr/local/bin/reboot_otomatis <<-EOF
#!/bin/bash
tanggal=\$(date +"%m-%d-%Y")
waktu=\$(date +"%T")
echo "Server successfully rebooted on \$tanggal at \$waktu." >> /etc/log-reboot.txt
/sbin/shutdown -r now
EOF
        chmod +x /usr/local/bin/reboot_otomatis
    fi

    # Tampilan menu
    echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\e[0;100;33m         • AUTO-REBOOT MENU •          \e[0m"
    echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e ""
    echo -e "[\e[36m1\e[0m] Auto-Reboot setiap 1 jam"
    echo -e "[\e[36m2\e[0m] Auto-Reboot setiap 6 jam"
    echo -e "[\e[36m3\e[0m] Auto-Reboot setiap 12 jam"
    echo -e "[\e[36m4\e[0m] Auto-Reboot setiap hari"
    echo -e "[\e[36m5\e[0m] Auto-Reboot setiap minggu"
    echo -e "[\e[36m6\e[0m] Auto-Reboot setiap bulan"
    echo -e "[\e[36m7\e[0m] Auto-Reboot saat CPU 100%"
    echo -e "[\e[36m8\e[0m] Nonaktifkan Auto-Reboot & CPU 100%"
    echo -e "[\e[36m9\e[0m] Tampilkan log reboot"
    echo -e "[\e[36m10\e[0m] Hapus log reboot"
    echo -e ""
    echo -e "[\e[31m0\e[0m] Kembali ke menu utama"
    echo -e ""
    echo -e "Tekan x atau [Ctrl+C] untuk keluar"
    echo -e ""
    echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -ne "Pilih menu : "; read -r opt
    echo ""

    case $opt in
        1)
            echo "10 * * * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
            echo "✅ Auto-Reboot setiap 1 jam diaktifkan."
            ;;
        2)
            echo "10 */6 * * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
            echo "✅ Auto-Reboot setiap 6 jam diaktifkan."
            ;;
        3)
            echo "10 */12 * * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
            echo "✅ Auto-Reboot setiap 12 jam diaktifkan."
            ;;
        4)
            read -p "🕐 Jam reboot harian (contoh 5 = jam 5 pagi): " jam
            echo "0 $jam * * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
            echo "✅ Auto-Reboot harian di jam $jam diaktifkan."
            ;;
        5)
            read -p "🕐 Jam reboot mingguan (contoh 20 = jam 8 malam): " jam
            echo "10 $jam */7 * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
            echo "✅ Auto-Reboot mingguan di jam $jam diaktifkan."
            ;;
        6)
            read -p "🕐 Jam reboot bulanan (contoh 20 = jam 8 malam): " jam
            echo "10 $jam 1 * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
            echo "✅ Auto-Reboot bulanan di jam $jam diaktifkan."
            ;;
        7)
            cat > /etc/cron.d/autocpu <<-EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/7 * * * * root /usr/bin/autocpu
EOF
            echo "✅ Auto-Reboot CPU 100% diaktifkan."
            ;;
        8)
            rm -f /etc/cron.d/reboot_otomatis /etc/cron.d/autocpu
            echo "🛑 Auto-Reboot dan Auto-Reboot CPU 100% dinonaktifkan."
            ;;
        9)
            clear
            echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
            echo -e "\e[0;100;33m          • LOG REBOOT •               \e[0m"
            echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
            if [[ ! -f /etc/log-reboot.txt || ! -s /etc/log-reboot.txt ]]; then
                echo -e "⚠️  Belum ada aktivitas reboot tercatat."
            else
                cat /etc/log-reboot.txt
            fi
            echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
            read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
            auto_reboot
            return
            ;;
        10)
            > /etc/log-reboot.txt
            echo "🧹 Log reboot berhasil dihapus."
            ;;
        0)
            menu
            return
            ;;
        x|X)
            exit 0
            ;;
        *)
            echo "❌ Pilihan tidak valid."
            ;;
    esac

    sleep 2
    auto_reboot
}


function bnw() {
    clear
    echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${COLOR1}${NC}${COLBG1}            • BANDWIDTH MONITOR •             ${NC}"
    echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e " ${WH}[${COLOR1}1${WH}]${NC}  ${COLOR1}Lihat Total Bandwidth Tersisa${NC}"
    echo -e " ${WH}[${COLOR1}2${WH}]${NC}  ${COLOR1}Penggunaan per 5 Menit${NC}"
    echo -e " ${WH}[${COLOR1}3${WH}]${NC}  ${COLOR1}Penggunaan per Jam${NC}"
    echo -e " ${WH}[${COLOR1}4${WH}]${NC}  ${COLOR1}Penggunaan per Hari${NC}"
    echo -e " ${WH}[${COLOR1}5${WH}]${NC}  ${COLOR1}Penggunaan per Bulan${NC}"
    echo -e " ${WH}[${COLOR1}6${WH}]${NC}  ${COLOR1}Penggunaan per Tahun${NC}"
    echo -e " ${WH}[${COLOR1}7${WH}]${NC}  ${COLOR1}Penggunaan Tertinggi${NC}"
    echo -e " ${WH}[${COLOR1}8${WH}]${NC}  ${COLOR1}Statistik Jam (Graph)${NC}"
    echo -e " ${WH}[${COLOR1}9${WH}]${NC}  ${COLOR1}Penggunaan Aktif Saat Ini${NC}"
    echo -e " ${WH}[${COLOR1}10${WH}]${NC} ${COLOR1}Live Trafik (Refresh per 5 Detik)${NC}"
    echo -e ""
    echo -e " ${WH}[${RED}0${WH}]${NC}  ${RED}Kembali ke Menu Utama${NC}"
    echo -e " ${WH}[${RED}x${WH}]${NC}  ${RED}Keluar${NC}"
    echo -e ""
    echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -ne " Pilih menu [1-10/0/x]: "; read -r opt
    echo ""

    case $opt in
        1)
            title="TOTAL BANDWIDTH SERVER"
            cmd="vnstat"
            ;;
        2)
            title="BANDWIDTH SETIAP 5 MENIT"
            cmd="vnstat -5"
            ;;
        3)
            title="BANDWIDTH PER JAM"
            cmd="vnstat -h"
            ;;
        4)
            title="BANDWIDTH PER HARI"
            cmd="vnstat -d"
            ;;
        5)
            title="BANDWIDTH PER BULAN"
            cmd="vnstat -m"
            ;;
        6)
            title="BANDWIDTH PER TAHUN"
            cmd="vnstat -y"
            ;;
        7)
            title="BANDWIDTH TERTINGGI"
            cmd="vnstat -t"
            ;;
        8)
            title="STATISTIK JAM (GRAFIK)"
            cmd="vnstat -hg"
            ;;
        9)
            clear
            echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${COLOR1}${NC}${COLBG1}       • PENGGUNAAN SAAT INI (LIVE) •         ${NC}"
            echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e " Tekan [ Ctrl+C ] untuk keluar dari mode live"
            echo -e ""
            vnstat -l
            bw
            return
            ;;
        10)
            clear
            echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${COLOR1}${NC}${COLBG1} • TRAFIK AKTIF (REFRESH PER 5 DETIK) •       ${NC}"
            echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e ""
            vnstat -tr
            bw
            return
            ;;
        0)
            menu
            return
            ;;
        x)
            clear
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Pilihan tidak valid!${NC}"
            sleep 1
            bw
            return
            ;;
    esac

    # Menampilkan hasil jika ada perintah yang valid
    if [[ -n $cmd ]]; then
        clear
        echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${COLOR1}${NC}${COLBG1}       • $title •        ${NC}"
        echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        eval "$cmd"
        echo ""
        echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        read -n 1 -s -r -p " Tekan sembarang tombol untuk kembali ke menu..."
        bw
    fi
}


function limitspeed() {
    clear
    GREEN="\033[32m"
    RED="\033[31m"
    YELLOW="\033[33m"
    NC="\033[0m"

    STATUS_ON="${GREEN}[ON]${NC}"
    STATUS_OFF="${RED}[OFF]${NC}"

    # Cek status saat ini
    cek=$(cat /home/limit 2>/dev/null)
    NIC=$(ip -o -4 route show to default | awk '{print $5}')

    # Fungsi untuk mulai limit
    function start() {
        clear
        echo -e "\n\033[1;34m╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮"
        echo -e "│         LIMIT BANDWIDTH SPEED         │"
        echo -e "╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯\033[0m"
        echo -e ""

        read -rp "🔻 Maksimal Download (Kbps): " down
        read -rp "🔺 Maksimal Upload   (Kbps): " up

        if [[ -z $down || -z $up ]]; then
            echo -e "\n${RED}[ERROR]${NC} Input tidak boleh kosong!"
            sleep 2
            limitspeed
            return
        fi

        echo -e "\n${YELLOW}[INFO]${NC} Mengatur limit pada interface: ${NIC}"
        wondershaper -a "$NIC" -d "$down" -u "$up" > /dev/null 2>&1
        systemctl enable --now wondershaper.service > /dev/null 2>&1

        echo "start" > /home/limit
        echo -e "${GREEN}[OK]${NC} Limit bandwidth telah diaktifkan."
        sleep 2
        limitspeed
    }

    # Fungsi untuk stop limit
    function stop() {
        clear
        echo -e "\n\033[1;34m╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮"
        echo -e "│         DISABLE BANDWIDTH LIMIT       │"
        echo -e "╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯\033[0m"
        echo -e ""

        wondershaper -ca "$NIC" > /dev/null 2>&1
        systemctl stop wondershaper.service > /dev/null 2>&1
        echo > /home/limit

        echo -e "${GREEN}[OK]${NC} Limit bandwidth telah dinonaktifkan."
        sleep 2
        limitspeed
    }

    # Menentukan status
    if [[ "$cek" == "start" ]]; then
        status="${STATUS_ON}"
    else
        status="${STATUS_OFF}"
    fi

    # Tampilkan menu
    clear
    echo -e "\n\033[1;36m╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮"
    echo -e "│          LIMIT BANDWIDTH MENU         │"
    echo -e "╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯\033[0m"
    echo -e ""
    echo -e " Status: $status\n"
    echo -e " [1] Start Limit Bandwidth"
    echo -e " [2] Stop Limit Bandwidth"
    echo -e " [0] Kembali ke Menu Utama"
    echo -e ""
    echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

    read -rp " Pilih opsi [0-2]: " num
    case $num in
        1) start ;;
        2) stop ;;
        0) menu ;;
        *) 
            echo -e "\n${RED}[ERROR]${NC} Pilihan tidak valid!"
            sleep 2
            limitspeed
            ;;
    esac
}


function certv2ray() {
    clear
    echo -e "\n\033[1;34m╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮"
    echo -e "│         INSTALL & RENEW XRAY CERTIFICATE    │"
    echo -e "╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯\033[0m"

    # Ambil domain
    source /var/lib/ipvps.conf >/dev/null 2>&1
    domain=$(cat /etc/xray/domain)

    if [[ -z $domain ]]; then
        echo -e "\n\033[31m[ERROR]\033[0m Domain tidak ditemukan di /etc/xray/domain"
        sleep 2
        menu
        return
    fi

    echo -e "\n\033[33m[INFO]\033[0m Menghentikan service sementara..."
    stop_service=$(lsof -i:89 | awk 'NR==2 {print $1}')
    systemctl stop "$stop_service" 2>/dev/null
    systemctl stop nginx 2>/dev/null

    echo -e "\033[33m[INFO]\033[0m Menghapus dan menyiapkan folder acme.sh..."
    rm -rf /root/.acme.sh
    mkdir -p /root/.acme.sh

    echo -e "\033[33m[INFO]\033[0m Mengunduh acme.sh script..."
    curl -s https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh

    chmod +x /root/.acme.sh/acme.sh

    echo -e "\033[33m[INFO]\033[0m Registrasi akun ACME..."
    /root/.acme.sh/acme.sh --register-account -m rmbl@slowapp.cfd

    echo -e "\033[33m[INFO]\033[0m Mengatur Let’s Encrypt sebagai default CA..."
    /root/.acme.sh/acme.sh --set-default-ca --server letsencrypt

    echo -e "\033[33m[INFO]\033[0m Memproses pembuatan sertifikat untuk: \033[36m$domain\033[0m"
    /root/.acme.sh/acme.sh --issue -d "$domain" --standalone -k ec-256

    echo -e "\033[33m[INFO]\033[0m Memasang sertifikat ke direktori Xray..."
    ~/.acme.sh/acme.sh --installcert -d "$domain" \
        --fullchainpath /etc/xray/xray.crt \
        --keypath /etc/xray/xray.key --ecc

    chmod 600 /etc/xray/xray.key

    echo -e "\n\033[32m[SUKSES]\033[0m Sertifikat telah dipasang!"

    echo -e "\n\033[33m[INFO]\033[0m Menyalakan kembali service..."
    systemctl restart nginx
    systemctl restart xray

    echo -e "\n\033[1;32mSertifikat berhasil diperbarui dan service telah direstart.\033[0m"
    sleep 2
    menu
}


function clearcache() {
    clear
    echo -e "\n\033[1;34m╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮"
    echo -e "│        CLEAR RAM CACHE           │"
    echo -e "╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯\033[0m"

    echo -e "\n[ \033[1;33mINFO\033[0m ] Membersihkan RAM cache..."
    echo 1 > /proc/sys/vm/drop_caches
    sleep 2

    echo -e "[ \033[1;32mOK\033[0m ] RAM cache berhasil dibersihkan."
    echo -e "\nKembali ke menu dalam 2 detik..."
    sleep 2
    menu
}


function m-bot2() {
    clear

    # Tampilan menu utama
    echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
    echo -e "${COLOR1}  ${WH}Silakan pilih jenis Bot berikut:               ${NC}"
    echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
    echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
    echo -e "${COLOR1}  [ 1 ] ${WH}Buat/Edit BOT Multi Login (SSH, XRAY, Transaksi)${NC}"
    echo -e "${COLOR1}  [ 2 ] ${WH}Buat/Edit BOT Info User & Lainnya                ${NC}"
    echo -e "${COLOR1}  [ 3 ] ${WH}Buat/Edit BOT Backup Telegram                    ${NC}"
    echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
    
    echo ""
    read -rp " Pilih nomor [1-3] atau tombol apa saja untuk keluar: " bot
    echo ""

    case "$bot" in
        1)
            clear
            echo -e "${COLOR1}[ INFO ]${NC} Menyiapkan database Bot Multi Login..."
            rm -rf /etc/perlogin
            mkdir -p /etc/perlogin
            cd /etc/perlogin || exit

            read -rp "Masukkan Token (buat via @BotFather)   : " token
            echo "$token" > token

            read -rp "Masukkan ID Telegram (lihat @userinfobot): " id
            echo "$id" > id

            echo -e "\n${COLOR1}[ DONE ]${NC} Bot Multi Login berhasil dikonfigurasi!"
            sleep 1
            m-bot2
            ;;
        2)
            clear
            echo -e "${COLOR1}[ INFO ]${NC} Menyiapkan database Bot Info User..."
            rm -rf /etc/per
            mkdir -p /etc/per
            cd /etc/per || exit

            read -rp "Masukkan Token (buat via @BotFather)   : " token
            echo "$token" > token

            read -rp "Masukkan ID Telegram (lihat @userinfobot): " id
            echo "$id" > id

            echo -e "\n${COLOR1}[ DONE ]${NC} Bot Info User berhasil dikonfigurasi!"
            sleep 1
            m-bot2
            ;;
        3)
            clear
            echo -e "${COLOR1}[ INFO ]${NC} Menyiapkan database Bot Backup Telegram..."
            rm -f /usr/bin/token /usr/bin/idchat

            read -rp "Masukkan Token (buat via @BotFather)   : " token
            echo "$token" > /usr/bin/token

            read -rp "Masukkan ID Telegram (lihat @userinfobot): " id
            echo "$id" > /usr/bin/idchat

            echo -e "\n${COLOR1}[ DONE ]${NC} Bot Backup Telegram berhasil dikonfigurasi!"
            sleep 1
            m-bot2
            ;;
        *)
            menu
            ;;
    esac
}


function m-webmin() {
    clear

    # Warna
    Green="\033[32m"
    Red="\033[31m"
    Yellow="\033[33m"
    Info="${Green}[Installed]\033[0m"
    Error="${Red}[Not Installed]\033[0m"
    NC="\033[0m"

    # Cek status Webmin
    cek=$(netstat -ntlp | grep 10000 | awk '{print $7}' | cut -d'/' -f2)
    if [[ "$cek" == "perl" ]]; then
        status="$Info"
    else
        status="$Error"
    fi

    # Function install Webmin
    function install() {
        clear
        IP=$(wget -qO- ifconfig.me/ip)
        echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "\e[0;100;33m          • INSTALL WEBMIN •         ${NC}"
        echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
        sleep 0.5

        echo -e "${Green}[Info]${NC} Menambahkan repository Webmin..."
        echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list
        apt install -y gnupg gnupg1 gnupg2 > /dev/null 2>&1
        wget -q http://www.webmin.com/jcameron-key.asc
        apt-key add jcameron-key.asc > /dev/null 2>&1

        echo -e "${Green}[Info]${NC} Memulai instalasi Webmin..."
        apt update > /dev/null 2>&1
        apt install -y webmin > /dev/null 2>&1
        sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf

        echo -e "${Green}[Info]${NC} Merestart Webmin..."
        /etc/init.d/webmin restart > /dev/null 2>&1
        rm -f jcameron-key.asc

        echo -e "\n${Green}[Sukses]${NC} Webmin berhasil diinstal!"
        echo -e "Akses melalui: ${Green}http://$IP:10000${NC}\n"
        echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
        read -n 1 -s -r -p "Tekan sembarang tombol untuk kembali ke menu..."
        m-webmin
    }

    # Function restart Webmin
    function restart() {
        clear
        echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "\e[0;100;33m         • RESTART WEBMIN •          ${NC}"
        echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
        echo -e "${Green}[Info]${NC} Merestart layanan Webmin..."
        service webmin restart > /dev/null 2>&1
        echo -e "${Green}[Sukses]${NC} Webmin berhasil dijalankan ulang!\n"
        echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
        read -n 1 -s -r -p "Tekan sembarang tombol untuk kembali ke menu..."
        m-webmin
    }

    # Function uninstall Webmin
    function uninstall() {
        clear
        echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "\e[0;100;33m        • UNINSTALL WEBMIN •         ${NC}"
        echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
        echo -e "${Green}[Info]${NC} Menghapus repository Webmin..."
        rm -f /etc/apt/sources.list.d/webmin.list
        apt update > /dev/null 2>&1

        echo -e "${Green}[Info]${NC} Menghapus paket Webmin..."
        apt autoremove --purge webmin -y > /dev/null 2>&1

        echo -e "\n${Green}[Sukses]${NC} Webmin berhasil dihapus!"
        echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
        read -n 1 -s -r -p "Tekan sembarang tombol untuk kembali ke menu..."
        m-webmin
    }

    # Tampilan menu utama Webmin
    clear
    echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "\e[0;100;33m           • WEBMIN MENU •           ${NC}"
    echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    echo -e " Status Webmin : $status\n"
    echo -e " ${Green}[1]${NC} Install Webmin"
    echo -e " ${Green}[2]${NC} Restart Webmin"
    echo -e " ${Green}[3]${NC} Uninstall Webmin"
    echo -e " ${Red}[0]${NC} Kembali ke menu utama"
    echo -e "\n Tekan ${Red}x${NC} atau [ Ctrl + C ] untuk keluar"
    echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

    # Input pilihan
    read -rp " Pilih menu [0-3]: " num
    case $num in
        1) install ;;
        2) restart ;;
        3) uninstall ;;
        0) menu ;;
        x) exit ;;
        *) 
            echo -e "\n${Red}Input tidak valid!${NC}"; 
            sleep 1
            m-webmin
            ;;
    esac
}


function speed() {
    clear

    if [[ -e /etc/speedi ]]; then
        speedtest
    else
        echo -e "\n🔧 Menginstal Speedtest CLI...\n"
        sudo apt-get update -y
        sudo apt-get install curl -y
        curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
        sudo apt-get install speedtest -y
        touch /etc/speedi
        clear
        echo -e "\n✅ Instalasi selesai! Menjalankan Speedtest...\n"
        sleep 1
        speedtest
    fi
}


function gotopp() {
    clear
    cd || return

    if [[ -e /usr/bin/gotop ]]; then
        gotop
    else
        echo -e "\n🔧 Menginstal Gotop...\n"
        git clone --depth=1 https://github.com/cjbassi/gotop /tmp/gotop &> /dev/null
        bash /tmp/gotop/scripts/download.sh &> /dev/null

        if [[ -f /root/gotop ]]; then
            chmod +x /root/gotop
            mv /root/gotop /usr/bin/
        fi

        rm -rf /tmp/gotop
        echo -e "\n✅ Gotop berhasil diinstal!\n"
        sleep 1
        gotop
    fi
}


function coremenu() {
    clear
    BIN_PATH="/usr/local/bin/xray"
    OFFICIAL_CORE="/usr/local/bin/offixray"

    echo -e "\e[1;36m╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮"
    echo -e "│               🔧 GANTI XRAY CORE               │"
    echo -e "╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯\e[0m"

    # Backup core resmi jika belum ada
    [[ ! -e "$OFFICIAL_CORE" ]] && cp "$BIN_PATH" "$OFFICIAL_CORE" &> /dev/null

    echo -e "\nPilih versi Xray Core:"
    echo -e "  \e[1;32m[1]\e[0m  Official (Bawaan)"
    echo -e "  \e[1;32m[2]\e[0m  v1.8.5 → ⚡ Stabil, support Reality, TLS/XTLS"
    echo -e "  \e[1;32m[3]\e[0m  v1.8.4 → 🔧 Bugfix Reality, fallback optimal"
    echo -e "  \e[1;32m[4]\e[0m  v1.8.1 → 🧪 Optimal TLS & performa tinggi"
    echo -e "  \e[1;32m[5]\e[0m  v1.7.5 → 🧱 Versi klasik, stabil tanpa Reality"
    echo -e "  \e[1;32m[6]\e[0m  v1.6.5 → 🪶 Ringan, cocok untuk VPS spesifikasi rendah"
    echo -e "  \e[1;32m[7]\e[0m  Input manual versi (cth: 1.8.6)"
    echo -e "  \e[1;31m[0]\e[0m  Kembali ke menu utama\n"

    read -rp "Pilih versi [0-7]: " core

    case $core in
        1)
            echo -e "\n🔄 Mengganti ke: \e[1;36mXray Core Official (Bawaan)...\e[0m"
            cp -f "$OFFICIAL_CORE" "$BIN_PATH"
            ;;
        2)
            version="1.8.5"
            ;;
        3)
            version="1.8.4"
            ;;
        4)
            version="1.8.1"
            ;;
        5)
            version="1.7.5"
            ;;
        6)
            version="1.6.5"
            ;;
        7)
            read -rp "Masukkan versi Xray (contoh: 1.8.6): " version
            ;;
        0)
            menu
            return
            ;;
        *)
            echo -e "\n❌ Pilihan tidak valid!"
            sleep 1
            coremenu
            return
            ;;
    esac

    # Jika bukan opsi 1 atau 0, berarti kita unduh
    if [[ $core -ne 1 && $core -ne 0 ]]; then
        echo -e "\n⬇️  Mengunduh Xray v$version..."
        URL="https://github.com/XTLS/Xray-core/releases/download/v${version}/xray-linux-64"
        if wget -q --spider "$URL"; then
            wget -q -O "$BIN_PATH" "$URL"
            chmod +x "$BIN_PATH"
            echo -e "\n✅ Xray v$version berhasil diinstal!"
        else
            echo -e "\n❌ Versi $version tidak ditemukan di GitHub!"
            sleep 1
            coremenu
            return
        fi
    fi

    systemctl restart xray
    echo -e "\n✅ Xray telah direstart dan siap digunakan."
    read -n 1 -s -r -p "Tekan tombol apa saja untuk kembali..."
    menu
}


clear
clear
echo -e "${COLOR1}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${COLOR1}║${NC}${COLBG1}                  ${WH}• SYSTEM MENU •                     ${NC}${COLOR1}║${NC}"
echo -e "${COLOR1}╠════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${COLOR1}║${NC}  [01] CHANGE DOMAIN           [08] CHANGE BANNER             ${COLOR1}║${NC}"
echo -e "${COLOR1}║${NC}  [02] SPEEDTEST               [09] SETTING BOT               ${COLOR1}║${NC}"
echo -e "${COLOR1}║${NC}  [03] AUTO-REBOOT             [10] CERT DOMAIN               ${COLOR1}║${NC}"
echo -e "${COLOR1}║${NC}  [04] CHECK BANDWIDTH         [11] GOTOP PANEL               ${COLOR1}║${NC}"
echo -e "${COLOR1}║${NC}  [05] INSTALL WEBMIN          [12] CORE XRAY                 ${COLOR1}║${NC}"
echo -e "${COLOR1}║${NC}  [06] CHANGE THEME            [13] CLEAR CACHE               ${COLOR1}║${NC}"
echo -e "${COLOR1}║${NC}  [07] LIMIT SPEED             [00] GO BACK TO MAIN MENU      ${COLOR1}║${NC}"
echo -e "${COLOR1}╚════════════════════════════════════════════════════════════════╝${NC}"
echo -ne " ${WH}Select menu ${COLOR1}: ${WH}"; read opt
echo ""

case $opt in
  01|1)   clear ; add-host       ; exit ;;
  02|2)   clear ; speed          ; exit ;;
  03|3)   clear ; auto-reboot    ; exit ;;
  04|4)   clear ; bnw            ; exit ;;
  05|5)   clear ; m-webmin       ; exit ;;
  06|6)   clear ; m-theme        ; exit ;;
  07|7)   clear ; limitspeed     ; exit ;;
  08|8)   clear ; nano /etc/issue.net ; exit ;;
  09|9)   clear ; m-bot2         ; exit ;;
  10)     clear ; certv2ray      ; exit ;;
  11)     clear ; gotopp         ; exit ;;
  12)     clear ; coremenu       ; exit ;;
  13)     clear ; clearcache     ; exit ;;
  00|0)   clear ; menu           ; exit ;;
  *)      echo -e "${COLOR1}Invalid selection. Please try again.${NC}" ; sleep 1 ; m-system ;;
esac
