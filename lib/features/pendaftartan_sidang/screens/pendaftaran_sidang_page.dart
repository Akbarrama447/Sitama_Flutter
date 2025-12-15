import 'package:flutter/material.dart';
import '../constants/sidang_colors.dart';
import 'revisi_page.dart';
import '../models/jadwal_sidang_model.dart';
import '../models/status_pendaftaran_model.dart';
import '../services/jadwal_sidang_service.dart';
import '../services/document_list_service.dart';
import '../models/document_model.dart';

class PendaftaranSidangPage extends StatefulWidget {
  const PendaftaranSidangPage({super.key});

  @override
  State<PendaftaranSidangPage> createState() => _PendaftaranSidangPageState();
}

class _PendaftaranSidangPageState extends State<PendaftaranSidangPage> {
  final TextEditingController _judulController = TextEditingController();

  // Logic Status Revisi (True = Butuh Revisi/Biru, False = Lulus/Abu)
  bool isRevisiNeeded = true;
  bool _allDocumentsVerified = false;
  bool _isLoading = true;
  List<JadwalSidang> _jadwalList = [];
  JadwalSidang? _selectedJadwal;
  bool _isSubmitting = false;
  StatusPendaftaranResponse? _statusPendaftaran;
  bool _isCheckingStatus = true;

  @override
  void initState() {
    super.initState();
    _checkStatusPendaftaran();
  }

  Future<void> _checkStatusPendaftaran() async {
    setState(() {
      _isCheckingStatus = true;
    });

    try {
      // Cek status pendaftaran terlebih dahulu
      StatusPendaftaranResponse? statusResponse = await JadwalSidangService.getStatusPendaftaran();

      if (statusResponse != null && statusResponse.status == 'success') {
        setState(() {
          _statusPendaftaran = statusResponse;
        });

        // Jika mahasiswa belum mendaftar, cek dokumen untuk menentukan apakah bisa mendaftar
        if (statusResponse.data == null) {
          // Mahasiswa belum daftar, lanjutkan dengan cek dokumen
          await _checkAllDocumentsVerified();
        }
      } else {
        // Jika gagal mendapatkan status, tetap coba cek dokumen sebagai fallback
        await _checkAllDocumentsVerified();
      }
    } catch (e) {
      print('Error saat mengecek status pendaftaran: $e');
      await _checkAllDocumentsVerified(); // fallback ke cek dokumen
    } finally {
      setState(() {
        _isCheckingStatus = false;
      });
    }
  }

