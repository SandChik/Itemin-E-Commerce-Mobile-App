import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'package:frontend/screens/home_screen.dart'; // Impor layar home kita
=======
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/register_screen.dart';
import 'package:frontend/screens/welcome_screen.dart';
>>>>>>> Stashed changes


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Itemin App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark, // Tema gelap agar keren
      ),
<<<<<<< Updated upstream
      home: const HomeScreen(), // Layar pertama yang ditampilkan adalah HomeScreen
=======
      home:
          const WelcomeScreen(), // Layar pertama yang ditampilkan adalah HomeScreen
      routes: {
        // Daftar route (alamat layar) yang bisa diakses di aplikasi
        '/welcome': (context) => const WelcomeScreen(),
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const RegisterScreen(),
      },
>>>>>>> Stashed changes
    );
  }
}
