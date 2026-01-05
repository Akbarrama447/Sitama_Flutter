import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as Path;
import '../../../main.dart'; // untuk mengakses storageService
import '../../../core/services/api_service.dart';

class DocumentUploadService {

  // Tambahkan flag untuk menentukan apakah menggunakan API atau tidak
  static bool useApi = false; // Set ke false untuk menggunakan mode lokal sementara

  static Future<Map<String, dynamic>?> uploadFile({
    required File file,
    required int documentId, // Ini sekarang adalah dokumen_id sesuai dengan API
    String? token,
  }) async {
    // Jika tidak menggunakan API, gunakan versi lokal
    if (!useApi) {
      return await _uploadFileLocal(file, documentId);
    }

    // Jika menggunakan API, gunakan versi asli
    try {
      // Cek apakah file benar-benar ada sebelum mencoba membaca
      if (!await file.exists()) {
        return {
          'success': false,
          'message': 'File tidak ditemukan atau tidak valid',
        };
      }

      // Ambil token dari storage jika tidak disediakan
      String authToken = token ?? await storageService.getToken() ?? '';

      if (authToken.isEmpty) {
        return {
          'success': false,
          'message': 'Token autentikasi tidak ditemukan',
        };
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/upload-dokumen'),
      );

      // Tambahkan header
      request.headers['Authorization'] = 'Bearer $authToken';
      request.headers['Accept'] = 'application/json';

      // Membaca file sebagai bytes
      List<int> fileBytes = await file.readAsBytes();

      // Tambahkan file ke request menggunakan bytes
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: Path.basename(file.path),
        ),
      );

      // Tambahkan dokumen_id ke request
      request.fields['dokumen_id'] = documentId.toString();

      // Cek ukuran file sebelum upload
      int fileSizeInBytes = await file.length();
      int maxFileSizeInBytes = 10 * 1024 * 1024; // 10 MB sesuai permintaan
      if (fileSizeInBytes > maxFileSizeInBytes) {
        return {
          'success': false,
          'message': 'Ukuran file terlalu besar. Maksimal 10 MB.',
        };
      }

