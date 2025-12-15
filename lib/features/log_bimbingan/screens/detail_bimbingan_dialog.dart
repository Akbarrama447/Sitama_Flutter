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
    if (token == null) throw Exception('Token tidak ditemukan.');

    final res = await http.get(
      Uri.parse(ApiService.profileUrl),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return Map<String, dynamic>.from(body['data']);
    } else {
      throw Exception('Gagal memuat profil');
    }
  }

  String _formatTanggal(dynamic raw) {
    try {
      final d = DateTime.parse(raw.toString());
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(d);
    } catch (_) {
      return '-';
    }
  }

  // ================= STATUS BADGE =================
  Widget _statusBadge(String key) {
    final isApprove = key == 'approve';
    final color = isApprove ? Colors.green : Colors.red;
    final text = isApprove ? 'DISETUJUI' : 'DITOLAK';
    final icon = isApprove ? Icons.check_circle : Icons.cancel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  // =================================================

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    final statusKey =
        data['status']?.toString() == '1' ? 'approve' : 'ditolak';

    final judul = data['judul'] ?? '-';
    final deskripsi = data['deskripsi'] ?? '-';
    final pembimbing =
        data['dosen_nama'] ?? data['pembimbing'] ?? '-';
    final tanggal = _formatTanggal(data['tanggal']);
    final filePath = data['file_url']?.toString() ?? '-';
    final fileName =
        filePath != '-' ? filePath.split('/').last : '-';
    final catatan =
        data['catatan_dosen'] ?? data['catatan'] ?? '-';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Container(color: Colors.black.withOpacity(0.4)),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: FutureBuilder<Map<String, dynamic>>(
                future: _profileFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  if (snap.hasError) {
                    return Center(
                        child: Text(
                      snap.error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ));
                  }

                  final profile = snap.data!;
                  final nama = profile['nama'] ?? '-';
                  final nim = profile['nim'] ?? '-';
                  final prodi = profile['prodi'] ?? '-';

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ===== HEADER MAHASISWA =====
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                nama.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$nim — $prodi",
                                style: const TextStyle(
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),
                        _statusBadge(statusKey),

                        const SizedBox(height: 16),

                        const Text("Judul Bimbingan",
                            style:
                                TextStyle(fontWeight: FontWeight.bold)),
                        Text(judul),

                        const SizedBox(height: 12),
                        const Text("Deskripsi",
                            style:
                                TextStyle(fontWeight: FontWeight.bold)),
                        Text(deskripsi),

                        const SizedBox(height: 12),
                        const Text("Dosen Pembimbing",
                            style:
                                TextStyle(fontWeight: FontWeight.bold)),
                        Text(pembimbing.toString()),

                        const SizedBox(height: 12),
                        const Text("Jadwal Bimbingan",
                            style:
                                TextStyle(fontWeight: FontWeight.bold)),
                        Text(tanggal),

                        const SizedBox(height: 12),
                        const Text("File",
                            style:
                                TextStyle(fontWeight: FontWeight.bold)),
                        Text(fileName),

                        const SizedBox(height: 12),
                        const Text("Catatan Dosen",
                            style:
                                TextStyle(fontWeight: FontWeight.bold)),
                        Text(catatan),

                        const SizedBox(height: 20),

                        // ===== ACTION =====
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context),
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
                                              FilePreviewScreen(
                                                  fileUrl: filePath),
                                        ),
                                      );
                                    },
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
