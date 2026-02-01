import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../main.dart'; // untuk mengakses storageService
import '../../../core/services/api_service.dart';

class DocumentListService {
  // Fungsi untuk mengambil daftar dokumen yang sudah diupload dari API
  static Future<List<Map<String, dynamic>>?> getUploadedDocuments() async {
    try {
      String? token = await storageService.getToken();
      if (token == null) {
        print('Token tidak ditemukan');
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiService.apiHost}/api/my-uploaded-documents'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          print('Gagal mengambil daftar dokumen: ${data['message']}');
          return null;
        }
      } else {
        print('Gagal mengambil daftar dokumen: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error saat mengambil daftar dokumen: $e');
      return null;
    }
  }
}