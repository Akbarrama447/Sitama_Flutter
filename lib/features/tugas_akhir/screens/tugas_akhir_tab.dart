import 'package:flutter/material.dart';

class TugasAkhirTab extends StatefulWidget {
  const TugasAkhirTab({super.key});

  @override
  State<TugasAkhirTab> createState() => _TugasAkhirTabState();
}

class _TugasAkhirTabState extends State<TugasAkhirTab> {
  late Future<dynamic> _tugasAkhirFuture;

  @override
  void initState() {
    super.initState();
    _tugasAkhirFuture = _fetchTugasAkhir();
  }

  Future<dynamic> _fetchTugasAkhir() async {
    try {
      print('Memanggil GET /api/tugas-akhir...');
      await Future.delayed(const Duration(seconds: 2));
      print('Selesai panggil API.');

      // --- Skenario 1: Mahasiswa BELUM punya TA (API balikin data null) ---
      return null;

      // --- Skenario 2: Mahasiswa SUDAH punya TA (API balikin data) ---
      // (Comment 'return null;' di atas dan uncomment di bawah ini)
      // return {
      //   'judul': 'Rancang Bangun Sistem Akademik Mobile',
      //   'status': 'Bimbingan - BAB 3',
      //   'pembimbing1': 'Dr. Ir. Budi Rahardjo, M.Sc.',
      //   'pembimbing2': 'Siti Karmila, S.Kom., M.T.',
      //   'anggota': ['Ahmad (NIM: 123)', 'Budi (NIM: 456)'],
      // };
      
    } catch (e) {
      print('Error fetching TA: $e');
      throw Exception('Gagal memuat data Tugas Akhir');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _tugasAkhirFuture,
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${snapshot.error.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final taData = snapshot.data;

        if (taData == null) {
          // Tampilkan pesan kosong (karena tombol ada di FAB)
          // **Revisi**: Kita hapus FAB dan pakai tombol di sini
          return _buildAjukanJudulView(); 
        }
        else {
          // Tampilkan detail TA
          return _buildDetailTugasAkhirView(taData);
        }
      },
    );
  }

  /// Widget yang tampil jika mahasiswa BELUM punya TA
  /// **Revisi**: Kita kembalikan tombol di sini karena FAB tidak ada
  Widget _buildAjukanJudulView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'Anda belum memiliki data Tugas Akhir.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            const Text(
              'Silakan ajukan judul baru untuk memulai.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Ajukan Judul TA Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                // Nanti ini trigger ke halaman form POST /api/tugas-akhir
                print('Navigasi ke halaman Form Pengajuan Judul...');
              },
            ),
          ],
        ),
      ),
    );
  }


  /// Widget yang tampil jika mahasiswa SUDAH punya TA
  Widget _buildDetailTugasAkhirView(dynamic taData) {
    final data = taData as Map<String, dynamic>;
    final List<String> anggota = List<String>.from(data['anggota'] ?? []);

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _tugasAkhirFuture = _fetchTugasAkhir();
        });
      },
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDetailCard('Judul Tugas Akhir', data['judul']),
          _buildDetailCard('Status', data['status'], isStatus: true),
          _buildDetailCard('Pembimbing 1', data['pembimbing1']),
          _buildDetailCard('Pembimbing 2', data['pembimbing2']),
          _buildDetailCard('Anggota Kelompok', anggota.join('\n')),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
            ),
            child: const Text('Update Progres / Edit Judul'),
            onPressed: () {
              print('Navigasi ke halaman Update TA...');
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Upload Berkas Syarat Sidang'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.teal,
            ),
            onPressed: () {
              print('Navigasi ke halaman Upload Syarat...');
            },
          ),
        ],
      ),
    );
  }

  /// Helper widget buat nampilin item detail di card
  Widget _buildDetailCard(String label, String value, {bool isStatus = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isStatus ? FontWeight.bold : FontWeight.w500,
                color: isStatus ? Colors.blue.shade700 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}