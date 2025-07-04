-- ===================================================================
-- ITEMIN DATABASE MIGRATION FILE
-- ===================================================================
-- File ini berisi perintah SQL untuk membuat tabel di database PostgreSQL.
-- File ini dijalankan otomatis saat container backend start (melalui entrypoint.sh).
-- Tujuannya agar struktur database selalu siap sebelum aplikasi Go berjalan.

-- ===================================================================
-- EKSTENSI YANG DIBUTUHKAN
-- ===================================================================

-- Pastikan ekstensi UUID tersedia untuk menghasilkan UUID secara otomatis
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Ekstensi untuk full-text search (memungkinkan pencarian produk yang lebih baik)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ===================================================================
-- TIPE ENUM
-- ===================================================================

-- Membuat tipe enum untuk role user
CREATE TYPE user_role AS ENUM ('buyer', 'seller', 'admin');

-- Membuat tipe enum untuk status order
CREATE TYPE order_status AS ENUM ('pending', 'paid', 'processing', 'completed', 'failed', 'cancelled', 'refunded');

-- Membuat tipe enum untuk status fulfillment
CREATE TYPE fulfillment_status AS ENUM ('pending', 'processing', 'success', 'failed', 'cancelled');

-- Membuat tipe enum untuk status penarikan
CREATE TYPE withdrawal_status AS ENUM ('pending', 'processed', 'rejected', 'cancelled');

-- Membuat tipe enum untuk metode pembayaran
CREATE TYPE payment_method AS ENUM ('bank_transfer', 'e_wallet', 'virtual_account', 'credit_card', 'qris', 'balance');

-- Membuat tipe enum untuk tipe notifikasi
CREATE TYPE notification_type AS ENUM ('transaction', 'system', 'promotion', 'account');

-- ===================================================================
-- TABEL UTAMA
-- ===================================================================

-- Tabel Users: Menyimpan data pengguna aplikasi
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    phone_number VARCHAR(20),
    role user_role NOT NULL DEFAULT 'buyer',
    email_verified_at TIMESTAMP,
    phone_verified_at TIMESTAMP,
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP,
    last_login_ip VARCHAR(45),  -- Mendukung IPv6
    reset_password_token TEXT,
    reset_password_expires_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP
);

-- Tabel Wallet: Menyimpan data saldo pengguna
CREATE TABLE IF NOT EXISTS wallets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    balance DECIMAL(15, 2) NOT NULL DEFAULT 0,
    total_income DECIMAL(15, 2) NOT NULL DEFAULT 0,  -- Total pendapatan sepanjang waktu
    total_withdrawn DECIMAL(15, 2) NOT NULL DEFAULT 0,  -- Total penarikan sepanjang waktu
    last_transaction_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT positive_balance CHECK (balance >= 0)
);

-- Tabel Wallet Transactions: Menyimpan riwayat transaksi wallet
CREATE TABLE IF NOT EXISTS wallet_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount DECIMAL(15, 2) NOT NULL,
    type VARCHAR(20) NOT NULL,  -- 'credit', 'debit'
    description TEXT NOT NULL,
    reference_id UUID,  -- ID transaksi terkait (order_id, withdrawal_id, dll)
    reference_type VARCHAR(30),  -- 'order', 'withdrawal', 'refund', dll
    balance_before DECIMAL(15, 2) NOT NULL,
    balance_after DECIMAL(15, 2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT valid_amount CHECK (amount <> 0)
);

-- Tabel Kategori Produk: Mengkategorikan produk yang dijual
CREATE TABLE IF NOT EXISTS product_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    icon_url TEXT,
    image_url TEXT,
    description TEXT,
    parent_id INTEGER REFERENCES product_categories(id) ON DELETE SET NULL,
    is_featured BOOLEAN DEFAULT FALSE,
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Tabel Produk: Menyimpan data produk yang dijual
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    seller_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id INTEGER NOT NULL REFERENCES product_categories(id) ON DELETE RESTRICT,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    short_description VARCHAR(500),
    sku VARCHAR(50) UNIQUE NOT NULL,
    price DECIMAL(15, 2) NOT NULL,
    discount_price DECIMAL(15, 2),
    stock INTEGER NOT NULL DEFAULT 0,
    image_url TEXT,
    image_urls JSONB,  -- Array gambar tambahan
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    fulfillment_fields JSONB, -- Deskripsi field yang dibutuhkan (misal: {"user_id": "required", "server_id": "required"})
    fulfillment_instructions TEXT,  -- Instruksi untuk pembeli
    total_sales INTEGER DEFAULT 0,  -- Jumlah penjualan untuk perhitungan popularitas
    avg_rating DECIMAL(3, 2) DEFAULT 0,  -- Rating rata-rata dari review
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP,
    CONSTRAINT positive_price CHECK (price > 0),
    CONSTRAINT valid_discount CHECK (discount_price IS NULL OR (discount_price > 0 AND discount_price < price))
);

