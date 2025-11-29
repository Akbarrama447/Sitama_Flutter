import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Untuk delay simulasi upload

// ====================================================================
// --- BAGIAN 1: SETUP UTAMA (MAIN) ---
// ====================================================================

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PageState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Sidang',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
      // HALAMAN PERTAMA YANG DIBUKA ADALAH PERSYARATAN SIDANG
      home: const PersyaratanSidangScreen(),
    );
  }
}

// ====================================================================
// --- BAGIAN 2: LOGIKA DATA (PROVIDER) ---
// ====================================================================

enum DocumentStatus { waiting, verified, rejected }

class DocumentItemModel {
  final int id;
  final String label;
  String filename;
  DocumentStatus status;

  DocumentItemModel(this.id, this.label, this.filename, this.status);
}

class PageState extends ChangeNotifier {
  // Data Dokumen
  final List<DocumentItemModel> _documents = [
    DocumentItemModel(1, 'Surat Keterangan Magang', 'suratketerangan.pdf',
        DocumentStatus.rejected),
    DocumentItemModel(
        2, 'Transkrip Nilai', 'transkrip.pdf', DocumentStatus.verified),
    DocumentItemModel(3, 'Sertifikat TOEFL', '', DocumentStatus.waiting),
    DocumentItemModel(4, 'Kartu Bimbingan', '', DocumentStatus.waiting),
    DocumentItemModel(5, 'Bukti Pembayaran', '', DocumentStatus.waiting),
    DocumentItemModel(6, 'Ijazah Terakhir', '', DocumentStatus.waiting),
  ];

  List<DocumentItemModel> get documents => _documents;

  // Cek apakah semua dokumen sudah VERIFIED (Biru)
  bool get isRegistrationEnabled {
    return _documents.every((doc) => doc.status == DocumentStatus.verified);
  }

  // Fungsi Simulasi Upload
  void uploadDocument(int id, String newFilename) {
    final index = _documents.indexWhere((doc) => doc.id == id);
    if (index != -1) {
      _documents[index].filename = newFilename;
      _documents[index].status =
          DocumentStatus.waiting; // Reset jadi waiting setelah upload
      notifyListeners();
    }
  }

  // Fungsi DEBUG: Buat semua verified (Untuk testing tombol Daftar Sidang)
  void debugVerifyAll() {
    for (var doc in _documents) {
      doc.status = DocumentStatus.verified;
      doc.filename = "file_verified.pdf";
    }
    notifyListeners();
  }
}

// ====================================================================
// --- BAGIAN 3: HALAMAN PERSYARATAN SIDANG (PAGE 1) ---
// ====================================================================

class PersyaratanSidangScreen extends StatelessWidget {
  const PersyaratanSidangScreen({super.key});

  // Palet Warna
  static const Color headerTextBlue = Color(0xFF0D47A1);
  static const Color cardTopBorderBlue = Color(0xFF2196F3);
  static const Color primaryBtnBlue = Color(0xFF0091EA);
  static const Color secondaryBtnGray = Color(0xFF9E9E9E);

