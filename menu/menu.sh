#!/bin/bash

# Load theme color from config
colornow=$(cat /etc/rmbl/theme/color.conf)
export NC="\e[0m"
export yl='\033[0;33m'
export RED="\033[0;31m"
export COLOR1="$(grep -w "TEXT" /etc/rmbl/theme/$colornow | cut -d: -f2 | sed 's/ //g')"
export COLBG1="$(grep -w "BG" /etc/rmbl/theme/$colornow | cut -d: -f2 | sed 's/ //g')"
WH='\033[1;37m'

# Get system memory info
tram=$(free -h | awk 'NR==2 {print $2}')
uram=$(free -h | awk 'NR==2 {print $3}')

# Get system ISP and city info
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)

# Get public IP of the server
MYIP=$(cat /etc/myipvps)

# Ensure necessary directories and files exist
cd
mkdir -p /etc/per /etc/perlogin /etc/vmess /etc/vless /etc/trojan /etc/xray/sshx

# Check and create missing files
touch /etc/per/id /etc/per/token /etc/perlogin/id /etc/perlogin/token
touch /etc/xray/ssh /etc/xray/sshx/listlock /etc/vmess/listlock /etc/vless/listlock /etc/trojan/listlock

# Clear screen for clean display
clear

# Get OS model
MODEL2=$(grep -w PRETTY_NAME /etc/os-release | sed 's/.*=//g' | tr -d '"')

# Get vnstat profile
vnstat_profile=$(vnstat | sed -n '3p' | awk '{print $1}' | grep -o '[^:]*')

# Collect vnstat data for today, yesterday, and the month
today=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $8}')
today_v=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $9}')
today_rx=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $2}')
today_rxv=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $3}')
today_tx=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $5}')
today_txv=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $6}')

# Get monthly data
bulan=$(date +%b)
tahun=$(date +%y)
ba=$(curl -s https://pastebin.com/raw/0gWiX6hE)

# Check if data for the current month exists
if [ "$(grep -wc ${bulan} /etc/t1)" != '0' ]; then
  month=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $9}')
  month_v=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $10}')
  month_rx=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $3}')
  month_rxv=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $4}')
  month_tx=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $6}')
  month_txv=$(vnstat -i ${vnstat_profile} | grep "$bulan $ba$tahun" | awk '{print $7}')
else
  bulan2=$(date +%Y-%m)
  month=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $8}')
  month_v=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $9}')
  month_rx=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $2}')
  month_rxv=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $3}')
  month_tx=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $5}')
  month_txv=$(vnstat -i ${vnstat_profile} | grep "$bulan2 " | awk '{print $6}')
fi

# Get yesterday's data
if [ "$(grep -wc yesterday /etc/t1)" != '0' ]; then
  yesterday=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $8}')
  yesterday_v=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $9}')
  yesterday_rx=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $2}')
  yesterday_rxv=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $3}')
  yesterday_tx=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $5}')
  yesterday_txv=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $6}')
else
  yesterday=NULL
  yesterday_v=NULL
  yesterday_rx=NULL
  yesterday_rxv=NULL
  yesterday_tx=NULL
  yesterday_txv=NULL
fi