-- Tabel Product Tags: Untuk menambahkan tag pada produk (many-to-many)
CREATE TABLE IF NOT EXISTS product_tags (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    slug VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Tabel Product-Tag Relationship
CREATE TABLE IF NOT EXISTS product_tag_relations (
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    tag_id INTEGER NOT NULL REFERENCES product_tags(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, tag_id)
);

-- Tabel Orders: Menyimpan data pesanan
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    buyer_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    total_amount DECIMAL(15, 2) NOT NULL,
    discount_amount DECIMAL(15, 2) DEFAULT 0,
    final_amount DECIMAL(15, 2) NOT NULL,
    status order_status NOT NULL DEFAULT 'pending',
    payment_method payment_method,
    payment_gateway VARCHAR(50),
    payment_gateway_ref VARCHAR(100),
    payment_proof_url TEXT,  -- Untuk upload bukti transfer
    payment_expired_at TIMESTAMP,
    paid_at TIMESTAMP,
    processing_at TIMESTAMP,
    completed_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    refunded_at TIMESTAMP,
    cancellation_reason TEXT,
    notes TEXT,  -- Catatan pembeli
    admin_notes TEXT,  -- Catatan admin
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT positive_total CHECK (total_amount > 0),
    CONSTRAINT valid_final_amount CHECK (final_amount > 0 AND final_amount <= total_amount)
);

-- Tabel Order Items: Menyimpan detail item dalam pesanan
CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    seller_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL DEFAULT 1,
    price_per_item DECIMAL(15, 2) NOT NULL,
    discount_amount DECIMAL(15, 2) DEFAULT 0,
    subtotal DECIMAL(15, 2) NOT NULL,
    fulfillment_target JSONB NOT NULL, -- Untuk menyimpan data target pengiriman (misal: {"user_id": "12345", "server_id": "789"})
    fulfillment_status fulfillment_status DEFAULT 'pending',
    fulfillment_error TEXT,
    fulfillment_details JSONB, -- Untuk menyimpan data hasil pengiriman
    fulfillment_at TIMESTAMP,
    seller_revenue DECIMAL(15, 2),  -- Jumlah yang diterima penjual
    platform_fee DECIMAL(15, 2),  -- Jumlah fee platform
    is_reviewed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT positive_quantity CHECK (quantity > 0),
    CONSTRAINT positive_price_per_item CHECK (price_per_item > 0),
    CONSTRAINT valid_subtotal CHECK (subtotal = (price_per_item * quantity) - discount_amount)
);

-- Tabel Order History: Menyimpan riwayat perubahan status pesanan
CREATE TABLE IF NOT EXISTS order_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    status order_status NOT NULL,
    notes TEXT,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,  -- Siapa yang mengubah status (bisa admin, sistem, user)
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Tabel Rekening Bank Penjual: Menyimpan data rekening untuk penarikan dana
CREATE TABLE IF NOT EXISTS seller_bank_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    seller_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    bank_name VARCHAR(100) NOT NULL,
    bank_code VARCHAR(20) NOT NULL,  -- Kode bank untuk integrasi dengan payment gateway
    account_number VARCHAR(50) NOT NULL,
    account_holder_name VARCHAR(255) NOT NULL,
    branch VARCHAR(100),
    is_primary BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    verification_proof TEXT,  -- Bukti verifikasi admin
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(seller_id, bank_name, account_number)
);

-- Tabel Penarikan Dana: Menyimpan data penarikan dana penjual
CREATE TABLE IF NOT EXISTS withdrawals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    seller_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    bank_account_id UUID NOT NULL REFERENCES seller_bank_accounts(id) ON DELETE RESTRICT,
    amount DECIMAL(15, 2) NOT NULL,
    fee DECIMAL(15, 2) DEFAULT 0,
    final_amount DECIMAL(15, 2) NOT NULL,
    status withdrawal_status NOT NULL DEFAULT 'pending',
    admin_note TEXT,
    seller_note TEXT,
    transfer_proof_url TEXT,
    processed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    processed_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    rejected_at TIMESTAMP,
    cancellation_reason TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT positive_amount CHECK (amount > 0),
    CONSTRAINT valid_final_amount CHECK (final_amount = amount - fee)
);

