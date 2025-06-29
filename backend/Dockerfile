# --- TAHAP 1: BUILDER ---
# Menggunakan image Go resmi berbasis Alpine Linux (ringan dan cepat).
FROM golang:1.24-alpine AS builder

# Menetapkan direktori kerja di dalam container builder.
WORKDIR /app

# Salin file go.mod dan go.sum terlebih dahulu untuk memanfaatkan cache Docker layer.
COPY go.mod go.sum ./
# Download semua dependensi Go yang dibutuhkan project.
RUN go mod download

# Salin seluruh source code project ke dalam container builder.
COPY . .

# Compile aplikasi Go menjadi file binary bernama 'server'.
# CGO_ENABLED=0: hasilkan binary statis (tidak tergantung library C)
# GOOS=linux: agar binary bisa dijalankan di container Linux
RUN CGO_ENABLED=0 GOOS=linux go build -o ./server ./cmd/api

# --- TAHAP 2: FINAL ---
# Menggunakan image Alpine Linux yang sangat kecil untuk hasil akhir (production image).
FROM alpine:latest

# Menetapkan direktori kerja di dalam container final.
WORKDIR /app

# Install psql (PostgreSQL client) agar bisa menjalankan migrasi SQL dari entrypoint.sh
RUN apk add --no-cache postgresql-client

# Salin file binary hasil build dari tahap builder ke image final.
COPY --from=builder /app/server .

# Salin script entrypoint yang akan menjalankan migrasi dan server Go.
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Salin file .env jika ada, agar environment variable bisa digunakan di container.
COPY .env .

# Salin file migrasi SQL dari builder ke image final, agar bisa dijalankan saat container start.
COPY --from=builder /app/internal/model/migration.sql ./internal/model/migration.sql

# Memberitahu Docker bahwa container ini akan membuka port 8080 (untuk aplikasi Go).
EXPOSE 8080

# Menetapkan entrypoint container: jalankan entrypoint.sh (bukan langsung binary Go),
# agar migrasi database dijalankan sebelum server Go dijalankan.
ENTRYPOINT ["./entrypoint.sh"]