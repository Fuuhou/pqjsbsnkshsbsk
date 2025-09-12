#!/bin/bash

# Define the repository URL
repo="https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/"

# System upgrade and package installation
apt dist-upgrade -y
apt install -y netfilter-persistent screen curl jq bzip2 gzip vnstat coreutils rsyslog iftop zip unzip git apt-transport-https build-essential

# Remove unnecessary packages
apt-get remove --purge ufw firewalld exim4 -y

# Initialize variables
export DEBIAN_FRONTEND=noninteractive
MYIP=$(wget -qO- ipinfo.io/ip)
MYIP2="s/xxxxxxxxx/$MYIP/g"
NET=$(ip -o -4 route show to default | awk '{print $5}')
source /etc/os-release
ver=$VERSION_ID

# Company details (for SSL certificates, if needed)
country=ID
state=Indonesia
locality=Jakarta
organization=none
organizationalunit=none
commonname=none
email=none

# Set a simple password policy
curl -sS ${repo}install/password | openssl aes-256-cbc -d -a -pass pass:scvps07gg -pbkdf2 > /etc/pam.d/common-password
chmod +x /etc/pam.d/common-password

# Configure rc.local service
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

# Create /etc/rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
exit 0
END

# Set executable permissions for rc.local
chmod +x /etc/rc.local

# Enable and start rc-local service
systemctl enable rc-local
systemctl start rc-local.service

# Disable IPv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# System update
apt update -y
apt upgrade -y
apt dist-upgrade -y

# Install additional tools
apt -y install jq shc wget curl figlet ruby
gem install lolcat

# Set timezone to GMT+7 (Asia/Jakarta)
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# Adjust SSH configuration
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config

# Install essential utilities
apt-get --reinstall --fix-missing install -y bzip2 gzip coreutils wget screen rsyslog iftop htop net-tools zip unzip curl nano sed screen gnupg gnupg1 bc apt-transport-https build-essential dirmngr libxml-parser-perl neofetch git lsof

# Add 'clear' and 'menu' to .profile
echo "clear" >> .profile
echo "menu" >> .profile

install_ssl() {
    # Install necessary packages
    if command -v apt-get &> /dev/null; then
        apt-get install -y nginx certbot || apt install -y nginx certbot
    else
        yum install -y nginx certbot
    fi

    sleep 3s

    # Stop nginx service
    systemctl stop nginx.service

    # Obtain SSL certificate
    if command -v apt-get &> /dev/null; then
        echo "A" | certbot certonly --renew-by-default --register-unsafely-without-email --standalone -d ${domain}
    else
        echo "Y" | certbot certonly --renew-by-default --register-unsafely-without-email --standalone -d ${domain}
    fi

    sleep 3s
}

# Install web server and PHP
apt -y install nginx php php-fpm php-cli php-mysql libxml-parser-perl

# Remove default Nginx site configuration and set new configuration
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default

curl -s https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/install/nginx.conf -o /etc/nginx/nginx.conf
curl -s https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/install/vps.conf -o /etc/nginx/conf.d/vps.conf

# Update PHP-FPM socket configuration
sed -i 's/listen = \/var\/run\/php-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php/fpm/pool.d/www.conf

# Create new user and set up public_html directory
useradd -m vps
mkdir -p /home/vps/public_html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
chown -R www-data:www-data /home/vps/public_html
chmod -R g+rw /home/vps/public_html

# Download initial index.html for the user
cd /home/vps/public_html
wget -O index.html "${repo}install/index.html1"

# Restart Nginx service
systemctl restart nginx

# Install BadVPN
cd
wget -qO /usr/sbin/badvpn "${repo}install/badvpn"
chmod +x /usr/sbin/badvpn

# Download BadVPN service files
for i in {1..3}; do
    wget -q -O /etc/systemd/system/badvpn${i}.service "${repo}install/badvpn${i}.service"
    
    # Enable and start BadVPN services
    systemctl disable badvpn${i}
    systemctl stop badvpn${i}
    systemctl enable badvpn${i}
    systemctl start badvpn${i}
done

# Update SSH configuration to add ports and enable PasswordAuthentication
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
for port in 500 40000 51443 58080 200 22; do
    sed -i "/Port 22/a Port $port" /etc/ssh/sshd_config
done

# Function to install Dropbear
install_dropbear() {
    echo "=== Install Dropbear ==="
    apt -y install dropbear
    
    # Configure Dropbear
    sed -i 's/NO_START=1/NO_START=0/' /etc/default/dropbear
    sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=143/' /etc/default/dropbear
    sed -i 's|^DROPBEAR_EXTRA_ARGS=.*|DROPBEAR_EXTRA_ARGS="-p 50000 -p 109 -p 110 -p 69"|' /etc/default/dropbear
    
    # Update shell configurations
    echo "/bin/false" >> /etc/shells
    echo "/usr/sbin/nologin" >> /etc/shells
    
    # Restart services
    systemctl restart ssh
    systemctl restart dropbear
}

# Function to install Squid
install_squid() {
    echo "=== Install Squid ==="
    apt -y install squid squid3
    
    # Configure Squid
    wget -O /etc/squid/squid.conf "${repo}install/squid3.conf"
    sed -i $MYIP2 /etc/squid/squid.conf
}

