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
  final TextEditingController _confirmPasswordController = TextEditingController(); // Controller input konfirmasi password
  bool _isLoading = false; // Status loading saat request berlangsung
  String? _errorMessage; // Pesan error jika registrasi gagal
  bool _obscurePassword = true; // Status untuk show/hide password
  bool _obscureConfirmPassword = true; // Status untuk show/hide konfirmasi password

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
        // Jika sukses, tampilkan notifikasi dan pindah ke HomeScreen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil!')),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false); // Pindah ke Home dan hapus semua route sebelumnya
        return; // Hentikan eksekusi agar tidak lanjut ke blok finally
      } else {
        // Jika gagal, tampilkan pesan error dari backend
        final data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['error'] ?? 'Registrasi gagal';
        });
      }
    } catch (e) {
      // Jika gagal koneksi ke backend
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan koneksi';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false; // Sembunyikan loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2331), // Warna latar belakang utama
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/welcome');
          },
        ), // Tombol back custom
        title: const Text('Registrasi Akun'),
        backgroundColor: const Color(0xFF1C2331), // Samakan warna AppBar dengan background
        elevation: 0, // Hilangkan shadow agar lebih rata
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
        ),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Image.asset(
              'assets/images/logo_itemin.png', // Gambar logo Itemin
              height: 200, // Tinggi gambar
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Padding seluruh halaman
                child: Form(
                  key: _formKey, // Key untuk validasi form
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Tengah vertikal
                    children: [
                      // Input email
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.black), // Warna teks input
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.black), // Warna label
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Email wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      // Input password
                      TextFormField(
                        controller: _passwordController,
                        style: const TextStyle(color: Colors.black), // Warna teks input
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.black), // Warna label
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword, // Sembunyikan karakter password
                        validator: (value) => value == null || value.isEmpty ? 'Password wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      // Input konfirmasi password
                      TextFormField(
                        controller: _confirmPasswordController,
                        style: const TextStyle(color: Colors.black), // Warna teks input
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi Password',
                          labelStyle: const TextStyle(color: Colors.black), // Warna label
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Konfirmasi password wajib diisi';
                          if (value != _passwordController.text) return 'Password tidak sama';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // Tampilkan pesan error jika ada
                      if (_errorMessage != null)
                        Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      // Tombol daftar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Warna biru untuk tombol
                            foregroundColor: Colors.white, // Warna teks putih
                          ),
                          onPressed: _isLoading
                              ? null // Disable tombol saat loading
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    _register(); // Jalankan fungsi registrasi jika form valid
                                  }
                                },
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white) // Loading spinner
                              : const Text('SIGN UP'), // Teks tombol
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'ALREADY HAVE AN ACCOUNT?',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: const Text(
                              'LOG IN',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
