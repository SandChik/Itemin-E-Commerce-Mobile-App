#!/bin/sh
set -e

# Load environment variables from .env if exists
test -f .env && export $(grep -v '^#' .env | xargs)

# Jalankan migrasi SQL jika ada
if [ -f ./internal/model/migration.sql ]; then
  echo "Menjalankan migrasi database..."
  until psql "$DATABASE_URL" -f ./internal/model/migration.sql; do
    echo "Menunggu database siap..."
    sleep 2
  done
fi

# Jalankan aplikasi Go
exec ./server