# Check status of services
check_status() {
  local service=$1
  local service_name=$2
  status=$(systemctl status "$service" | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g')
  if [[ $status == "running" ]]; then
    echo "${COLOR1}$service_name ON${NC}"
  else
    echo "${RED}$service_name OFF${NC}"
  fi
}

# Check status of various services
status_ws=$(check_status "ws-stunnel" "WS")
status_nginx=$(check_status "nginx" "Nginx")
status_xray=$(check_status "xray" "Xray")
status_dropbear=$(check_status "/etc/init.d/dropbear" "Dropbear")
status_udp=$(check_status "udp-custom" "UDP Custom")

# Count total accounts created
vmess=$(grep -c -E "^#vmg " "/etc/xray/config.json")
vless=$(grep -c -E "^#vlg " "/etc/xray/config.json")
trtls=$(grep -c -E "^#trg " "/etc/xray/config.json")
total_ssh=$(grep -c -E "^### " "/etc/xray/ssh")

# Mengambil jumlah hari uptime
uphours=$(uptime -p | awk '{print $2}')

# Mengambil jumlah menit uptime
upminutes=$(uptime -p | awk '{print $4}')

# Mengambil bagian terakhir dari output uptime (misalnya jam atau menit)
uptimecek=$(uptime -p | awk '{print $6}')

# Cek apakah ada kata "day" dalam output uptime
cekup=$(uptime -p | grep -ow "day")


# Function untuk Menampilkan Menu Bot dan Mengelola Bot
function m-botnotif() {
    clear
    echo -e "$COLOR1╭══════════════════════════════════════════╮${NC}"
    echo -e "$COLOR1  ${WH}Please select a Bot type below                 ${NC}"
    echo -e "$COLOR1╰══════════════════════════════════════════╯${NC}"
    echo -e "$COLOR1╭══════════════════════════════════════════╮${NC}"
    echo -e "$COLOR1  [ 1 ] ${WH}Buat/Edit BOT INFO Multi Login SSH, XRAY & TRANSAKSI   ${NC}"
    echo -e "$COLOR1  [ 2 ] ${WH}Buat/Edit BOT INFO Create User & Lain Lain    ${NC}"
    echo -e "$COLOR1  [ 3 ] ${WH}Buat/Edit BOT INFO Backup Telegram    ${NC}"
    echo -e "$COLOR1╰══════════════════════════════════════════╯${NC}"
    
    read -p "   Please select numbers 1-3 or Any Button (Random) to exit: " bot
    echo ""

    case $bot in
        1)
            # Multi Login Bot Database
            clear
            rm -rf /etc/perlogin
            mkdir -p /etc/perlogin
            cd /etc/perlogin
            touch token id
            echo -e ""
            echo -e "$COLOR1 [ INFO ] ${WH}Create for database Multi Login"
            
            # Input Token dan ID
            read -rp "Enter Token (Create on @BotFather): " token2
            echo "$token2" > token
            read -rp "Enter Your ID (Create on @userinfobot): " idat
            echo "$idat" > id
            sleep 1
            m_bot2
            ;;
        2)
            # Create User Bot Database
            clear
            rm -rf /etc/per
            mkdir -p /etc/per
            cd /etc/per
            touch token id
            echo -e ""
            echo -e "$COLOR1 [ INFO ] ${WH}Create for database Akun Dan Lain Lain"
            
            # Input Token dan ID
            read -rp "Enter Token (Create on @BotFather): " token3
            echo "$token3" > token
            read -rp "Enter Your ID (Create on @userinfobot): " idat2
            echo "$idat2" > id
            sleep 1
            m_bot2
            ;;
        3)
            # Backup Telegram Bot Database
            clear
            rm -rf /usr/bin/token /usr/bin/idchat
            echo -e ""
            echo -e "$COLOR1 [ INFO ] ${WH}Create for database Backup Telegram"
            
            # Input Token dan ID
            read -rp "Enter Token (Create on @BotFather): " token23
            echo "$token23" > /usr/bin/token
            read -rp "Enter Your ID (Create on @userinfobot): " idchat
            echo "$idchat" > /usr/bin/idchat
            sleep 1
            m_bot2
            ;;
        *)
            # Menangani pilihan selain 1, 2, 3
            echo -e "$COLOR1 [ INFO ] ${WH}Exiting or invalid selection. Returning to menu..."
            menu
            ;;
    esac
}


clear

# Informasi Sistem
echo -e "=== SYSTEM ==="
echo -e " OS         : $MODEL2"
echo -e " RAM        : $tram / $uram MB"
echo -e " Date       : $DATE2 WIB"
echo -e " Uptime     : $uphours $upminutes $uptimecek"
echo -e " ISP        : $ISP"
echo -e " City       : $CITY"
echo -e " IP Server  : $MYIP"
echo -e " Sub-Domain : $(cat /etc/xray/domain)"
echo -e " NS-Domain  : $(cat /etc/domain/nsdomain)"

# Status Server
echo -e "=== SERVICES ==="
echo -e " SSH         : $status_ws"
echo -e " XRAY        : $status_xray"
echo -e " NGINX       : $status_nginx"
echo -e " DROPBEAR    : $status_beruangjatuh"
echo -e " UDP CUSTOM  : $status_udp"

# Account Premium
echo -e "=== ACCOUNT ==="
printf "%-10s : %-4s ACCOUNT\n" "SSH" "$total_ssh"
printf "%-10s : %-4s ACCOUNT\n" "VMESS" "$vmess"
printf "%-10s : %-4s ACCOUNT\n" "VLESS" "$vless"
printf "%-10s : %-4s ACCOUNT\n" "TROJAN" "$trtls"

# Menu Pilihan
echo -e "=== MENU ==="
echo -e "[01] SSH-WS      [Menu]    [02] BOT PANEL   [Menu]"
echo -e "[03] VMESS       [Menu]    [04] BOT NOTIF   [Menu]"
echo -e "[05] VLESS       [Menu]    [06] UPDATE      [Menu]"
echo -e "[07] TROJAN      [Menu]    [08] SYSTEM      [Menu]"
echo -e "[09] RESTART     [Menu]    [10] BACKUP      [Menu]"
echo -e "[11] REBOOT      [Menu]    [12] RUNNING     [Menu]"
echo -e "[00] EXIT        [Menu]"

# Pilihan Menu
echo -ne " ${WH}Select menu option ${COLOR1}: ${WH}"
read opt
case $opt in
    01 | 1) clear ; m-sshovpn ;;
    02 | 2) clear ; m-bot ;;
    03 | 3) clear ; m-vmess ;;
    04 | 4) clear ; m-botnotif ;;
    05 | 5) clear ; m-vless ;;
    06 | 6) clear ; m-update ;;
    07 | 7) clear ; m-trojan ;;
    08 | 8) clear ; m-system ;;
    09 | 9) clear ; restartservice ;;
    10) clear ; m-backup ;;
    11) clear ; reboot ;;
    12) clear ; running ;;
    13) clear ;  ;;
    00 | 0) clear ; menu ;;
    *) clear ; menu ;;
esac
