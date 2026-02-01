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
      backgroundColor: Colors.grey.shade100, // Background abu-abu muda seperti sebelumnya
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: const Color(0xFFBBDEFB), // Warna biru muda
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFBBDEFB), // Biru muda di atas
                        Color(0xFFE3F2FD), // Biru muda di bawah
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40, top: 60),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _namaMahasiswa?.toUpperCase() ?? 'NAMA MAHASISWA',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2196F3), // Warna biru sesuai permintaan
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_nim ?? '0.0.0.0'} - ${_prodi ?? 'D3 Teknik Informatika'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF2196F3), // Warna biru sesuai permintaan
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF2196F3), // Warna biru sesuai permintaan
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                'Detail Tugas Akhir',
                style: const TextStyle(
                  color: Color(0xFF2196F3), // Warna biru sesuai permintaan
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            SliverToBoxAdapter(
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : errorMessage.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.warning_rounded,
                                      size: 48,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      errorMessage,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
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
                                  backgroundColor: const Color(0xFF2196F3), // Warna biru sesuai permintaan
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Daftar Tugas Akhir'),
                              ),
                            ],
                          ),
                        )
                      : thesisData == null
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text('Data tugas akhir tidak ditemukan'),
                              ),
                            )
                          : _buildContent(context),
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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kartu Informasi Tugas Akhir
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul Tugas Akhir
                  _buildDetailItem(
                    'Judul Tugas Akhir',
                    Text(
                      thesisData?['judul'] ?? 'Judul tidak tersedia',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Deskripsi Tugas Akhir
                  _buildDetailItem(
                    'Deskripsi',
                    Text(
                      thesisData?['deskripsi'] ?? 'Deskripsi tidak tersedia',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Status
                  _buildDetailItem(
                    'Status',
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(thesisData?['status']),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        thesisData?['status']?.toUpperCase() ?? '-',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getStatusTextColor(thesisData?['status']),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Kartu Dosen Pembimbing
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dosen Pembimbing',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3), // Warna biru sesuai permintaan
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- Pembimbing 1 ---
                  _buildPembimbingItem(
                    1,
                    thesisData?['pembimbing_1'],
                    thesisData?['pembimbing_1_nip'],
                  ),
                  const SizedBox(height: 12),

                  // --- Pembimbing 2 ---
                  _buildPembimbingItem(
                    2,
                    thesisData?['pembimbing_2'],
                    thesisData?['pembimbing_2_nip'],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Kartu Dosen Penguji
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dosen Penguji',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3), // Warna biru sesuai permintaan
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Daftar Penguji
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (thesisData?['penguji'] as List? ?? [])
                        .asMap()
                        .entries
                        .map<Widget>((entry) {
                      int index = entry.key;
                      var penguji = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ${penguji['nama'] ?? "-"}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2196F3), // Warna biru sesuai permintaan
                              ),
                            ),
                            if (penguji['nip'] != null)
                              Text(
                                'NIP: ${penguji['nip'] ?? "-"}',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Kartu Anggota Kelompok
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Anggota Kelompok',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3), // Warna biru sesuai permintaan
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Daftar Anggota
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (thesisData?['anggota_kelompok'] as List? ??
                            [])
                        .asMap()
                        .entries
                        .map<Widget>((entry) {
                      int index = entry.key;
                      var anggota = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ${anggota['nama'] ?? "-"}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2196F3), // Warna biru sesuai permintaan
                              ),
                            ),
                            if (anggota['nim'] != null)
                              Text(
                                'NIM: ${anggota['nim'] ?? "-"}',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
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
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('$urutan. -'),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$urutan. $nama',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2196F3), // Warna biru sesuai permintaan
            ),
          ),
          if (nip != null)
            Text(
              'NIP: $nip',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  // Widget untuk setiap baris detail
  Widget _buildDetailItem(String title, Widget contentWidget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2196F3), // Warna biru sesuai permintaan
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: contentWidget,
        ),
      ],
    );
  }

  // Fungsi untuk menentukan warna status
  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey.shade300;

    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'approved':
        return const Color(0xFFE3F2FD); // Biru muda
      case 'diajukan':
      case 'submitted':
        return const Color(0xFFFFF3E0); // Oranye muda
      case 'ditolak':
      case 'rejected':
        return const Color(0xFFFCE4EC); // Merah muda
      default:
        return Colors.grey.shade100;
    }
  }

  // Fungsi untuk menentukan warna teks status
  Color _getStatusTextColor(String? status) {
    if (status == null) return Colors.grey.shade700;

    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'approved':
        return const Color(0xFF2196F3); // Biru sesuai permintaan
      case 'diajukan':
      case 'submitted':
        return const Color(0xFFEF6C00); // Oranye gelap
      case 'ditolak':
      case 'rejected':
        return const Color(0xFFC62828); // Merah gelap
      default:
        return Colors.grey.shade700;
    }
  }
}