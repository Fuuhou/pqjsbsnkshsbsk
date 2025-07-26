#!/bin/bash
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
colornow=$(cat /etc/rmbl/theme/color.conf)
NC="\e[0m"
RED="\033[0;31m"
COLOR1="$(cat /etc/rmbl/theme/$colornow | grep -w "TEXT" | cut -d: -f2|sed 's/ //g')"
COLBG1="$(cat /etc/rmbl/theme/$colornow | grep -w "BG" | cut -d: -f2|sed 's/ //g')"
WH='\033[1;37m'
ipsaya=$(wget -qO- ifconfig.me)
data_server=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
date_list=$(date +"%Y-%m-%d" -d "$data_server")
data_ip="https://raw.githubusercontent.com/Fuuhou/izin/main/ip"

ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
author=$(cat /etc/profil)
TIMES="10"
CHATID=$(cat /etc/per/id)
KEY=$(cat /etc/per/token)
URL="https://api.telegram.org/bot$KEY/sendMessage"
domain=`cat /etc/xray/domain`
CHATID2=$(cat /etc/perlogin/id)
KEY2=$(cat /etc/perlogin/token)
URL2="https://api.telegram.org/bot$KEY2/sendMessage"
cd
if [ ! -e /etc/xray/sshx/akun ]; then
mkdir -p /etc/xray/sshx/akun
fi

function usernew(){
clear
domen=`cat /etc/xray/domain`
sldomain=`cat /etc/xray/dns`
slkey=`cat /etc/slowdns/server.pub`
TIMES="10"
CHATID=$(cat /etc/per/id)
KEY=$(cat /etc/per/token)
URL="https://api.telegram.org/bot$KEY/sendMessage"
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
author=$(cat /etc/profil)
clear
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}              ${WH}• SSH PANEL MENU •               ${NC} $COLOR1│ $NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
until [[ $Login =~ ^[a-zA-Z0-9_.-]+$ && ${CLIENT_EXISTS} == '0' ]]; do
read -p "Username : " Login
CLIENT_EXISTS=$(grep -w $Login /etc/xray/ssh | wc -l)
if [[ ${CLIENT_EXISTS} == '1' ]]; then
clear
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}              ${WH}• SSH PANEL MENU •               ${NC} $COLOR1│ $NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1│${WH} Nama Duplikat Silahkan Buat Nama Lain.          $COLOR1│"
read -n 1 -s -r -p "Press any key to back"
usernew
fi
done
read -p "Password : " Pass
until [[ $masaaktif =~ ^[0-9]+$ ]]; do
read -p "Expired (hari): " masaaktif
done
until [[ $iplim =~ ^[0-9]+$ ]]; do
read -p "Limit User (IP): " iplim
done
if [ ! -e /etc/xray/sshx ]; then
mkdir -p /etc/xray/sshx
fi
if [ -z ${iplim} ]; then
iplim="0"
fi
echo "${iplim}" >/etc/xray/sshx/${Login}IP
IP=$(cat /etc/myipvps)

sleep 1
clear
expi=`date -d "$masaaktif days" +"%Y-%m-%d"`
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
echo -e "### $Login $expi $Pass" >> /etc/xray/ssh

TEXT="
━━━━━━━━━━━━━━━━━━━━
<b>PREMIUM SSH ACCOUNT</b>
━━━━━━━━━━━━━━━━━━━━
<b>Hostname :</b> <code>$domen</code>
<b>Username :</b> <code>$Login</code>
<b>Password :</b> <code>$Pass</code>
<b>Format WS : <code>$domen:80@$Login:$Pass</code>
<b>Format UDP : <code>$domen:1-65535@$Login:$Pass</code>
━━━━━━━━━━━━━━━━━━━━
<b>ISP :</b> <code>$ISP</code>
<b>City :</b> <code>$CITY</code>
<b>Login Limit :</b> ${iplim} IP
<b>Port OpenSSH :</b> 22
<b>Port Dropbear :</b> 109, 143
<b>Port SSH WS :</b> 80, 7788, 8181, 8282
<b>Port SSH SSL WS :</b> 443
<b>Port SSL/TLS :</b> 8443,8080
<b>Port OVPN WS SSL :</b> 2086
<b>Port OVPN SSL :</b> 990
<b>Port OVPN TCP :</b> 1194
<b>Port OVPN UDP :</b> 2200
<b>Proxy Squid :</b> 3128
<b>Port Slowdns :</b> 80, 443, 53
<b>BadVPN UDP :</b> 7100 - 7300
<b>NS Hostname :</b> <code>$sldomain</code>
<b>Pub Key :</b> <code>$slkey</code>
━━━━━━━━━━━━━━━━━━━━
<b>Payload WS :</b>
<code>GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: ws[crlf][crlf]</code>
━━━━━━━━━━━━━━━━━━━━
<b>OpenVPN SSL :</b> http://$domen:81/ssl.ovpn
<b>OpenVPN TCP :</b> http://$domen:81/tcp.ovpn
<b>OpenVPN UDP :</b> http://$domen:81/udp.ovpn
━━━━━━━━━━━━━━━━━━━━
<b>EXPIRES ON :</b> <code>$exp</code>
"

curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi

user2=$(echo "$Login" | cut -c 1-3)
TIME2=$(date +'%Y-%m-%d %H:%M:%S')
TEXT2="
<code>━━━━━━━━━━━━━━━━━━━━</code>
<b>   PEMBELIAN SSH SUCCES </b>
<code>━━━━━━━━━━━━━━━━━━━━</code>
<b>DOMAIN  :</b> <code>${domain} </code>
<b>CITY    :</b> <code>$CITY </code>
<b>DATE    :</b> <code>${TIME2} WIB </code>
<b>DETAIL  :</b> <code>Trx SSH </code>
<b>USER    :</b> <code>${user2}xxx </code>
<b>IP      :</b> <code>${iplim} IP </code>
<b>DURASI  :</b> <code>$masaaktif Hari </code>
<code>━━━━━━━━━━━━━━━━━━━━</code>
<i>Notif Pembelian Akun Ssh..</i>"
curl -s --max-time $TIMES -d "chat_id=$CHATID2&disable_web_page_preview=1&text=$TEXT2&parse_mode=html" $URL2 >/dev/null

clear

LOG_FILE="/etc/xray/sshx/akun/log-create-${Login}.log"

# Tulis informasi akun ke log file
{
echo -e "━━━━━━━━━━━━━━━━━━━━"
echo -e "PREMIUM SSH ACCOUNT"
echo -e "━━━━━━━━━━━━━━━━━━━━"
echo -e "Hostname : $domen"
echo -e "Username : $Login"
echo -e "Password : $Pass"
echo -e "Format WS : $domen:80@$Login:$Pass"
echo -e "Format UDP : $domen:1-65535@$Login:$Pass"
echo -e "━━━━━━━━━━━━━━━━━━━━"
echo -e "ISP : $ISP"
echo -e "City : $CITY"
echo -e "Login Limit : ${iplim} IP"
echo -e "Port OpenSSH : 22"
echo -e "Port Dropbear : 109, 143"
echo -e "Port SSH WS : 80, 7788, 8181, 8282"
echo -e "Port SSH SSL WS : 443"
echo -e "Port SSL/TLS : 8443,8080"
echo -e "Port OVPN WS SSL : 2086"
echo -e "Port OVPN SSL : 990"
echo -e "Port OVPN TCP : 1194"
echo -e "Port OVPN UDP : 2200"
echo -e "Proxy Squid : 3128"
echo -e "Port SlowDNS : 80, 443, 53"
echo -e "BadVPN UDP : 7100 - 7300"
echo -e "NS Hostname : $sldomain"
echo -e "Pub Key : $slkey"
echo -e "━━━━━━━━━━━━━━━━━━━━"
echo -e "Payload WS :"
echo -e "GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: ws[crlf][crlf]"
echo -e "━━━━━━━━━━━━━━━━━━━━"
echo -e "OpenVPN SSL : http://$domen:81/ssl.ovpn"
echo -e "OpenVPN TCP : http://$domen:81/tcp.ovpn"
echo -e "OpenVPN UDP : http://$domen:81/udp.ovpn"
echo -e "━━━━━━━━━━━━━━━━━━━━"
echo -e "EXPIRES ON : $exp"
} | tee -a "$LOG_FILE"

read -n 1 -s -r -p "Press any key to back on menu"
menu
}

function trial(){
clear
domen=`cat /etc/xray/domain`
sldomain=`cat /etc/xray/dns`
slkey=`cat /etc/slowdns/server.pub`
TIMES="10"
CHATID=$(cat /etc/per/id)
KEY=$(cat /etc/per/token)
URL="https://api.telegram.org/bot$KEY/sendMessage"
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
author=$(cat /etc/profil)
clear
IP=$(cat /etc/myipvps)
cd
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}           ${WH}• TRIAL SSH Account •               ${NC} $COLOR1│ $NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e ""
until [[ $timer =~ ^[0-9]+$ ]]; do
read -p "Expired (Minutes): " timer
done
Login=Trial-`</dev/urandom tr -dc X-Z0-9 | head -c4`
hari=1
Pass=1
iplim=1
if [ ! -e /etc/xray/sshx ]; then
mkdir -p /etc/xray/sshx
fi
if [ -z ${iplim} ]; then
iplim="0"
fi
if [[ -e /etc/cloudfront ]]; then
cloudfront=$(cat /etc/cloudfront)
else
cloudfront="Kosong"
fi
echo "$iplim" > /etc/xray/sshx/${Login}IP
expi=`date -d "$hari days" +"%Y-%m-%d"`
useradd -e `date -d "$hari days" +"%Y-%m-%d"` -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
echo -e "### $Login $expi $Pass" >> /etc/xray/ssh
tmux new-session -d -s $Login "trial ssh $Login $expi $Pass ${timer}"
# Jadwalkan penghapusan akun setelah 60 menit
echo "rm -f /etc/xray/sshx/${Login} /etc/xray/sshx/${Login}IP && sed -i '/$user/d' /etc/xray/ssh " | at now + $timer minutes

