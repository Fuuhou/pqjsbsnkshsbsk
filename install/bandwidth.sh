#!/bin/bash
# Ambil nama interface vnStat dari output vnstat (baris ke-3)
vnstat_profile=$(vnstat | sed -n '3p' | awk '{print $1}' | grep -o '[^:]*')
if [[ -z "$vnstat_profile" ]]; then
  echo "Gagal mengambil vnstat_profile"
  exit 1
fi

# Simpan output vnstat ke file sementara
vnstat -i "${vnstat_profile}" > /etc/t1

# Ambil informasi waktu dan ambil data tambahan dari pastebin
bulan=$(date +%b)    # Contoh: Jan, Feb, dst.
tahun=$(date +%y)    # Dua digit tahun, misalnya 23
ba=$(curl -s https://pastebin.com/raw/0gWiX6hE)

# Cek apakah output vnstat di file /etc/t1 memuat nama bulan (format "Jan")
if grep -qw "${bulan}" /etc/t1; then
    # Misalnya, grep untuk format: "Jan $ba23" (jika $ba berisi karakter tambahan seperti pemisah)
    month_tx=$(vnstat -i "${vnstat_profile}" | grep "$bulan $ba$tahun" | awk '{print $6}')
    month_txv=$(vnstat -i "${vnstat_profile}" | grep "$bulan $ba$tahun" | awk '{print $7}')
else
    # Jika tidak ditemukan, gunakan format YYYY-MM
    bulan2=$(date +%Y-%m)
    month_tx=$(vnstat -i "${vnstat_profile}" | grep "$bulan2 " | awk '{print $5}')
    month_txv=$(vnstat -i "${vnstat_profile}" | grep "$bulan2 " | awk '{print $6}')
fi

# Simpan hasil penggunaan ke file /etc/usage2
echo "$month_tx $month_txv" > /etc/usage2

# Ambil nilai penggunaan dan prefix dari file
usage2=$(cat /etc/usage2)
usagee=$(cat /etc/usagee)

# Daftar ambang batas yang menyebabkan shutdown
# (Anda dapat menyesuaikan ambang batas sesuai kebutuhan)
shutdown_thresholds=(
    ".10 TiB"
    ".20 TiB"
    ".30 TiB"
    ".40 TiB"
    ".50 TiB"
    ".01 TiB"
    ".02 TiB"
    ".03 TiB"
    ".04 TiB"
    ".05 TiB"
)

# Periksa apakah usage2 sama dengan salah satu threshold.
# Menggabungkan prefix usagee dengan threshold.
for threshold in "${shutdown_thresholds[@]}"; do
    if [[ "$usage2" == "${usagee}${threshold}" ]]; then
        /sbin/shutdown now
        exit 0
    fi
done

# Jika tidak ada yang cocok, tidak lakukan apa-apa
exit 0