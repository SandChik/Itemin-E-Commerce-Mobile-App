-- migration.sql
-- File ini berisi perintah SQL untuk membuat tabel users di database PostgreSQL.
-- File ini dijalankan otomatis saat container backend start (melalui entrypoint.sh).
-- Tujuannya agar struktur database selalu siap sebelum aplikasi Go berjalan.

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,           -- Kolom id, auto increment, sebagai primary key (unik untuk setiap user)
    email VARCHAR(255) UNIQUE NOT NULL, -- Kolom email, harus unik dan wajib diisi
    password TEXT NOT NULL,          -- Kolom password, menyimpan hash password, wajib diisi
    created_at TIMESTAMP NOT NULL    -- Kolom waktu pembuatan user, wajib diisi
);