TEXT="
━━━━━━━━━━━━━━━━━━━━
<b>TRIAL SSH ACCOUNT</b>
━━━━━━━━━━━━━━━━━━━━
<b>Hostname :</b> <code>$domen</code>
<b>Username :</b> <code>$Login</code>
<b>Password :</b> <code>$Pass</code>
<b>Format WS : <code>$domen:80@$Login:$Pass</code>
<b>Format UDP : <code>$domen:1-65535@$Login:$Pass</code>
━━━━━━━━━━━━━━━━━━━━
<b>ISP :</b> <code>$ISP</code>
<b>City :</b> <code>$CITY</code>
<b>Login Limit :</b> ${iplim} IP
<b>Port OpenSSH :</b> 22
<b>Port Dropbear :</b> 109, 143
<b>Port SSH WS :</b> 80, 7788, 8181, 8282
<b>Port SSH SSL WS :</b> 443
<b>Port SSL/TLS :</b> 8443,8080
<b>Port OVPN WS SSL :</b> 2086
<b>Port OVPN SSL :</b> 990
<b>Port OVPN TCP :</b> 1194
<b>Port OVPN UDP :</b> 2200
<b>Proxy Squid :</b> 3128
<b>Port Slowdns :</b> 80, 443, 53
<b>BadVPN UDP :</b> 7100 - 7300
<b>NS Hostname :</b> <code>$sldomain</code>
<b>Pub Key :</b> <code>$slkey</code>
━━━━━━━━━━━━━━━━━━━━
<b>Payload WS :</b>
<code>GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: ws[crlf][crlf]</code>
━━━━━━━━━━━━━━━━━━━━
<b>OpenVPN SSL :</b> http://$domen:81/ssl.ovpn
<b>OpenVPN TCP :</b> http://$domen:81/tcp.ovpn
<b>OpenVPN UDP :</b> http://$domen:81/udp.ovpn
━━━━━━━━━━━━━━━━━━━━
<b>EXPIRES ON :</b> <code>$timer Minutes</code>
"

curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
cat> /etc/cron.d/trialssh${Login} << EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/$timer * * * * root /usr/bin/trial ssh $Login $Pass $expi
EOF
clear

LOG_FILE="/etc/xray/sshx/akun/log-create-${Login}.log"

# Tulis informasi akun ke log file
{
echo -e "━━━━━━━━━━━━━━━━━━━━"
echo -e "TRIAL SSH ACCOUNT"
echo -e "━━━━━━━━━━━━━━━━━━━━"
echo -e "Hostname : $domen"
echo -e "Username : $Login"
echo -e "Password : $Pass"
echo -e "Format WS : $domen:80@$Login:$Pass"
echo -e "Format UDP : $domen:1-65535@$Login:$Pass"
echo -e "━━━━━━━━━━━━━━━━━━━━"
echo -e "ISP : $ISP"
echo -e "City : $CITY"
echo -e "Login Limit : ${iplim} IP"
echo -e "Port OpenSSH : 22"
echo -e "Port Dropbear : 109, 143"
echo -e "Port SSH WS : 80, 7788, 8181, 8282"
echo -e "Port SSH SSL WS : 443"
echo -e "Port SSL/TLS : 8443,8080"
echo -e "Port OVPN WS SSL : 2086"
echo -e "Port OVPN SSL : 990"
echo -e "Port OVPN TCP : 1194"
echo -e "Port OVPN UDP : 2200"
echo -e "Proxy Squid : 3128"
echo -e "Port SlowDNS : 80, 443, 53"
echo -e "BadVPN UDP : 7100 - 7300"
echo -e "NS Hostname : $sldomain"
echo -e "Pub Key : $slkey"
echo -e "━━━━━━━━━━━━━━━━━━━━"
echo -e "Payload WS :"
echo -e "GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: ws[crlf][crlf]"
echo -e "━━━━━━━━━━━━━━━━━━━━"
echo -e "OpenVPN SSL : http://$domen:81/ssl.ovpn"
echo -e "OpenVPN TCP : http://$domen:81/tcp.ovpn"
echo -e "OpenVPN UDP : http://$domen:81/udp.ovpn"
echo -e "━━━━━━━━━━━━━━━━━━━━"
echo -e "EXPIRES ON : $timer Minutes"
} | tee -a "$LOG_FILE"

read -n 1 -s -r -p "Press any key to back on menu"
menu
}

