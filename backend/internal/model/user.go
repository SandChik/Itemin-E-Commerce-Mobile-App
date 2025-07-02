package model

import "time"

// Struct User merepresentasikan satu baris data user di tabel users pada database.
// Struct ini digunakan untuk mapping data dari/ke database dan juga untuk response API.
type User struct {
	ID        int64     `json:"id"`         // ID unik user (primary key di database)
	Email     string    `json:"email"`      // Email user
	Password  string    `json:"-"`          // Hash password user (tidak dikirim ke frontend, karena tag json:"-")
	CreatedAt time.Time `json:"created_at"` // Waktu user dibuat (diambil dari database)
}
