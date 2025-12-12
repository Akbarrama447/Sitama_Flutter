import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Untuk format tanggal

import '../../../main.dart'; // Untuk storageService
import '../../auth/screens/login_screen.dart';
import 'add_log_screen.dart';

class TugasAkhirTab extends StatefulWidget {
  const TugasAkhirTab({super.key});

  @override
  State<TugasAkhirTab> createState() => _TugasAkhirTabState();
}

class _TugasAkhirTabState extends State<TugasAkhirTab> {
  late Future<List<dynamic>> _logsFuture;
  // Sesuaikan IP backend lo
  final String _baseUrl = 'http://localhost:8000';

  // Target bimbingan (misal minimal 8 kali)
  final int _targetBimbingan = 8;

  // Filter state
  String _selectedFilter = 'Semua Bimbingan';

  @override
  void initState() {
    super.initState();
    _logsFuture = _fetchLogs();
  }

  Future<List<dynamic>> _fetchLogs() async {
    try {
      final token = await storageService.getToken();
      if (token == null) {
        _forceLogout();
        return [];
      }
      final url = '$_baseUrl/api/log-bimbingan';
      debugPrint('DEBUG: Fetching logs from $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('DEBUG: Logs API Response: ${response.statusCode}');
      debugPrint('DEBUG: Logs API Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else if (response.statusCode == 401) {
        _forceLogout();
        return [];
      } else if (response.statusCode == 404) {
        // Handle kasus saat belum ada tugas akhir
        final responseBody = jsonDecode(response.body);
        if (responseBody['message'] != null &&
            responseBody['message'].toString().toLowerCase().contains('belum ada tugas akhir')) {
          // Kembalikan list kosong jika belum ada tugas akhir
          return [];
        } else {
          throw Exception('Gagal load log: ${response.statusCode} - ${response.body}');
        }
      } else {
        throw Exception('Gagal load log: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching logs: $e');
      // buat nampilin error di UI
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  void _forceLogout() {
    storageService.deleteToken();
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Background agak abu terang
      body: FutureBuilder<List<dynamic>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // Cek apakah error karena belum ada tugas akhir
            String errorText = snapshot.error.toString();
            if (errorText.toLowerCase().contains('belum ada tugas akhir') ||
                errorText.toLowerCase().contains('404')) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.assignment_outlined, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada tugas akhir',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Silakan daftarkan tugas akhir terlebih dahulu',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600]
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 80, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}',
                         style: const TextStyle(color: Colors.red)),
                  ],
                ),
              );
            }
          }

          final allLogs = snapshot.data ?? [];
          // Filter logs based on selected filter
          final logs = _selectedFilter == 'Semua Bimbingan'
              ? allLogs
              : _selectedFilter == 'Disetujui'
                  ? allLogs.where((log) => log['status'] == 1).toList()
                  : allLogs.where((log) => log['status'] == 0).toList(); // Menunggu

          // Hitung jumlah bimbingan yang sudah disetujui (status == 1)
          // Atau hitung semua log, tergantung kebijakan kampus lo.
          final progressCount = allLogs.length;
          final progressValue = (progressCount / _targetBimbingan).clamp(0.0, 1.0);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER STATUS
                _buildStatusCard(progressCount, progressValue),

                const SizedBox(height: 24),

                // 2. JUDUL & KONTROL (Filter + Tambah)
                const Text(
                  'Pembimbingan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                ),
                const SizedBox(height: 12),
                _buildControls(),

                const SizedBox(height: 16),

                // 3. LIST LOG
                if (logs.isEmpty)
                  _buildEmptyState()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      return _buildLogItem(logs[index]);
                    },
                  ),

                const SizedBox(height: 80), // Space bawah
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildStatusCard(int count, double progress) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Status Bimbingan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                ),
                // Link Cetak (Placeholder)
                InkWell(
                  onTap: () => debugPrint('Cetak diklik'),
                  child: Row(
                    children: [
                      const Icon(Icons.print_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      const Text('Cetak lembar persetujuan', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Mahasiswa (Bisa ambil dari storage jika mau dinamis)
                      FutureBuilder<String?>(
                        future: storageService.getUserName(),
                        builder: (context, snapshot) => Text(
                           snapshot.data ?? 'Mahasiswa',
                           style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.grey[200],
                          color: const Color(0xFF03A9F4), // Warna biru muda sesuai gambar
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '$count/$_targetBimbingan',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Tombol Lembar Kontrol
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF039BE5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.assignment_outlined, color: Colors.white),
                      const Text('Kontrol', style: TextStyle(color: Colors.white, fontSize: 9)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      children: [
        // Dropdown Filter
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFilter,
                isExpanded: true,
                items: ['Semua Bimbingan', 'Disetujui', 'Menunggu'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedFilter = val;
                    });
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Tombol Tambah
        ElevatedButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddLogScreen()),
            );
            if (result == true) {
              // Refresh the list
              setState(() {
                _logsFuture = _fetchLogs();
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF03A9F4), // Warna biru sesuai gambar
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildLogItem(dynamic logData) {
    final log = logData as Map<String, dynamic>;

    // Parse tanggal dari String "YYYY-MM-DD" ke DateTime
    final date = DateTime.parse(log['tanggal']);
    // Format ke "Senin, 1 Maret 2025" (tanpa locale untuk menghindari error)
    final formattedDate = DateFormat('EEEE, d MMMM yyyy').format(date);
  // Pisahkan tanggal untuk tampilan 2 baris (opsional, sesuai selera desain)
  // (tidak digunakan sekarang — hapus jika tidak diperlukan)

    final status = log['status']; // 0, 1, atau 2

    // Tentukan icon berdasarkan status
    IconData statusIcon;
    Color statusColor;
    if (status == 1) { // Disetujui
      statusIcon = Icons.check;
      statusColor = Colors.green;
    } else if (status == 2) { // Ditolak
      statusIcon = Icons.close;
      statusColor = Colors.red;
    } else { // 0 = Menunggu/Draft
      statusIcon = Icons.edit;
      statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Biar rata atas
        children: [
          // Kolom Tanggal
          SizedBox(
            width: 90,
            child: Text(
              // Ganti spasi dengan newline biar jadi 2 baris kayak di gambar
              formattedDate.replaceFirst(', ', '\n'),
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500
              ),
            ),
          ),
          // Garis Pemisah Vertikal
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          // Kolom Konten
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log['dosen'] ?? 'Dosen',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2C3E50)),
                ),
                const SizedBox(height: 4),
                Text(
                  log['catatan'] ?? '-',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Kolom Icon Status
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(statusIcon, size: 20, color: statusColor),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const Icon(Icons.history_edu_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Belum ada riwayat bimbingan.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text('Tambahkan log bimbingan pertama Anda', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