function renew(){
clear
TIMES="10"
CHATID=$(cat /etc/per/id)
KEY=$(cat /etc/per/token)
URL="https://api.telegram.org/bot$KEY/sendMessage"
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
domain=$(cat /etc/xray/domain)
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/ssh")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}             ${WH}• RENEW USERS •                    │${NC}$COLOR1$NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│                                                 │"
echo -e "$COLOR1│${WH} User Tidak Ada!                              $COLOR1   │"
echo -e "$COLOR1│                                                 │"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
m-sshovpn
fi
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}             ${WH}• RENEW USERS •                    │${NC}$COLOR1$NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│ ${WH}Silahkan Pilih User Yang Mau di Renew$COLOR1           │"
echo -e "$COLOR1│ ${WH}ketik [0] kembali kemenu$COLOR1                        │"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Select one client [1]: " CLIENT_NUMBER
else
read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-sshovpn
fi
fi
done
User=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
Pass=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
egrep "^$User" /etc/passwd >/dev/null
if [ $? -eq 0 ]; then
read -p "Day Extend : " Days
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $Days))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
passwd -u $User
usermod -e  $exp4 $User
egrep "^$User" /etc/passwd >/dev/null
echo -e "$Pass\n$Pass\n"|passwd $User &> /dev/null
sed -i "s/### $User $exp/### $User $exp4/g" /etc/xray/ssh >/dev/null
clear
TEXT="
━━━━━━━━━━━━━━━━━━━━
<b>  SSH RENEW</b>
━━━━━━━━━━━━━━━━━━━━
<b>DOMAIN   :</b> <code>${domain} </code>
<b>ISP      :</b> <code>$ISP $CITY </code>
<b>USERNAME :</b> <code>$User </code>
<b>EXPIRED  :</b> <code>$exp4 </code>
━━━━━━━━━━━━━━━━━━━━
"
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
user2=$(echo "$User" | cut -c 1-3)
TIME2=$(date +'%Y-%m-%d %H:%M:%S')
TEXT2="
━━━━━━━━━━━━━━━━━━━━
<b>   TRANSAKSI SUCCES </b>
━━━━━━━━━━━━━━━━━━━━
<b>DOMAIN   :</b> <code>${domain} </code>
<b>ISP      :</b> <code>$CITY </code>
<b>DATE   :</b> <code>${TIME2} WIB</code>
<b>DETAIL   :</b> <code>Trx SSH </code>
<b>USER :</b> <code>${user2}xxx </code>
<b>DURASI  :</b> <code>$Days Hari </code>
━━━━━━━━━━━━━━━━━━━━
<i>Renew Account From Server..</i>
"
curl -s --max-time $TIMES -d "chat_id=$CHATID2&disable_web_page_preview=1&text=$TEXT2&parse_mode=html" $URL2 >/dev/null
clear
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}             ${WH}• RENEW USERS •                    │${NC}$COLOR1$NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│"
echo -e "$COLOR1│ ${WH}Username   : $User"
echo -e "$COLOR1│ ${WH}Days Added : $Days Days"
echo -e "$COLOR1│ ${WH}Expired on : $exp4"
echo -e "$COLOR1│"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
fi
read -n 1 -s -r -p "Press any key to back on menu"
m-sshovpn
}

function hapus(){
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/ssh")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}             ${WH}• DELETE USERS •                   │${NC}$COLOR1$NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│                                                 │"
echo -e "$COLOR1│${WH} User Tidak Ada!                              $COLOR1   │"
echo -e "$COLOR1│                                                 │"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
m-sshovpn
fi
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}             ${WH}• DELETE USERS •                   │${NC}$COLOR1$NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│ ${WH}Silahkan Pilih User Yang Mau Didelete     $COLOR1      │"
echo -e "$COLOR1│ ${WH}ketik [0] kembali kemenu                     $COLOR1   │"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Select one client [1]: " CLIENT_NUMBER
else
read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-sshovpn
fi
fi
done
Pengguna=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
Days=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
Pass=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
sed -i "/^### $Pengguna $Days $Pass/d" /etc/xray/ssh
rm /home/vps/public_html/ssh-$Pengguna.txt >/dev/null 2>&1
rm /etc/xray/sshx/${Pengguna}IP >/dev/null 2>&1
rm /etc/xray/sshx/${Pengguna}login >/dev/null 2>&1
if getent passwd $Pengguna > /dev/null 2>&1; then
userdel $Pengguna > /dev/null 2>&1
echo -e "User $Pengguna was removed."
else
echo -e "Failure: User $Pengguna Not Exist."
fi
TEXT="
━━━━━━━━━━━━━━━━━━━━
<b>  DELETE SSH OVPN</b>
━━━━━━━━━━━━━━━━━━━━
<b>DOMAIN   :</b> <code>${domain} </code>
<b>ISP      :</b> <code>$ISP $CITY </code>
<b>USERNAME :</b> <code>$Pengguna </code>
<b>EXPIRED  :</b> <code>$Days </code>
━━━━━━━━━━━━━━━━━━━━
<i>Succes Delete This User...</i>
"
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
read -n 1 -s -r -p "Press any key to back on menu"
m-sshovpn
}
function cekconfig(){
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
author=$(cat /etc/profil)
IP=$(cat /etc/myipvps)
domen=`cat /etc/xray/domain`
sldomain=`cat /etc/xray/dns`
slkey=`cat /etc/slowdns/server.pub`
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/ssh")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}             ${WH}• USER CONFIG •                    │${NC}$COLOR1$NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│                                                 │"
echo -e "$COLOR1│${WH} User Tidak Ada!                              $COLOR1   │"
echo -e "$COLOR1│                                                 │"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
m-sshovpn
fi
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}             ${WH}• USER CONFIG •                    │${NC}$COLOR1$NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│ ${WH}Silahkan Pilih User Yang Mau Dicek     $COLOR1         │"
echo -e "$COLOR1│ ${WH}ketik [0] kembali kemenu                     $COLOR1   │"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Select one client [1]: " CLIENT_NUMBER
else
read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-sshovpn
fi
fi
done
Login=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
cat /etc/xray/sshx/akun/log-create-${Login}.log
cat /etc/xray/sshx/akun/log-create-${Login}.log > /etc/notifakun
sed -i 's/\x1B\[1;37m//g' /etc/notifakun
sed -i 's/\x1B\[0;96m//g' /etc/notifakun
sed -i 's/\x1B\[0m//g' /etc/notifakun
TEXT=$(cat /etc/notifakun)
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
read -n 1 -s -r -p "   Press any key to back on menu"
menu
}

