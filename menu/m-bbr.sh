#!/usr/bin/env bash
set -euo pipefail

# 🌐 Network Optimizer with Auto-Speed Detection
# 🚀 Versi: 3.0.0 | License: MIT

# === 🎨 TAMPILAN ===
BOLD="\033[1m"
CYAN="\033[1;36m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

show_header() {
    clear
    echo -e "${CYAN}"
    echo "=============================================="
    echo " 🚀  TCP BBR + BUFFER OPTIMIZER PRO  "
    echo "=============================================="
    echo -e "${RESET}"
    echo -e "${YELLOW}💡 Optimasi jaringan berbasis bandwidth aktual${RESET}"
    echo -e "${YELLOW}   Support: Kernel Linux 5.4+ | Speedtest-cli${RESET}\n"
}

# === 🛠️ UTILITAS ===
fail() {
    echo -e "${RED}❌ $1${RESET}" >&2
    exit 1
}

ensure_command() {
    command -v "$1" >/dev/null 2>&1 || {
        echo -e "${YELLOW}⚠️  $1 tidak terdeteksi, mencoba menginstal...${RESET}"
        if [[ -f /etc/debian_version ]]; then
            apt-get update && apt-get install -y "$2"
        elif [[ -f /etc/redhat-release ]]; then
            yum install -y "$2"
        else
            fail "Instalasi manual diperlukan untuk $1"
        fi
    }
}

read_bandwidth() {
    while true; do
        read -rp "📶 Masukkan bandwidth (Mbps): " bw
        if [[ "$bw" =~ ^[0-9]+$ ]] && (( bw >= 1 && bw <= 10000 )); then
            echo "$bw"
            return
        fi
        echo -e "${YELLOW}⚠️  Masukkan angka 1-10000${RESET}"
    done
}

# === 📶 SPEEDTEST AUTO-DETECT ===
run_speedtest() {
    ensure_command "speedtest-cli" "speedtest-cli"
    
    echo -e "\n${CYAN}🔄 Mengukur kecepatan internet...${RESET}"
    echo -e "${YELLOW}⏳ Ini mungkin memakan waktu 15-30 detik...${RESET}"
    
    local result
    if ! result=$(speedtest-cli --secure --simple 2>/dev/null); then
        fail "Gagal menjalankan speedtest"
    fi

    local down_mbps=$(echo "$result" | awk '/Download/ {print int($2)}')
    local up_mbps=$(echo "$result" | awk '/Upload/ {print int($2)}')
    
    (( down_mbps > 0 )) || fail "Kecepatan tidak valid terdeteksi"
    
    echo -e "\n${GREEN}📊 Hasil Speedtest:${RESET}"
    echo -e "📥 ${BOLD}${down_mbps} Mbps${RESET} (Download)"
    echo -e "📤 ${BOLD}${up_mbps} Mbps${RESET} (Upload)"
    
    echo "$down_mbps"
}

# === 📊 BUFFER CALCULATION ===
calculate_buffers() {
    local mbps="$1"
    local factor=$(( 125 * 1024 / 10 ))  # 12.5KB in bytes
    
    # Dynamic scaling with min/max clamping
    local rmem=$(( mbps * factor * 3 / 2 ))  # 1.5x for receive
    local wmem=$(( mbps * factor ))
    
    # Clamp values (4MB min, 16MB max)
    (( rmem < 4194304 )) && rmem=4194304
    (( wmem < 4194304 )) && wmem=4194304
    (( rmem > 16777216 )) && rmem=16777216
    (( wmem > 16777216 )) && wmem=16777216
    
    echo "4096 87380 $rmem 4096 65536 $wmem"
}

# === 🖥️ KONFIGURASI SISTEM ===
configure_system() {
    local bw="$1"
    local buffers=($(calculate_buffers "$bw"))
    
    echo -e "\n${CYAN}🔧 Menerapkan konfigurasi untuk ${bw}Mbps...${RESET}"
    
    # BBR Configuration
    cat > /etc/sysctl.d/99-bbr.conf <<EOF
# 🚀 Auto-configured for ${bw}Mbps
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_notsent_lowat = $(( bw * 1024 ))  # Dinamis berdasarkan bandwidth
EOF

    # TCP Buffer Configuration
    cat > /etc/sysctl.d/99-tcp-buf.conf <<EOF
# 📊 Buffer TCP Optimal
net.ipv4.tcp_rmem = ${buffers[0]} ${buffers[1]} ${buffers[2]}
net.ipv4.tcp_wmem = ${buffers[3]} ${buffers[4]} ${buffers[5]}
net.core.rmem_max = ${buffers[2]}
net.core.wmem_max = ${buffers[5]}
EOF

    # Load BBR module
    modprobe tcp_bbr 2>/dev/null || true
    echo "tcp_bbr" > /etc/modules-load.d/bbr.conf

    # Apply settings
    sysctl -p /etc/sysctl.d/99-bbr.conf >/dev/null
    sysctl -p /etc/sysctl.d/99-tcp-buf.conf >/dev/null
    
    echo -e "${GREEN}✅ Konfigurasi berhasil diterapkan!${RESET}"
}

# === 📜 MENU UTAMA ===
show_menu() {
    echo -e "\n${CYAN}${BOLD}:: PILIH METODE INPUT ::${RESET}"
    echo -e "1. Gunakan speedtest otomatis"
    echo -e "2. Masukkan manual"
    echo -e "3. Keluar"
    
    while true; do
        read -rp "➡ Pilihan [1-3]: " choice
        case "$choice" in
            1) echo "speedtest"; return ;;
            2) echo "manual"; return ;;
            3) exit 0 ;;
            *) echo -e "${YELLOW}⚠ Pilihan tidak valid${RESET}" ;;
        esac
    done
}

# === 🚀 EXECUTION ===
main() {
    show_header
    
    # Cek root
    [[ $EUID -ne 0 ]] && fail "Harus dijalankan sebagai root"
    
    case $(show_menu) in
        "speedtest")
            bandwidth=$(run_speedtest)
            ;;
        "manual")
            bandwidth=$(read_bandwidth)
            ;;
        *)
            exit 0
            ;;
    esac
    
    configure_system "$bandwidth"
    
    echo -e "\n${GREEN}${BOLD}🎉 SUKSES!${RESET}"
    echo -e "💻 ${CYAN}Hasil konfigurasi:${RESET}"
    sysctl net.ipv4.tcp_congestion_control net.ipv4.tcp_rmem net.ipv4.tcp_wmem
    
    echo -e "\n${YELLOW}💡 Disarankan reboot untuk hasil optimal${RESET}"
    echo -e "   Jalankan: ${BOLD}sudo reboot${RESET}\n"
}

main
