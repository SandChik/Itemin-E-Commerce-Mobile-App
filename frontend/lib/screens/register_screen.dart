import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Library untuk HTTP request ke backend
import 'dart:convert'; // Untuk encode/decode JSON

// Widget untuk halaman registrasi akun
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>(); // Key untuk validasi form
  final TextEditingController _emailController = TextEditingController(); // Controller input email
  final TextEditingController _passwordController = TextEditingController(); // Controller input password
  bool _isLoading = false; // Status loading saat request berlangsung
  String? _errorMessage; // Pesan error jika registrasi gagal

  // Fungsi untuk melakukan registrasi ke backend
  Future<void> _register() async {
    setState(() {
      _isLoading = true; // Tampilkan loading
      _errorMessage = null; // Reset error
    });
    final url = Uri.parse('http://localhost:8080/api/v1/register'); // Alamat endpoint backend
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'}, // Header wajib JSON
        body: jsonEncode({
          'email': _emailController.text, // Data email dari input
          'password': _passwordController.text, // Data password dari input
        }),
      );
      if (response.statusCode == 201) {
        // Jika sukses, tampilkan notifikasi dan kembali ke halaman sebelumnya
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil!')),
        );
        Navigator.pop(context);
      } else {
        // Jika gagal, tampilkan pesan error dari backend
        final data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['error'] ?? 'Registrasi gagal';
        });
      }
    } catch (e) {
      // Jika gagal koneksi ke backend
      setState(() {
        _errorMessage = 'Terjadi kesalahan koneksi';
      });
    } finally {
      setState(() {
        _isLoading = false; // Sembunyikan loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrasi Akun')), // Judul AppBar
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding seluruh halaman
        child: Form(
          key: _formKey, // Key untuk validasi form
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Tengah vertikal
            children: [
              // Input email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value == null || value.isEmpty ? 'Email wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              // Input password
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true, // Sembunyikan karakter password
                validator: (value) => value == null || value.isEmpty ? 'Password wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              // Tampilkan pesan error jika ada
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              // Tombol daftar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null // Disable tombol saat loading
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _register(); // Jalankan fungsi registrasi jika form valid
                          }
                        },
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white) // Loading spinner
                      : const Text('Daftar'), // Teks tombol
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
