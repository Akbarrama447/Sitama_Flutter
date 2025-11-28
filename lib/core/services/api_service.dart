// File ini untuk nyimpen semua konfigurasi API di satu tempat

class ApiService {
  // --- GANTI INI DENGAN IP LARAVEL KAMU ---
  // Gunakan '10.0.2.2' jika pakai Emulator Android
  // Gunakan IP Wifi (cth: 192.168.1.10) jika pakai HP asli
  static const String apiHost = 'http://172.16.160.154:8000';
  // ----------------------------------------

  // Nanti semua endpoint bisa kita daftarin di sini
  static const String loginUrl = '$apiHost/api/login';
  static const String profileUrl = '$apiHost/api/profil';
  static const String gantiPasswordUrl = '$apiHost/api/ganti-password';
  static const String tugasAkhirUrl = '$apiHost/api/tugas-akhir';
  // ... dst
}
