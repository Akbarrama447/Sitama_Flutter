import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/storage_service.dart';
import '../main.dart'; // To access the global storageService
import 'dart:async'; // Untuk Timer/Future
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/auth/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    // Jalankan fungsi cek status saat halaman dibuka
    _checkStatusAndNavigate();
  }

  Future<void> _checkStatusAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));

    // 2. Cek Token using the global storageService
    String? token = await storageService.getToken();

    if (!mounted) return;

    if (token != null) {
      // Jika ada token, lempar ke Dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      // Jika tidak ada token, lempar ke Login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Warna background disesuaikan dengan warna dominan aplikasi/logo
      backgroundColor: const Color(0xFFF8F8F8), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- BAGIAN ANIMASI LOGO SITAMA ---
            // Ganti ini dengan Image.asset atau Lottie
            SizedBox(
              width: 200,
              height: 200,
              child: Image.asset(
                'assets/logo_sitama_animasi.gif', 
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}