function hapuslama(){
clear
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1 ${NC} ${COLBG1}                 ${WH}• MEMBER SSH •                 ${NC}$COLOR1$NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo "USERNAME          EXP DATE          STATUS"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
while read expired
do
AKUN="$(echo $expired | cut -d: -f1)"
ID="$(echo $expired | grep -v nobody | cut -d: -f3)"
exp="$(chage -l $AKUN | grep "Account expires" | awk -F": " '{print $2}')"
status="$(passwd -S $AKUN | awk '{print $2}' )"
if [[ $ID -ge 1000 ]]; then
if [[ "$status" = "L" ]]; then
printf "%-17s %2s %-17s %2s \n" "$AKUN" "$exp     " "LOCKED"
else
printf "%-17s %2s %-17s %2s \n" "$AKUN" "$exp     " "UNLOCKED"
fi
fi
done < /etc/passwd
JUMLAH="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo "Account number: $JUMLAH user"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1 ${NC}${COLBG1}              ${WH}• DELETE USERS •                   ${NC}$COLOR1$NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo ""
read -p "Username SSH to Delete : " Pengguna
if getent passwd $Pengguna > /dev/null 2>&1; then
userdel $Pengguna > /dev/null 2>&1
echo -e "User $Pengguna was removed."
else
echo -e "Failure: User $Pengguna Not Exist."
fi
sed -i "/^### $Pengguna/d" /etc/xray/ssh
read -n 1 -s -r -p "Press any key to back on menu"
m-sshovpn
}

function cek(){
TIMES="10"
CHATID=$(cat /etc/per/id)
KEY=$(cat /etc/per/token)
URL="https://api.telegram.org/bot$KEY/sendMessage"
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
domain=$(cat /etc/xray/domain)
author=$(cat /etc/profil)
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}             ${WH}• SSH ACTIVE USERS •              ${NC} $COLOR1│ $NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
rm -rf /tmp/ssh2
sleep 3
if [ -e "/var/log/auth.log" ]; then
LOG="/var/log/auth.log";
fi
cat /etc/passwd | grep "/home/" | cut -d":" -f1 > /etc/user.txt
username1=( `cat "/etc/user.txt" `);
i="0";
for user in "${username1[@]}"
do
username[$i]=`echo $user | sed 's/'\''//g'`;
jumlah[$i]=0;
i=$i+1;
done
cat $LOG | grep -i dropbear | grep -i "Password auth succeeded" > /tmp/log-db.txt
proc=( `ps aux | grep -i dropbear | awk '{print $2}'`);
for PID in "${proc[@]}"
do
cat /tmp/log-db.txt | grep "dropbear\[$PID\]" > /tmp/log-db-pid.txt
NUM=`cat /tmp/log-db-pid.txt | wc -l`;
USER=`cat /tmp/log-db-pid.txt | awk '{print $10}' | sed 's/'\''//g'`;
IP=`cat /tmp/log-db-pid.txt | awk '{print $12}'`;
if [ $NUM -eq 1 ]; then
TIME=$(date +'%H:%M:%S')
echo "$USER $TIME : $IP" >>/tmp/ssh2
i=0;
for user1 in "${username[@]}"
do
if [ "$USER" == "$user1" ]; then
jumlah[$i]=`expr ${jumlah[$i]} + 1`;
pid[$i]="${pid[$i]} $PID"
fi
i=$i+1;
done
fi
done
cat $LOG | grep -i sshd | grep -i "Accepted password for" > /tmp/log-db.txt
data=( `ps aux | grep "\[priv\]" | sort -k 72 | awk '{print $2}'`);
for PID in "${data[@]}"
do
cat /tmp/log-db.txt | grep "sshd\[$PID\]" > /tmp/log-db-pid.txt;
NUM=`cat /tmp/log-db-pid.txt | wc -l`;
USER=`cat /tmp/log-db-pid.txt | awk '{print $9}'`;
IP=`cat /tmp/log-db-pid.txt | awk '{print $11}'`;
if [ $NUM -eq 1 ]; then
TIME=$(date +'%H:%M:%S')
echo "$USER $TIME : $IP" >>/tmp/ssh2
i=0;
for user1 in "${username[@]}"
do
if [ "$USER" == "$user1" ]; then
jumlah[$i]=`expr ${jumlah[$i]} + 1`;
pid[$i]="${pid[$i]} $PID"
fi
i=$i+1;
done
fi
done
j="0";
for i in ${!username[*]}
do
limitip="0"
if [[ ${jumlah[$i]} -gt $limitip ]]; then
sship=$(cat /tmp/ssh2  | grep -w "${username[$i]}" | wc -l)
echo -e "$COLOR1${NC} USERNAME : \033[0;33m${username[$i]}";
echo -e "$COLOR1${NC} IP LOGIN : \033[0;33m$sship";
echo -e ""
fi
done
if [ -f "/etc/openvpn/server/openvpn-tcp.log" ]; then
echo " "
cat /etc/openvpn/server/openvpn-tcp.log | grep -w "^CLIENT_LIST" | cut -d ',' -f 2,3,8 | sed -e 's/,/      /g' > /tmp/vpn-login-tcp.txt
cat /tmp/vpn-login-tcp.txt
fi
if [ -f "/etc/openvpn/server/openvpn-udp.log" ]; then
echo " "
cat /etc/openvpn/server/openvpn-udp.log | grep -w "^CLIENT_LIST" | cut -d ',' -f 2,3,8 | sed -e 's/,/      /g' > /tmp/vpn-login-udp.txt
cat /tmp/vpn-login-udp.txt
fi
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
m-sshovpn
}

