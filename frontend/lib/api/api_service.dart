// frontend/lib/api/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

// Impor PENTING di bawah ini
import 'package:flutter/foundation.dart' show kIsWeb; // Cara resmi untuk mengecek platform web
import 'dart:io' show Platform; // Kita tetap butuh ini untuk mengecek Android

class ApiService {
  // Kita ubah ini menjadi sebuah fungsi agar bisa punya logika di dalamnya
  String getBaseUrl() {
    // Logika BARU:
    // 1. Cek dulu apakah kita sedang di web?
    if (kIsWeb) {
      // Jika ya, selalu gunakan localhost.
      return 'http://localhost:8080';
    }
    // 2. Jika BUKAN di web, baru kita aman untuk mengecek platform lain.
    else if (Platform.isAndroid) {
      // Jika ini Android, gunakan IP khusus emulator.
      return 'http://10.0.2.2:8080';
    }
    // 3. Jika bukan web dan bukan Android (misal: iOS, Windows, dll)
    else {
      return 'http://localhost:8080';
    }
  }

  // Fungsi untuk mengambil data produk dari backend.
  Future<List<Product>> fetchProducts() async {
    // Panggil fungsi getBaseUrl() untuk mendapatkan alamat yang benar
    final String baseUrl = getBaseUrl();
    final response = await http.get(Uri.parse('$baseUrl/api/v1/products'));

    if (response.statusCode == 200) { // Jika berhasil
      List<dynamic> body = jsonDecode(response.body);
      List<Product> products =
          body.map((dynamic item) => Product.fromJson(item)).toList();
      return products;
    } else {
      // Jika gagal, lemparkan error.
      throw Exception('Failed to load products');
    }
  }
}