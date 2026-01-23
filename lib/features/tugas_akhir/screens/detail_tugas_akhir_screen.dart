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

  // Variabel state untuk menyimpan data user yang sedang login
  String? _namaMahasiswa = 'NAMA MAHASISWA';
  String? _nim = '0.0.0.0';
  String? _prodi = 'D3 Teknik Informatika';

  @override
  void initState() {
    super.initState();
    _loadThesisDetail();
  }

  Future<void> _loadThesisDetail() async {
    try {
      // Ambil data user dari storage dulu
      final storedProfile = await storageService.getProfile();
      final storedName = storedProfile['nama'];
      final storedNim = storedProfile['nim'];
      final storedProdi = storedProfile['prodi'];

      // Update state dengan data dari storage
      setState(() {
        _namaMahasiswa = storedName ?? _namaMahasiswa;
        _nim = storedNim ?? _nim;
        _prodi = storedProdi ?? _prodi;
      });

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
                                          const DaftarTugasAkhirScreen(),
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
    // Gunakan data user yang sudah diambil dari storage di _loadThesisDetail
    String namaMahasiswa = _namaMahasiswa ?? 'NAMA MAHASISWA';
    String nim = _nim ?? '0.0.0.0';
    String prodi = _prodi ?? 'D3 Teknik Informatika';

    // Jika data dari storage kosong atau tidak valid, fallback ke data dari thesisData
    if ((namaMahasiswa == 'NAMA MAHASISWA' || nim == '0.0.0.0') &&
        thesisData?['anggota_kelompok'] != null) {
      final List<dynamic>? anggotaKelompok = thesisData?['anggota_kelompok'];
      if (anggotaKelompok != null && anggotaKelompok.isNotEmpty) {
        final Map<String, dynamic>? currentUser = anggotaKelompok[0];
        if (currentUser != null) {
          // Hanya gunakan data dari thesisData jika data dari storage kosong
          if (namaMahasiswa == 'NAMA MAHASISWA') {
            namaMahasiswa = currentUser['nama'] ?? namaMahasiswa;
          }
          if (nim == '0.0.0.0') {
            nim = currentUser['nim']?.toString() ?? nim;
          }
        }
      }
    }

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
                      Colors.transparent,
                    ),

                    // Deskripsi Tugas Akhir
                    _buildDetailItem(
                      'Deskripsi',
                      Text(
                        thesisData?['deskripsi'] ?? 'Deskripsi tidak tersedia',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Colors.grey.shade200,
                    ),

                    // Status
                    _buildDetailItem(
                      'Status',
                      Text(
                        thesisData?['status'] ?? '-',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Colors.transparent,
                    ),

                    // Dosen Pembimbing
                   _buildDetailItem(
                      'Dosen Pembimbing',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Pembimbing 1 ---
                          _buildPembimbingItem(
                            1,
                            thesisData?['pembimbing_1'],
                            thesisData?['pembimbing_1_nip'],
                          ),

                          const SizedBox(height: 8),

                          // --- Pembimbing 2 ---
                          _buildPembimbingItem(
                            2,
                            thesisData?['pembimbing_2'],
                            thesisData?['pembimbing_2_nip'],
                          ),
                        ],
                      ),
                      Colors.grey.shade200,
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
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${index + 1}. ${penguji['nama'] ?? "-"}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              if (penguji['nip'] != null)
                                Text(
                                  'NIP: ${penguji['nip'] ?? "-"}',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                      Colors.grey.shade200,
                    ),

                    // Anggota Kelompok
                    _buildDetailItem(
                      'Anggota Kelompok',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (thesisData?['anggota_kelompok'] as List? ??
                                [])
                            .asMap()
                            .entries
                            .map<Widget>((entry) {
                          int index = entry.key;
                          var anggota = entry.value;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${index + 1}. ${anggota['nama'] ?? "-"}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              if (anggota['nim'] != null)
                                Text(
                                  'NIM: ${anggota['nim'] ?? "-"}',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                      Colors.grey.shade200,
                    ),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  // Helper Widget untuk menghandle Pembimbing (Support Format String Lama & Map Baru)
  Widget _buildPembimbingItem(
      int urutan, dynamic pembimbingData, dynamic oldNip) {
    String nama = '-';
    String? nip;

    if (pembimbingData != null) {
      if (pembimbingData is Map) {
        // Format Baru (Object/Map) -> Jika API mengirim {nama: ..., nip: ...}
        nama = pembimbingData['nama'] ?? '-';
        nip = pembimbingData['nip'];
      } else if (pembimbingData is String) {
        // Format Lama (String biasa) -> Jika API mengirim "Nama Dosen"
        nama = pembimbingData;
        nip = oldNip; // Ambil dari key terpisah (backward compatibility)
      }
    } else {
      return Text('$urutan. -');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$urutan. $nama',
          style: const TextStyle(fontSize: 16),
        ),
        if (nip != null)
          Text(
            'NIP: $nip',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
      ],
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