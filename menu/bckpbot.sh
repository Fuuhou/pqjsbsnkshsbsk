#!/usr/bin/env bash
# Telegram Bot Installer
# A clean, robust script to set up your bot with or without a database

set -euo pipefail
IFS=$'\n\t'

# Load color configuration
theme_name="$(< /etc/rmbl/theme/color.conf)"
theme_file="/etc/rmbl/theme/${theme_name}"

NOCOLOR='\e[0m'
RED='\e[0;31m'
GREEN='\e[0;32m'
BLUE='\e[0;34m'
WHITE='\e[1;37m'

COLOR_TEXT="$(grep -w 'TEXT'  "$theme_file" | cut -d: -f2 | tr -d '[:space:]')"
COLOR_BG="$(grep -w 'BG'    "$theme_file" | cut -d: -f2 | tr -d '[:space:]')"

clear

echo -e "${BLUE}┌──────────────────────────────────────────┐${NOCOLOR}"
echo -e "${BLUE}│      Please select a Bot type below     │${NOCOLOR}"
echo -e "${BLUE}└──────────────────────────────────────────┘${NOCOLOR}"
echo -e "${BLUE}┌──────────────────────────────────────────┐${NOCOLOR}"
echo -e "${BLUE}│ 1) Create Database BOT                  │${NOCOLOR}"
echo -e "${BLUE}│ 2) No Database BOT                      │${NOCOLOR}"
echo -e "${BLUE}└──────────────────────────────────────────┘${NOCOLOR}"
echo

read -rp "Select an option [1-2] or press any other key for random: " bot_choice
echo

case "$bot_choice" in
  1)
    clear
    rm -f /etc/chat/token2 /etc/chat/backup
    echo -e "[ ${GREEN}INFO${NOCOLOR} ] Creating database for bot"
    read -rp "Enter Bot Token (from @BotFather): " token2
    echo "$token2" > /etc/chat/token2

    read -rp "Enter Your Chat ID (from @userinfobot): " user_id
    echo "$user_id"  > /etc/chat/backup

    sleep 1
    bottelegram
    ;;
  2)
    bottelegram
    ;;
  *)
    bottelegram
    ;;
esac