function limitssh(){
cd
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/ssh")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "$COLOR1 ${NC}${COLBG1}    ${WH}⇱ Limit SSH Account ⇲        ${NC} $COLOR1 $NC"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "You have no existing clients!"
echo ""
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
m-sshovpn
fi
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "$COLOR1 ${NC}${COLBG1}    ${WH}⇱ Limit SSH Account ⇲        ${NC} $COLOR1 $NC"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Select the existing client you want to change ip"
echo " ketik [0] kembali kemenu"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Select one client [1]: " CLIENT_NUMBER
else
read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-sshovpn
fi
fi
done
until [[ $iplim =~ ^[0-9]+$ ]]; do
read -p "Limit User (IP) New: " iplim
done
if [ ! -e /etc/xray/sshx ]; then
mkdir -p /etc/xray/sshx
fi
if [ -z ${iplim} ]; then
iplim="0"
fi
user=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
echo "${iplim}" >/etc/xray/sshx/${user}IP
TEXT="
━━━━━━━━━━━━━━━━━━━━
<b>  SSH IP LIMIT</b>
━━━━━━━━━━━━━━━━━━━━
<b>DOMAIN   :</b> <code>${domain} </code>
<b>ISP      :</b> <code>$ISP $CITY </code>
<b>USERNAME :</b> <code>$user </code>
<b>EXPIRED  :</b> <code>$exp </code>
<b>IP LIMIT NEW :</b> <code>$iplim IP </code>
━━━━━━━━━━━━━━━━━━━━
<i>Succes Change IP LIMIT...</i>
"
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
clear
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " SSH Account Was Successfully Change Limit IP"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " Client Name : $user"
echo " Limit IP    : $iplim IP"
echo ""
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
m-sshovpn
}

