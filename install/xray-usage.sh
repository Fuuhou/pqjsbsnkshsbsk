#!/usr/bin/env bash
set -euo pipefail

########################
# KONFIGURASI
########################
API_URL="http://127.0.0.1:10085/stats"
DB_PATH="/var/lib/xray/usage.db"

# Informasi waktu
NOW_TS=$(date +%s)
DATE_DAY=$(date +%Y-%m-%d)
DATE_WEEK=$(date +%Y-W%U)   # Minggu (Sun-start)
DATE_MONTH=$(date +%Y-%m)
DATE_YEAR=$(date +%Y)

# Informasi sistem (fallback jika file kosong/tidak ada)
read_file() { [[ -f "$1" ]] && cat "$1" || echo "-"; }
IP=$(read_file /etc/myipvps)
ISP=$(read_file /etc/xray/isp)
CITY=$(read_file /etc/xray/city)
DOMAINZ=$(read_file /etc/xray/domain)
AUTHOR=$(read_file /etc/profil)
LC_TIME=id_ID.UTF-8
TIME_NOW="$(LC_TIME=$LC_TIME date '+%A, %d %B %Y - %H:%M WIB')"

# Telegram bot
BOT_TOKEN=$(read_file /etc/per/token)
CHAT_ID2=$(read_file /etc/perlogin/id)
URL_DOC="https://api.telegram.org/bot${BOT_TOKEN}/sendDocument"

# Util: Escape HTML untuk caption
html_escape() {
  sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
}

# Util: Escape single-quote untuk SQL literal
sql_escape() {
  sed "s/'/''/g"
}

# Util: Eksekusi SQLite
sql() {
  sqlite3 -batch "$DB_PATH" "$1"
}

########################
# INISIALISASI DATABASE
########################
sqlite3 "$DB_PATH" <<'SQL'
PRAGMA journal_mode = WAL;

CREATE TABLE IF NOT EXISTS snapshot (
  protocol TEXT NOT NULL,
  user_id  TEXT NOT NULL,
  up       INTEGER NOT NULL DEFAULT 0,  -- counter kumulatif dari Xray
  down     INTEGER NOT NULL DEFAULT 0,  -- counter kumulatif dari Xray
  ts       INTEGER NOT NULL,            -- timestamp terakhir update (bukan indikator aktivitas)
  PRIMARY KEY (protocol, user_id)
);

CREATE TABLE IF NOT EXISTS usage (
  date_key TEXT NOT NULL,
  period   TEXT NOT NULL, -- daily, weekly, monthly, yearly
  protocol TEXT NOT NULL,
  user_id  TEXT NOT NULL,
  up       INTEGER NOT NULL DEFAULT 0,
  down     INTEGER NOT NULL DEFAULT 0,
  total    INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (date_key, period, protocol, user_id)
);

-- Trafik all-time per user (+ riwayat kemunculan & aktivitas)
CREATE TABLE IF NOT EXISTS totals (
  protocol    TEXT NOT NULL,
  user_id     TEXT NOT NULL,
  up          INTEGER NOT NULL DEFAULT 0,    -- akumulasi delta
  down        INTEGER NOT NULL DEFAULT 0,
  total       INTEGER NOT NULL DEFAULT 0,
  first_seen  INTEGER NOT NULL,              -- pertama kali terdeteksi pada skrip ini
  last_seen   INTEGER NOT NULL,              -- terakhir kali nama user muncul di API stats
  last_active INTEGER NOT NULL,              -- terakhir kali ada delta > 0 (trafik)
  PRIMARY KEY (protocol, user_id)
);
SQL

########################
# AMBIL DATA XRAY
########################
RESPONSE=$(curl -s --max-time 5 "$API_URL" || true)
if [[ -z "$RESPONSE" || "$RESPONSE" == "null" ]]; then
  echo "Gagal mengambil data dari Xray API"
  exit 0
fi

########################
# PROSES DATA
########################
# Catatan:
# - Delta dihitung dari selisih counter kumulatif Xray.
# - last_seen: diperbarui setiap entry user muncul dari API.
# - last_active: hanya diperbarui saat delta > 0 (ada trafik).
# - snapshot.ts tidak digunakan untuk kebijakan hapus; yang dipakai totals.last_active.