# Function to set up vnStat
setup_vnstat() {
    echo "=== Setting up vnStat ==="
    apt -y install vnstat libsqlite3-dev
    systemctl restart vnstat

    # Download and install vnStat
    wget -q https://github.com/Fuuhou/pqjsbsnkshsbsk/raw/refs/heads/main/vnstat-2.6.tar.gz
    tar zxvf vnstat-2.6.tar.gz
    cd vnstat-2.6
    ./configure --prefix=/usr --sysconfdir=/etc && make && make install
    cd ..
    
    # Initialize vnStat interface and configurations
    vnstat -u -i $NET
    sed -i 's/Interface "eth0"/Interface "'"$NET"'"/g' /etc/vnstat.conf
    chown -R vnstat:vnstat /var/lib/vnstat
    systemctl enable vnstat
    systemctl restart vnstat
    
    # Clean up
    rm -f vnstat-2.6.tar.gz
    rm -rf vnstat-2.6
}

# Function to install stunnel4
install_stunnel() {
    echo "=== Install stunnel ==="
    apt install -y stunnel4
    
    # Create stunnel configuration
    cat > /etc/stunnel/stunnel.conf <<-END
pid = /var/run/stunnel4/stunnel.pid
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear1]
accept = 8880
connect = 127.0.0.1:22

[dropbear2]
accept = 8443
connect = 127.0.0.1:109

[ws-stunnel]
accept = 444
connect = 700

[openvpn]
accept = 990
connect = 127.0.0.1:1194
END

    # Create SSL certificate
    openssl genrsa -out key.pem 2048
    openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
    -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
    
    cat key.pem cert.pem > /etc/stunnel/stunnel.pem
    
    # Enable stunnel
    sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/stunnel4
    systemctl restart stunnel4
}

# Function to install OpenVPN
install_openvpn() {
    echo "=== Install OpenVPN ==="
    wget -q ${repo}install/vpn.sh && chmod +x vpn.sh && ./vpn.sh
}

# Function to install lolcat
install_lolcat() {
    echo "=== Install lolcat ==="
    wget -q ${repo}install/lolcat.sh && chmod +x lolcat.sh && ./lolcat.sh
}

# Function to create a swap file
setup_swap() {
    echo "=== Setting up Memory Swap ==="
    cd
    dd if=/dev/zero of=/swapfile bs=1M count=1024
    mkswap /swapfile
    chmod 0600 /swapfile
    swapon /swapfile
    echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
}

# Function to install Fail2Ban
install_fail2ban() {
    echo "=== Installing Fail2Ban ==="
    apt -y install fail2ban
}

# Function to install DDOS Deflate
install_ddos_flare() {
    echo "=== Installing DDOS Deflate ==="
    
    if [ -d '/usr/local/ddos' ]; then
        echo "Please un-install the previous version first."
        exit 0
    fi

    mkdir /usr/local/ddos
    echo "Downloading source files..."
    
    wget -q -O /usr/local/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf
    wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE
    wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list
    wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh
    
    chmod 0755 /usr/local/ddos/ddos.sh
    cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
    
    echo "Creating cron job to run script every minute (Default setting)..."
    /usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
    
    echo "Installation completed."
    echo "Config file is at /usr/local/ddos/ddos.conf"
    echo "Please send your comments and suggestions to zaf@vsnl.com"
}

# Function to modify SSH and Dropbear configurations
configure_banners() {
    echo "=== Configuring Banners ==="
    
    echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
    sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/issue.net"@g' /etc/default/dropbear
    wget -O /etc/issue.net "${repo}install/issue.net"
}

# Function to block torrent traffic
block_torrents() {
    echo "=== Blocking Torrent Traffic ==="
    
    iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
    iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
    iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
    iptables -A FORWARD -m string --string "BitTorrent" -j DROP
    iptables -A FORWARD -m string --string "BitTorrent protocol" -j DROP
    iptables -A FORWARD -m string --string "peer_id=" -j DROP
    iptables -A FORWARD -m string --string ".torrent" -j DROP
    iptables -A FORWARD -m string --string "announce.php?passkey=" -j DROP
    iptables -A FORWARD -m string --string "torrent" -j DROP
    iptables -A FORWARD -m string --string "announce" -j DROP
    iptables -A FORWARD -m string --string "info_hash" -j DROP
    
    iptables-save > /etc/iptables.up.rules
    netfilter-persistent save
    netfilter-persistent reload
}

# Function to download scripts
download_scripts() {
    echo "=== Downloading Scripts ==="
    
    cd /usr/bin
    wget -O issue "${repo}install/issue.net"
    wget -O m-theme "${repo}menu/m-theme.sh"
    wget -O speedtest "${repo}install/speedtest_cli.py"

    chmod +x issue m-theme speedtest
    cd -
}


# Function to remove unnecessary files
cleanup_system() {
    echo "=== Cleaning Up ==="
    
    apt autoclean -y
    apt -y remove --purge unscd samba* apache2* bind9* sendmail*
    apt autoremove -y
    rm -f /root/key.pem /root/cert.pem /root/ssh-vpn.sh /root/bbr.sh
    rm -rf /etc/apache2
}

# Restart SSH service to apply changes
systemctl restart sshd
# Call the install_ssl function
install_ssl

# Execute the functions in order
install_dropbear
install_squid
setup_vnstat
install_stunnel
install_openvpn
install_lolcat
setup_swap

# Main execution flow
install_fail2ban
install_ddos_flare
configure_banners
block_torrents
download_scripts
setup_cron_jobs
cleanup_system

clear