clear
function listssh(){
clear
echo -e "$COLOR1╭══════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│ \033[1;37mPlease select a your Choice              $COLOR1│${NC}"
echo -e "$COLOR1╰══════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭══════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│  [ 1 ]  \033[1;37mAUTO LOCKED USER SSH      ${NC}"
echo -e "$COLOR1│  [ 2 ]  \033[1;37mAUTO DELETE USER SSH    ${NC}"
echo -e "$COLOR1│  "
echo -e "$COLOR1│  [ 0 ]  \033[1;37mBACK TO MENU    ${NC}"
echo -e "$COLOR1╰══════════════════════════════════════════╯${NC}"
until [[ $lock =~ ^[0-2]+$ ]]; do
read -p "   Please select numbers 1 sampai 2 : " lock
done
if [[ $lock == "0" ]]; then
menu
elif [[ $lock == "1" ]]; then
clear
echo "lock" > /etc/typessh
echo -e "$COLOR1╭═══════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}          ${WH}• SETTING MULTI LOGIN •            ${NC} $COLOR1│ $NC"
echo -e "$COLOR1╰═══════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═══════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│$NC Succes Ganti Auto Lock  ${NC}"
echo -e "$COLOR1│$NC Jika User Melanggar auto lock Account. ${NC}"
echo -e "$COLOR1╰═══════════════════════════════════════════════╯${NC}"
sleep 1
elif [[ $lock == "2" ]]; then
clear
echo "delete" > /etc/typessh
echo -e "$COLOR1╭═══════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}          ${WH}• SETTING MULTI LOGIN •            ${NC} $COLOR1│ $NC"
echo -e "$COLOR1╰═══════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═══════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│$NC Succes Ganti Auto Delete Accounr ${NC}"
echo -e "$COLOR1│$NC Jika User Melanggar auto Delete Account. ${NC}"
echo -e "$COLOR1╰═══════════════════════════════════════════════╯${NC}"
sleep 1
fi
type=$(cat /etc/typessh)
if [ $type = "lock" ]; then
clear
echo -e "$COLOR1╭═══════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}          ${WH}• SETTING MULTI LOGIN •            ${NC} $COLOR1│ $NC"
echo -e "$COLOR1╰═══════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═══════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│$NC SILAHKAN TULIS JUMLAH WAKTU UNTUK LOCKED  ${NC}"
echo -e "$COLOR1│$NC BISA TULIS 15 MENIT DLL. ${NC}"
echo -e "$COLOR1╰═══════════════════════════════════════════════╯${NC}"
read -rp "   Jumlah Waktu Lock: " -e notif2
echo "${notif2}" > /etc/waktulockssh
clear
echo -e "$COLOR1╭═══════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}          ${WH}• SETTING MULTI LOGIN •            ${NC} $COLOR1│ $NC"
echo -e "$COLOR1╰═══════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│ $NC SILAHKAN TULIS JUMLAH NOTIFIKASI UNTUK AUTO LOCK    ${NC}"
echo -e "${COLOR1}│ $NC AKUN USER YANG MULTI LOGIN     ${NC}"
echo -e "$COLOR1╰═══════════════════════════════════════════════╯${NC}"
read -rp "   Jika Mau 3x Notif baru kelock tulis 3, dst: " -e notif
cd /etc/xray/sshx
echo "$notif" > notif
clear
echo -e "$COLOR1╭═══════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}          ${WH}• SETTING MULTI LOGIN •            ${NC} $COLOR1│ $NC"
echo -e "$COLOR1╰═══════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│ $NC SUCCES GANTI NOTIF LOCK JADI $notif $NC "
echo -e "${COLOR1}│ $NC SUCCES GANTI TIME NOTIF LOCK JADI $notif2 MENIT $NC "
echo -e "$COLOR1╰═══════════════════════════════════════════════╯${NC}"
else
echo -e "$COLOR1╭═══════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}          ${WH}• SETTING MULTI LOGIN •            ${NC} $COLOR1│ $NC"
echo -e "$COLOR1╰═══════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═══════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│$NC SILAHKAN TULIS JUMLAH WAKTU UNTUK UNTUK SCAN ${NC}"
echo -e "$COLOR1│$NC USER YANG SEDANG MULTI LOGIN . ${NC}"
echo -e "$COLOR1╰═══════════════════════════════════════════════╯${NC}"
read -rp "   Tulis Waktu Scan (Menit) : " -e notif2
echo "# Autokill" >/etc/cron.d/tendang
echo "SHELL=/bin/sh" >>/etc/cron.d/tendang
echo "PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin" >>/etc/cron.d/tendang
echo "*/$notif2 * * * *  root /usr/bin/tendang" >>/etc/cron.d/tendang
clear
echo -e "$COLOR1╭═══════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}          ${WH}• SETTING MULTI LOGIN •            ${NC} $COLOR1│ $NC"
echo -e "$COLOR1╰═══════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│ $NC SILAHKAN TULIS JUMLAH NOTIFIKASI UNTUK AUTO LOCK    ${NC}"
echo -e "${COLOR1}│ $NC AKUN USER YANG MULTI LOGIN     ${NC}"
echo -e "$COLOR1╰═══════════════════════════════════════════════╯${NC}"
read -rp "   Jika Mau 3x Notif baru kelock tulis 3, dst: " -e notif
cd /etc/xray/sshx
echo "$notif" > notif
clear
echo -e "$COLOR1╭═══════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}          ${WH}• SETTING MULTI LOGIN •            ${NC} $COLOR1│ $NC"
echo -e "$COLOR1╰═══════════════════════════════════════════════╯{NC}"
echo -e "$COLOR1╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│ $NC SUCCES GANTI NOTIF LOCK JADI $notif $NC "
echo -e "${COLOR1}│ $NC SUCCES GANTI TIME NOTIF LOCK JADI $notif2 MENIT $NC "
echo -e "$COLOR1╰═══════════════════════════════════════════════╯${NC}"
fi
read -n 1 -s -r -p "Press any key to back on menu"
m-sshovpn
}

