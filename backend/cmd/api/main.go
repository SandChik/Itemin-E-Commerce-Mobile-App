// Ini adalah titik awal program backend kita.
package main

import (
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"itemin.app/backend/internal/handler" // Mengimpor handler yang akan kita buat
	"itemin.app/backend/internal/model"
)

func main() {
	// Inisialisasi koneksi database PostgreSQL.
	// Jika gagal, aplikasi akan berhenti dan menampilkan pesan error.
	if err := model.InitDB(); err != nil {
		panic("Gagal koneksi database: " + err.Error())
	}

	// Membuat instance Echo, framework web utama yang akan menangani semua request HTTP.
	e := echo.New()

	// Middleware adalah fungsi yang dijalankan sebelum handler utama.
	// Logger: mencatat semua request ke terminal/log.
	// Recover: mencegah server mati jika terjadi panic/error tak terduga.
	// CORS: mengizinkan request dari domain lain (misal dari aplikasi Flutter).
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())
	e.Use(middleware.CORS())

	// Mendefinisikan route sederhana untuk health check.
	// GET /health akan mengembalikan status OK jika server hidup.
	e.GET("/health", func(c echo.Context) error {
		return c.JSON(http.StatusOK, map[string]string{"status": "ok"})
	})

	// Membuat group route di bawah /api/v1 agar rapi dan mudah di-maintain.
	v1 := e.Group("/api/v1")

	// Membuat instance handler produk dan user.
	productHandler := handler.NewProductHandler()
	userHandler := handler.NewUserHandler()

	// Mendefinisikan endpoint GET /api/v1/products untuk mengambil daftar produk.
	v1.GET("/products", productHandler.GetProducts)
	// Mendefinisikan endpoint POST /api/v1/register untuk registrasi user baru.
	v1.POST("/register", userHandler.Register)

	// Menjalankan server pada port 8080.
	// Jika terjadi error saat menjalankan server, aplikasi akan berhenti.
	e.Logger.Fatal(e.Start(":8080"))
}
