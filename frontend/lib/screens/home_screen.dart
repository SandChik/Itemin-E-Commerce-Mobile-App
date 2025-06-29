import 'package:flutter/material.dart';
import '../api/api_service.dart'; // Import service untuk request ke API backend
import '../models/product_model.dart'; // Import model produk

// Widget utama untuk halaman Home (daftar produk)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService(); // Instance service API
  Future<List<Product>>? futureProducts; // Variabel untuk menampung hasil dari API (asynchronous)

  @override
  void initState() {
    super.initState();
    // Panggil API saat layar pertama kali dimuat
    futureProducts = apiService.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itemin - Produk Digital'), // Judul di AppBar
        actions: [
          // Tombol "Daftar" di pojok kanan atas untuk navigasi ke halaman registrasi
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register'); // Navigasi ke route '/register'
            },
            child: const Text('Daftar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Center(
        // FutureBuilder: widget untuk menampilkan data asynchronous dari API
        child: FutureBuilder<List<Product>>(
          future: futureProducts, // Sumber data future dari API
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Jika masih loading, tampilkan loading spinner
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              // Jika ada error saat request API, tampilkan pesan error
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              // Jika data sudah ada, tampilkan dalam bentuk list
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Product product = snapshot.data![index];
                  return ListTile(
                    leading: CircleAvatar(child: Text(product.id.substring(1))), // Avatar dengan ID produk
                    title: Text(product.name), // Nama produk
                    subtitle: Text('ID Produk: ${product.id}'), // ID produk
                  );
                },
              );
            } else {
              // Jika tidak ada data sama sekali
              return const Text('Tidak ada produk.');
            }
          },
        ),
      ),
    );
  }
}