// go.mod
// File ini adalah file modul utama untuk project Go kamu.
// Fungsinya untuk mendefinisikan nama modul, versi Go, dan semua dependensi (library) yang digunakan project.

module itemin.app/backend // Nama modul/project Go kamu (bisa diubah sesuai kebutuhan)

go 1.24.4 // Versi minimum Go yang digunakan project ini

require (
	github.com/jackc/pgx/v5 v5.5.4           // Library utama untuk koneksi PostgreSQL
	github.com/labstack/echo/v4 v4.13.4       // Framework web Echo untuk membuat REST API
	golang.org/x/crypto v0.38.0               // Library untuk fungsi kriptografi (misal: hash password)
)

require (
	github.com/jackc/pgpassfile v1.0.0 // indirect         // Dependensi tidak langsung (dibutuhkan oleh pgx)
	github.com/jackc/pgservicefile v0.0.0-20221227161230-091c0ba34f0a // indirect
	github.com/jackc/puddle/v2 v2.2.1 // indirect
	github.com/labstack/gommon v0.4.2 // indirect
	github.com/mattn/go-colorable v0.1.14 // indirect
	github.com/mattn/go-isatty v0.0.20 // indirect
	github.com/valyala/bytebufferpool v1.0.0 // indirect
	github.com/valyala/fasttemplate v1.2.2 // indirect
	golang.org/x/net v0.40.0 // indirect
	golang.org/x/sync v0.14.0 // indirect
	golang.org/x/sys v0.33.0 // indirect
	golang.org/x/text v0.25.0 // indirect
	golang.org/x/time v0.11.0 // indirect
)

// Keterangan:
// - Bagian require pertama adalah dependensi utama yang kamu gunakan langsung di kode.
// - Bagian require kedua (indirect) adalah dependensi yang dibutuhkan oleh library lain (tidak kamu import langsung).
// - File ini dikelola otomatis oleh Go. Jangan edit manual kecuali paham, gunakan 'go get', 'go mod tidy', dll.
