import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/api_service.dart';

class RevisiService {
  // Endpoint untuk mengambil data revisi tugas akhir
  static const String revisiEndpoint = '${ApiService.baseUrl}/revisi-tugas-akhir-saya';

  // Model untuk data revisi
  static Future<List<Map<String, dynamic>>?> getRevisiData(String token) async {
    try {
      final response = await http.get(
        Uri.parse(revisiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success' && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Gagal mengambil data revisi');
        }
      } else {
        throw Exception('Gagal mengambil data revisi (Error: ${response.statusCode})');
      }
    } catch (e) {
      print('Error saat mengambil data revisi: $e');
      rethrow;
    }
  }

  // Fungsi untuk mendapatkan status revisi terbaru berdasarkan updated_at
  static int? getLatestRevisiStatus(List<Map<String, dynamic>> revisiList) {
    if (revisiList.isEmpty) return null;

    // Urutkan berdasarkan updated_at terbaru
    revisiList.sort((a, b) {
      final updatedAtA = DateTime.parse(a['updated_at']);
      final updatedAtB = DateTime.parse(b['updated_at']);
      return updatedAtB.compareTo(updatedAtA);
    });

    // Ambil status_revisi dari record terbaru
    return revisiList.first['status_revisi'];
  }

  // Fungsi untuk mendapatkan deskripsi status
  static String getStatusDescription(int? status) {
    switch (status) {
      case 0:
        return 'Terjadwal';
      case 1:
        return 'Lulus';
      case 2:
        return 'Lulus dengan Revisi';
      case 3:
        return 'Revisi';
      case 4:
        return 'Tidak Lulus';
      default:
        return 'Status Tidak Dikenal';
    }
  }

  // Fungsi untuk mendapatkan warna berdasarkan status
  static String getStatusColor(int? status) {
    switch (status) {
      case 0:
        return '#2196F3'; // Biru
      case 1:
        return '#4CAF50'; // Hijau
      case 2:
        return '#FF9800'; // Oranye
      case 3:
        return '#FF5722'; // Merah
      case 4:
        return '#9E9E9E'; // Abu-abu
      default:
        return '#757575'; // Abu-abu gelap
    }
  }

  // Fungsi untuk mengecek apakah status memerlukan revisi
  static bool isRevisiRequired(int? status) {
    return status == 2 || status == 3; // Lulus dengan Revisi atau Revisi
  }
}