  Future<void> _checkAllDocumentsVerified() async {
    try {
      List<Map<String, dynamic>>? uploadedDocuments = await DocumentListService.getUploadedDocuments();

      // Kita mengasumsikan bahwa semua dokumen yang diperlukan memiliki ID dari 1-8
      List<int> requiredDocumentIds = [1, 2, 3, 4, 5, 6, 7, 8];

      bool allVerified = true;

      // Periksa apakah semua dokumen yang diperlukan sudah diupload dan terverifikasi
      for (int docId in requiredDocumentIds) {
        Map<String, dynamic>? uploadedDoc = uploadedDocuments?.firstWhere(
          (doc) => doc['dokumen_id'] == docId,
          orElse: () => {},
        );

        if (uploadedDoc == null || uploadedDoc.isEmpty) {
          // Dokumen ini belum diupload
          allVerified = false;
          break;
        }

        // Periksa apakah dokumen ini terverifikasi
        if (uploadedDoc['verified'] != 1) {
          // Dokumen ini sudah diupload tapi belum terverifikasi
          allVerified = false;
          break;
        }
      }

      if (allVerified && _statusPendaftaran?.data == null) {
        // Jika semua dokumen terverifikasi dan belum mendaftar, ambil jadwal sidang yang tersedia
        await _loadJadwalTersedia();
      }

      setState(() {
        _allDocumentsVerified = allVerified;
        _isLoading = false;
      });

      if (!allVerified && _statusPendaftaran?.data == null) {
        // Tampilkan pesan bahwa semua dokumen harus terverifikasi
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showErrorDialog(
            'Tidak dapat mengakses pendaftaran sidang. Harap pastikan semua dokumen persyaratan sudah diupload dan terverifikasi.'
          );
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error saat memeriksa status dokumen: $e');
    }
  }

  Future<void> _loadJadwalTersedia() async {
    try {
      List<JadwalSidang>? jadwalTersedia = await JadwalSidangService.getJadwalTersedia();

      if (jadwalTersedia != null) {
        setState(() {
          _jadwalList = jadwalTersedia;
        });
      } else {
        print('Gagal memuat jadwal sidang');
      }
    } catch (e) {
      print('Error saat memuat jadwal sidang: $e');
    }
  }

  // --- DIALOG LOGIC ---
  void _showKonfirmasiDialog() {
    // Validasi apakah semua dokumen terverifikasi sebelum izinkan pendaftaran
    if (!_allDocumentsVerified) {
      _showErrorDialog('Tidak dapat melanjutkan pendaftaran sidang. Harap pastikan semua dokumen persyaratan sudah terverifikasi.');
      return;
    }

    // Validasi apakah judul dan jadwal sudah diisi
    if (_judulController.text.trim().isEmpty) {
      _showErrorDialog('Silakan lengkapi judul tugas akhir.');
      return;
    }

    if (_selectedJadwal == null) {
      _showErrorDialog('Silakan pilih jadwal sidang terlebih dahulu.');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.white),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close,
                            size: 28, color: Colors.black54))),
                const SizedBox(height: 10),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFF263238), width: 3)),
                  child: const Center(
                      child: Text("!",
                          style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF263238)))),
                ),
                const SizedBox(height: 20),
                const Text("APAKAH ANDA YAKIN?",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF263238)),
                    textAlign: TextAlign.center),
                const SizedBox(height: 30),
                SizedBox(
                  width: 100,
                  height: 35,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _prosesPendaftaran(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: SidangColors.buttonBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    child: const Text("Ya",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }


  // Fungsi untuk proses pendaftaran sidang
  void _prosesPendaftaran(BuildContext context) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Panggil API untuk mendaftarkan sidang
      PendaftaranResponse? result = await JadwalSidangService.daftarSidang(
        judul: _judulController.text.trim(),
        jadwalSidangId: _selectedJadwal!.id,
      );

      if (result != null && result.status == 'success') {
        // Tampilkan pesan sukses
        _showSuccessDialog();
      } else {
        String errorMessage = result?.message ?? 'Gagal mendaftarkan sidang';
        _showErrorDialog('Pendaftaran gagal: $errorMessage');
      }
    } catch (e) {
      // Tampilkan pesan error
      _showErrorDialog('Gagal memproses pendaftaran: ${e.toString()}');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Berhasil"),
          content: const Text("Dokumen persyaratan sidang berhasil disimpan."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup success dialog
                Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF455A64),
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(color: Color(0xFF263238), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: SidangColors.buttonBlue, borderRadius: BorderRadius.circular(15)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingStatus) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Memeriksa status pendaftaran...'),
            ],
          ),
        ),
      );
    }

    // Jika mahasiswa sudah mendaftar, tampilkan detail pendaftaran
    if (_statusPendaftaran?.data != null) {
      return _buildPendaftaranDetail();
    }

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Memeriksa status dokumen...'),
            ],
          ),
        ),
      );
    }

    if (!_allDocumentsVerified) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_rounded,
                  size: 80,
                  color: Colors.orange,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pendaftaran Sidang Belum Dapat Dilakukan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Harap lengkapi dan verifikasi semua dokumen persyaratan terlebih dahulu.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 200,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Kembali ke halaman sebelumnya
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SidangColors.buttonBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Kembali',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Suko Tyas',
                      style: TextStyle(
                          color: SidangColors.headerTextBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _checkStatusPendaftaran,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 250,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFE3F2FD), Colors.white]),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  width: double.infinity,
                                  height: 4,
                                  color: SidangColors.cardTopBorderBlue),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(20, 20, 20, 15),
                                  child: Text('Pendaftaran Sidang',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF37474F)))),
                              const Divider(
                                  height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel(
                                        label: 'Judul Final Tugas Akhir',
                                        isRequired: true),
                                    const SizedBox(height: 8),
                                    _buildTextField(
                                        controller: _judulController,
                                        hintText:
                                            'Masukan Judul Final Tugas Akhir'),
                                    const SizedBox(height: 20),
                                    _buildLabel(
                                        label: 'Pilih Jadwal Sidang',
                                        isRequired: false),
                                    const SizedBox(height: 8),
                                    _buildDropdown(),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(
                                  height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 25.0),
                                child: Center(
                                  child: SizedBox(
                                    width: 150,
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: _isSubmitting ? null : _showKonfirmasiDialog,
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: _isSubmitting
                                              ? Colors.grey
                                              : SidangColors.buttonBlue,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6))),
                                      child: _isSubmitting
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Text('Daftar Sidang',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildPendaftaranDetail() {
    final pendaftaran = _statusPendaftaran!.data!;
    final jadwal = pendaftaran.pendaftaranSidang.jadwalSidang;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Suko Tyas',
                      style: TextStyle(
                          color: SidangColors.headerTextBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _checkStatusPendaftaran,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 250,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFE3F2FD), Colors.white]),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  width: double.infinity,
                                  height: 4,
                                  color: SidangColors.cardTopBorderBlue),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(20, 20, 20, 15),
                                  child: Text('Detail Pendaftaran Sidang',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF37474F)))),
                              const Divider(
                                  height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDetailInfoRow('Judul Tugas Akhir', pendaftaran.tugasAkhir.judul),
                                    _buildDetailInfoRow('Status Tugas Akhir', pendaftaran.tugasAkhir.status),
                                    _buildDetailInfoRow('Tanggal Sidang', jadwal.tanggal),
                                    _buildDetailInfoRow('Waktu Sidang', '${jadwal.sesi.jamMulai} - ${jadwal.sesi.jamSelesai}'),
                                    _buildDetailInfoRow('Ruangan', jadwal.ruangan.namaRuangan),
                                    _buildDetailInfoRow('Tanggal Daftar', _formatTanggal(pendaftaran.pendaftaranSidang.tanggalDaftar)),
                                    _buildDetailInfoRow('Status Pendaftaran', pendaftaran.pendaftaranSidang.status),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(
                                  height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 25.0),
                                child: Center(
                                  child: Text(
                                    'Anda sudah terdaftar pada jadwal sidang ini',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  String _formatTanggal(String tanggal) {
    // Format tanggal dari "2025-01-10T10:30:00Z" menjadi "10 Januari 2025, 10:30"
    try {
      DateTime dateTime = DateTime.parse(tanggal);
      String bulan = _getNamaBulan(dateTime.month);
      return '${dateTime.day} $bulan ${dateTime.year}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return tanggal; // Jika gagal format, kembalikan tanggal asli
    }
  }

  String _getNamaBulan(int bulan) {
    const List<String> namaBulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return namaBulan[bulan];
  }

  Widget _buildDetailInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF455A64),
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(color: Color(0xFF263238), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildLabel({required String label, required bool isRequired}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF455A64),
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto'),
        children: isRequired
            ? const [
                TextSpan(
                    text: ' *',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold))
              ]
            : [],
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller, required String hintText}) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
          color: _statusPendaftaran?.data != null ? Colors.grey[100] : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: SidangColors.borderColor)),
      child: TextField(
        controller: controller,
        enabled: _statusPendaftaran?.data == null,
        style: TextStyle(fontSize: 13, color: _statusPendaftaran?.data != null ? Colors.grey : Colors.black87),
        decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 12)),
      ),
    );
  }

  Widget _buildDropdown() {
    if (_jadwalList.isEmpty) {
      return Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: SidangColors.borderColor)),
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text("Tidak ada jadwal tersedia",
              style: TextStyle(color: Colors.grey, fontSize: 13)),
        ),
      );
    }

    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: SidangColors.borderColor)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<JadwalSidang>(
          value: _selectedJadwal,
          hint: const Text("Pilih jadwal sidang",
              style: TextStyle(color: Colors.grey, fontSize: 13)),
          icon: const Icon(Icons.arrow_drop_down),
          isExpanded: true,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          onChanged: _isSubmitting || _statusPendaftaran?.data != null
              ? null
              : (JadwalSidang? value) {
                  setState(() {
                    _selectedJadwal = value;
                  });
                },
          items: _jadwalList
              .map((jadwal) => DropdownMenuItem(
                    value: jadwal,
                    child: Text(
                      '${jadwal.tanggal} ${jadwal.sesi.jamMulai}-${jadwal.sesi.jamSelesai} (${jadwal.ruangan.namaRuangan})',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

}

