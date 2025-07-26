#!/bin/bash

setup_dnstt() {
	cd
	mkdir -p /etc/slowdns
	wget -O dnstt-server "https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/slowdns/dnstt-server" >/dev/null 2>&1
	chmod +x dnstt-server >/dev/null 2>&1
	wget -O dnstt-client "https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/slowdns/dnstt-client" >/dev/null 2>&1
	chmod +x dnstt-client >/dev/null 2>&1
	./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
	chmod +x *
	mv * /etc/slowdns
	wget -O /etc/systemd/system/client.service "https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/slowdns/client" >/dev/null 2>&1
	wget -O /etc/systemd/system/server.service "https://raw.githubusercontent.com/Fuuhou/pqjsbsnkshsbsk/main/slowdns/server" >/dev/null 2>&1
	sed -i "s/xxxx/$NS_DOMAIN/g" /etc/systemd/system/client.service 
	sed -i "s/xxxx/$NS_DOMAIN/g" /etc/systemd/system/server.service 
}
setup_dnstt
systemctl restart client
systemctl restart server
exit
