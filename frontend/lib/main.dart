import 'package:flutter/material.dart';
import 'package:frontend/screens/home_screen.dart'; // Impor layar home kita
import 'package:frontend/screens/register_screen.dart'; // Impor layar register kita

// Fungsi utama yang pertama kali dijalankan saat aplikasi Flutter dimulai
void main() {
  runApp(const MyApp()); // Menjalankan widget utama aplikasi
}

// Widget utama aplikasi, bertanggung jawab untuk setup tema dan routing
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Itemin App', // Judul aplikasi (muncul di task switcher)
      theme: ThemeData(
        primarySwatch: Colors.blue, // Warna utama aplikasi
        brightness: Brightness.dark, // Tema gelap agar keren
      ),
      home: const HomeScreen(), // Layar pertama yang ditampilkan adalah HomeScreen
      routes: {
        // Daftar route (alamat layar) yang bisa diakses di aplikasi
        // '/register' akan membuka RegisterScreen
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}