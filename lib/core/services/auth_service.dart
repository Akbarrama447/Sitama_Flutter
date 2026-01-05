import 'package:flutter/material.dart';
import '../../main.dart'; // Untuk akses storageService
import '../../features/auth/screens/login_screen.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  // Fungsi untuk logout secara konsisten di seluruh aplikasi
  Future<void> logout(BuildContext context) async {
    await storageService.deleteToken();

    // Navigasi ke login screen dan hapus semua route sebelumnya
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // Fungsi untuk mengecek apakah token masih valid
  Future<bool> isAuthenticated() async {
    final token = await storageService.getToken();
    return token != null && token.isNotEmpty;
  }
}