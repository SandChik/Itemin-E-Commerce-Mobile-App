package handler

import (
	"context"
	"net/http"

	"github.com/labstack/echo/v4"
	"golang.org/x/crypto/bcrypt"
	"itemin.app/backend/internal/model"
)

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type LoginResponse struct {
	ID    int64  `json:"id"`
	Email string `json:"email"`
}

type LoginHandler struct{}

func NewLoginHandler() *LoginHandler {
	return &LoginHandler{}
}

func (h *LoginHandler) Login(c echo.Context) error {
	var req LoginRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "invalid request"})
	}
	if req.Email == "" || req.Password == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "email and password required"})
	}
	var user model.User
	err := model.DB.QueryRow(context.Background(), "SELECT id, email, password FROM users WHERE email=$1", req.Email).Scan(&user.ID, &user.Email, &user.Password)
	if err != nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"error": "email or password incorrect"})
	}
	if bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)) != nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"error": "email or password incorrect"})
	}
	return c.JSON(http.StatusOK, LoginResponse{ID: user.ID, Email: user.Email})
}
