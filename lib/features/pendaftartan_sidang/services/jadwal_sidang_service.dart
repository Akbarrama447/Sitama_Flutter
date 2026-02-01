import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../main.dart'; // untuk mengakses storageService
import '../../../core/services/api_service.dart';
import '../models/jadwal_sidang_model.dart';
import '../models/status_pendaftaran_model.dart';

class JadwalSidangService {
  // Fungsi untuk mengambil jadwal sidang yang tersedia
  static Future<List<JadwalSidang>?> getJadwalTersedia() async {
    try {
      String? token = await storageService.getToken();
      if (token == null) {
        print('Token tidak ditemukan');
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiService.apiHost}/api/jadwal-sidang/tersedia'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        if (data['status'] == 'success' && data['data'] != null) {
          List<dynamic> jadwalList = data['data'];
          return jadwalList.map((jadwal) => JadwalSidang.fromJson(jadwal)).toList();
        } else {
          print('Gagal mengambil jadwal sidang: ${data['message'] ?? 'Unknown error'}');
          return null;
        }
      } else {
        print('Gagal mengambil jadwal sidang: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error saat mengambil jadwal sidang: $e');
      return null;
    }
  }

  // Fungsi untuk mendaftar sidang
  static Future<PendaftaranResponse?> daftarSidang({
    required String judul,
    required int jadwalSidangId,
  }) async {
    try {
      String? token = await storageService.getToken();
      if (token == null) {
        print('Token tidak ditemukan');
        return null;
      }

      final response = await http.post(
        Uri.parse('${ApiService.apiHost}/api/daftar-sidang'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'judul': judul,
          'jadwal_sidang_id': jadwalSidangId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return PendaftaranResponse.fromJson(data);
      } else {
        print('Gagal mendaftar sidang: ${response.statusCode}');
        print('Response: ${response.body}');
        Map<String, dynamic> errorData = jsonDecode(response.body);
        return PendaftaranResponse(
          status: errorData['status'] ?? 'error',
          message: errorData['message'] ?? 'Unknown error',
        );
      }
    } catch (e) {
      print('Error saat mendaftar sidang: $e');
      return PendaftaranResponse(
        status: 'error',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // Fungsi untuk mengecek status pendaftaran sidang mahasiswa
  static Future<StatusPendaftaranResponse?> getStatusPendaftaran() async {
    try {
      String? token = await storageService.getToken();
      if (token == null) {
        print('Token tidak ditemukan');
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiService.apiHost}/api/pendaftaran-sidang'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          return StatusPendaftaranResponse.fromJson(data);
        } else {
          print('Gagal mengambil status pendaftaran: ${data['message'] ?? 'Unknown error'}');
          return StatusPendaftaranResponse(
            status: 'error',
            message: data['message'] ?? 'Unknown error',
            data: null,
          );
        }
      } else {
        print('Gagal mengambil status pendaftaran: ${response.statusCode}');
        print('Response body: ${response.body}');
        Map<String, dynamic> errorData = jsonDecode(response.body);
        return StatusPendaftaranResponse(
          status: 'error',
          message: errorData['message'] ?? 'Unknown error',
          data: null,
        );
      }
    } catch (e) {
      print('Error saat mengambil status pendaftaran: $e');
      return StatusPendaftaranResponse(
        status: 'error',
        message: 'Terjadi kesalahan: ${e.toString()}',
        data: null,
      );
    }
  }
}