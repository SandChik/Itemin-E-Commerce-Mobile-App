// File ini bertugas menangani logika untuk semua yang berhubungan dengan produk.
package handler

import (
	"net/http"
	"github.com/labstack/echo/v4"
)

// Ini adalah "cetakan" atau blueprint untuk data produk.
type Product struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

// Struct ini hanya untuk mengelompokkan fungsi-fungsi handler produk.
type ProductHandler struct{}

// Ini adalah fungsi yang membuat dan mengembalikan instance ProductHandler baru.
func NewProductHandler() *ProductHandler {
	return &ProductHandler{}
}

// Fungsi ini akan dijalankan ketika ada permintaan ke GET /api/v1/products.
func (h *ProductHandler) GetProducts(c echo.Context) error {
	// Untuk saat ini, kita hanya akan mengembalikan data palsu (dummy data).
	// Nanti, data ini akan diambil dari database.
	products := []Product{
		{ID: "P001", Name: "Voucher Game 100 Diamond"},
		{ID: "P002", Name: "Jasa Joki Rank Mythic"},
	}

	// Mengirim data produk sebagai response JSON dengan status "OK".
	return c.JSON(http.StatusOK, products)
}