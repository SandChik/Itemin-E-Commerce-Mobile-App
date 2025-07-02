#!/bin/sh
set -e  # Jika ada perintah yang gagal, script akan langsung berhenti (fail fast)

# Load environment variables dari file .env jika file tersebut ada
# Ini agar variabel seperti DATABASE_URL bisa digunakan di script dan aplikasi Go
# 'grep -v '^#'' mengabaikan baris komentar di .env
# 'xargs' meng-export semua variabel ke environment shell
# (catatan: cara ini sederhana, untuk .env kompleks bisa pakai tool khusus)
test -f .env && export $(grep -v '^#' .env | xargs)

# Jalankan migrasi SQL jika file migrasi ada
if [ -f ./internal/model/migration.sql ]; then
  echo "Menjalankan migrasi database..."
  # Ulangi perintah migrasi sampai berhasil (misal: database belum siap saat container baru start)
  until psql "$DATABASE_URL" -f ./internal/model/migration.sql; do
    echo "Menunggu database siap..."
    sleep 2  # Tunggu 2 detik sebelum mencoba lagi
  done
fi

# Jalankan aplikasi Go (binary server hasil build)
# 'exec' menggantikan shell dengan proses server, agar sinyal (SIGTERM, dsb) diteruskan ke server
exec ./server
