#!/bin/bash

# Load color configuration
colornow=$(cat /etc/rmbl/theme/color.conf)
export NC="\e[0m"
export YELLOW='\033[0;33m'
export RED="\033[0;31m"
export COLOR1="$(grep -w "TEXT" /etc/rmbl/theme/$colornow | cut -d: -f2 | sed 's/ //g')"
export COLBG1="$(grep -w "BG" /etc/rmbl/theme/$colornow | cut -d: -f2 | sed 's/ //g')"
export WH='\033[1;37m'

# Status indicators
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Green_background_prefix="\033[42;37m" 
Red_background_prefix="\033[41;37m"
Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[ON]${Font_color_suffix}"
Error="${Red_font_prefix}[OFF]${Font_color_suffix}"

function jamhabis() {
    clear
    # Cleanup old cron jobs
    rm -rf /etc/cron.d/autobackup
    rm -rf /etc/cron.d/bckp_otm
    rm -rf /etc/jam
    
    # Check current status
    cek=$(grep -c -E "^# Autobackup" /etc/cron.d/autobackup 2>/dev/null)
    [[ "$cek" = "1" ]] && sts="${Info}" || sts="${Error}"
    
    # Display menu
    echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e " ${COLBG1}          AUTO BACKUP          ${NC}"
    echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e " Status Auto Backup : $sts"
    echo -e ""
    echo -e " [1] AutoBackup Every 30 Minutes"
    echo -e " [2] AutoBackup Every 60 Minutes"
    echo -e " [3] AutoBackup Every 120 Minutes"
    echo -e " [4] AutoBackup Every 180 Minutes"
    echo -e " [5] AutoBackup Every 240 Minutes"
    echo -e " [6] Turn Off Auto Backup"
    echo -e " [x] Return to Main Menu"
    echo -e ""
    echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    read -p " Select an option [1-6 or x]: " backup
    [[ -z $backup ]] && jamhabis
    
    case $backup in
        1) set_cron_job "30" ;;
        2) set_cron_job "60" ;;
        3) set_cron_job "120" ;;
        4) set_cron_job "180" ;;
        5) set_cron_job "240" ;;
        6) disable_backup ;;
        x) clear; menu ;;
        *) jamhabis ;;
    esac
}

function set_cron_job() {
    local minutes=$1
    clear
    
    # Create new cron job
    cat > /etc/cron.d/autobackup <<EOF
# Autobackup
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/$minutes * * * * root /usr/bin/bottelegram
EOF
    
    # Display confirmation
    echo -e "\n${COLOR1}======================================${NC}"
    echo -e " AutoBackup Every : $minutes Minutes"
    echo -e "${COLOR1}======================================${NC}\n"
    
    # Restart cron service
    service cron restart >/dev/null 2>&1
    service cron reload >/dev/null 2>&1
}

function disable_backup() {
    clear
    rm -f /etc/cron.d/autobackup
    
    echo -e "\n${COLOR1}======================================${NC}"
    echo -e " Auto Backup Turned Off"
    echo -e "${COLOR1}======================================${NC}\n"
    
    service cron restart >/dev/null 2>&1
    service cron reload >/dev/null 2>&1
}

function jam2() {
    clear
    
    # Clean up old cron jobs
    rm -rf /etc/cron.d/{autobackup,bckp_otm,bckp_otm2,jam}
    
    # Display header
    echo -e ""
    echo -e "$COLOR1┌──────────────────────────────────────────┐${NC}"
    echo -e "$COLOR1  Silahkan Tulis Jamnya (contoh: 2 Jam tulis 2) ${NC}"
    echo -e "$COLOR1└──────────────────────────────────────────┘${NC}"
    echo -e ""
    
    # Get user input
    read -p "   Silahkan tulis jam auto backup nya: " jam2
    echo "$jam2" > /etc/jam2
    
    # Read the stored value
    jam2=$(cat /etc/jam2)
    
    # Create new cron job
    cat > /etc/cron.d/autobackup <<-EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
10 */${jam2} * * * root /usr/bin/bottelegram
EOF
    
    # Restart cron service
    service cron restart >/dev/null 2>&1
    service cron reload >/dev/null 2>&1
    
    # Display confirmation
    clear
    echo -e "${BIGreen}Auto Backup Tiap ${jam2} Jam ${NC}"
    echo -e ""
}

function jam() {
    clear
    
    # Clean up previous cron jobs and files
    rm -rf /etc/cron.d/{autobackup,bckp_otm,bckp_otm2,jam}
    
    # Display instructions
    echo -e "\n$COLOR1┌──────────────────────────────────────────┐${NC}"
    echo -e "$COLOR1  Contoh Format Jam: 4 = jam 4 pagi, 20 = jam 8 malam ${NC}"
    echo -e "$COLOR1└──────────────────────────────────────────┘${NC}\n"
    
    # Get user input
    read -p "   Silahkan tulis jam auto backup nya: " jam
    echo "$jam" > /etc/jam
    
    # Create new cron job
    cat > /etc/cron.d/bckp_otm <<-EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 ${jam} * * * root /usr/bin/bottelegram
EOF
    
    # Restart cron service
    service cron restart >/dev/null 2>&1
    service cron reload >/dev/null 2>&1
    
    # Display confirmation
    clear
    echo -e "${BIGreen}Auto Backup Tiap Jam ${jam}:00 WIB${NC}\n"
}

