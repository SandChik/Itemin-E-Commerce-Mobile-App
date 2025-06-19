# 🛒 Itemin - E-Commerce Mobile App

<div align="center">
  <img src="https://via.placeholder.com/200x200?text=Itemin+Logo" alt="Itemin Logo" width="200"/>
  <p><em>Marketplace Digital Produk Game yang Aman dan Terpercaya</em></p>
</div>

## 📱 Tentang Aplikasi

**Itemin** adalah aplikasi mobile e-commerce yang dirancang khusus untuk jual beli produk digital seperti top-up game, voucher, dan akun game, terinspirasi oleh Itemku.com. Aplikasi ini dibangun untuk memfasilitasi transaksi antara penjual dan pembeli produk digital dengan aman, cepat, dan efisien.

![Lisensi](https://img.shields.io/badge/License-MIT-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Go](https://img.shields.io/badge/Go-1.21-blue)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue)

## 📸 Tampilan Aplikasi

<div align="center">
  <table>
    <tr>
      <td><img src="https://via.placeholder.com/250x500?text=Home+Screen" alt="Home Screen" width="250"/></td>
      <td><img src="https://via.placeholder.com/250x500?text=Product+Detail" alt="Product Detail" width="250"/></td>
      <td><img src="https://via.placeholder.com/250x500?text=Checkout" alt="Checkout" width="250"/></td>
    </tr>
    <tr>
      <td align="center">Beranda</td>
      <td align="center">Detail Produk</td>
      <td align="center">Checkout</td>
    </tr>
  </table>
</div>

## ✨ Fitur Utama

Aplikasi ini menyediakan dua peran utama: **Pengguna (Pembeli)** dan **Penjual**, masing-masing dengan fungsionalitas yang berbeda.

### 👤 Fungsionalitas Pengguna (Pembeli)

- **🔐 Autentikasi & Profil**
  - Registrasi dan login dengan email/password atau OAuth (Google, Facebook)
  - Verifikasi akun melalui email atau OTP
  - Manajemen profil pengguna lengkap
  
- **🛍️ Belanja & Transaksi**
  - Melihat, mencari, dan memfilter produk digital berdasarkan kategori
  - Menyimpan produk favorit ke wishlist
  - Menambahkan produk ke keranjang belanja
  - Checkout dan pembayaran melalui berbagai metode
  - Melihat riwayat transaksi dan status pesanan
  
- **⭐ Interaksi & Ulasan**
  - Memberikan ulasan dan rating setelah transaksi selesai
  - Komunikasi dengan penjual melalui fitur chat

### 🏪 Fungsionalitas Penjual

- **📦 Manajemen Produk**
  - Mendaftarkan dan mengelola produk digital yang dijual
  - Mengatur harga, deskripsi, dan stok produk
  - Upload gambar produk dan detail informasi
  
- **💰 Manajemen Penjualan**
  - Dashboard analitik penjualan
  - Melihat riwayat dan status penjualan
  - Melakukan pencairan dana/saldo ke rekening bank

### 🔧 Fungsionalitas Sistem

- **🔒 Keamanan**
  - Autentikasi dan otorisasi aman menggunakan JWT/OAuth
  - Enkripsi data sensitif
  
- **💳 Pembayaran**
  - Integrasi dengan payment gateway seperti Midtrans atau Xendit
  - Mendukung berbagai metode pembayaran (kartu kredit, transfer bank, e-wallet)
  
- **📢 Komunikasi**
  - Sistem notifikasi real-time menggunakan Firebase Cloud Messaging (FCM)
  - Email notifikasi untuk update status transaksi

## 🛠️ Teknologi yang Digunakan

Proyek ini dibangun dengan arsitektur client-server menggunakan tumpukan teknologi modern yang skalabel:

| Layer | Teknologi |
|-------|-----------|
| **Frontend** | Flutter (Dart) |
| **Backend API** | Go (Echo Framework) |
| **Database** | PostgreSQL |
| **Auth** | JWT / OAuth |
| **Payment** | Midtrans / Xendit |
| **Notifikasi** | Firebase Cloud Messaging (FCM) |
| **Storage** | AWS S3 / Cloudinary |
| **Infrastruktur** | Docker + Docker Compose |

## 📋 Prasyarat

Sebelum memulai, pastikan perangkat Anda sudah terinstal perangkat lunak berikut:

- [Git](https://git-scm.com/downloads)
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versi 3.x atau lebih baru)
- [Docker](https://www.docker.com/get-started) & [Docker Compose](https://docs.docker.com/compose/install/)
- IDE/Text Editor ([Visual Studio Code](https://code.visualstudio.com/) direkomendasikan)
- (Opsional) Klien Database seperti [DBeaver](https://dbeaver.io/) atau [pgAdmin](https://www.pgadmin.org/)

## 🚀 Panduan Instalasi & Menjalankan

Lingkungan backend dan database proyek ini sepenuhnya dikelola oleh Docker, membuatnya sangat mudah untuk dijalankan di berbagai mesin.

### 1. Clone Repository

```bash
git clone https://github.com/SandChik/Itemin-E-Commerce-Mobile-App.git
cd Itemin-E-Commerce-Mobile-App
```

### 2. Konfigurasi Lingkungan Backend

Salin file konfigurasi contoh untuk backend. File ini berisi variabel lingkungan seperti port dan koneksi database.

```bash
cp backend/.env.example backend/.env
```
> (Tidak perlu mengubah isinya untuk saat ini karena sudah disesuaikan untuk Docker)

### 3. Jalankan Backend & Database via Docker

Perintah ini akan membangun dan menjalankan container untuk server Go dan database PostgreSQL di latar belakang.

```bash
docker-compose up --build -d
```

> 💡 Anda bisa melihat log backend dengan perintah: `docker-compose logs -f backend`

### 4. Jalankan Aplikasi Frontend Flutter

Buka terminal baru, masuk ke direktori frontend, dan jalankan aplikasi.

```bash
cd frontend
flutter pub get
flutter run
```

Pilih device yang tersedia (Android Emulator, iOS Simulator, Chrome, dll). Aplikasi akan otomatis terhubung ke backend yang berjalan di Docker.

## 📂 Struktur Proyek
## 📂 Struktur Proyek

```
.
├── backend/            # Kode sumber untuk Backend (Go + Echo)
│   ├── cmd/            # Titik masuk aplikasi (main.go)
│   ├── internal/       # Kode internal aplikasi
│   │   ├── handler/    # HTTP handler untuk API
│   │   ├── model/      # Definisi struktur data
│   │   ├── repository/ # Akses dan operasi database
│   │   ├── service/    # Logika bisnis aplikasi
│   │   └── util/       # Utilitas dan helper
│   ├── Dockerfile      # Konfigurasi container backend
│   ├── go.mod          # Dependency Go
│   └── .env.example    # Template konfigurasi lingkungan
├── frontend/           # Kode sumber untuk Aplikasi Mobile (Flutter)
│   ├── lib/            # Kode sumber Dart
│   │   ├── api/        # Klien API dan layanan HTTP
│   │   ├── models/     # Model data
│   │   ├── screens/    # UI aplikasi
│   │   ├── widgets/    # Komponen UI yang dapat digunakan kembali
│   │   └── main.dart   # Titik masuk aplikasi
│   ├── android/        # Konfigurasi platform Android
│   ├── ios/            # Konfigurasi platform iOS
│   └── pubspec.yaml    # Dependency Flutter
├── docker-compose.yml  # File orkestrasi untuk menjalankan backend & database
└── README.md           # Anda sedang membaca ini
```

## 📚 API Documentation

API backend diimplementasikan menggunakan RESTful principles dengan endpoint berikut:

### Auth Endpoints

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/api/auth/register` | Pendaftaran pengguna baru |
| POST | `/api/auth/login` | Login pengguna |
| POST | `/api/auth/logout` | Logout pengguna |
| GET | `/api/auth/me` | Mendapatkan informasi pengguna yang sedang login |

### Product Endpoints

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/products` | Mendapatkan daftar produk |
| GET | `/api/products/{id}` | Mendapatkan detail produk |
| POST | `/api/products` | Membuat produk baru (penjual) |
| PUT | `/api/products/{id}` | Memperbarui produk (penjual) |
| DELETE | `/api/products/{id}` | Menghapus produk (penjual) |

### Transaction Endpoints

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/transactions` | Mendapatkan riwayat transaksi |
| POST | `/api/transactions` | Membuat transaksi baru |
| GET | `/api/transactions/{id}` | Mendapatkan detail transaksi |

> 📘 **Dokumentasi API Lengkap**: Untuk dokumentasi yang lebih lengkap, jalankan server backend dan akses `/swagger/index.html`

## ⚙️ Environment Variables

### Backend Environment

Berikut adalah contoh variabel lingkungan yang digunakan pada backend:

```
# Server
PORT=8080
ENV=development

# Database
DB_HOST=postgres
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=itemin_db

# JWT
JWT_SECRET=your_secret_key
JWT_EXPIRY=24h

# File Storage
STORAGE_TYPE=s3
AWS_ACCESS_KEY=your_access_key
AWS_SECRET_KEY=your_secret_key
AWS_REGION=ap-southeast-1
AWS_BUCKET=itemin-bucket
```

## 🔄 Workflow Pengembangan

### Git Workflow

Kami menggunakan Gitflow workflow untuk pengembangan proyek ini:

1. Branch `main` berisi kode produksi yang stabil
2. Branch `develop` adalah tempat pengembangan berjalan
3. Fitur baru dikembangkan pada branch `feature/nama-fitur`
4. Perbaikan bug dilakukan pada branch `bugfix/nama-bug`
5. Release persiapan menggunakan branch `release/v1.x.x`

### Continuous Integration

Proyek ini menggunakan CI/CD untuk otomatisasi pengujian dan deployment:

- Setiap push ke branch `develop` akan memicu pengujian otomatis
- Merge ke `main` akan memicu build dan deployment ke staging
- Rilis versi baru (tag) akan men-deploy ke production

## 🤝 Kontribusi

Kontribusi dari anggota tim sangat diharapkan. Silakan ikuti alur kerja berikut:

1. Fork repository ini
2. Buat branch baru untuk fitur Anda (`git checkout -b feature/amazing-feature`)
3. Commit perubahan Anda (`git commit -m 'Add some amazing feature'`)
4. Push ke branch Anda (`git push origin feature/amazing-feature`)
5. Buka Pull Request untuk di-review

### Coding Standards

- **Backend (Go)**: Ikuti [Effective Go](https://golang.org/doc/effective_go) dan gunakan `gofmt`
- **Frontend (Flutter/Dart)**: Ikuti [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) dan gunakan `flutter analyze`

## 🐛 Issue Reporting

Jika Anda menemukan bug atau masalah, harap buat issue baru dengan informasi sebagai berikut:

1. Judul yang jelas dan deskriptif
2. Langkah-langkah untuk mereproduksi masalah
3. Perilaku yang diharapkan dan apa yang sebenarnya terjadi
4. Screenshot jika mungkin
5. Informasi lingkungan (OS, browser, device, dll.)

## 📜 Lisensi

Proyek ini dilisensikan di bawah [Lisensi MIT](LICENSE). Lihat file LICENSE untuk detail lebih lanjut.

## 📞 Kontak

- **Pengembang**: [Nama Anda](mailto:email@anda.com)
- **Website**: [website-anda.com](https://website-anda.com)
- **GitHub**: [@username](https://github.com/username)

---

<div align="center">
  <p>Dibuat dengan ❤️ oleh Tim Itemin</p>
  <p>© 2025 Itemin. Hak Cipta Dilindungi.</p>
</div>