-- Tabel Withdrawal History: Menyimpan riwayat perubahan status penarikan
CREATE TABLE IF NOT EXISTS withdrawal_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    withdrawal_id UUID NOT NULL REFERENCES withdrawals(id) ON DELETE CASCADE,
    status withdrawal_status NOT NULL,
    notes TEXT,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Tabel Review dan Rating: Menyimpan ulasan dan rating produk
CREATE TABLE IF NOT EXISTS reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_item_id UUID NOT NULL REFERENCES order_items(id) ON DELETE CASCADE,
    buyer_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    seller_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    reply TEXT,  -- Balasan dari penjual
    reply_at TIMESTAMP,
    image_urls JSONB,  -- Array URL gambar yang diupload oleh pembeli
    is_visible BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,  -- Untuk highlight review tertentu
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(order_item_id) -- Satu item order hanya bisa di-review sekali
);

-- Tabel Notifikasi: Menyimpan notifikasi untuk pengguna
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type notification_type NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    reference_id UUID, -- ID yang direferensikan (order_id, withdrawal_id, etc.)
    reference_type VARCHAR(50), -- orders, withdrawals, etc.
    image_url TEXT,  -- Gambar notifikasi (opsional)
    action_url TEXT,  -- URL yang akan dibuka jika notifikasi di-klik
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    expiry_at TIMESTAMP  -- Kapan notifikasi kedaluwarsa (opsional)
);

-- Tabel Device Tokens: Menyimpan token perangkat untuk push notification
CREATE TABLE IF NOT EXISTS device_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_token TEXT NOT NULL,
    device_type VARCHAR(20) NOT NULL, -- 'android', 'ios', 'web'
    is_active BOOLEAN DEFAULT TRUE,
    last_used_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, device_token)
);

