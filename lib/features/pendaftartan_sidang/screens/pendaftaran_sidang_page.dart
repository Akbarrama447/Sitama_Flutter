import 'package:flutter/material.dart';
import '../constants/sidang_colors.dart';
import 'revisi_page.dart';
import '../services/sidang_registration_service.dart';
import '../services/document_list_service.dart';
import '../models/document_model.dart';

class PendaftaranSidangPage extends StatefulWidget {
  const PendaftaranSidangPage({super.key});

  @override
  State<PendaftaranSidangPage> createState() => _PendaftaranSidangPageState();
}

class _PendaftaranSidangPageState extends State<PendaftaranSidangPage> {
  final TextEditingController _judulController = TextEditingController();
  String? _selectedJadwal;
  final List<String> _listJadwal = [
    '01-12-2025, Senin 13.00-15.00',
    '02-12-2025, Selasa 09.00-11.00',
    '03-12-2025, Rabu 15.00-17.00',
  ];

  // Logic Status Revisi (True = Butuh Revisi/Biru, False = Lulus/Abu)
  bool isRevisiNeeded = true;
  bool _allDocumentsVerified = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAllDocumentsVerified();
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

      setState(() {
        _allDocumentsVerified = allVerified;
        _isLoading = false;
      });

      if (!allVerified) {
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

  // --- DIALOG LOGIC ---
  void _showKonfirmasiDialog() {
    // Validasi apakah semua dokumen terverifikasi sebelum izinkan pendaftaran
    if (!_allDocumentsVerified) {
      _showErrorDialog('Tidak dapat melanjutkan pendaftaran sidang. Harap pastikan semua dokumen persyaratan sudah terverifikasi.');
      return;
    }

    // Validasi apakah judul dan jadwal sudah diisi
    if (_judulController.text.isEmpty || _selectedJadwal == null) {
      _showErrorDialog('Silakan lengkapi judul tugas akhir dan pilih jadwal sidang terlebih dahulu.');
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
                      _showInfoDialog();
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

  void _showInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Disable dismiss to prevent accidental closure during upload
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: SidangColors.buttonBlue,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("FARHAN DWI CAHYANTO",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Text("3.34.24.2.11 - D3 Teknik Informatika",
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                            "Judul Tugas Akhir", _judulController.text),
                        _buildInfoRow("Deskripsi", "Alat sensor pendeteksi"),
                        _buildInfoRow(
                            "Dosen Pembimbing", "1. Pak Suko\n2. Pak Amran"),
                        _buildInfoRow(
                            "Dosen Penguji", "1. Pak Suko\n2. Pak Amran"),
                        _buildInfoRow("Sekretaris", "Wiktasari"),
                        const SizedBox(height: 10),
                        Row(children: [
                          _buildBadge(_selectedJadwal ?? "Belum dipilih"),
                          const SizedBox(width: 10),
                          _buildBadge("08:00 WIB")
                        ]),
                        const SizedBox(height: 20),
                        const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 20),
                        Center(
                          child: SizedBox(
                            width: 150,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                // Proses pendaftaran sidang
                                _prosesPendaftaran(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: SidangColors.buttonBlue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              child: const Text("Daftar Sidang",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Fungsi untuk proses pendaftaran sidang
  void _prosesPendaftaran(BuildContext context) async {
    // Tutup dialog info
    Navigator.pop(context);

    try {
      // Panggil API untuk mendaftarkan sidang
      Map<String, dynamic>? result = await SidangRegistrationService.registerSidang(
        judulTa: _judulController.text,
        jadwalSidang: _selectedJadwal!,
      );

      if (result != null && result['success'] == true) {
        // Tampilkan pesan sukses
        _showSuccessDialog();
      } else {
        String errorMessage = result?['message'] ?? 'Gagal mendaftarkan sidang';
        _showErrorDialog('Pendaftaran gagal: $errorMessage');
      }
    } catch (e) {
      // Tampilkan pesan error
      _showErrorDialog('Gagal memproses pendaftaran: ${e.toString()}');
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
              child: const Align(
                  alignment: Alignment.centerRight,
                  child: Text('Suko Tyas',
                      style: TextStyle(
                          color: SidangColors.headerTextBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14))),
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
                                      onPressed: _showKonfirmasiDialog,
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: SidangColors.buttonBlue,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6))),
                                      child: const Text('Daftar Sidang',
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: SidangColors.borderColor)),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
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
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: SidangColors.borderColor)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedJadwal,
          hint: const Text("",
              style: TextStyle(color: Colors.grey, fontSize: 13)),
          icon: const SizedBox.shrink(),
          isExpanded: true,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          onChanged: (val) => setState(() => _selectedJadwal = val),
          items: _listJadwal
              .map((val) => DropdownMenuItem(value: val, child: Text(val)))
              .toList(),
        ),
      ),
    );
  }

}

