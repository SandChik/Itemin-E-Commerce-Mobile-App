package model

import (
	"context"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"
)

// DB adalah variabel global yang menyimpan pool koneksi ke database PostgreSQL.
// Pool ini digunakan untuk melakukan query ke database dari berbagai bagian aplikasi.
var DB *pgxpool.Pool

// InitDB adalah fungsi untuk menginisialisasi koneksi ke database PostgreSQL.
// Fungsi ini akan membaca environment variable DATABASE_URL untuk mendapatkan string koneksi.
// Jika DATABASE_URL tidak ada, maka akan menggunakan default ke localhost (biasanya untuk development/testing).
// Fungsi ini harus dipanggil sekali di awal aplikasi (misal di main.go).
func InitDB() error {
	// Ambil string koneksi dari environment variable DATABASE_URL
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		// Jika tidak ada, gunakan default (biasanya untuk development lokal)
		dsn = "postgres://postgres:postgres@db:5432/postgres?sslmode=disable"
	}
	// Membuat pool koneksi ke database dengan pgxpool
	pool, err := pgxpool.New(context.Background(), dsn)
	if err != nil {
		// Jika gagal koneksi, kembalikan error
		return err
	}
	// Simpan pool koneksi ke variabel global DB
	DB = pool
	return nil // Sukses
}
