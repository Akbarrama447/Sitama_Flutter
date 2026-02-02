import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // --- KONFIGURASI HOST ---
  // localhost -> Browser | 10.0.2.2 -> Emulator | IP WiFi -> HP Asli

  // endpoint local untuk development = http://localhost:8000
  // endpoint production = https://sitamanext.informatikapolines.id


  static const String apiHost = 'https://sitamanext.informatikapolines.id';
  static const String baseUrl = '$apiHost/api';
  // ----------------------------------------
  // --- ENDPOINTS ---
  static const String loginUrl = '$baseUrl/login';
  static const String profileUrl = '$baseUrl/profil';
  static const String gantiPasswordUrl = '$baseUrl/ganti-password';
  static const String tugasAkhirUrl = '$baseUrl/tugas-akhir';
  static const String uploadDokumenUrl = '$baseUrl/upload-dokumen';
  static const String uploadRevisiUrl = '$baseUrl/upload-revisi-file';

  // --- 1. LOGIN ---
  static Future<Map<String, dynamic>> login(String? email, String? password) async {
  // 1. Cek Input. Pakai String? (nullable) dulu biar gak crash di pintu masuk
  print("DEBUG LOGIN: Email: $email, Password: $password");

  if (email == null || password == null) {
    throw Exception("Email atau Password tidak boleh kosong!");
  }

  try {
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    print("DEBUG STATUS: ${response.statusCode}");
    print("DEBUG BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Handle kalau response bukan JSON valid
      try {
        final error = jsonDecode(response.body);
        // Pastikan ambil message dengan aman
        final message = error['message']?.toString() ?? 'Login gagal (Unknown Error)';
        throw Exception(message);
      } catch (e) {
        // Kalau jsonDecode gagal (misal error HTML dari server), throw body mentah
        throw Exception("Server Error: ${response.statusCode}");
      }
    }
  } catch (e) {
    print("DEBUG ERROR: $e");
    rethrow; // Lempar error ke UI biar muncul di dialog
  }
}

  // --- 2. AMBIL DATA TUGAS AKHIR ---
  static Future<Map<String, dynamic>> getThesis(String token) async {
    final response = await http.get(
      Uri.parse(tugasAkhirUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Gagal mengambil data tugas akhir (Error: ${response.statusCode})');
    }
  }

  // --- 3. BUAT TUGAS AKHIR BARU ---
  static Future<void> createThesis({
    required String token,
    required String title,
    required String description,
    required List<String> members,
  }) async {
    final requestBody = {
      'judul': title,
      'deskripsi': description,
      'anggota': members.isEmpty ? [] : members,
    };

    final response = await http.post(
      Uri.parse(tugasAkhirUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Gagal membuat tugas akhir');
    }
  }

  // --- 4. GANTI PASSWORD ---
  static Future<void> changePassword(
      String token, String oldPass, String newPass) async {
    final response = await http.post(
      Uri.parse(gantiPasswordUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'old_password': oldPass,
        'new_password': newPass,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengganti password');
    }
  }

  // --- 5. AMBIL PROFIL USER ---
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse(profileUrl),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengambil data profil');
    }
  }

  // --- 6. UPLOAD DOKUMEN ---
  // Note: Untuk upload file biasanya pakai http.MultipartRequest
  static Future<void> uploadDocument(String token, String filePath) async {
    // Implementasi Multipart bisa ditambahkan di sini nanti
    print('Fitur upload dokumen untuk path: $filePath sedang diproses');
  }

  static const String mahasiswaUrl = '$baseUrl/mahasiswa';
  static const String logBimbinganUrl = '$baseUrl/log-bimbingan';
  static const String pembimbingUrl = '$baseUrl/pembimbing';

  static Future<List<dynamic>> getStudents(String token) async {
    final response = await http.get(
      Uri.parse(mahasiswaUrl),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Mengharapkan array mahasiswa
    } else {
      throw Exception('Gagal mengambil daftar mahasiswa');
    }
  }

  // Fungsi untuk mengambil data log bimbingan
  static Future<List<dynamic>> getLogBimbingan(String token, {int? urutan}) async {
    String url = logBimbinganUrl;
    if (urutan != null) {
      url += '?urutan=$urutan';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'] ?? jsonDecode(response.body); // Mengharapkan array log bimbingan
    } else {
      throw Exception('Gagal mengambil data log bimbingan');
    }
  }

  // Fungsi untuk mengambil data pembimbing
  static Future<List<dynamic>> getPembimbing(String token) async {
    final response = await http.get(
      Uri.parse(pembimbingUrl),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'] ?? jsonDecode(response.body); // Mengharapkan array pembimbing
    } else {
      throw Exception('Gagal mengambil data pembimbing');
    }
  }
}
