// Ini adalah titik awal program backend kita.
package main

import (
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"itemin.app/backend/internal/handler" // Mengimpor handler yang akan kita buat
)

func main() {
	// 1. Membuat instance Echo, ini adalah server utama kita.
	e := echo.New()

	// 2. Middleware (Perangkat Lunak Perantara)
	// Ini adalah fungsi-fungsi yang dijalankan pada setiap permintaan sebelum ditangani oleh handler.
	e.Use(middleware.Logger())  // Untuk mencatat (log) setiap permintaan yang masuk ke terminal.
	e.Use(middleware.Recover()) // Untuk mencegah server mati jika terjadi error tak terduga.
	e.Use(middleware.CORS())    // PENTING: Agar aplikasi Flutter kita nanti diizinkan untuk "berbicara" dengan server ini.

	// 3. Routes (Rute / Alamat URL)
	// Mendefinisikan alamat-alamat URL yang bisa diakses.
	e.GET("/health", func(c echo.Context) error {
		// Ini adalah rute sederhana untuk mengecek apakah server hidup.
		return c.JSON(http.StatusOK, map[string]string{"status": "ok"})
	})

	// Kita kelompokkan semua rute API di bawah /api/v1 agar rapi.
	v1 := e.Group("/api/v1")

	// Membuat instance dari product handler kita.
	productHandler := handler.NewProductHandler()
	// Menetapkan bahwa jika ada permintaan GET ke /api/v1/products,
	// maka akan ditangani oleh fungsi GetProducts dari productHandler.
	v1.GET("/products", productHandler.GetProducts)


	// 4. Menjalankan server
	e.Logger.Fatal(e.Start(":8080")) // Menjalankan server di port 8080.
}