import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'core/services/storage_service.dart'; // Import service kita

// PENTING: Buat instance storage service secara global agar gampang diakses
// Kita akan inisialisasi di main()
late StorageService storageService;

void main() async {
  // Pastikan semua widget siap sebelum app jalan
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi service penyimpanan
  final prefs = await SharedPreferences.getInstance();
  storageService = StorageService(prefs);

  // Cek token
  final token = await storageService.getToken();

  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;
  const MyApp({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    // Tentukan tema warna utama
    final ColorScheme kColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1565C0), // Biru tua (sesuai desain)
    );

    return MaterialApp(
      title: 'Aplikasi Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: kColorScheme,
        useMaterial3: true,
        // Tema AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: kColorScheme.primary,
          foregroundColor: kColorScheme.onPrimary, // Warna teks (putih)
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Tema Tombol
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kColorScheme.primary,
            foregroundColor: kColorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Tema Input Teks
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: kColorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: kColorScheme.primary, width: 2),
          ),
          labelStyle: TextStyle(color: kColorScheme.onSurfaceVariant),
        ),
      ),
      // --- Logika Navigasi Awal ---
      // Jika token ada (tidak null), langsung ke Dashboard
      // Jika token null, ke Halaman Login
      home: token != null ? const DashboardScreen() : const LoginScreen(),
    );
  }
}
