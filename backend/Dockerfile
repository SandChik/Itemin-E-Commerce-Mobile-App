# --- TAHAP 1: BUILDER ---
# Kita mulai dengan image resmi Go versi 1.22 yang ringan (alpine).
# Ini adalah lingkungan untuk meng-compile aplikasi kita.
FROM golang:1.24-alpine AS builder

# Menetapkan direktori kerja di dalam container.
WORKDIR /app

# Salin file manajemen dependensi terlebih dahulu.
# Ini memanfaatkan cache Docker. Jika file-file ini tidak berubah, Docker tidak akan mengunduh ulang dependensi.
COPY go.mod go.sum ./
RUN go mod download

# Salin sisa kode sumber proyek kita.
COPY . .

# Compile aplikasi Go kita.
# CGO_ENABLED=0 membuat binary yang statis (tidak bergantung pada library C di sistem).
# GOOS=linux memastikan binary ini bisa berjalan di lingkungan Linux (seperti image alpine).
RUN CGO_ENABLED=0 GOOS=linux go build -o ./server ./cmd/api

# --- TAHAP 2: FINAL ---
# Kita mulai lagi dari image dasar yang sangat kecil (alpine) untuk hasil akhir.
# Ini membuat image container kita sangat ringan dan aman.
FROM alpine:latest

WORKDIR /app

# Salin HANYA file binary yang sudah di-compile dari tahap 'builder'.
# Kita tidak perlu membawa seluruh source code Go ke image final.
COPY --from=builder /app/server .

# Memberitahu Docker bahwa container ini akan mengekspos port 8080.
EXPOSE 8080

# Perintah yang akan dijalankan saat container ini dinyalakan.
CMD ["./server"]