  static const Color statusRedBg = Color(0xFFFFCDD2);
  static const Color statusRedText = Color(0xFFD32F2F);
  static const Color statusBlueBg = Color(0xFFB3E5FC);
  static const Color statusBlueText = Color(0xFF0277BD);
  static const Color statusGrayBorder = Color(0xFFBDBDBD);
  static const Color statusGrayText = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Nama
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              alignment: Alignment.centerRight,
              child: GestureDetector(
                // Fitur Rahasia: Klik nama "Suko Tyas" untuk men-verify semua data (Debug)
                onLongPress: () {
                  Provider.of<PageState>(context, listen: false)
                      .debugVerifyAll();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("DEBUG: Semua dokumen diverifikasi!")));
                },
                child: const Text(
                  "Suko Tyas",
                  style: TextStyle(
                      color: headerTextBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),

            // Banner Gradient
            Container(
              height: 60,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE3F2FD), Colors.white],
                ),
              ),
            ),

            // MAIN CARD
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: 5,
                          width: double.infinity,
                          color: cardTopBorderBlue),

                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Text(
                          'Persyaratan Sidang',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: headerTextBlue),
                        ),
                      ),

                      const Divider(height: 1, color: Color(0xFFEEEEEE)),

                      // LIST DOKUMEN
                      Expanded(
                        child: Scrollbar(
                          thumbVisibility: true,
                          radius: const Radius.circular(10),
                          child: Consumer<PageState>(
                            builder: (context, pageState, child) {
                              return ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: pageState.documents.length,
                                itemBuilder: (context, index) {
                                  return DocumentItemWidget(
                                      item: pageState.documents[index]);
                                },
                              );
                            },
                          ),
                        ),
                      ),

                      // TOMBOL ACTION
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryBtnBlue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6)),
                                    elevation: 0,
                                  ),
                                  child: const Text('Simpan',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),

                            // TOMBOL DAFTAR SIDANG (NAVIGASI KE PAGE 2)
                            Expanded(
                              child: Consumer<PageState>(
                                  builder: (context, state, _) {
                                return SizedBox(
                                  height: 40,
                                  child: ElevatedButton(
                                    // JIKA ENABLED, PINDAH KE HALAMAN PENDAFTARAN
                                    onPressed: state.isRegistrationEnabled
                                        ? () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const PendaftaranSidangPage()),
                                            );
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          state.isRegistrationEnabled
                                              ? primaryBtnBlue
                                              : secondaryBtnGray,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: secondaryBtnGray,
                                      disabledForegroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      elevation: 0,
                                    ),
                                    child: const Text('Daftar Sidang',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// WIDGET ITEM DOKUMEN (PERSYARATAN)
class DocumentItemWidget extends StatelessWidget {
  final DocumentItemModel item;
  const DocumentItemWidget({super.key, required this.item});

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text("Upload ${item.label}",
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.cloud_upload_outlined, size: 60, color: Colors.blue),
              SizedBox(height: 15),
              Text("Pilih file PDF dari penyimpanan Anda."),
              SizedBox(height: 5),
              Text("(Maks. 2 MB)",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Mengupload ${item.label}...'),
                      duration: const Duration(seconds: 1)),
                );
                Future.delayed(const Duration(seconds: 1), () {
                  Provider.of<PageState>(context, listen: false).uploadDocument(
                      item.id, "file_baru_${DateTime.now().second}.pdf");
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("Pilih File",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color fillColor;
    Color textColor;
    Color borderColor;

    if (item.status == DocumentStatus.rejected) {
      fillColor = PersyaratanSidangScreen.statusRedBg;
      textColor = PersyaratanSidangScreen.statusRedText;
      borderColor = Colors.transparent;
    } else if (item.status == DocumentStatus.verified) {
      fillColor = PersyaratanSidangScreen.statusBlueBg;
      textColor = PersyaratanSidangScreen.statusBlueText;
      borderColor = Colors.transparent;
    } else {
      fillColor = Colors.white;
      textColor = PersyaratanSidangScreen.statusGrayText;
      borderColor = PersyaratanSidangScreen.statusGrayBorder;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF455A64))),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 23,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: borderColor,
                        width: 1.0,
                        style: item.status == DocumentStatus.waiting
                            ? BorderStyle.solid
                            : BorderStyle.none),
                  ),
                  child: Text(
                    item.filename.isEmpty ? "Belum ada file" : item.filename,
                    style: TextStyle(
                      color:
                          item.filename.isEmpty ? Colors.grey[400] : textColor,
                      fontSize: 14,
                      fontStyle: item.filename.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                child: InkWell(
                  onTap: () => _showUploadDialog(context),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 45,
                    width: 45,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: PersyaratanSidangScreen.statusGrayBorder),
                    ),
                    child: const Icon(Icons.file_upload_outlined,
                        color: PersyaratanSidangScreen.statusGrayText,
                        size: 24),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// --- 1. HALAMAN PENDAFTARAN SIDANG (MAIN) ---
// ====================================================================

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

  // --- CONFIG STATUS ---
  // Ubah variable ini menjadi false untuk melihat tombol jadi abu-abu
  bool isRevisiNeeded = true;

  // --- PALET WARNA ---
  static const Color headerTextBlue = Color(0xFF0D47A1);
  static const Color cardTopBorderBlue = Color(0xFF2196F3);
  static const Color buttonBlue = Color(0xFF039BE5);
  static const Color borderColor = Color(0xFFCFD8DC);
  static const Color dividerColor = Color(0xFFEEEEEE);
  static const Color darkText = Color(0xFF263238);

  // --- LOGIKA DIALOG ---

  // 1. Dialog Konfirmasi "Apakah Anda Yakin?" (Image 2)
  void _showKonfirmasiDialog() {
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
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol X di kiri atas
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close,
                        size: 28, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 10),

                // Ikon Tanda Seru Besar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFF263238), width: 3),
                  ),
                  child: const Center(
                    child: Text("!",
                        style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF263238))),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "APAKAH ANDA YAKIN?",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263238)),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                // Tombol Ya
                SizedBox(
                  width: 100,
                  height: 35,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Tutup dialog konfirmasi
                      _showInfoDialog(); // Buka dialog informasi
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
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

  // 2. Dialog Informasi Hasil / Kartu Mahasiswa (Image 1)
  void _showInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(15), // Agar card lebar
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SingleChildScrollView(
              // Agar tidak error di layar kecil
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // HEADER BIRU
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: buttonBlue, // Warna biru cerah
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "FARHAN DWI CAHYANTO",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "3.34.24.2.11 - D3 Teknik Informatika",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  // BODY PUTIH
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                            "Judul Tugas Akhir", "Sensor Pendeteksi Semut"),
                        _buildInfoRow("Deskripsi", "Alat sensor pendeteksi"),
                        _buildInfoRow(
                            "Dosen Pembimbing", "1. Pak Suko\n2. Pak Amran"),
                        _buildInfoRow(
                            "Dosen Penguji", "1. Pak Suko\n2. Pak Amran"),
                        _buildInfoRow("Sekretaris", "Wiktasari"),

                        const SizedBox(height: 10),

                        // Badges (Lab & Jam)
                        Row(
                          children: [
                            _buildBadge("Lab Multimedia SB II/04"),
                            const SizedBox(width: 10),
                            _buildBadge("08:00 WIB"),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Divider(thickness: 1, color: dividerColor),
                        const SizedBox(height: 20),

                        // TOMBOL REVISI (LOGIKA)
                        Center(
                          child: SizedBox(
                            width: 150,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: isRevisiNeeded
                                  ? () {
                                      Navigator.pop(context); // Tutup dialog
                                      // Navigasi ke Page Revisi
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const RevisiPage()),
                                      );
                                    }
                                  : null, // Jika null, tombol otomatis disable (abu-abu)
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonBlue, // Biru jika aktif
                                disabledBackgroundColor:
                                    Colors.grey[300], // Abu jika nonaktif
                                disabledForegroundColor: Colors.grey[600],
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              child: const Text("Revisi",
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

  // Helper Widget untuk Baris Info di Dialog
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

  // Helper Widget untuk Badge Biru
  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: buttonBlue,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  // --- MAIN BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: const Align(
                alignment: Alignment.centerRight,
                child: Text('Suko Tyas',
                    style: TextStyle(
                        color: headerTextBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: dividerColor),

            // Konten
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
                          colors: [Color(0xFFE3F2FD), Colors.white],
                        ),
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
                                offset: const Offset(0, 2)),
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
                                  color: cardTopBorderBlue),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(20, 20, 20, 15),
                                child: Text('Pendaftaran Sidang',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF37474F))),
                              ),
                              const Divider(
                                  height: 1, thickness: 1, color: dividerColor),
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
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(
                                  height: 1, thickness: 1, color: dividerColor),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 25.0),
                                child: Center(
                                  child: SizedBox(
                                    width: 150,
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed:
                                          _showKonfirmasiDialog, // Memicu dialog konfirmasi
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: buttonBlue,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                      ),
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

  // --- Helper Widgets untuk PendaftaranSidangPage ---
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
          border: Border.all(color: borderColor)),
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
          border: Border.all(color: borderColor)),
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

