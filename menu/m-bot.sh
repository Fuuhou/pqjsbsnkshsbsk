#!/bin/bash

# Load configuration
DOMAINZ=$(cat /etc/xray/domain)
grenbo="\e[92;1m"
NC='\e[0m'
WH='\033[1;37m'

function install-bot() {
    # Update system and install dependencies
    echo -e "${grenbo}[*] Updating system packages...${NC}"
    apt update -y && apt upgrade -y
    apt install -y python3 python3-pip git speedtest-cli p7zip-full
    
    # Install bot files
    echo -e "${grenbo}[*] Installing bot files...${NC}"
    cd /usr/bin
    wget -q https://raw.githubusercontent.com/wibuxie/autoscript/main/bot/bot.zip
    unzip -q bot.zip
    mv bot/* /usr/bin
    chmod +x /usr/bin/*
    rm -rf bot.zip
    
    # Install Python requirements
    echo -e "${grenbo}[*] Installing Python requirements...${NC}"
    wget -q https://raw.githubusercontent.com/wibuxie/autoscript/main/bot/kyt.zip
    unzip -q kyt.zip
    pip3 install -r kyt/requirements.txt
    
    # Prepare bot files
    echo -e "${grenbo}[*] Setting up bot environment...${NC}"
    cd /usr/bin/kyt/bot
    chmod +x *
    mv -f * /usr/bin
    rm -rf /usr/bin/kyt/bot /usr/bin/*.zip
    
    # Display installation header
    clear
    
    echo -e "$COLOR1 ${NC} ${COLBG1}                ${WH}• BOT PANEL •                  ${NC} $COLOR1 $NC"
    
    
    echo -e "${grenbo} Tutorial Create Bot and ID Telegram${NC}"
    echo -e "${grenbo} [*] Create Bot and Token Bot : @BotFather${NC}"
    echo -e "${grenbo} [*] Info ID Telegram : @MissRose_bot, command /info${NC}"
    
    
    # Clean temporary files
    rm -rf /usr/bin/ddsdswl.session /usr/bin/kyt/var.txt /usr/bin/kyt/database.db
    
    # Get user credentials
    echo -e ""
    read -p "[*] Input your Bot Token : " bottoken
    read -p "[*] Input Your ID Telegram : " admin
    
    # Create configuration files
    cat > /usr/bin/kyt/var.txt <<-EOF
BOT_TOKEN="$bottoken"
ADMIN="$admin"
DOMAINZ="$DOMAINZ"
EOF
    
    # Store credentials
    echo "$bottoken" > /etc/per/token
    echo "$admin" > /etc/per/id
    echo "$bottoken" > /etc/chat/token2
    echo "$admin" > /etc/chat/backup
    echo "$bottoken" > /etc/perlogin/token
    echo "$admin" > /etc/perlogin/id
    
    
    # Membuat service systemd untuk XieTunnel Bot
    cat << 'EOF' > /etc/systemd/system/kyt.service
[Unit]
Description=XieTunnel Bot
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=/usr/bin
ExecStart=/usr/bin/python3 -m kyt
Restart=on-failure
RestartSec=5
User=root
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF
    
    # Enable and start service
    echo -e "${grenbo}[*] Starting bot service...${NC}"
    systemctl daemon-reload &> /dev/null
    systemctl enable kyt &> /dev/null
    systemctl start kyt &> /dev/null
    systemctl restart kyt &> /dev/null
    
    echo -e "${grenbo}[+] Bot installation completed!${NC}"
}


function restart-bot() {
    echo -e "${grenbo}[*] Restarting XieTunnel Bot...${NC}"
    systemctl restart kyt &> /dev/null

    if systemctl is-active --quiet kyt; then
        echo -e "${grenbo}[+] Bot restarted!${NC}"
    else
        echo -e "${redbo}[-] Failed to restart the bot. Please check the service status.${NC}"
    fi
}



# Cek apakah file /usr/bin/kyt ada
if [ ! -f /usr/bin/kyt ]; then
    install-bot
fi


clear

echo -e "[01] GANTI BOT"
echo -e "[02] UPDATE BOT"
echo -e "[03] DELETE BOT"
echo -e "[04] GANTI NAMA BOT (MULTI SERVER)"
echo -e "[05] TAMBAH ADMIN"
echo -e "[06] RESTART BOT"

until [[ $pilihbot =~ ^[1-5]$ ]]; do 
    read -p "   Please select number [1-5]: " pilihbot
done

if [[ $pilihbot == "1" ]]; then
    clear

    echo -e "${grenbo}Tutorial Create Bot dan ID Telegram${NC}"
    echo -e "${grenbo}[*] Create Bot dan Token Bot : @BotFather${NC}"
    echo -e "${grenbo}[*] Info ID Telegram : @MissRose_bot , perintah /info${NC}"
    echo

    # Hapus file lama
    rm -rf /usr/bin/ddsdswl.session /usr/bin/kyt/var.txt /usr/bin/kyt/database.db

    # Input token dan admin
    read -e -p "[*] Input your Bot Token       : " bottoken
    read -e -p "[*] Input your Telegram ID     : " admin

    # Simpan konfigurasi
    cat >/usr/bin/kyt/var.txt <<EOF
BOT_TOKEN="$bottoken"
ADMIN="$admin"
DOMAIN="$DOMAINZ"
EOF

    echo "$bottoken" > /etc/per/token
    echo "$admin" > /etc/per/id

    # Membuat service systemd untuk XieTunnel Bot
    cat << 'EOF' > /etc/systemd/system/kyt.service
[Unit]
Description=XieTunnel Bot
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=/usr/bin
ExecStart=/usr/bin/python3 -m kyt
Restart=on-failure
RestartSec=5
User=root
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF

    # Reload dan jalankan service
    systemctl daemon-reload &> /dev/null
    systemctl enable --now kyt &> /dev/null
    systemctl restart kyt &> /dev/null

    echo -e "\nDone"
    echo -e "Installation complete. Type /menu on your bot."
    read -n 1 -s -r -p "Press any key to return to menu..."
    menu
fi

if [[ $pilihbot == "2" ]]; then
    clear
    cp -r /usr/bin/kyt/var.txt /usr/bin &> /dev/null

    # Hapus versi lama
    rm -rf /usr/bin/kyt.zip /usr/bin/kyt

    cd /usr/bin
    wget -q https://raw.githubusercontent.com/wibuxie/autoscript/main/bot/bot.zip
    unzip -qq bot.zip
    mv bot/* /usr/bin
    chmod +x /usr/bin/*
    rm -rf bot.zip

    wget -q https://raw.githubusercontent.com/wibuxie/autoscript/main/bot/kyt.zip
    unzip -qq kyt.zip
    cd kyt
    pip3 install -r kyt/requirements.txt
    cd /usr/bin/kyt/bot
    chmod +x *
    mv -f * /usr/bin

    # Bersih-bersih
    rm -rf /usr/bin/kyt/bot /usr/bin/*.zip
    mv /usr/bin/var.txt /usr/bin/kyt

    # Restart service
    systemctl daemon-reload &> /dev/null
    systemctl enable --now kyt &> /dev/null
    systemctl restart kyt &> /dev/null

    echo -e "\nSuccess Update BOT Telegram"
    read -n 1 -s -r -p "Press any key to return to menu..."
    menu
fi

if [[ $pilihbot == "3" ]]; then
    clear

    # Hapus file utama bot
    rm -rf /usr/bin/kyt

    # Hapus service systemd jika ada
    systemctl stop kyt.service &>/dev/null
    systemctl disable kyt.service &>/dev/null
    rm -f /etc/systemd/system/kyt.service

    # Reload systemd daemon agar perubahan diterapkan
    systemctl daemon-reload

    echo -e "\e[32m✅ BOT Telegram berhasil dihapus.\e[0m"
    read -n 1 -s -r -p "Tekan tombol apa saja untuk kembali ke menu..."
    menu
fi

if [[ $pilihbot == "4" ]]; then
    clear

    echo -e "${grenbo}Fitur ini digunakan untuk mengganti nama panggilan BOT.${NC}"
    echo -e "${grenbo}Berguna jika Anda ingin memakai satu BOT untuk banyak server.${NC}"
    echo

    read -e -p "[*] Input Nama Panggilan Botnya : " namabot

    # Target file yang dimodifikasi
    files_menu="/usr/bin/kyt/modules/menu.py"
    files_start="/usr/bin/kyt/modules/start.py"
    files_admin="/usr/bin/kyt/modules/admin.py"
    files_vmess="/usr/bin/kyt/modules/vmess.py"
    files_vless="/usr/bin/kyt/modules/vless.py"
    files_trojan="/usr/bin/kyt/modules/trojan.py"
    files_ssh="/usr/bin/kyt/modules/ssh.py"

    # Ganti identifier di berbagai file
    sed -i "s/77/${namabot}/g" "$files_menu" "$files_start"
    sed -i "s/sshovpn/sshovpn${namabot}/g" "$files_menu"
    sed -i "s/vmess/vmess${namabot}/g" "$files_menu"
    sed -i "s/vless/vless${namabot}/g" "$files_menu"
    sed -i "s/trojan/trojan${namabot}/g" "$files_menu"

    sed -i "s&.menu|/menu&.${namabot}|/${namabot}&g" "$files_menu"
    sed -i "s&.start|/start&.start${namabot}|/start${namabot}&g" "$files_start"
    sed -i "s&.admin|/admin&.admin${namabot}|/admin${namabot}&g" "$files_admin"

    sed -i "s/b'start'/b'start${namabot}'/g" "$files_start"
    sed -i "s/b'admin'/b'admin${namabot}'/g" "$files_admin"
    sed -i "s/b'menu'/b'${namabot}'/g" "$files_menu" "$files_start"

    for file in "$files_vmess" "$files_vless" "$files_trojan" "$files_ssh"; do
        sed -i "s/7-/${namabot}-/g" "$file"
        sed -i "s/b'$(basename "$file" .py)'/b'$(basename "$file" .py)${namabot}'/g" "$file"
        sed -i "s/\"menu\"/\"${namabot}\"/g" "$file"
    done

    clear
    echo -e "✅ Berhasil mengganti nama panggilan BOT Telegram."
    echo -e "📌 Gunakan perintah .${namabot} atau /${namabot} untuk memanggil menu."
    echo -e "📌 Gunakan perintah .start${namabot} atau /start${namabot} untuk start."
    
    systemctl restart kyt
    read -n 1 -s -r -p "Press any key to return to menu..."
    menu
fi

if [[ $pilihbot == "5" ]]; then
    clear

    read -e -p "[*] Input ID Telegram User Admin : " user
    userke=$(wc -l < /usr/bin/kyt/var.txt)

    # Tambahkan ke database (menggunakan placeholder `hello`)
    sed -i "/(ADMIN,))/a hello	c.execute(\"INSERT INTO admin (user_id) VALUES (?)\",(USER${userke},))" /usr/bin/kyt/__init__.py

    # Simpan ke file konfigurasi
    echo "USER${userke}=\"$user\"" >> /usr/bin/kyt/var.txt

    # Hapus placeholder
    sed -i "s/hello//g" /usr/bin/kyt/__init__.py

    clear
    echo -e "✅ Admin BOT Telegram berhasil ditambahkan."

    # Bersih-bersih session dan DB lama
    rm -rf /usr/bin/ddsdswl.session /usr/bin/kyt/database.db

    systemctl restart kyt
    read -n 1 -s -r -p "Press any key to return to menu..."
    menu
fi

if [[ $pilihbot == "6" ]]; then

    restart-bot
    
    read -n 1 -s -r -p "Press any key to return to menu..."
    menu
fi
