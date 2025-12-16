import 'package:flutter/material.dart';

// Pastikan file form_revisi_screen.dart ada di folder yang sama
import 'form_revisi_screen.dart'; 

class InfoRevisiScreen extends StatelessWidget {
  // Data yang diterima dari halaman sebelumnya
  final Map<String, dynamic> dataSidang;
  final String hasilSidang;
  
  // Status Upload (Default false/belum upload)
  final bool sudahUploadRevisi; 

  const InfoRevisiScreen({
    super.key, 
    required this.dataSidang, 
    required this.hasilSidang,
    this.sudahUploadRevisi = false, 
  });

  // --- Getters Data ---
  String get namaMahasiswa => dataSidang['namaMahasiswa'] ?? "N/A";
  String get nimProdi => dataSidang['nimProdi'] ?? "N/A";
  String get judulTA => dataSidang['judulTA'] ?? "N/A";
  String get deskripsiTA => dataSidang['deskripsiTA'] ?? "N/A";
  
  List<String> get dosenPembimbing => List<String>.from(dataSidang['dosenPembimbing'] ?? []);
  List<String> get dosenPenguji => List<String>.from(dataSidang['dosenPenguji'] ?? []);
  
  String get sekretaris => dataSidang['sekretaris'] ?? "N/A";
  String get labSidang => dataSidang['labSidang'] ?? "N/A";
  String get waktuSidang => dataSidang['waktuSidang'] ?? "N/A";
  String get namaDosenPembimbing => dataSidang['namaDosen'] ?? "Dosen";


  // --- Widget Pembantu Tampilan ---

  Widget _buildInfoRow(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 2),
          content,
        ],
      ),
    );
  }

  Widget _buildDosenList(List<String> dosenList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: dosenList.asMap().entries.map((entry) {
        int index = entry.key;
        String nama = entry.value;
        return Text('${index + 1}. $nama', style: const TextStyle(fontSize: 14, color: Colors.black54));
      }).toList(),
    );
  }

  // --- Widget Utama ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('INFO SIDANG TUGAS AKHIR'),
        backgroundColor: Colors.white, // Sesuaikan warna appbar jika perlu
        foregroundColor: Colors.black, // Warna teks appbar
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                namaDosenPembimbing,
                style: const TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            
            // Bagian "Selamat Datang" SUDAH DIHAPUS

            // Card Putih Utama
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Box Biru Header Mahasiswa
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600, // Warna biru header
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          namaMahasiswa,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nimProdi,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  // Detail Konten
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Judul Tugas Akhir', Text(judulTA, style: const TextStyle(fontSize: 14, color: Colors.black54))),
                        _buildInfoRow('Deskripsi', Text(deskripsiTA, style: const TextStyle(fontSize: 14, color: Colors.black54))),
                        _buildInfoRow('Dosen Pembimbing', _buildDosenList(dosenPembimbing)),
                        _buildInfoRow('Dosen Penguji', _buildDosenList(dosenPenguji)),
                        _buildInfoRow('Sekretaris', Text(sekretaris, style: const TextStyle(fontSize: 14, color: Colors.black54))),
                        
                        const SizedBox(height: 10),

                        // Jadwal Sidang & Lokasi (Menggunakan Column agar tidak overflow)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Lokasi
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.blue.shade300)
                              ),
                              child: Text(labSidang, style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500, fontSize: 13)),
                            ),
                            const SizedBox(height: 8), // Jarak ke bawah
                            // Waktu
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey.shade300)
                              ),
                              child: Text(waktuSidang, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13)),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 30),

                        // TOMBOL AKSI
                        Center(
                          child: _buildActionButton(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Metode Kondisional Tombol
  Widget _buildActionButton(BuildContext context) {
    // 1. Jika sudah upload revisi, tombol Revisi jadi MATI (Abu-abu)
    if (sudahUploadRevisi && hasilSidang == "Revisi") {
       return ElevatedButton(
          onPressed: null, // null membuat tombol disable/mati
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade300, // Warna Abu-abu muda
            disabledBackgroundColor: Colors.grey.shade300, // Pastikan warna saat disable
            foregroundColor: Colors.grey.shade600, // Warna teks saat disable
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            'Revisi (Sudah Upload)', 
            style: TextStyle(fontSize: 16),
          ),
        );
    }

    // 2. Logika Standar berdasarkan Hasil Sidang
    switch (hasilSidang) {
      case "Revisi":
        // Tombol Revisi Aktif (Biru) -> Navigasi ke Form Upload
        return ElevatedButton(
          onPressed: () => _navigasiKeFormRevisi(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Revisi', style: TextStyle(fontSize: 16)),
        );

      case "Tidak Lulus":
        return ElevatedButton(
          onPressed: null, 
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade600,
            disabledBackgroundColor: Colors.grey.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Tidak Lulus', style: TextStyle(fontSize: 16, color: Colors.white)),
        );

      case "Lulus":
        return ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            disabledBackgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Lulus', style: TextStyle(fontSize: 16, color: Colors.white)),
        );

      default:
        // Tombol placeholder jika status belum jelas
        return const SizedBox.shrink();
    }
  }

  // Fungsi Navigasi yang mendeteksi hasil balikan dari Form Revisi
  Future<void> _navigasiKeFormRevisi(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FormRevisiScreen(), 
      ),
    );

    // Jika result == true (Berhasil Upload)
    if (result == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InfoRevisiScreen(
            dataSidang: dataSidang,
            hasilSidang: hasilSidang,
            sudahUploadRevisi: true, // Ubah status jadi true
          ),
        ),
      );
    }
  }
}