#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipinfo.io/ip);
domain=$(cat /root/domain)
#MYIP2="s/xxxxxxxxx/$MYIP/g";
MYIP2="s/xxxxxxxxx/$domain/g";

function ovpn_install() {
    rm -rf /etc/openvpn
    mkdir -p /etc/openvpn
    wget -O /etc/openvpn/vpn.zip "https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/install/vpn.zip" >/dev/null 2>&1 
    unzip -d /etc/openvpn/ /etc/openvpn/vpn.zip
    rm -f /etc/openvpn/vpn.zip
    chown -R root:root /etc/openvpn/server/easy-rsa/
}
function config_easy() {
    cd
    mkdir -p /usr/lib/openvpn/
    cp /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so /usr/lib/openvpn/openvpn-plugin-auth-pam.so
    sed -i 's/#AUTOSTART="all"/AUTOSTART="all"/g' /etc/default/openvpn
    systemctl enable --now openvpn-server@server-tcp
    systemctl enable --now openvpn-server@server-udp
    /etc/init.d/openvpn restart
}

function make_follow() {
    echo 1 > /proc/sys/net/ipv4/ip_forward
    sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
cat > /etc/openvpn/tcp.ovpn <<-END
client
dev tun
proto tcp
remote xxxxxxxxx 1194
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END
    
    sed -i $MYIP2 /etc/openvpn/tcp.ovpn;
cat > /etc/openvpn/udp.ovpn <<-END
client
dev tun
proto udp
remote xxxxxxxxx 2200
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END
    
    sed -i $MYIP2 /etc/openvpn/udp.ovpn;
cat > /etc/openvpn/ws-ssl.ovpn <<-END
client
dev tun
proto tcp
remote xxxxxxxxx 443
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END
    sed -i $MYIP2 /etc/openvpn/ws-ssl.ovpn;
cat > /etc/openvpn/ssl.ovpn <<-END
client
dev tun
proto tcp
remote xxxxxxxxx 443
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END
    sed -i $MYIP2 /etc/openvpn/ssl.ovpn;
}
function cert_ovpn() {
    echo '<ca>' >> /etc/openvpn/tcp.ovpn
    cat /etc/openvpn/server/ca.crt >> /etc/openvpn/tcp.ovpn
    echo '</ca>' >> /etc/openvpn/tcp.ovpn
    cp /etc/openvpn/tcp.ovpn /var/www/html/tcp.ovpn
    echo '<ca>' >> /etc/openvpn/udp.ovpn
    cat /etc/openvpn/server/ca.crt >> /etc/openvpn/udp.ovpn
    echo '</ca>' >> /etc/openvpn/udp.ovpn
    cp /etc/openvpn/udp.ovpn /var/www/html/udp.ovpn
    echo '<ca>' >> /etc/openvpn/ws-ssl.ovpn
    cat /etc/openvpn/server/ca.crt >> /etc/openvpn/ws-ssl.ovpn
    echo '</ca>' >> /etc/openvpn/ws-ssl.ovpn
    cp /etc/openvpn/ws-ssl.ovpn /var/www/html/ws-ssl.ovpn
    echo '</ca>' >> /etc/openvpn/ssl.ovpn
    cp /etc/openvpn/ws-ssl.ovpn /var/www/html/ssl.ovpn

cd /var/www/html/
zip WixieTunnel-Project.zip tcp.ovpn udp.ovpn ssl.ovpn ws-ssl.ovpn > /dev/null 2>&1
cd

cat <<'mySiteOvpn' > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <title>OVPN Config Download</title>
    <meta name="description" content="Secure VPN Configurations">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <meta name="theme-color" content="#222222">
    
    <!-- External CSS & Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/css/bootstrap.min.css">
    
    <style>
        /* Dark Mode Theme */
        body {
            background-color: #181818;
            color: #fff;
            font-family: Arial, sans-serif;
        }
        
        .container {
            margin-top: 4em;
            margin-bottom: 4em;
        }

        .card {
            background-color: #222;
            border-radius: 10px;
            box-shadow: 0px 4px 10px rgba(255, 255, 255, 0.1);
            transition: transform 0.3s;
        }

        .card:hover {
            transform: scale(1.03);
        }

        .card-title {
            font-size: 1.4em;
            text-transform: uppercase;
            text-align: center;
            font-weight: bold;
            color: #00ffcc;
        }

        .list-group-item {
            background-color: #333;
            border: none;
            margin-bottom: 10px;
            color: #fff;
            transition: background 0.3s;
        }

        .list-group-item:hover {
            background-color: #444;
        }

        .btn-download {
            float: right;
            font-weight: bold;
            border-radius: 5px;
            transition: all 0.3s;
        }

        .btn-download:hover {
            background-color: #00ffcc !important;
            color: #000 !important;
            transform: scale(1.1);
        }
        
        .badge {
            background-color: #00ffcc;
            color: #000;
            font-weight: bold;
        }

        .footer {
            text-align: center;
            margin-top: 20px;
            font-size: 14px;
            color: #aaa;
        }

        .footer a {
            color: #00ffcc;
            text-decoration: none;
        }

        .footer a:hover {
            text-decoration: underline;
        }
    </style>
</head>

<body>

    <div class="container">
        <div class="col-md">
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title"><i class="fas fa-download"></i> OVPN Configurations</h5>
                    <ul class="list-group">
                    
                        <li class="list-group-item">
                            <p>TCP <span class="badge">Android / iOS / PC / Modem</span></p>
                            <a class="btn btn-outline-success btn-sm btn-download" href="https://YOUR_SERVER_IP:81/tcp.ovpn">
                                <i class="fa fa-download"></i> Download
                            </a>
                        </li>

                        <li class="list-group-item">
                            <p>UDP <span class="badge">Android / iOS / PC / Modem</span></p>
                            <a class="btn btn-outline-success btn-sm btn-download" href="https://YOUR_SERVER_IP:81/udp.ovpn">
                                <i class="fa fa-download"></i> Download
                            </a>
                        </li>

                        <li class="list-group-item">
                            <p>SSL <span class="badge">Android / iOS / PC / Modem</span></p>
                            <a class="btn btn-outline-success btn-sm btn-download" href="https://YOUR_SERVER_IP:81/ssl.ovpn">
                                <i class="fa fa-download"></i> Download
                            </a>
                        </li>

                        <li class="list-group-item">
                            <p>WebSocket SSL <span class="badge">Android / iOS / PC / Modem</span></p>
                            <a class="btn btn-outline-success btn-sm btn-download" href="https://YOUR_SERVER_IP:81/ws-ssl.ovpn">
                                <i class="fa fa-download"></i> Download
                            </a>
                        </li>

                        <li class="list-group-item">
                            <p>All Configs (ZIP) <span class="badge">Android / iOS / PC / Modem</span></p>
                            <a class="btn btn-outline-success btn-sm btn-download" href="https://YOUR_SERVER_IP:81/WixieTunnel-Project.zip">
                                <i class="fa fa-download"></i> Download
                            </a>
                        </li>

                    </ul>
                </div>
            </div>
        </div>

        <div class="footer">
            <p>Powered by <a href="https://t.me/xiestorez" target="_blank">WixieTunnel</a> | Secure & Fast VPN Service</p>
        </div>
    </div>

</body>

</html>
mySiteOvpn

sed -i "s|YOUR_SERVER_IP|$(curl -sS ifconfig.me)|g" /var/www/html/index.html
}

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
