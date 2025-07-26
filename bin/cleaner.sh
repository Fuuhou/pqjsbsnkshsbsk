#!/bin/bash

clear

# Daftar pola file log yang akan dibersihkan
log_patterns=('*.log' '*.err' 'mail.*')

# Membersihkan semua file log sesuai pola
for pattern in "${log_patterns[@]}"; do
    find /var/log/ -type f -name "$pattern" -exec truncate -s 0 {} \; -print
done

# Membersihkan log sistem secara langsung
truncate -s 0 /var/log/{syslog,btmp,messages,debug}

# Tampilkan pesan sukses
echo -e "\nSuccessfully cleaned logs at $(date)\n"

sleep 0.5
clear