-- Tabel Sistem Settings: Menyimpan pengaturan sistem
CREATE TABLE IF NOT EXISTS system_settings (
    id SERIAL PRIMARY KEY,
    key VARCHAR(100) UNIQUE NOT NULL,
    value TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Tabel API Logs: Menyimpan log API untuk debugging dan monitoring
CREATE TABLE IF NOT EXISTS api_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    method VARCHAR(10) NOT NULL,
    path TEXT NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    ip_address VARCHAR(45) NOT NULL,
    user_agent TEXT,
    request_body JSONB,
    response_code INTEGER,
    response_time DECIMAL(10, 2), -- Dalam milliseconds
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    fcm_token TEXT UNIQUE NOT NULL, -- Firebase Cloud Messaging Token
    device_type VARCHAR(20), -- 'android', 'ios'
    last_login_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_user_devices_user_id ON user_devices(user_id);

CREATE TABLE IF NOT EXISTS user_favorites (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (user_id, product_id) -- Mencegah duplikasi
);
-- ===================================================================
-- INDEKS UNTUK MENINGKATKAN PERFORMA QUERY
-- ===================================================================

-- Users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_phone_number ON users(phone_number);
CREATE INDEX idx_users_created_at ON users(created_at);

-- Wallets
CREATE INDEX idx_wallets_user_id ON wallets(user_id);
CREATE INDEX idx_wallets_balance ON wallets(balance);

-- Wallet Transactions
CREATE INDEX idx_wallet_transactions_wallet_id ON wallet_transactions(wallet_id);
CREATE INDEX idx_wallet_transactions_user_id ON wallet_transactions(user_id);
CREATE INDEX idx_wallet_transactions_type ON wallet_transactions(type);
CREATE INDEX idx_wallet_transactions_created_at ON wallet_transactions(created_at);
CREATE INDEX idx_wallet_transactions_reference ON wallet_transactions(reference_id, reference_type);

-- Product Categories
CREATE INDEX idx_product_categories_parent_id ON product_categories(parent_id);
CREATE INDEX idx_product_categories_is_active ON product_categories(is_active);

-- Products
CREATE INDEX idx_products_seller_id ON products(seller_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_slug ON products(slug);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_is_active ON products(is_active);
CREATE INDEX idx_products_is_featured ON products(is_featured);
CREATE INDEX idx_products_created_at ON products(created_at);
CREATE INDEX idx_products_avg_rating ON products(avg_rating);
CREATE INDEX idx_products_total_sales ON products(total_sales);
-- Full Text Search index untuk produk
CREATE INDEX idx_products_search ON products USING gin (to_tsvector('indonesian', name || ' ' || COALESCE(description, '')));
CREATE INDEX idx_products_search_english ON products USING gin (to_tsvector('english', name || ' ' || COALESCE(description, '')));

-- Product Tags
CREATE INDEX idx_product_tags_slug ON product_tags(slug);

-- Orders
CREATE INDEX idx_orders_buyer_id ON orders(buyer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_orders_order_number ON orders(order_number);
CREATE INDEX idx_orders_payment_method ON orders(payment_method);
CREATE INDEX idx_orders_payment_gateway_ref ON orders(payment_gateway_ref);

-- Order Items
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_order_items_seller_id ON order_items(seller_id);
CREATE INDEX idx_order_items_fulfillment_status ON order_items(fulfillment_status);

-- Order History
CREATE INDEX idx_order_history_order_id ON order_history(order_id);
CREATE INDEX idx_order_history_status ON order_history(status);
CREATE INDEX idx_order_history_created_at ON order_history(created_at);

-- Seller Bank Accounts
CREATE INDEX idx_bank_accounts_seller_id ON seller_bank_accounts(seller_id);

-- Withdrawals
CREATE INDEX idx_withdrawals_seller_id ON withdrawals(seller_id);
CREATE INDEX idx_withdrawals_status ON withdrawals(status);
CREATE INDEX idx_withdrawals_created_at ON withdrawals(created_at);

-- Withdrawal History
CREATE INDEX idx_withdrawal_history_withdrawal_id ON withdrawal_history(withdrawal_id);
CREATE INDEX idx_withdrawal_history_status ON withdrawal_history(status);

-- Reviews
CREATE INDEX idx_reviews_product_id ON reviews(product_id);
CREATE INDEX idx_reviews_seller_id ON reviews(seller_id);
CREATE INDEX idx_reviews_buyer_id ON reviews(buyer_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_reviews_created_at ON reviews(created_at);
CREATE INDEX idx_reviews_is_featured ON reviews(is_featured);

-- Notifications
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_reference ON notifications(reference_id, reference_type);

-- Device Tokens
CREATE INDEX idx_device_tokens_user_id ON device_tokens(user_id);
CREATE INDEX idx_device_tokens_device_type ON device_tokens(device_type);

-- API Logs
CREATE INDEX idx_api_logs_user_id ON api_logs(user_id);
CREATE INDEX idx_api_logs_path ON api_logs(path);
CREATE INDEX idx_api_logs_created_at ON api_logs(created_at);
CREATE INDEX idx_api_logs_response_code ON api_logs(response_code);

CREATE INDEX idx_user_devices_user_id ON user_devices(user_id);

-- ===================================================================
-- DATA AWAL & PENGATURAN SISTEM
-- ===================================================================

-- Pengaturan sistem awal
INSERT INTO system_settings (key, value, description)
VALUES 
    ('platform_fee_percentage', '5.0', 'Persentase fee yang diambil platform dari setiap transaksi'),
    ('min_withdrawal_amount', '50000', 'Jumlah minimum penarikan dana (dalam Rupiah)'),
    ('withdrawal_fee', '6500', 'Biaya administrasi penarikan dana (dalam Rupiah)'),
    ('maintenance_mode', 'false', 'Status mode maintenance sistem'),
    ('version', '1.0.0', 'Versi aplikasi saat ini');

-- Kategori produk awal
INSERT INTO product_categories (name, slug, description, is_active, display_order)
VALUES 
    ('Game Voucher', 'game-voucher', 'Voucher untuk berbagai game online', true, 1),
    ('Jasa Joki', 'jasa-joki', 'Layanan joki untuk berbagai game online', true, 2),
    ('Akun Game', 'akun-game', 'Akun game berbagai platform', true, 3),
    ('Item Game', 'item-game', 'Item dan skin game', true, 4);

-- ===================================================================
-- KOMENTAR MENGENAI PERFORMA DATABASE
-- ===================================================================

-- 1. Gunakan EXPLAIN ANALYZE untuk menganalisis query kompleks
-- 2. Pertimbangkan penggunaan partisi untuk tabel besar (seperti api_logs)
-- 3. Selalu gunakan prepared statements untuk menghindari SQL injection
-- 4. Buat maintenance routine untuk membersihkan data lama (api_logs, notifications)
-- 5. Untuk query produk yang sering, pertimbangkan materialized view
-- 6. Perhatikan jumlah indeks, terlalu banyak indeks dapat mempengaruhi performa INSERT/UPDATE
-- 7. Lakukan vacuum dan analyze secara berkala untuk menjaga performa
-- 8. Pertimbangkan menggunakan caching untuk data yang sering diakses tapi jarang berubah
