#!/usr/bin/env bash
set -euo pipefail

# === Fungsi pembantu ===
add_line() {
    local file="$1"
    local line="$2"
    if ! grep -qxF "$line" "$file" 2>/dev/null; then
        echo "$line" >> "$file"
    fi
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "❌ Skrip ini harus dijalankan sebagai root."
        exit 1
    fi
}

backup_config() {
    local src="$1"
    local dst="$BACKUP_DIR/$(basename "$src").bak"
    if [[ -f "$src" ]]; then
        cp "$src" "$dst"
        echo "🔄 Backup: $src -> $dst"
    fi
}

restore_config() {
    echo "♻️  Memulihkan konfigurasi lama..."
    for bak in "$BACKUP_DIR"/*.bak; do
        [[ -f "$bak" ]] || continue
        local orig="/etc/$(basename "${bak%.bak}")"
        cp "$bak" "$orig"
        echo "✅ Pulih: $orig"
    done
    sysctl --system >/dev/null 2>&1 || true
    echo "Konfigurasi lama sudah dipulihkan."
    exit 0
}

install_if_missing() {
    local pkg_name="$1"
    local bin_name="$2"
    if ! command -v "$bin_name" >/dev/null 2>&1; then
        echo "📦 Menginstal $pkg_name ..."
        if command -v apt >/dev/null 2>&1; then
            apt update -y >/dev/null 2>&1
            apt install -y "$pkg_name" >/dev/null 2>&1
        elif command -v yum >/dev/null 2>&1; then
            yum install -y "$pkg_name" >/dev/null 2>&1
        elif command -v dnf >/dev/null 2>&1; then
            dnf install -y "$pkg_name" >/dev/null 2>&1
        else
            echo "❌ Tidak dapat menginstal $pkg_name otomatis."
            exit 1
        fi
        echo "✅ $pkg_name terinstal."
    fi
}

# === Fungsi untuk mengukur bandwidth dan menyesuaikan buffer ===
detect_speed() {
    install_if_missing "speedtest-cli" "speedtest-cli"

    # Jalankan speedtest dan ambil angka kecepatan download (Mbps)
    local down_mbps
    down_mbps=$(speedtest-cli --secure --simple | awk '/Download/ {print int($2)}')

    if [[ -z "$down_mbps" || "$down_mbps" -le 0 ]]; then
        echo "❌ Gagal mendeteksi kecepatan internet."
        exit 1
    fi

    echo "📊 Kecepatan unduh terdeteksi: ${down_mbps} Mbps"

    # Faktor konversi aman: setiap 1 Mbps ≈ 12.5 KB buffer tambahan
    local FACTOR=$((125 * 1024 / 10))  # 12800 byte per Mbps

    # Fungsi untuk menghitung buffer max berdasarkan kecepatan
    calc_buffer() {
        local mbps="$1"
        local min_bytes="$2"
        local max_bytes="$3"
        local calc=$(( mbps * FACTOR ))

        # Clamp agar tidak terlalu kecil atau terlalu besar
        if (( calc < min_bytes )); then
            calc="$min_bytes"
        elif (( calc > max_bytes )); then
            calc="$max_bytes"
        fi
        echo "$calc"
    }

    # Hitung nilai max untuk rmem dan wmem (min 4MB, max 16MB)
    RMEM_MAX=$(calc_buffer "$down_mbps" $((4 * 1024 * 1024)) $((16 * 1024 * 1024)))
    WMEM_MAX=$(calc_buffer "$down_mbps" $((4 * 1024 * 1024)) $((16 * 1024 * 1024)))

    # Tetapkan nilai TCP rmem dan wmem
    TCP_RMEM="4096 87380 ${RMEM_MAX}"
    TCP_WMEM="4096 65536 ${WMEM_MAX}"
}

# === Fungsi untuk mengaktifkan BBR ===
install_bbr() {
    echo "=== Mengaktifkan TCP BBR ==="
    modprobe tcp_bbr || { echo "❌ Gagal load tcp_bbr"; exit 1; }
    mkdir -p /etc/sysctl.d /etc/modules-load.d
    add_line "/etc/modules-load.d/bbr.conf" "tcp_bbr"
    add_line "/etc/sysctl.d/99-bbr.conf" "net.core.default_qdisc = fq"
    add_line "/etc/sysctl.d/99-bbr.conf" "net.ipv4.tcp_congestion_control = bbr"
    sysctl -p /etc/sysctl.d/99-bbr.conf >/dev/null
    echo "✅ TCP BBR aktif."
}

# === Fungsi optimasi sistem ===
tune_system() {
    echo "=== Mengoptimalkan Sistem & Jaringan ==="
    mkdir -p /etc/security/limits.d

    cat > /etc/security/limits.d/99-tuning.conf <<EOF
* soft nofile 1048576
* hard nofile 1048576
root soft nofile 1048576
root hard nofile 1048576
EOF

    cat > /etc/sysctl.d/99-network.conf <<EOF
fs.file-max = 2097152
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 10000
net.core.somaxconn = 32768
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_rfc1337 = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_dsack = 1
net.ipv4.tcp_fack = 1
net.ipv4.tcp_frto = 2
net.ipv4.tcp_rmem = $TCP_RMEM
net.ipv4.tcp_wmem = $TCP_WMEM
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_early_retrans = 3
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_low_latency = 0
net.core.busy_poll = 50
net.core.busy_read = 50
EOF

    sysctl -p /etc/sysctl.d/99-network.conf >/dev/null
    echo "✅ Pengaturan jaringan diterapkan."
}

# === Main ===
BACKUP_DIR="/root/netopt-backup"
mkdir -p "$BACKUP_DIR"

case "${1:-}" in
    rollback)
        restore_config
        ;;
    *)
        check_root
        install_if_missing "iproute2" "tc"
        detect_speed
        backup_config "/etc/sysctl.d/99-bbr.conf"
        backup_config "/etc/sysctl.d/99-network.conf"
        backup_config "/etc/security/limits.d/99-tuning.conf"
        install_bbr
        tune_system
        echo "Konfigurasi selesai. Untuk kembali ke pengaturan lama: $0 rollback"
        ;;
esac