# Gunakan process substitution untuk menghindari subshell pada while | while
while read -r entry; do
  PROTO=$(jq -r '.tag // empty' <<<"$entry")
  USER=$(jq -r '.user // empty' <<<"$entry")
  UPD=$(jq -r '.uplink // 0' <<<"$entry")
  DND=$(jq -r '.downlink // 0' <<<"$entry")

  [[ -z "$PROTO" || -z "$USER" ]] && continue

  PROTO_ESC=$(printf "%s" "$PROTO" | sql_escape)
  USER_ESC=$(printf "%s" "$USER"  | sql_escape)

  # Ambil snapshot lama
  OLD=$(sql "SELECT up||' '||down||' '||ts FROM snapshot WHERE protocol='$PROTO_ESC' AND user_id='$USER_ESC';" || true)
  if [[ -n "$OLD" ]]; then
    OLD_UP=$(awk '{print $1}' <<<"$OLD")
    OLD_DN=$(awk '{print $2}' <<<"$OLD")
    OLD_TS=$(awk '{print $3}' <<<"$OLD")
  else
    OLD_UP=0; OLD_DN=0; OLD_TS=0
  fi

  # Hitung delta (non-negatif)
  DELTA_UP=$(( UPD - OLD_UP ))
  DELTA_DN=$(( DND - OLD_DN ))
  (( DELTA_UP < 0 )) && DELTA_UP=0
  (( DELTA_DN < 0 )) && DELTA_DN=0
  DELTA=$(( DELTA_UP + DELTA_DN ))

  # Agregasi usage per periode (hanya jika ada delta)
  if (( DELTA > 0 )); then
    for PERIOD in daily weekly monthly yearly; do
      case $PERIOD in
        daily)   KEY="$DATE_DAY" ;;
        weekly)  KEY="$DATE_WEEK" ;;
        monthly) KEY="$DATE_MONTH" ;;
        yearly)  KEY="$DATE_YEAR" ;;
      esac
      sql "
      INSERT INTO usage(date_key,period,protocol,user_id,up,down,total)
      VALUES('$KEY','$PERIOD','$PROTO_ESC','$USER_ESC',$DELTA_UP,$DELTA_DN,$DELTA)
      ON CONFLICT(date_key,period,protocol,user_id) DO UPDATE
        SET up=up+$DELTA_UP, down=down+$DELTA_DN, total=total+$DELTA;"
    done
  fi

  # Update totals (all-time)
  # - first_seen: NOW_TS saat pertama kali muncul.
  # - last_seen: selalu NOW_TS ketika user muncul di API.
  # - last_active: NOW_TS hanya jika DELTA > 0, jika tidak pakai nilai sebelumnya.
  sql "
  INSERT INTO totals(protocol,user_id,up,down,total,first_seen,last_seen,last_active)
  VALUES('$PROTO_ESC','$USER_ESC',$DELTA_UP,$DELTA_DN,$DELTA,$NOW_TS,$NOW_TS,CASE WHEN $DELTA>0 THEN $NOW_TS ELSE 0 END)
  ON CONFLICT(protocol,user_id) DO UPDATE SET
    up=up+$DELTA_UP,
    down=down+$DELTA_DN,
    total=total+$DELTA,
    last_seen=$NOW_TS,
    last_active=CASE WHEN $DELTA>0 THEN $NOW_TS ELSE last_active END;
  "

  # Update snapshot (ts diset ke NOW_TS agar tidak NULL; indikator aktif tetap memakai totals.last_active)
  sql "
  INSERT INTO snapshot(protocol,user_id,up,down,ts)
  VALUES('$PROTO_ESC','$USER_ESC',$UPD,$DND,$NOW_TS)
  ON CONFLICT(protocol,user_id) DO UPDATE
    SET up=$UPD, down=$DND, ts=$NOW_TS;
  "
done < <(echo "$RESPONSE" | jq -c '.entries[]')

