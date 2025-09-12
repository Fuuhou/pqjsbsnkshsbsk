#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
OS=$(uname -m)
MYIP=$(wget -qO- ipinfo.io/ip)
DOMAIN=$(cat /root/domain)
MYIP2="s/xxxxxxxxx/$DOMAIN/g"

# === Instalasi OpenVPN dan Ekstraksi Template ===
function ovpn_install() {
  rm -rf /etc/openvpn
  mkdir -p /etc/openvpn
  wget -qO /etc/openvpn/vpn.zip "https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/install/vpn.zip"
  unzip -q -d /etc/openvpn/ /etc/openvpn/vpn.zip
  rm -f /etc/openvpn/vpn.zip
  chown -R root:root /etc/openvpn/server/easy-rsa/
}

# === Konfigurasi Plugin dan Aktivasi Service ===
function config_easy() {
  mkdir -p /usr/lib/openvpn/
  cp /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so /usr/lib/openvpn/openvpn-plugin-auth-pam.so
  sed -i 's/#AUTOSTART="all"/AUTOSTART="all"/g' /etc/default/openvpn
  systemctl enable --now openvpn-server@server-tcp
  systemctl enable --now openvpn-server@server-udp
  /etc/init.d/openvpn restart
}

# === Pembuatan Config File untuk Klien ===
function make_follow() {
  echo 1 > /proc/sys/net/ipv4/ip_forward
  sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

  declare -A OVPN_PROFILES=(
    [tcp]=1194
    [udp]=2200
    [ws-ssl]=443
    [ssl]=443
  )

  for profile in "${!OVPN_PROFILES[@]}"; do
    cat > "/etc/openvpn/${profile}.ovpn" << EOF
client
dev tun
proto ${profile/ssl/tcp}
remote xxxxxxxxx ${OVPN_PROFILES[$profile]}
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
EOF
    sed -i "$MYIP2" "/etc/openvpn/${profile}.ovpn"
  done
}

# === Menambahkan Sertifikat dan Menyiapkan Unduhan ===
function cert_ovpn() {
  for profile in tcp udp ws-ssl ssl; do
    echo '<ca>' >> "/etc/openvpn/${profile}.ovpn"
    cat /etc/openvpn/server/ca.crt >> "/etc/openvpn/${profile}.ovpn"
    echo '</ca>' >> "/etc/openvpn/${profile}.ovpn"
    cp "/etc/openvpn/${profile}.ovpn" "/var/www/html/${profile}.ovpn"
  done

  cd /var/www/html/
  zip -q XieStore.zip tcp.ovpn udp.ovpn ssl.ovpn ws-ssl.ovpn
  cd ~

  # Generate halaman HTML unduhan
  cat << 'HTML' > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>OVPN Config Download</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta name="theme-color" content="#000000" />
  <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.8.2/css/all.css">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.3.1/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
  <div class="container" style="margin-top:8em;">
    <h3 class="text-center">Download Config OpenVPN</h3>
    <ul class="list-group mt-4">
      <li class="list-group-item">
        TCP <a class="btn btn-sm btn-success float-right" href="https://IP-ADDRESSS:81/tcp.ovpn"><i class="fa fa-download"></i> Download</a>
      </li>
      <li class="list-group-item">
        UDP <a class="btn btn-sm btn-success float-right" href="https://IP-ADDRESSS:81/udp.ovpn"><i class="fa fa-download"></i> Download</a>
      </li>
      <li class="list-group-item">
        SSL <a class="btn btn-sm btn-success float-right" href="https://IP-ADDRESSS:81/ssl.ovpn"><i class="fa fa-download"></i> Download</a>
      </li>
      <li class="list-group-item">
        WS-SSL <a class="btn btn-sm btn-success float-right" href="https://IP-ADDRESSS:81/ws-ssl.ovpn"><i class="fa fa-download"></i> Download</a>
      </li>
      <li class="list-group-item">
        Semua <a class="btn btn-sm btn-primary float-right" href="https://IP-ADDRESSS:81/XieStore.zip"><i class="fa fa-download"></i> ZIP</a>
      </li>
    </ul>
  </div>
</body>
</html>
HTML

  sed -i "s|IP-ADDRESSS|$(curl -sS ifconfig.me)|g" /var/www/html/index.html
}

# === Proses Instalasi dan Finalisasi ===
function install_ovpn() {
  ovpn_install
  config_easy
  make_follow
  cert_ovpn
  systemctl enable openvpn
  systemctl start openvpn
  /etc/init.d/openvpn restart
}

install_ovpn
