#!/bin/bash
repo="https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/"
function CEKIP () {
ipsaya=$(wget -qO- ifconfig.me)
MYIP=$(curl -sS ipv4.icanhazip.com)
IPVPS=$(curl -sS https://raw.githubusercontent.com/Fuuhou/izin/main/ip | grep $MYIP | awk '{print $4}')
if [[ $MYIP == $IPVPS ]]; then
domain
WXTNL6
else
  domain
  WXTNL6
fi
}
clear
# Colors
BGCOLOR9="\e[48;5;4m"
red='\e[1;31m'
green='\e[0;32m'
yell='\e[1;33m'
BIBlue='\033[1;94m'       # Blue
BGCOLOR='\e[1;97;101m'    # WHITE RED
tyblue='\e[1;36m'
NC='\e[0m'
purple() { echo -e "\\033[35;1m${*}\\033[0m"; }
tyblue() { echo -e "\\033[36;1m${*}\\033[0m"; }
yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
cd /root
if [ "${EUID}" -ne 0 ]; then
echo "You need to run this script as root"
exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
echo "OpenVZ is not supported"
exit 1
fi
localip=$(hostname -I | cut -d\  -f1)
hst=( `hostname` )
dart=$(cat /etc/hosts | grep -w `hostname` | awk '{print $2}')
if [[ "$hst" != "$dart" ]]; then
echo "$localip $(hostname)" >> /etc/hosts
fi
secs_to_human() {
echo "Installation time : $(( ${1} / 3600 )) hours $(( (${1} / 60) % 60 )) minute's $(( ${1} % 60 )) seconds"
}
rm -rf /etc/rmbl
mkdir -p /etc/rmbl
mkdir -p /etc/rmbl/theme
mkdir -p /var/lib/ >/dev/null 2>&1
echo "IP=" >> /var/lib/ipvps.conf
clear
echo " "
until [[ $name =~ ^[a-zA-Z0-9_.-]+$ ]]; do
read -rp "Enter your name here without spaces: " -e name
done
rm -rf /etc/profil
echo "$name" > /etc/profil
echo ""
clear
author=$(cat /etc/profil)
echo ""
echo ""

# Fungsi untuk update domain
function domain() {
    fun_bar() {
        CMD[0]="$1"
        CMD[1]="$2"
        (
            [[ -e $HOME/fim ]] && rm $HOME/fim
            "${CMD[@]}" -y >/dev/null 2>&1
            touch $HOME/fim
        ) >/dev/null 2>&1 &

        tput civis
        echo -ne "  \033[0;33mUpdate Domain.. \033[1;37m- \033[0;33m["
        while true; do
            for ((i = 0; i < 18; i++)); do
                echo -ne "\033[0;32m#"
                sleep 0.1s
            done
            [[ -e $HOME/fim ]] && rm $HOME/fim && break
            echo -e "\033[0;33m]"
            sleep 1s
            tput cuu1
            tput dl1
            echo -ne "  \033[0;33mUpdate Domain... \033[1;37m- \033[0;33m["
        done
        echo -e "\033[0;33m]\033[1;37m -\033[1;32m Success!\033[1;37m"
        tput cnorm
    }

# Fungsi untuk menginstal wxtnl
res1() {
    wget "${repo}install/wxtnl.sh" && chmod +x wxtnl.sh && ./wxtnl.sh
}

# Function to prompt the user for their domain
set_domain() {
    clear
    echo -e "${BIBlue}│  \033[1;37mEnter Your Custom Domain       ${NC}"
    
    # Loop until a valid domain is entered
    while [[ ! $domain =~ ^[a-zA-Z0-9_.-]+$ ]]; do
        read -rp "   🔹 Enter your domain: " -e domain
        if [[ ! $domain =~ ^[a-zA-Z0-9_.-]+$ ]]; then
            echo -e "${BIRed}❌ Invalid domain. Please enter a valid domain.${NC}"
        fi
    done

    # Loop until a valid nameserver (NS) is entered
    while [[ ! $nameserver =~ ^[a-zA-Z0-9_.-]+$ ]]; do
        read -rp "   🔹 Enter your domain's nameserver (NS): " -e nameserver
        if [[ ! $nameserver =~ ^[a-zA-Z0-9_.-]+$ ]]; then
            echo -e "${BIRed}❌ Invalid NS. Please enter a valid nameserver.${NC}"
        fi
    done

    # Call function to update domain settings
    update_domains "$domain" "$nameserver"
}

# Fungsi untuk memperbarui domain
update_domains() {
    local domain_value="$1"
    local ns_value="$2"
    rm -rf /etc/xray /etc/v2ray /etc/nsdomain /etc/per
    mkdir -p /etc/xray /etc/v2ray /etc/nsdomain /etc/per
    touch /etc/xray/domain /etc/v2ray/domain /etc/xray/slwdomain /etc/v2ray/scdomain /etc/nsdomain/domain
    echo "$domain_value" > /root/domain
    echo "$domain_value" > /etc/xray/domain
    echo "$domain_value" > /etc/v2ray/domain
    echo "$domain_value" > /etc/nsdomain/domain
    echo "$ns_value" >> /etc/nsdomain/domain
    echo "$ns_value" >> /etc/xray/dns
    echo "$domain_value" > /var/lib/ipvps.conf
    echo "$dn1" > /root/subdomainx
    sleep 1
    clear
}
# Memanggil fungsi utama untuk mengatur domain
set_domain
rm /root/subdomainx
}

cat <<EOF>> /etc/rmbl/theme/green
BG : \E[40;1;42m
TEXT : \033[0;32m
EOF
cat <<EOF>> /etc/rmbl/theme/yellow
BG : \E[40;1;43m
TEXT : \033[0;33m
EOF
cat <<EOF>> /etc/rmbl/theme/red
BG : \E[40;1;41m
TEXT : \033[0;31m
EOF
cat <<EOF>> /etc/rmbl/theme/blue
BG : \E[40;1;44m
TEXT : \033[0;34m
EOF
cat <<EOF>> /etc/rmbl/theme/magenta
BG : \E[40;1;45m
TEXT : \033[0;35m
EOF
cat <<EOF>> /etc/rmbl/theme/cyan
BG : \E[40;1;46m
TEXT : \033[0;36m
EOF
cat <<EOF>> /etc/rmbl/theme/lightgray
BG : \E[40;1;47m
TEXT : \033[0;37m
EOF
cat <<EOF>> /etc/rmbl/theme/darkgray
BG : \E[40;1;100m
TEXT : \033[0;90m
EOF
cat <<EOF>> /etc/rmbl/theme/lightred
BG : \E[40;1;101m
TEXT : \033[0;91m
EOF
cat <<EOF>> /etc/rmbl/theme/lightgreen
BG : \E[40;1;102m
TEXT : \033[0;92m
EOF
cat <<EOF>> /etc/rmbl/theme/lightyellow
BG : \E[40;1;103m
TEXT : \033[0;93m
EOF
cat <<EOF>> /etc/rmbl/theme/lightblue
BG : \E[40;1;104m
TEXT : \033[0;94m
EOF
cat <<EOF>> /etc/rmbl/theme/lightmagenta
BG : \E[40;1;105m
TEXT : \033[0;95m
EOF
cat <<EOF>> /etc/rmbl/theme/lightcyan
BG : \E[40;1;106m
TEXT : \033[0;96m
EOF
cat <<EOF>> /etc/rmbl/theme/color.conf
lightcyan
EOF

function WXTNL6(){
cd
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1
clear
wget ${repo}tools.sh &> /dev/null
chmod +x tools.sh 
bash tools.sh
clear
start=$(date +%s)
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
apt install git curl -y >/dev/null 2>&1
apt install python -y >/dev/null 2>&1
}

function WXTNL9(){
            echo -e "Installing Full Setup (SSH, Xray, SlowDNS, UDP Custom)..."
            wget ${repo}install/ssh-vpn.sh && chmod +x ssh-vpn.sh && ./ssh-vpn.sh
            clear

            wget ${repo}install/ins-xray.sh && chmod +x ins-xray.sh && ./ins-xray.sh
            clear

            wget ${repo}sshws/insshws.sh && chmod +x insshws.sh && ./insshws.sh
            clear

            wget ${repo}install/set-br.sh && chmod +x set-br.sh && ./set-br.sh
            clear

            wget ${repo}sshws/ohp.sh && chmod +x ohp.sh && ./ohp.sh
            clear

            wget ${repo}update.sh && chmod +x update.sh && ./update.sh
            clear

            wget ${repo}slowdns/installsl.sh && chmod +x installsl.sh && bash installsl.sh
            clear

            wget ${repo}install/udp-custom.sh && chmod +x udp-custom.sh && bash udp-custom.sh
            clear

            wget ${repo}bin/limit.sh && chmod +x limit.sh && ./limit.sh
            clear
}

function iinfo() {
    clear
    
    # Configuration
    TIMES="10"
    CHATID="-1002085952759"
    KEY="8165453621:AAGbbhY_3xzi0_fFxM_HKxTQFpMWO-phNak"
    URL="https://api.telegram.org/bot$KEY/sendMessage"
    
    # System Information
    MYIP=$(curl -sS ipv4.icanhazip.com)
    ISP=$(cat /etc/xray/isp)
    CITY=$(cat /etc/xray/city)
    DOMAIN=$(cat /etc/xray/domain)
    RAMMS=$(free -m | awk 'NR==2 {print $2}')
    OS_NAME=$(grep -w PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')
    TIME=$(date '+%d %b %Y')
    
    # Authorization Check
    USRSC=$(wget -qO- https://raw.githubusercontent.com/Fuuhou/izin/main/ip | grep $MYIP | awk '{print $2}')
    EXPSC=$(wget -qO- https://raw.githubusercontent.com/Fuuhou/izin/main/ip | grep $MYIP | awk '{print $3}')
    
    # Telegram Message Formatting
    TEXT="
━━━━━━━━━━━━━━━━━━━━
<b>🚀 INSTALL AUTOSCRIPT PREMIUM</b>
━━━━━━━━━━━━━━━━━━━━
<b>👤 Client : </b><code>$USRSC</code>
<b>📅 Date : </b><code>$TIME</code>
<b>⏳ Expiry : </b><code>$EXPSC</code>
<b>🌍 ISP : </b><code>$ISP</code>
<b>🏙️ City : </b><code>$CITY</code>
<b>🖥️ OS : </b><code>$OS_NAME</code>
<b>💾 RAM : </b><code>${RAMMS}MB</code>
━━━━━━━━━━━━━━━━━━━━
"'&reply_markup={"inline_keyboard":[[{"text":"ᴏʀᴅᴇʀ","url":"https://t.me/superxiez"},{"text":"ᴊᴏɪɴ","url":"https://t.me/xiestorez"}]]}' 

    # Send Notification to Telegram
    curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
    
    clear
}

CEKIP
WXTNL9
cat> /root/.profile << END
if [ "$BASH" ]; then
if [ -f ~/.bashrc ]; then
. ~/.bashrc
fi
fi
mesg n || true
clear
menu
END
chmod 644 /root/.profile
if [ -f "/root/log-install.txt" ]; then
rm /root/log-install.txt > /dev/null 2>&1
fi
if [ -f "/etc/afak.conf" ]; then
rm /etc/afak.conf > /dev/null 2>&1
fi
if [ ! -f "/etc/log-create-user.log" ]; then
echo "Log All Account " > /etc/log-create-user.log
fi
history -c
serverV=$( curl -sS ${repo}versi  )
echo $serverV > /opt/.ver
aureb=$(cat /home/re_otm)
b=11
if [ $aureb -gt $b ]
then
gg="PM"
else
gg="AM"
fi
cd
curl -sS ifconfig.me > /etc/myipvps
curl -s ipinfo.io/city?token=75082b4831f909 >> /etc/xray/city
curl -s ipinfo.io/org?token=75082b4831f909  | cut -d " " -f 2-10 >> /etc/xray/isp
rm /root/setup.sh >/dev/null 2>&1
rm /root/slhost.sh >/dev/null 2>&1
rm /root/ssh-vpn.sh >/dev/null 2>&1
rm /root/ins-xray.sh >/dev/null 2>&1
rm /root/insshws.sh >/dev/null 2>&1
rm /root/set-br.sh >/dev/null 2>&1
rm /root/ohp.sh >/dev/null 2>&1
rm /root/update.sh >/dev/null 2>&1
rm /root/slowdns.sh >/dev/null 2>&1
secs_to_human "$(($(date +%s) - ${start}))" | tee -a log-install.txt
sleep 3
echo  ""
cd
iinfo
rm -rf *

# Display Completion Message
clear
echo -e "${BIBlue}╭════════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│${NC}  ${BGCOLOR9} 🚀 INSTALLATION COMPLETED SUCCESSFULLY! ${NC}  ${BIBlue}│${NC}"
echo -e "${BIBlue}╰════════════════════════════════════════════╯${NC}"
echo ""
sleep 2

# Countdown Timer Before Reboot
echo -e "[ ${yell}⚠️ WARNING${NC} ] System will reboot in:"
for i in {15..1}; do
    echo -ne "  🔄 Rebooting in ${yell}$i${NC} seconds...\r"
    sleep 1
done

# Perform Reboot
echo -e "\n\n🚀 ${BIBlue}System is rebooting now...${NC}"
sleep 2
reboot