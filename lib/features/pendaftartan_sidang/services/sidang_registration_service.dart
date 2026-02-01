import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../main.dart'; // untuk mengakses storageService
import '../../../core/services/api_service.dart';

class SidangRegistrationService {
  // Fungsi untuk mendaftarkan sidang
  static Future<Map<String, dynamic>?> registerSidang({
    required String judulTa,
    required String jadwalSidang,
  }) async {
    try {
      String? token = await storageService.getToken();
      if (token == null) {
        print('Token tidak ditemukan');
        return null;
      }

      // Format tanggal dan jam dari jadwalSidang (format: "01-12-2025, Senin 13.00-15.00")
      // Misalnya kita ekstrak jadi: tanggal="2025-12-01", jam_mulai="13:00", jam_selesai="15:00"
      String tanggal = "";
      String jamMulai = "";
      String jamSelesai = "";
      
      // Parsing string jadwal
      if (jadwalSidang.contains(',')) {
        String tanggalPart = jadwalSidang.split(',')[0].trim();
        String waktuPart = jadwalSidang.split(',')[1].trim();
        
        // Ubah format tanggal dari DD-MM-YYYY ke YYYY-MM-DD
        List<String> tanggalParts = tanggalPart.split('-');
        if (tanggalParts.length == 3) {
          tanggal = "${tanggalParts[2]}-${tanggalParts[1]}-${tanggalParts[0]}";
        }
        
        // Ekstrak jam mulai dan selesai
        if (waktuPart.contains('-')) {
          String jam = waktuPart.split('-')[0].trim();
          String jamSelesaiStr = waktuPart.split('-')[1].trim();
          
          // Tambahkan :00 jika formatnya HH.MM
          if (jam.contains('.')) {
            jam = jam.replaceAll('.', ':');
          }
          if (jamSelesaiStr.contains('.')) {
            jamSelesaiStr = jamSelesaiStr.replaceAll('.', ':');
          }
          
          jamMulai = jam;
          jamSelesai = jamSelesaiStr;
        }
      }

      final response = await http.post(
        Uri.parse('${ApiService.apiHost}/api/pendaftaran-sidang'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'judul_ta': judulTa,
          'tanggal_sidang': tanggal,
          'jam_mulai': jamMulai,
          'jam_selesai': jamSelesai,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        print('Gagal mendaftarkan sidang: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error saat mendaftarkan sidang: $e');
      return null;
    }
  }
}