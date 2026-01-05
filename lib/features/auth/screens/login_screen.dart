import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../main.dart'; // Untuk akses storageService
import '../../../core/services/api_service.dart';
import '../../../widgets/splash_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import 'ganti_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  // --- LOGIKA LOGIN YANG SUDAH DIPERBAIKI ---
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Memanggil ApiService yang sudah diperbaiki sebelumnya
      final responseBody = await ApiService.login(
        _emailController.text,
        _passwordController.text,
      );

      // Ambil data dari response (Sesuai JSON Laravel kamu)
      final token = responseBody['token']; // Pakai access_token, bukan token
      final userData = responseBody['user'];

      // Simpan ke storage
      await storageService.saveToken(token);
      
      if (userData != null && userData['name'] != null) {
        // Pakai 'name', sesuai JSON: "name": "Wika Dwi Aprilia"
        await storageService.saveUserName(userData['name']);
      }

      // --- REDIRECT TO SPLASH SCREEN FIRST, THEN TO DASHBOARD ---
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SplashScreen()),
        );
      }
    } catch (e) {
      // Menangkap error dari ApiService (401, 500, atau koneksi)
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      _showErrorDialog(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper untuk nampilin dialog error
  void _showErrorDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Login Gagal'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Konten Login
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    Image.asset(
                      'assets/sitama.png',
                      height: 180,
                      width: 180,
                      fit: BoxFit.contain,
                    ),
                    
                    const SizedBox(height: 0),
                  
                    Text(
                      'Sistem Informasi Tugas Akhir Mahasiswa',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: size.height * 0.05),

                    const SizedBox(height: 32),
                    // Form Email
                    TextFormField(
                      controller: _emailController,
                      decoration: _buildInputDecoration(
                        'Alamat Email',
                        Icons.email_outlined,
                        hintText: 'Masukkan email anda',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty ||
                            !value.contains('@')) {
                          return 'Masukkan email yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Form Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: _buildInputDecoration(
                        'Password',
                        Icons.lock_outline,
                        hintText: 'Masukkan password anda',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Baris "Ingat Saya" & "Lupa Password"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                            ),
                            const Text('Ingat Saya'),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const GantiPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text('Lupa password?'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Tombol Login
                    const SizedBox(height: 8),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Container(
                            width: double.infinity,
                            height: 55,
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 116, 165, 250),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Masuk',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk styling Tampilan Input
  InputDecoration _buildInputDecoration(
    String label,
    IconData prefixIcon, {
    Widget? suffixIcon,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, color: Colors.grey[600]),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
      labelStyle: TextStyle(color: Colors.grey[600]),
      hintStyle: TextStyle(color: Colors.grey[400]),
    );
  }
}