// ====================================================================
// --- 2. HALAMAN UPLOAD REVISI (DENGAN FUNGSI UPLOAD) ---
// ====================================================================

class RevisiPage extends StatefulWidget {
  const RevisiPage({super.key});

  @override
  State<RevisiPage> createState() => _RevisiPageState();
}

class _RevisiPageState extends State<RevisiPage> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _fileController =
      TextEditingController(); // Untuk nama file

  static const Color headerTextBlue = Color(0xFF0D47A1);
  static const Color cardTopBorderBlue = Color(0xFF2196F3);
  static const Color buttonBlue = Color(0xFF039BE5);
  static const Color borderColor = Color(0xFFCFD8DC);
  static const Color dividerColor = Color(0xFFEEEEEE);

  // --- FUNGSI POPUP UPLOAD (Sama seperti di Persyaratan Sidang) ---
  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Upload Revisi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.cloud_upload_outlined, size: 60, color: Colors.blue),
              SizedBox(height: 15),
              Text("Pilih file PDF revisi Anda."),
              SizedBox(height: 5),
              Text("(Maks. 5 MB)",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog

                // Tampilkan loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Mengupload revisi...'),
                      duration: Duration(seconds: 1)),
                );

                // Simulasi delay upload, lalu update nama file
                Future.delayed(const Duration(seconds: 1), () {
                  setState(() {
                    _fileController.text =
                        "revisi_final_v2.pdf"; // Nama file otomatis terisi
                  });
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("Pilih File",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: const Align(
                alignment: Alignment.centerRight,
                child: Text('Suko Tyas',
                    style: TextStyle(
                        color: headerTextBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: dividerColor),

            Expanded(
              child: Stack(
                children: [
                  // Gradient Background
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
                          colors: [Color(0xFFE3F2FD), Colors.white],
                        ),
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
                                offset: const Offset(0, 2)),
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
                                  color: cardTopBorderBlue),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(20, 20, 20, 15),
                                child: Text('Upload Revisi',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF37474F))),
                              ),
                              const Divider(
                                  height: 1, thickness: 1, color: dividerColor),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel("Judul"),
                                    const SizedBox(height: 8),
                                    _buildTextField(
                                        controller: _judulController,
                                        hintText: "Judul baru"),
                                    const SizedBox(height: 20),
                                    _buildLabel("Revisian"),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        // Input Text (Read Only)
                                        Expanded(
                                          child: _buildTextField(
                                              controller: _fileController,
                                              hintText: "revisian.pdf",
                                              enabled: false),
                                        ),
                                        const SizedBox(width: 10),

                                        // TOMBOL UPLOAD (Icon Button)
                                        Material(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: InkWell(
                                            onTap: () => _showUploadDialog(
                                                context), // Memicu Dialog Upload
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: Container(
                                              height: 45,
                                              width: 45,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: borderColor),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: const Icon(
                                                  Icons.description_outlined,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(
                                  height: 1, thickness: 1, color: dividerColor),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 25.0),
                                child: Center(
                                  child: SizedBox(
                                    width: 150,
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Validasi sederhana
                                        if (_fileController.text.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      "Harap upload file revisi dulu!")));
                                          return;
                                        }

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Revisi Berhasil Dikirim!")));
                                        Navigator.pop(
                                            context); // Kembali ke halaman sebelumnya
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: buttonBlue,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                      ),
                                      child: const Text('Upload',
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

  Widget _buildLabel(String label) {
    return Text(label,
        style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF455A64),
            fontWeight: FontWeight.w500));
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String hintText,
      bool enabled = true}) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor)),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
      ),
    );
  }
}

class DummyPage extends StatelessWidget {
  final String title;
  const DummyPage({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5),
      body: Center(
          child: Text(title,
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center)),
    );
  }
}
