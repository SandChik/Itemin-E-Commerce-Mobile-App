package handler

import (
	"context"
	"net/http"
	"time"

	"github.com/labstack/echo/v4"
	"golang.org/x/crypto/bcrypt"
	"itemin.app/backend/internal/model"
)

// Struct untuk menerima data request registrasi dari frontend (email & password)
type RegisterRequest struct {
	Email    string `json:"email"`    // Email user
	Password string `json:"password"` // Password user (plain, akan di-hash)
}

// Struct untuk response sukses registrasi ke frontend
type RegisterResponse struct {
	ID    int64  `json:"id"`    // ID user yang baru dibuat
	Email string `json:"email"` // Email user
}

// Handler untuk user, bisa ditambah method lain (login, dsb)
type UserHandler struct{}

// Membuat instance UserHandler (bisa untuk dependency injection)
func NewUserHandler() *UserHandler {
	return &UserHandler{}
}

// Handler utama untuk endpoint registrasi user
func (h *UserHandler) Register(c echo.Context) error {
	var req RegisterRequest
	// Mengambil data JSON dari request body dan mengisi ke struct req
	if err := c.Bind(&req); err != nil {
		// Jika data tidak valid, kembalikan error 400
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "invalid request"})
	}
	// Validasi: email dan password wajib diisi
	if req.Email == "" || req.Password == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "email and password required"})
	}
	// Cek ke database apakah email sudah terdaftar
	var exists bool
	err := model.DB.QueryRow(context.Background(), "SELECT EXISTS(SELECT 1 FROM users WHERE email=$1)", req.Email).Scan(&exists)
	if err != nil {
		// Jika gagal query ke database, kembalikan error 500
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "database error"})
	}
	if exists {
		// Jika email sudah terdaftar, kembalikan error 400
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "email already registered"})
	}
	// Hash password sebelum disimpan ke database
	hashed, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "failed to hash password"})
	}
	// Insert user baru ke database dan ambil ID-nya
	var userID int64
	err = model.DB.QueryRow(
		context.Background(),
		"INSERT INTO users (email, password, created_at) VALUES ($1, $2, $3) RETURNING id",
		req.Email, string(hashed), time.Now(),
	).Scan(&userID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "failed to save user"})
	}
	// Jika sukses, kembalikan response 201 beserta ID dan email user
	return c.JSON(http.StatusCreated, RegisterResponse{ID: userID, Email: req.Email})
}
