import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../main.dart'; // storageService
import '../../../core/services/api_service.dart';
import 'file_preview_screen.dart';

class DetailBimbinganDialog extends StatefulWidget {
  final Map<String, dynamic> data;
  const DetailBimbinganDialog({super.key, required this.data});

  @override
  State<DetailBimbinganDialog> createState() => _DetailBimbinganDialogState();
}

class _DetailBimbinganDialogState extends State<DetailBimbinganDialog> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfile();
  }

  Future<Map<String, dynamic>> _fetchProfile() async {
    final token = await storageService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan, silakan login ulang.');

    final url = Uri.parse(ApiService.profileUrl);
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return Map<String, dynamic>.from(body['data']);
    } else if (response.statusCode == 401) {
      throw Exception('Token expired. Silakan login ulang.');
    } else {
      throw Exception('Gagal memuat profil. Status: ${response.statusCode}');
    }
  }

  String _formatTanggal(dynamic raw) {
    if (raw == null) return '-';
    try {
      final d = DateTime.parse(raw.toString());
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(d);
    } catch (_) {
      return raw.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(0),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          Center(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: FutureBuilder<Map<String, dynamic>>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Gagal memuat profil:\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _profileFuture = _fetchProfile();
                              });
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                  }

                  final profile = snapshot.data ?? {};
                  final namaMahasiswa = profile['nama'] ?? '-';
                  final nim = profile['nim']?.toString() ?? '-';
                  final prodi = profile['prodi'] ?? '-';

                  final data = widget.data;
                  final judul = data['judul'] ?? '-';
                  final deskripsi = data['deskripsi'] ?? '-';
                  final pembimbing = data['dosen_nama'] ?? data['pembimbing'] ?? '-';
                  final tanggal = _formatTanggal(data['tanggal']);
                  final filePath = data['file_url']?.toString() ?? '-';
                  final fileName = filePath != '-' ? filePath.split('/').last : '-';
                  final catatan = data['catatan_dosen'] ?? data['catatan'] ?? '-';

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEADER
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                namaMahasiswa.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text("$nim — $prodi",
                                  style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text("Judul Bimbingan",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(judul),

                        const SizedBox(height: 12),
                        const Text("Deskripsi",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(deskripsi),

                        const SizedBox(height: 12),
                        const Text("Dosen Pembimbing",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(pembimbing.toString()),

                        const SizedBox(height: 12),
                        const Text("Jadwal Bimbingan",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(tanggal),

                        const SizedBox(height: 12),
                        const Text("File",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(fileName),

                        const SizedBox(height: 12),
                        const Text("Catatan Dosen",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(catatan),

                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Tutup")),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: filePath == '-'
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  FilePreviewScreen(fileUrl: filePath)));
                                    },
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text("Lihat File"),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
