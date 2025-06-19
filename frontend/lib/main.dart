import 'package:flutter/material.dart';
import 'package:frontend/screens/home_screen.dart'; // Impor layar home kita


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
      home: const HomeScreen(), // Layar pertama yang ditampilkan adalah HomeScreen
    );
  }
}