function autobckpbot() {
    clear
    
    # Main menu
    echo -e "\n$COLOR1┌──────────────────────────────────────────┐${NC}"
    echo -e "$COLOR1│        ${WH}Please select your choice        $COLOR1│${NC}"
    echo -e "$COLOR1└──────────────────────────────────────────┘${NC}"
    echo -e "$COLOR1┌──────────────────────────────────────────┐${NC}"
    echo -e "$COLOR1│           [ 1 ]  ${WH}OFF AUTO BACKUP         $COLOR1│${NC}"
    echo -e "$COLOR1│           [ 2 ]  ${WH}ON AUTO BACKUP          $COLOR1│${NC}"
    echo -e "$COLOR1└──────────────────────────────────────────┘${NC}"
    
    read -p "   Please select option 1-2 or any key to go back: " bot
    echo ""
    
    case $bot in
        1)
            # Turn OFF auto backup
            rm -rf /etc/cron.d/{bckp_otm,autobackup,jam}
            echo -e "Successfully turned OFF Auto Backup\n"
            read -n 1 -s -r -p "Press any key to return to menu"
            menu
            clear
            ;;
        2)
            # Submenu for ON options
            clear
            echo -e "\n$COLOR1┌──────────────────────────────────────────┐${NC}"
            echo -e "$COLOR1│        ${WH}Please select your choice        $COLOR1│${NC}"
            echo -e "$COLOR1└──────────────────────────────────────────┘${NC}"
            echo -e "$COLOR1┌──────────────────────────────────────────┐${NC}"
            echo -e "$COLOR1│           [ 1 ]  ${WH}AUTO BACKUP HOURLY     $COLOR1│${NC}"
            echo -e "$COLOR1│           [ 2 ]  ${WH}AUTO BACKUP DAILY      $COLOR1│${NC}"
            echo -e "$COLOR1└──────────────────────────────────────────┘${NC}"
            
            read -p "   Please select option 1-2 or any key to go back: " bott
            echo ""
            
            case $bott in
                1) jam2 ;;
                2) jam ;;
                *) menu ;;
            esac
            
            read -n 1 -s -r -p "Press any key to return to menu"
            menu
            clear
            ;;
        *) 
            menu
            ;;
    esac
}

function mbot() {
    cd
    
    # Check if token exists
    if [[ -e /usr/bin/token ]]; then
        bottelegram
    else
        clear
        echo -e "\n$COLOR1[ INFO ]${WH} Create Telegram Backup Database\n"
        
        # Get Telegram bot token
        read -rp "Enter Token (Create on @BotFather): " -e token2
        echo "$token2" > /usr/bin/token
        
        # Get user ID
        read -rp "Enter Your ID (Get from @userinfobot): " -e idchat
        echo "$idchat" > /usr/bin/idchat
        
        sleep 1
        bottelegram
    fi
}

echo -e "$COLOR1 ${NC}${COLBG1}             ${WH}• BACKUP PANEL MENU •             ${NC}$COLOR1 $NC"

echo -e " $COLOR1 $NC   ${WH}[${COLOR1}01${WH}]${NC} ${COLOR1}• ${WH}RESTORE VPS/TELE BOT          $COLOR1 $NC"
echo -e " $COLOR1 $NC                                               $COLOR1 $NC"
echo -e " $COLOR1 $NC   ${WH}[${COLOR1}02${WH}]${NC} ${COLOR1}• ${WH}BACKUP VPS                    $COLOR1 $NC"
echo -e " $COLOR1 $NC                                               $COLOR1 $NC"
echo -e " $COLOR1 $NC   ${WH}[${COLOR1}03${WH}]${NC} ${COLOR1}• ${WH}BACKUP VPS TELE BOT           $COLOR1 $NC"
echo -e " $COLOR1 $NC                                               $COLOR1 $NC"
echo -e " $COLOR1 $NC   ${WH}[${COLOR1}04${WH}]${NC} ${COLOR1}• ${WH}SET AUTO BACKUP TELE BOT      $COLOR1 $NC"
echo -e " $COLOR1 $NC                                               $COLOR1 $NC"
echo -e " $COLOR1 $NC   ${WH}[${COLOR1}00${WH}]${NC} ${COLOR1}• ${WH}GO BACK                       $COLOR1 $NC"
echo -e ""

read -p " ${WH}Select menu ${COLOR1}: ${WH}" opt
echo -e ""

case $opt in
    01 | 1) clear ; restore ;;
    02 | 2) clear ; backup ;;
    03 | 3) clear ; mbot ;;
    04 | 4) clear ; autobckpbot ;;
    00 | 0) clear ; menu ;;
    x) exit ;;
    *) echo -e "" ; echo "Press any key to back on menu" ; sleep 1 ; menu ;;
esac
