#!/bin/bash

colornow=$(cat /etc/rmbl/theme/color.conf)
NC="\e[0m"
WH='\033[1;37m'
COLOR1=$(grep -w "TEXT" /etc/rmbl/theme/$colornow | cut -d: -f2 | sed 's/ //g')
COLBG1=$(grep -w "BG" /etc/rmbl/theme/$colornow | cut -d: -f2 | sed 's/ //g')

declare -A color_map
color_map=(
  [1]="red"           [2]="green"         [3]="yellow"         [4]="blue"
  [5]="magenta"       [6]="cyan"          [7]="lightgray"      [8]="lightred"
  [9]="lightgreen"   [10]="lightyellow"  [11]="lightblue"     [12]="lightmagenta"
 [13]="lightcyan"    [14]="darkgray"
)

function apply_theme() {
  echo "$1" > /etc/rmbl/theme/color.conf
  echo -e "${WH}SUCCESS:${NC} Theme changed to $1"
  echo ""
  read -n 1 -s -r -p "  Press any key to return to menu..."
  menu
}

function preview_theme() {
  local newcolor=$1
  echo -e ""
  echo -e "\033[0mPreview: \033[1mTEXT SAMPLE\033[0m"
  echo -e "\033[38;5;$(get_color_code $newcolor)m███████████████ ${newcolor^^} ███████████████\033[0m"
  echo -e ""
  read -rp "Save this theme? [Y/N]: " confirm
  case "${confirm,,}" in
    y) apply_theme "$newcolor" ;;
    t|n) echo -e "${WH}Canceled.${NC}" ; sleep 1 ; menu ;;
    *) echo -e "Invalid input." ; sleep 1 ; menu ;;
  esac
}

function get_color_code() {
  case "$1" in
    red) echo 1 ;;
    green) echo 2 ;;
    yellow) echo 3 ;;
    blue) echo 4 ;;
    magenta) echo 5 ;;
    cyan) echo 6 ;;
    lightgray) echo 7 ;;
    darkgray) echo 8 ;;
    lightred) echo 9 ;;
    lightgreen) echo 10 ;;
    lightyellow) echo 11 ;;
    lightblue) echo 12 ;;
    lightmagenta) echo 13 ;;
    lightcyan) echo 14 ;;
    *) echo 7 ;; # default
  esac
}

clear
echo -e "${COLOR1}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${COLOR1}║${NC}${COLBG1}             ${WH}• THEMES PANEL MENU •              ${NC}${COLOR1}║${NC}"
echo -e "${COLOR1}╠════════════════════════════════════════════════════╣${NC}"
echo -e "${COLOR1}║${NC} ${WH}[01]${NC} COLOR RED          ${WH}[08]${NC} COLOR LIGHT RED      ${COLOR1}║${NC}"
echo -e "${COLOR1}║${NC} ${WH}[02]${NC} COLOR GREEN        ${WH}[09]${NC} COLOR LIGHT GREEN    ${COLOR1}║${NC}"
echo -e "${COLOR1}║${NC} ${WH}[03]${NC} COLOR YELLOW       ${WH}[10]${NC} COLOR LIGHT YELLOW   ${COLOR1}║${NC}"
echo -e "${COLOR1}║${NC} ${WH}[04]${NC} COLOR BLUE         ${WH}[11]${NC} COLOR LIGHT BLUE     ${COLOR1}║${NC}"
echo -e "${COLOR1}║${NC} ${WH}[05]${NC} COLOR MAGENTA      ${WH}[12]${NC} COLOR LIGHT MAGENTA  ${COLOR1}║${NC}"
echo -e "${COLOR1}║${NC} ${WH}[06]${NC} COLOR CYAN         ${WH}[13]${NC} COLOR LIGHT CYAN     ${COLOR1}║${NC}"
echo -e "${COLOR1}║${NC} ${WH}[07]${NC} COLOR LIGHT GRAY   ${WH}[14]${NC} COLOR DARKGRAY       ${COLOR1}║${NC}"
echo -e "${COLOR1}║${NC} ${WH}[00]${NC} BACK TO MENU                                ${COLOR1}║${NC}"
echo -e "${COLOR1}╚════════════════════════════════════════════════════╝${NC}"
echo -ne " ${WH}Select menu ${COLOR1}: ${WH}"; read input

if [[ "$input" == "0" || "$input" == "00" ]]; then
  clear
  menu
elif [[ -n "${color_map[$input]}" ]]; then
  preview_theme "${color_map[$input]}"
else
  echo -e "${RED}Invalid option!${NC}"
  sleep 1
  m-theme
fi
