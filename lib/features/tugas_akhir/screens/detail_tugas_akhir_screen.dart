import 'package:flutter/material.dart';
import '../../../main.dart'; // Untuk akses storageService
import '../../../core/services/api_service.dart';
import 'daftar_tugas_akhir_screen.dart';

class DetailTugasAkhirScreen extends StatefulWidget {
  const DetailTugasAkhirScreen({super.key});

  @override
  State<DetailTugasAkhirScreen> createState() => _DetailTugasAkhirScreenState();
}

class _DetailTugasAkhirScreenState extends State<DetailTugasAkhirScreen> {
  Map<String, dynamic>? thesisData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadThesisDetail();
  }

  Future<void> _loadThesisDetail() async {
    try {
      String? token = await storageService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }
      final response = await ApiService.getThesis(token);
      if (response['status'] == 'success') {
        if (response['data'] != null) {
          setState(() {
            thesisData = response['data'];
            isLoading = false;
          });
        } else {
          // Jika data null, berarti user belum memiliki tugas akhir
          setState(() {
            errorMessage =
                'Anda belum memiliki tugas akhir. Silakan daftar terlebih dahulu.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Gagal memuat data tugas akhir';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Background abu-abu muda
      body: SafeArea(
        child: Stack(
          children: [
            // Konten Utama (Header dan Detail)
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                errorMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  // Navigasi ke Daftar Tugas Akhir
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DaftarTugasAkhirScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Daftar Tugas Akhir'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : thesisData == null
                        ? const Center(
                            child: Text('Data tugas akhir tidak ditemukan'))
                        : _buildContent(context),

            // Back button (Ditempatkan di atas konten untuk akses mudah)
            Positioned(
              top: 10.0,
              left: 10.0,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 24,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // Ambil data mahasiswa pertama dari anggota_kelompok sebagai pengguna saat ini
    final List<dynamic>? anggotaKelompok = thesisData?['anggota_kelompok'];
    final Map<String, dynamic>? currentUser = anggotaKelompok != null &&
            anggotaKelompok.isNotEmpty
        ? anggotaKelompok[0] // Ambil anggota pertama sebagai pengguna saat ini
        : null;

    final String namaMahasiswa = currentUser?['nama'] ?? 'NAMA MAHASISWA';
    final String nim = currentUser?['nim']?.toString() ?? '0.0.0.0';
    final String prodi = 'D3 Teknik Informatika'; // Prodi default

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Mahasiswa (sesuai desain)
          _buildHeaderMahasiswa(namaMahasiswa, nim, prodi),

          // 2. Konten Detail (di dalam Card)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Card(
              elevation: 0, // Dibuat flat
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul Tugas Akhir
                    _buildDetailItem(
                      'Judul Tugas Akhir',
                      Text(thesisData?['judul'] ?? 'Judul tidak tersedia'),
                      Colors
                          .transparent, // Tidak ada container di sekeliling judul
                    ),

                    // Deskripsi Tugas Akhir
                    _buildDetailItem(
                      'Deskripsi',
                      Text(
                        thesisData?['deskripsi'] ?? 'Deskripsi tidak tersedia',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Colors.grey
                          .shade200, // Container abu-abu di sekeliling deskripsi
                    ),

                    // Status
                    _buildDetailItem(
                      'Status',
                      Text(
                        thesisData?['status'] ?? '-',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Colors.transparent, // Tidak ada container
                    ),

                    // Dosen Pembimbing
                    _buildDetailItem(
                      'Dosen Pembimbing',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('1. ${thesisData?['pembimbing_1'] ?? "-"}'),
                          Text('2. ${thesisData?['pembimbing_2'] ?? "-"}'),
                        ],
                      ),
                      Colors.transparent, // Tidak ada container
                    ),

                    // Dosen Penguji
                    _buildDetailItem(
                      'Dosen Penguji',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (thesisData?['penguji'] as List? ?? [])
                            .asMap()
                            .entries
                            .map<Widget>((entry) {
                          int index = entry.key;
                          var penguji = entry.value;
                          return Text(
                            '${index + 1}. NIP: ${penguji['nip']} - ${penguji['nama']}',
                            style: const TextStyle(fontSize: 16),
                          );
                        }).toList(),
                      ),
                      Colors.grey.shade200, // Container abu-abu
                    ),

                    // Anggota Kelompok
                    _buildDetailItem(
                      'Anggota Kelompok',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            (thesisData?['anggota_kelompok'] as List? ?? [])
                                .asMap()
                                .entries
                                .map<Widget>((entry) {
                          int index = entry.key;
                          var anggota = entry.value;
                          return Text(
                            '${index + 1}. NIM: ${anggota['nim']} - ${anggota['nama']}',
                            style: const TextStyle(fontSize: 16),
                          );
                        }).toList(),
                      ),
                      Colors.grey.shade200, // Container abu-abu
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // 3. Tombol Lulus (sesuai desain)
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implementasi Aksi tombol (misal: konfirmasi kelulusan)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tombol "Lulus" diklik!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade600,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Lulus',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  // Widget untuk Header Mahasiswa (Biru/Gradient)
  Widget _buildHeaderMahasiswa(String nama, String nim, String prodi) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 40),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), // Warna Biru Muda
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1976D2), // Warna Biru Tua
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nama.toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$nim - $prodi',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk setiap baris detail
  Widget _buildDetailItem(
      String title, Widget contentWidget, Color containerColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: containerColor != Colors.transparent
                ? const EdgeInsets.all(12.0)
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: contentWidget,
          ),
        ],
      ),
    );
  }
}