      print('Memulai request ke: ${ApiService.baseUrl}/upload-dokumen'); // Debug log
      print('Headers: ${request.headers}'); // Debug log
      print('Fields: ${request.fields}'); // Debug log
      print('Files: ${request.files.length} files'); // Debug log

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: $responseBody'); // Debug log

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Upload berhasil
        return {
          'success': true,
          'filename': Path.basename(file.path),
          'message': 'File berhasil diupload',
        };
      } else if (response.statusCode == 400) {
        // Biasanya error karena format file tidak didukung atau validasi gagal
        return {
          'success': false,
          'message': 'File tidak valid atau tidak sesuai persyaratan',
        };
      } else if (response.statusCode == 401) {
        // Token tidak valid, mungkin perlu login ulang
        return {
          'success': false,
          'message': 'Token tidak valid, silakan login kembali',
        };
      } else if (response.statusCode == 413) {
        // Request Entity Too Large
        return {
          'success': false,
          'message': 'Ukuran file terlalu besar',
        };
      } else if (response.statusCode == 422) {
        // Unprocessable Entity - biasanya validasi gagal di server
        try {
          Map<String, dynamic> errorResponse = json.decode(responseBody);
          print('Validation errors: $errorResponse'); // Debug log
          String errorMessage = errorResponse['message'] ??
                               (errorResponse['errors'] != null ? errorResponse['errors'].toString() : 'File tidak sesuai dengan persyaratan yang ditentukan');
          return {
            'success': false,
            'message': errorMessage,
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'File tidak sesuai dengan persyaratan yang ditentukan',
          };
        }
      } else {
        // Upload gagal - coba parse response body untuk pesan error spesifik
        try {
          Map<String, dynamic> errorResponse = json.decode(responseBody);
          String errorMessage = errorResponse['message'] ?? errorResponse['error'] ?? 'Gagal mengupload file';
          return {
            'success': false,
            'message': errorMessage,
          };
        } catch (e) {
          // Jika response bukan JSON, gunakan status code dan reason phrase
          return {
            'success': false,
            'message': 'Gagal mengupload file: ${response.statusCode} - ${response.reasonPhrase}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error saat mengupload file: ${e.toString()}',
      };
    }
  }

  // Fungsi lokal untuk upload tanpa API
  static Future<Map<String, dynamic>?> _uploadFileLocal(File file, int documentId) async {
    try {
      // Cek apakah file benar-benar ada sebelum mencoba membaca
      if (!await file.exists()) {
        return {
          'success': false,
          'message': 'File tidak ditemukan atau tidak valid',
        };
      }

      print('File exists: ${file.path}'); // Debug log
      print('File size: ${await file.length()} bytes'); // Debug log

      // Cek ukuran file sebelum proses
      int fileSizeInBytes = await file.length();
      int maxFileSizeInBytes = 10 * 1024 * 1024; // 10 MB sesuai permintaan
      if (fileSizeInBytes > maxFileSizeInBytes) {
        return {
          'success': false,
          'message': 'Ukuran file terlalu besar. Maksimal 10 MB.',
        };
      }

      // Ambil nama file
      String filename = Path.basename(file.path);
      print('File name: $filename'); // Debug log

      // Proses upload berhasil - kembalikan data yang dibutuhkan
      return {
        'success': true,
        'filename': filename,
        'message': 'File berhasil dipilih',
      };
    } catch (e) {
      print('Error in _uploadFileLocal: ${e.toString()}'); // Debug log
      return {
        'success': false,
        'message': 'Error saat memproses file: ${e.toString()}',
      };
    }
  }

  // Fungsi khusus untuk upload di web browser
  static Future<Map<String, dynamic>?> uploadFileWeb({
    required String fileName,
    required Uint8List? fileBytes,
    required int documentId,
    String? token,
  }) async {
    // Jika tidak menggunakan API, gunakan versi lokal
    if (!useApi) {
      // Cek ukuran file sebelum proses
      if (fileBytes != null) {
        int fileSizeInBytes = fileBytes.length;
        int maxFileSizeInBytes = 10 * 1024 * 1024; // 10 MB sesuai permintaan
        if (fileSizeInBytes > maxFileSizeInBytes) {
          return {
            'success': false,
            'message': 'Ukuran file terlalu besar. Maksimal 10 MB.',
          };
        }
      }

      return {
        'success': true,
        'filename': fileName,
        'message': 'File berhasil dipilih',
      };
    }

    // Jika menggunakan API, gunakan versi asli untuk web
    try {
      // Cek apakah file bytes tersedia
      if (fileBytes == null) {
        return {
          'success': false,
          'message': 'File tidak ditemukan atau tidak valid',
        };
      }

      // Ambil token dari storage jika tidak disediakan
      String authToken = token ?? await storageService.getToken() ?? '';

      if (authToken.isEmpty) {
        return {
          'success': false,
          'message': 'Token autentikasi tidak ditemukan',
        };
      }

      // Cek ukuran file sebelum upload
      int fileSizeInBytes = fileBytes.length;
      int maxFileSizeInBytes = 10 * 1024 * 1024; // 10 MB sesuai permintaan
      if (fileSizeInBytes > maxFileSizeInBytes) {
        return {
          'success': false,
          'message': 'Ukuran file terlalu besar. Maksimal 10 MB.',
        };
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/upload-dokumen'),
      );

      // Tambahkan header
      request.headers['Authorization'] = 'Bearer $authToken';
      request.headers['Accept'] = 'application/json';

      // Tambahkan file ke request menggunakan bytes
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );

      // Tambahkan dokumen_id ke request (ini yang benar sesuai API)
      request.fields['dokumen_id'] = documentId.toString();

      print('Memulai request ke: ${ApiService.baseUrl}/upload-dokumen'); // Debug log
      print('Headers: ${request.headers}'); // Debug log
      print('Fields: ${request.fields}'); // Debug log
      print('Files: ${request.files.length} files'); // Debug log

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: $responseBody'); // Debug log

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Upload berhasil
        return {
          'success': true,
          'filename': fileName,
          'message': 'File berhasil diupload',
        };
      } else if (response.statusCode == 400) {
        // Biasanya error karena format file tidak didukung atau validasi gagal
        return {
          'success': false,
          'message': 'File tidak valid atau tidak sesuai persyaratan',
        };
      } else if (response.statusCode == 401) {
        // Token tidak valid, mungkin perlu login ulang
        return {
          'success': false,
          'message': 'Token tidak valid, silakan login kembali',
        };
      } else if (response.statusCode == 413) {
        // Request Entity Too Large
        return {
          'success': false,
          'message': 'Ukuran file terlalu besar',
        };
      } else if (response.statusCode == 422) {
        // Unprocessable Entity - biasanya validasi gagal di server
        try {
          Map<String, dynamic> errorResponse = json.decode(responseBody);
          print('Validation errors: $errorResponse'); // Debug log
          String errorMessage = errorResponse['message'] ??
                               (errorResponse['errors'] != null ? errorResponse['errors'].toString() : 'File tidak sesuai dengan persyaratan yang ditentukan');
          return {
            'success': false,
            'message': errorMessage,
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'File tidak sesuai dengan persyaratan yang ditentukan',
          };
        }
      } else {
        // Upload gagal - coba parse response body untuk pesan error spesifik
        try {
          Map<String, dynamic> errorResponse = json.decode(responseBody);
          String errorMessage = errorResponse['message'] ?? errorResponse['error'] ?? 'Gagal mengupload file';
          return {
            'success': false,
            'message': errorMessage,
          };
        } catch (e) {
          // Jika response bukan JSON, gunakan status code dan reason phrase
          return {
            'success': false,
            'message': 'Gagal mengupload file: ${response.statusCode} - ${response.reasonPhrase}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error saat mengupload file: ${e.toString()}',
      };
    }
  }

}