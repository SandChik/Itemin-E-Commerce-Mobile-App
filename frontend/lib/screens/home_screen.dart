import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/product_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  Future<List<Product>>? futureProducts; // Variabel untuk menampung hasil dari API

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
        title: const Text('Itemin - Produk Digital'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            child: const Text('Daftar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Center(
        // FutureBuilder adalah widget canggih untuk menampilkan data dari API.
        child: FutureBuilder<List<Product>>(
          future: futureProducts, // Sumber datanya dari sini
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Jika masih loading, tampilkan ikon berputar.
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              // Jika ada error, tampilkan pesan error.
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              // Jika data sudah ada, tampilkan dalam bentuk list.
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Product product = snapshot.data![index];
                  return ListTile(
                    leading: CircleAvatar(child: Text(product.id.substring(1))),
                    title: Text(product.name),
                    subtitle: Text('ID Produk: ${product.id}'),
                  );
                },
              );
            } else {
              // Jika tidak ada apa-apa
              return const Text('Tidak ada produk.');
            }
          },
        ),
      ),
    );
  }
}