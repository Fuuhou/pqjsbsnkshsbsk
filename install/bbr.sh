#!/bin/bash

# Ultimate TCP BBRv3 Optimization Script
# Author: WixieTunnel (Enhanced)
# Verified on Kernel 5.10+

# Helper function
add_line() {
  grep -qxF "$2" "$1" || echo "$2" | tee -a "$1" >/dev/null
}

install_bbr() {
  echo "=== Installing BBR ==="
  
  if ! lsmod | grep -q bbr; then
    modprobe tcp_bbr || { echo "Gagal load modul BBR"; exit 1; }
    add_line "/etc/modules-load.d/bbr.conf" "tcp_bbr"
  fi

  # Kernel 5.17+ parameters
  add_line "/etc/sysctl.d/99-bbr.conf" "net.core.default_qdisc = fq_codel"
  add_line "/etc/sysctl.d/99-bbr.conf" "net.ipv4.tcp_congestion_control = bbr"
  add_line "/etc/sysctl.d/99-bbr.conf" "net.ipv4.tcp_notsent_lowat = 16384"
  
  sysctl -p /etc/sysctl.d/99-bbr.conf || echo "Error applying sysctl!"
}

tune_system() {
  echo "=== System Tuning ==="
  
  # Kernel limits
  cat > /etc/security/limits.d/99-tun.conf <<EOF
* soft nofile 1048576
* hard nofile 1048576
root soft nofile 1048576
root hard nofile 1048576
EOF

  # Advanced network tuning
  cat > /etc/sysctl.d/99-net.conf <<EOF
# Core
fs.file-max = 2097152
net.core.rmem_max = 2147483647
net.core.wmem_max = 2147483647
net.core.netdev_max_backlog = 100000
net.core.somaxconn = 32768

# IPv4
net.ipv4.tcp_fastopen = 511
net.ipv4.tcp_mtu_probing = 2
net.ipv4.tcp_rfc1337 = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_dsack = 1
net.ipv4.tcp_frto = 2

# Memory
net.ipv4.tcp_mem = 786432 1048576 1572864
net.ipv4.tcp_rmem = 4096 1048576 2147483647
net.ipv4.tcp_wmem = 4096 1048576 2147483647

# Timeouts
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_fin_timeout = 15

# Advanced
net.ipv4.tcp_early_retrans = 3
net.ipv4.tcp_slow_start_after_idle = 0
net.core.busy_poll = 50
net.core.busy_read = 50
EOF

  sysctl -p /etc/sysctl.d/99-net.conf
}

# Main
install_bbr
tune_system
rm -f /root/bbr.sh
# Optional: Reboot suggestion
echo "Untuk hasil terbaik, disarankan reboot sistem."
