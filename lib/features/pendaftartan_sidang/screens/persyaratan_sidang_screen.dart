import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/document_model.dart';
import '../widgets/document_item_widget.dart';
import '../constants/sidang_colors.dart';
import 'pendaftaran_sidang_page.dart';
import '../services/document_upload_service.dart';
import '../services/document_list_service.dart';
import '../../../core/services/upload_status_manager.dart';
import '../../../main.dart'; // untuk mengakses storageService
import '../../../core/services/api_service.dart'; // untuk akses API bimbingan

class PersyaratanSidangScreen extends StatefulWidget {
  const PersyaratanSidangScreen({super.key});

  @override
  State<PersyaratanSidangScreen> createState() => _PersyaratanSidangScreenState();
}

class _PersyaratanSidangScreenState extends State<PersyaratanSidangScreen> {
  List<DocumentItemModel> documents = [];
  bool isLoading = false; // Gak perlu loading karena pake data lokal dulu
  String? errorMessage;
  bool _allDocumentsUploaded = false;

  // Variabel state untuk menyimpan nama user
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final storedName = await storageService.getUserName();
      if (storedName != null && storedName != 'Memuat...') {
        setState(() {
          _userName = storedName;
        });
      }
    } catch (e) {
      debugPrint('Error saat mengambil nama user dari storage: $e');
      // Biarkan _userName tetap 'User' sebagai fallback
    }
    // Setelah ambil nama, baru load status dokumen
    // Set ke mode API sekarang untuk upload
    DocumentUploadService.useApi = true;
    _loadDocumentsStatus(); // Load status dokumen dari storage
  }

  Future<void> _loadDocumentsStatus() async {
    // Buat dokumen default
    List<DocumentItemModel> defaultDocuments = [
      DocumentItemModel(1, 'Proposal', '', DocumentStatus.waiting),
      DocumentItemModel(2, 'Laporan Akhir', '', DocumentStatus.waiting),
      DocumentItemModel(3, 'Transkrip Nilai', '', DocumentStatus.waiting),
      DocumentItemModel(4, 'KRS', '', DocumentStatus.waiting),
      DocumentItemModel(5, 'Surat Keterangan Aktif', '', DocumentStatus.waiting),
      DocumentItemModel(6, 'Persetujuan Pembimbing', '', DocumentStatus.waiting),
      DocumentItemModel(7, 'Beasiswa', '', DocumentStatus.waiting),
      DocumentItemModel(8, 'Logbook Bimbingan', '', DocumentStatus.waiting),
    ];

    // Ambil data dokumen dari API dulu (data paling akurat)
    List<Map<String, dynamic>>? uploadedFromApi = await DocumentListService.getUploadedDocuments();

    if (uploadedFromApi != null) {
      // Perbarui status dokumen berdasarkan data dari API
      for (var apiDoc in uploadedFromApi) {
        int dokumenId = apiDoc['dokumen_id'];
        String filename = apiDoc['dokumen_file_original'];
        int verified = apiDoc['verified'];

        int index = defaultDocuments.indexWhere((doc) => doc.id == dokumenId);
        if (index != -1) {
          // Update status dokumen berdasarkan data dari API
          defaultDocuments[index].filename = filename;
          defaultDocuments[index].status = verified == 1
              ? DocumentStatus.verified
              : DocumentStatus.uploaded; // Gunakan uploaded sementara jika belum verified
        }
      }
    } else {
      // Jika tidak bisa mengambil data dari API, coba gunakan data dari storage lokal
      List<DocumentItemModel> savedUploadedDocuments = await UploadStatusManager.getDocumentsStatus();

      if (savedUploadedDocuments.isNotEmpty) {
        // Jika ada dokumen yang tersimpan, perbarui status dokumen default sesuai dengan yang tersimpan
        for (var savedDoc in savedUploadedDocuments) {
          int index = defaultDocuments.indexWhere((doc) => doc.id == savedDoc.id);
          if (index != -1) {
            defaultDocuments[index] = savedDoc;
          }
        }
      }
    }

    setState(() {
      documents = defaultDocuments;
    });

    // Load status kelengkapan dokumen
    final status = await UploadStatusManager.getAllDocumentsUploaded();
    setState(() {
      _allDocumentsUploaded = status;
    });

    // Cek juga status bimbingan setelah load dokumen
    await _checkBimbinganStatus();
  }

  bool _bimbinganCompleted = false; // Tambahkan state untuk status bimbingan

  // Fungsi untuk cek status bimbingan
  Future<void> _checkBimbinganStatus() async {
    try {
      String? token = await storageService.getToken();
      if (token == null) {
        debugPrint('Token tidak ditemukan untuk cek status bimbingan');
        return;
      }

      // Ambil data pembimbing
      List<dynamic> pembimbingList = await ApiService.getPembimbing(token);

      if (pembimbingList.isEmpty) {
        setState(() {
          _bimbinganCompleted = false;
        });
        return;
      }

      // Target jumlah bimbingan yang harus diselesaikan
      const int targetBimbingan = 8;

      bool allPembimbingCompleted = true;

      // Cek setiap pembimbing
      for (var pembimbing in pembimbingList) {
        int urutan = pembimbing['urutan'];

        // Ambil log bimbingan untuk pembimbing ini
        List<dynamic> logBimbingan = await ApiService.getLogBimbingan(token, urutan: urutan);

        // Hitung jumlah log bimbingan yang approved (status = 1)
        // Konversi status ke integer untuk memastikan tipe datanya benar
        int approvedCount = logBimbingan.where((log) {
          int status = 0;
          try {
            status = int.tryParse(log['status'].toString()) ?? 0;
          } catch (e) {
            status = 0;
          }
          return status == 1;
        }).length;

        // Jika jumlah approved log kurang dari target, maka bimbingan belum selesai
        if (approvedCount < targetBimbingan) {
          allPembimbingCompleted = false;
          break;
        }
      }

      setState(() {
        _bimbinganCompleted = allPembimbingCompleted;
      });
    } catch (e) {
      debugPrint('Error saat cek status bimbingan: $e');
      setState(() {
        _bimbinganCompleted = false;
      });
    }
  }

  bool get isRegistrationEnabled {
    // Cek apakah semua dokumen verified ATAU status sebelumnya sudah diupload semua
    bool allDocumentsVerified = documents.every((doc) => doc.status == DocumentStatus.verified);

    // Gabungkan dengan status bimbingan
    bool documentsReady = allDocumentsVerified || _allDocumentsUploaded;

    // Registrasi enabled jika dokumen siap DAN bimbingan selesai
    return documentsReady && _bimbinganCompleted;
  }

  // Fungsi untuk cek apakah semua dokumen udah diupload (belum tentu verified)
  bool get isAllDocumentsUploaded {
    // Cek apakah semua dokumen udah diupload (status uploaded atau verified)
    bool allUploaded = documents.every((doc) =>
      doc.status == DocumentStatus.uploaded || doc.status == DocumentStatus.verified
    );
    return allUploaded;
  }

  Future<void> _saveDocumentsStatus() async {
    await UploadStatusManager.setDocumentsStatus(documents);
  }

  Future<void> _setAllDocumentsUploadedStatus(bool status) async {
    await UploadStatusManager.setAllDocumentsUploaded(status);

    setState(() {
      _allDocumentsUploaded = status;
    });
  }

  void _checkAndUpdateUploadStatus() {
    bool allVerified = documents.every((doc) => doc.status == DocumentStatus.verified);
    if (allVerified) {
      _setAllDocumentsUploadedStatus(true);
    }

    // Cek ulang status bimbingan setelah update dokumen
    _checkBimbinganStatus();
  }

  Future<void> _clearUploadStatus() async {
    await UploadStatusManager.clearUploadStatus();
    setState(() {
      _allDocumentsUploaded = false;
      // Reset semua dokumen ke status awal
      for (var doc in documents) {
        doc.status = DocumentStatus.waiting;
        doc.filename = '';
      }
    });
  }

  Future<void> _resetDocumentStatus(int documentId) async {
    await UploadStatusManager.resetDocumentStatus(documentId);

    // Update status dokumen lokal
    int index = documents.indexWhere((doc) => doc.id == documentId);
    if (index != -1) {
      setState(() {
        documents[index].status = DocumentStatus.waiting;
        documents[index].filename = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading jika dokumen belum dimuat
    if (documents.isEmpty) {
      return Scaffold(
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Memuat dokumen...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header dengan tombol kembali dan nama
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol kembali
                  InkWell(
                    onTap: () {
                      // Pop semua screen hingga ke home
                      Navigator.of(context).popUntil(ModalRoute.withName(Navigator.defaultRouteName));
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: SidangColors.headerTextBlue,
                      size: 24,
                    ),
                  ),
                  // Nama
                  Text(
                    _userName,
                    style: const TextStyle(
                        color: SidangColors.headerTextBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  // Spacer untuk menjaga keseimbangan layout
                  const SizedBox(width: 24), // Lebar sesuai dengan ikon
                ],
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
                          color: SidangColors.cardTopBorderBlue),

                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Text(
                          'Persyaratan Sidang',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: SidangColors.headerTextBlue),
                        ),
                      ),

                      const Divider(height: 1, color: Color(0xFFEEEEEE)),

                      // LIST DOKUMEN
                      Expanded(
                        child: Scrollbar(
                          thumbVisibility: true,
                          radius: const Radius.circular(10),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: documents.length,
                            itemBuilder: (context, index) {
                              if (documents.isEmpty) {
                                return const SizedBox.shrink(); // Jangan tampilkan apapun jika list kosong
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: DocumentItemWidget(
                                    item: documents[index],
                                    onDocumentUpdate: () {
                                      // Refresh UI setelah dokumen diupdate
                                      setState(() {});
                                      // Cek apakah semua dokumen sudah verified dan simpan statusnya
                                      _checkAndUpdateUploadStatus();
                                      // Simpan status semua dokumen
                                      _saveDocumentsStatus();
                                    }),
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
                                  onPressed: () {
                                    // Update semua dokumen menjadi verified
                                    setState(() {
                                      for (var doc in documents) {
                                        if (doc.status != DocumentStatus.verified) {
                                          doc.status = DocumentStatus.verified;
                                        }
                                      }
                                    });

                                    // Cek apakah semua dokumen sudah verified dan simpan statusnya
                                    _checkAndUpdateUploadStatus();
                                    // Simpan status semua dokumen
                                    _saveDocumentsStatus();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: SidangColors.primaryBtnBlue,
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

                            // TOMBOL DAFTAR SIDANG
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: isRegistrationEnabled
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
                                        isRegistrationEnabled
                                            ? SidangColors.primaryBtnBlue
                                            : SidangColors.secondaryBtnGray,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: SidangColors.secondaryBtnGray,
                                    disabledForegroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(6)),
                                    elevation: 0,
                                  ),
                                  child: isRegistrationEnabled
                                      ? const Text('Daftar Sidang',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14))
                                      : Text(
                                          _allDocumentsUploaded && _bimbinganCompleted
                                              ? 'Memuat...'
                                              : !_allDocumentsUploaded && !_bimbinganCompleted
                                                  ? 'Dokumen & Bimbingan Belum Lengkap'
                                                  : !_allDocumentsUploaded
                                                      ? 'Dokumen Belum Lengkap'
                                                      : 'Bimbingan Belum Lengkap',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.white),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

