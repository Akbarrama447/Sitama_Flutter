import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'core/services/storage_service.dart'; // Import service kita
import 'widgets/splash_screen.dart';
// PENTING: Buat instance storage service secara global agar gampang diakses
// Kita akan inisialisasi di main()
late StorageService storageService;

void main() async {
  // Pastikan semua widget siap sebelum app jalan
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi localization untuk format tanggal
  await initializeDateFormatting('id_ID', null);
  
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

    final ColorScheme kColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1565C0), // Biru tua (sesuai desain)
    );

    return MaterialApp(
      title: 'Aplikasi Mahasiswa',
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Indonesian
        Locale('en', 'US'), // English
      ],
      locale: const Locale('id', 'ID'), // Set Indonesian as default
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
      
     routes: {
    '/login': (context) => const LoginScreen(),
    '/dashboard': (context) => const DashboardScreen(), // Pastikan nama routenya sesuai
  },
    );
  }
}
