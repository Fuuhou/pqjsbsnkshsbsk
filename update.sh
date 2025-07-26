#!/bin/bash
repo="https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/"
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
###########- COLOR CODE -##############
echo -e " [INFO] Downloading File"
wget -q -O /usr/bin/menu "${repo}menu/menu.sh" && chmod +x /usr/bin/menu
wget -q -O /usr/bin/restore "${repo}menu/restore.sh" && chmod +x /usr/bin/restore
wget -q -O /usr/bin/backup "${repo}menu/backup.sh" && chmod +x /usr/bin/backup
wget -q -O /usr/bin/m-bot "${repo}menu/m-bot.sh" && chmod +x /usr/bin/m-bot
wget -q -O /usr/bin/m-theme "${repo}menu/m-theme.sh" && chmod +x /usr/bin/m-theme
wget -q -O /usr/bin/m-vmess "${repo}menu/m-vmess.sh" && chmod +x /usr/bin/m-vmess
wget -q -O /usr/bin/m-vless "${repo}menu/m-vless.sh" && chmod +x /usr/bin/m-vless
wget -q -O /usr/bin/m-trojan "${repo}menu/m-trojan.sh" && chmod +x /usr/bin/m-trojan
wget -q -O /usr/bin/m-system "${repo}menu/m-system.sh" && chmod +x /usr/bin/m-system
wget -q -O /usr/bin/m-sshovpn "${repo}menu/m-sshovpn.sh" && chmod +x /usr/bin/m-sshovpn
wget -q -O /usr/bin/running "${repo}menu/running.sh" && chmod +x /usr/bin/running
wget -q -O /usr/bin/m-backup "${repo}menu/m-backup.sh" && chmod +x /usr/bin/m-backup
wget -q -O /usr/bin/speedtest "${repo}install/speedtest_cli.py" && chmod +x /usr/bin/speedtest
wget -q -O /usr/bin/bckpbot "${repo}menu/bckpbot.sh" && chmod +x /usr/bin/bckpbot
wget -q -O /usr/bin/tendang "${repo}menu/tendang.sh" && chmod +x /usr/bin/tendang
wget -q -O /usr/bin/bottelegram "${repo}menu/bottelegram.sh" && chmod +x /usr/bin/bottelegram
wget -q -O /usr/bin/xraylimit "${repo}menu/xraylimit.sh" && chmod +x /usr/bin/xraylimit
wget -q -O /usr/bin/trialvmess "${repo}menu/trialvmess.sh" && chmod +x /usr/bin/trialvmess
wget -q -O /usr/bin/trialvless "${repo}menu/trialtrojan.sh" && chmod +x /usr/bin/trialtrojan
wget -q -O /usr/bin/trialtrojan "${repo}menu/trialvless.sh" && chmod +x /usr/bin/trialvless
wget -q -O /usr/bin/trialssh "${repo}menu/trialssh.sh" && chmod +x /usr/bin/trialssh
wget -q -O /usr/bin/bandwidth "${repo}install/bandwidth" && chmod +x /usr/bin/bandwidth
echo -e " [INFO] Download File Successfully"
exit