function lockssh(){
clear
cd
if [ ! -e /etc/xray/sshx/listlock ]; then
echo "" > /etc/xray/sshx/listlock
fi
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/sshx/listlock")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "$COLOR1 ${NC}${COLBG1}    ${WH}⇱ Unlock SSH Account ⇲       ${NC} $COLOR1 $NC"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "You have no existing user Lock!"
echo ""
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -n 1 -s -r -p "Press any key to back on menu"
m-sshovpn
fi
clear
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "$COLOR1 ${NC}${COLBG1}    ${WH}⇱ Unlock SSH Account ⇲       ${NC} $COLOR1 $NC"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Select the existing client you want to Unlock"
echo " ketik [0] kembali kemenu"
echo " tulis clear untuk delete semua Akun"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "     No  User      Expired"
grep -E "^### " "/etc/xray/sshx/listlock" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Select one client [1]: " CLIENT_NUMBER
else
read -rp "Select one client [1-${NUMBER_OF_CLIENTS}] to Unlock: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-sshovpn
fi
if [[ ${CLIENT_NUMBER} == 'clear' ]]; then
rm /etc/xray/sshx/listlock
m-sshovpn
fi
fi
done
user=$(grep -E "^### " "/etc/xray/sshx/listlock" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/etc/xray/sshx/listlock" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
pass=$(grep -E "^### " "/etc/xray/sshx/listlock" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
passwd -u $user &> /dev/null
echo -e "### $Login $exp $Pass" >> /etc/xray/ssh
sed -i "/^### $user $exp $pass/d" /etc/xray/sshx/listlock &> /dev/null
TEXT="
━━━━━━━━━━━━━━━━━━━━
<b>  SSH UNLOK </b>
<code>◇━━━━━━━━━━━━━━◇
<b>DOMAIN   :</b> <code>${domain} </code>
<b>ISP      :</b> <code>$ISP $CITY </code>
<b>USERNAME :</b> <code>$user </code>
<b>IP LIMIT  :</b> <code>$iplim IP </code>
<b>EXPIRED  :</b> <code>$exp </code>
━━━━━━━━━━━━━━━━━━━━
<i>Succes Unlock Akun...</i>
"
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
clear
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " SSH Account Unlock Successfully"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Client Name : $user"
echo " Status  : Unlocked"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
m-sshovpn
}

clear
author=$(cat /etc/profil)
echo -e " $COLOR1╭════════════════════════════════════════════════════╮${NC}"
echo -e " $COLOR1│${NC} ${COLBG1}            ${WH}• SSH PANEL MENU •                    ${NC} $COLOR1│ $NC"
echo -e " $COLOR1╰════════════════════════════════════════════════════╯${NC}"
echo -e " $COLOR1╭════════════════════════════════════════════════════╮${NC}"
echo -e " $COLOR1│ $NC  ${WH}[${COLOR1}01${WH}]${NC} ${COLOR1}• ${WH}ADD AKUN${NC}        ${WH}[${COLOR1}05${WH}]${NC} ${COLOR1}• ${WH}CEK USER ONLINE${NC}    $COLOR1│ $NC"
echo -e " $COLOR1│ $NC  ${WH}[${COLOR1}02${WH}]${NC} ${COLOR1}• ${WH}TRIAL AKUN${NC}      ${WH}[${COLOR1}06${WH}]${NC} ${COLOR1}• ${WH}CEK USER CONFIG${NC}    $COLOR1│ $NC"
echo -e " $COLOR1│ $NC  ${WH}[${COLOR1}03${WH}]${NC} ${COLOR1}• ${WH}RENEW AKUN${NC}      ${WH}[${COLOR1}07${WH}]${NC} ${COLOR1}• ${WH}CHANGE IP LIMIT${NC}    $COLOR1│ $NC"
echo -e " $COLOR1│ $NC  ${WH}[${COLOR1}04${WH}]${NC} ${COLOR1}• ${WH}DELETE AKUN${NC}     ${WH}[${COLOR1}08${WH}]${NC} ${COLOR1}• ${WH}SETTING LOCK LOGIN${NC} $COLOR1│ $NC"
echo -e " $COLOR1│ $NC  ${WH}[${COLOR1}00${WH}]${NC} ${COLOR1}• ${WH}GO BACK${NC}         ${WH}[${COLOR1}09${WH}]${NC} ${COLOR1}• ${WH}UNLOCK LOGIN${NC}      $COLOR1 │$NC"
echo -e " $COLOR1╰════════════════════════════════════════════════════╯${NC}"
echo -e " $COLOR1╭═════════════════════════ ${WH}BY${NC} ${COLOR1}═══════════════════════╮ ${NC}"
echo -e "  $COLOR1${NC}              ${WH}   • $author •                 $COLOR1 $NC"
echo -e " $COLOR1╰════════════════════════════════════════════════════╯${NC}"
echo -e ""
echo -ne " ${WH}Select menu ${COLOR1}: ${WH}"; read opt
case $opt in
01 | 1) clear ; usernew ; exit ;;
02 | 2) clear ; trial ; exit ;;
03 | 3) clear ; renew ; exit ;;
04 | 4) clear ; hapus ; exit ;;
05 | 5) clear ; cek ; exit ;;
06 | 6) clear ; cekconfig ; exit ;;
07 | 7) clear ; limitssh; exit ;;
08 | 8) clear ; listssh ; exit ;;
09 | 9) clear ; lockssh ; exit ;;
10 | 10) clear ; hapuslama ; exit ;;
00 | 0) clear ; menu ; exit ;;
X  | 0) clear ; m-sshovpn ;;
x) exit ;;
*) echo "Anda salah tekan " ; sleep 1 ; m-sshovpn ;;
esac
