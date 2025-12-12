import 'dart:convert';
import 'package:http/http.dart' as http;

// File ini untuk nyimpen semua konfigurasi API di satu tempat

class ApiService {
  // --- GANTI INI DENGAN IP LARAVEL KAMU ---
  // Gunakan '10.0.2.2' jika pakai Emulator Android
  // Gunakan IP Wifi (cth: 192.168.1.10) jika pakai HP asli
  static const String apiHost = 'http://localhost:8000';
  // ----------------------------------------

  // Nanti semua endpoint bisa kita daftarin di sini
  static const String loginUrl = '$apiHost/api/login';
  static const String profileUrl = '$apiHost/api/profil';
  static const String gantiPasswordUrl = '$apiHost/api/ganti-password';
  static const String tugasAkhirUrl = '$apiHost/api/tugas-akhir';
  static const String uploadDokumenUrl = '$apiHost/api/upload-dokumen';
  // ... dst

  // Method untuk membuat tugas akhir baru
  static Future<void> createThesis({
    required String token,
    required String title,
    required String description,
    required List<String> members,
  }) async {
    // Membuat body request - pastikan field anggota selalu dikirim sebagai array, bahkan jika kosong
    final requestBody = {
      'judul': title,
      'deskripsi': description,
      'anggota': members.isEmpty
          ? []
          : members, // kirim sebagai array, bahkan jika kosong
    };

    print('Mengirim data ke API: $requestBody'); // Debug log

    final response = await http.post(
      Uri.parse(tugasAkhirUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    print('Status Code: ${response.statusCode}'); // Debug log
    print('Response Body: ${response.body}'); // Debug log

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Berhasil
      return;
    } else {
      // Gagal - coba parsing pesan error dari server
      String errorMessage = 'Gagal membuat tugas akhir';
      try {
        final responseBody = jsonDecode(response.body);
        print('Response JSON: $responseBody'); // Debug log

        if (responseBody['message'] != null) {
          errorMessage = responseBody['message'].toString();
        } else if (responseBody['errors'] != null) {
          // Jika ada validasi error, ambil pesan pertama
          if (responseBody['errors'] is Map) {
            final firstError = responseBody['errors'].values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first.toString();
            }
          }
        }
      } catch (e) {
        // Jika parsing error gagal, gunakan status code
        errorMessage = 'Error ${response.statusCode}: ${response.reasonPhrase}';
      }

      // Jika statusnya 401 (Unauthorized), beri pesan khusus
      if (response.statusCode == 401) {
        throw Exception(
            'Token tidak valid atau telah kadaluarsa. Silakan login kembali.');
      }

      throw Exception(errorMessage);
    }
  }

  // Method untuk mendapatkan detail tugas akhir
  static Future<Map<String, dynamic>> getThesis(String token) async {
    final response = await http.get(
      Uri.parse(tugasAkhirUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('GET Thesis Status Code: ${response.statusCode}'); // Debug log
    print('GET Thesis Response Body: ${response.body}'); // Debug log

    if (response.statusCode == 200) {
      // Berhasil - parsing response
      final responseBody = jsonDecode(response.body);
      return responseBody;
    } else {
      // Gagal - coba parsing pesan error dari server
      String errorMessage = 'Gagal mengambil data tugas akhir';
      try {
        final responseBody = jsonDecode(response.body);
        print('GET Thesis Response JSON: $responseBody'); // Debug log

        if (responseBody['message'] != null) {
          errorMessage = responseBody['message'].toString();
        } else if (responseBody['errors'] != null) {
          // Jika ada validasi error, ambil pesan pertama
          if (responseBody['errors'] is Map) {
            final firstError = responseBody['errors'].values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first.toString();
            }
          }
        }
      } catch (e) {
        // Jika parsing error gagal, gunakan status code
        errorMessage = 'Error ${response.statusCode}: ${response.reasonPhrase}';
      }

      // Jika statusnya 401 (Unauthorized), beri pesan khusus
      if (response.statusCode == 401) {
        throw Exception(
            'Token tidak valid atau telah kadaluarsa. Silakan login kembali.');
      }
      // Jika statusnya 404 (Not Found), beri pesan khusus
      else if (response.statusCode == 404) {
        throw Exception('Tugas akhir tidak ditemukan');
      }

      throw Exception(errorMessage);
    }
  }


}
