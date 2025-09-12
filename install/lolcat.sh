#!/bin/bash
set -euo pipefail

clear

# 🛠️ Instal Ruby dan Figlet
apt-get update
apt-get install -y ruby figlet

# 🎨 Instalasi lolcat
cd /tmp
wget -q https://github.com/busyloop/lolcat/archive/master.zip -O lolcat.zip
unzip -q lolcat.zip
rm -f lolcat.zip
cd lolcat-master/bin
gem install lolcat

# 📁 Clone figlet fonts dan pindahkan ke direktori figlet
cd /usr/share
git clone https://github.com/xero/figlet-fonts
mkdir -p figlet
mv figlet-fonts/* figlet/
rm -rf figlet-fonts

# 🧹 Bersihkan file skrip yang tidak diperlukan
rm -f ~/lolcat.sh

# ✅ Info sukses
echo -e "\n✅ Instalasi figlet, lolcat, dan font tambahan berhasil!"