########################
# HAPUS USER NONAKTIF ≥30 HARI
########################
# Kriteria:
# - last_active = 0 (belum pernah ada trafik) ATAU
# - last_active < now - 30 hari
# Dihapus dari: totals & snapshot (riwayat usage agregat tetap dipertahankan).
REMOVABLE_CNT=$(sql "
WITH cand AS (
  SELECT protocol,user_id FROM totals
  WHERE last_active=0 OR last_active < strftime('%s','now','-30 day')
)
SELECT COUNT(*) FROM cand;
")
# Hapus snapshot yang terkait
sql "
DELETE FROM snapshot
WHERE (protocol,user_id) IN (
  SELECT protocol,user_id FROM totals
  WHERE last_active=0 OR last_active < strftime('%s','now','-30 day')
);
"
# Hapus totals (detail user)
sql "
DELETE FROM totals
WHERE last_active=0 OR last_active < strftime('%s','now','-30 day');
"

########################
# LAPORAN TELEGRAM 23:59
########################
LOCK_FILE="/tmp/xray_daily_report.lock"

if [[ "$(date +%H:%M)" == "23:59" ]]; then
  # Hindari kirim ganda di tanggal yang sama
  if [[ -f "$LOCK_FILE" && "$(cat "$LOCK_FILE")" == "$DATE_DAY" ]]; then
    exit 0
  fi
  echo "$DATE_DAY" > "$LOCK_FILE"

  get_total() {
    local key="$1" period="$2"
    sql "SELECT
           printf('%.2f',COALESCE(SUM(up),0)/1024.0/1024/1024),
           printf('%.2f',COALESCE(SUM(down),0)/1024.0/1024/1024),
           printf('%.2f',COALESCE(SUM(total),0)/1024.0/1024/1024)
         FROM usage WHERE date_key='$key' AND period='$period';"
  }

  read D_UP D_DN D_TOT <<<"$(get_total "$DATE_DAY"   daily)"
  read W_UP W_DN W_TOT <<<"$(get_total "$DATE_WEEK"  weekly)"
  read M_UP M_DN M_TOT <<<"$(get_total "$DATE_MONTH" monthly)"
  read Y_UP Y_DN Y_TOT <<<"$(get_total "$DATE_YEAR"  yearly)"

  ########################
  # BANGUN FILE LAPORAN TERFORMAT & KIRIM
  ########################
  REPORT_FILE="/tmp/xray_usage_report_${DATE_DAY}.txt"
  {
    echo "====================== XRAY USAGE REPORT ======================"
    echo "Generated : $TIME_NOW"
    echo "Server    : $AUTHOR  | ISP: $ISP | City: $CITY | Domain: $DOMAINZ"
    echo ""
    echo "== Ringkasan (GB) =="
    printf "%-10s  %-10s  %-10s  %-10s\n" "Periode" "Upload" "Download" "Total"
    printf "%-10s  %-10s  %-10s  %-10s\n" "Harian"  "$D_UP"  "$D_DN"    "$D_TOT"
    printf "%-10s  %-10s  %-10s  %-10s\n" "Mingguan" "$W_UP" "$W_DN"    "$W_TOT"
    printf "%-10s  %-10s  %-10s  %-10s\n" "Bulanan" "$M_UP" "$M_DN"     "$M_TOT"
    printf "%-10s  %-10s  %-10s  %-10s\n" "Tahunan" "$Y_UP" "$Y_DN"     "$Y_TOT"
    echo ""
    echo "== All-Time Per User (diurutkan total terbesar) =="
  } > "$REPORT_FILE"

  sqlite3 -header -column "$DB_PATH" "
    SELECT
      protocol AS proto,
      user_id AS user,
      printf('%.2f', up/1024.0/1024/1024)   AS up_gb,
      printf('%.2f', down/1024.0/1024/1024) AS down_gb,
      printf('%.2f', total/1024.0/1024/1024) AS total_gb,
      datetime(first_seen,'unixepoch','localtime')  AS first_seen,
      CASE WHEN last_active>0 THEN datetime(last_active,'unixepoch','localtime') ELSE '-' END AS last_active,
      datetime(last_seen,'unixepoch','localtime')   AS last_seen,
      CASE WHEN last_active>0
           THEN CAST( (strftime('%s','now')-last_active)/86400 AS INT)
           ELSE '-' END AS days_since_active
    FROM totals
    ORDER BY total DESC;
  " >> "$REPORT_FILE"

  {
    echo ""
    echo "== Hari Ini Per User (GB) =="
  } >> "$REPORT_FILE"

  sqlite3 -header -column "$DB_PATH" "
    SELECT
      protocol AS proto,
      user_id AS user,
      printf('%.2f', up/1024.0/1024/1024)   AS up_gb,
      printf('%.2f', down/1024.0/1024/1024) AS down_gb,
      printf('%.2f', total/1024.0/1024/1024) AS total_gb
    FROM usage
    WHERE period='daily' AND date_key='$DATE_DAY'
    ORDER BY total DESC;
  " >> "$REPORT_FILE"

  # === TOP 5 USER HARI INI ===
  TOP5_ROWS=$(sql "
    WITH today AS (
      SELECT protocol, user_id, total
      FROM usage
      WHERE period='daily' AND date_key='$DATE_DAY'
    ),
    agg AS (
      SELECT COALESCE(SUM(total),0) AS day_total FROM today
    )
    SELECT
      protocol||'|'||user_id||'|'||
      printf('%.2f', total/1024.0/1024/1024)||'|'||
      printf('%.1f', CASE WHEN (SELECT day_total FROM agg)>0
                          THEN 100.0*total/(SELECT day_total FROM agg)
                          ELSE 0 END)
    FROM today
    ORDER BY total DESC
    LIMIT 5;
  ")

  # Formatkan menjadi list bernomor
  CAP_TOP5=""
  if [[ -n "$TOP5_ROWS" ]]; then
    i=0
    while IFS='|' read -r proto user gb pct; do
      i=$((i+1))
      CAP_TOP5+=$'\n'"<b>${i}.</b> ${user} [${proto}] — ${gb} GB (${pct}%)"
    done <<< "$TOP5_ROWS"
  else
    CAP_TOP5=$'\n-'
  fi

  CAPTION="
📋 <b>Lampiran Laporan Trafik Xray</b>
━━━━━━━━━━━━━━━━━━━━
🏆 <b>Top 5 User — Trafik Harian</b>
${CAP_TOP5}
━━━━━━━━━━━━━━━━━━━━
🔖 <b>Label :</b> ${AUTHOR}
🏢 <b>ISP :</b> ${ISP}
🌆 <b>Kota :</b> ${CITY}
📆 <b>Periode :</b> ${DATE_DAY}
📦 <b>Total Harian :</b> ${D_TOT} GB
🧹 <b>Dibersihkan (≥30 hari nonaktif) :</b> ${REMOVABLE_CNT}
━━━━━━━━━━━━━━━━━━━━
"

  ESCAPED_CAPTION=$(echo "$CAPTION" | html_escape)

  # Kirim laporan terformat
  curl -s -F "chat_id=${CHAT_ID2}" \
          -F "parse_mode=html" \
          -F "caption=${ESCAPED_CAPTION}" \
          -F "document=@${REPORT_FILE};filename=xray_usage_report_${DATE_DAY}.txt" \
          "$URL_DOC" >/dev/null || true

########################
# PEMBERSIHAN OTOMATIS RIWAYAT USAGE
########################
# Daily: jaga 30 hari
sql "DELETE FROM usage WHERE period='daily' AND date(date_key) < date('now','-30 day');"

# Weekly: approx hapus jika Senin minggu tsb lebih tua dari 120 hari
# (Hitung: 1 Jan tahun itu + N minggu)
sql "
DELETE FROM usage
WHERE period='weekly'
  AND date(substr(date_key,1,4)||'-01-01','+'||substr(date_key,6)||' weeks')
      < date('now','-120 day');
"

# Monthly: jaga 12 bulan
sql "DELETE FROM usage WHERE period='monthly'
     AND date(date_key||'-01') < date('now','-365 day');"

exit 0
