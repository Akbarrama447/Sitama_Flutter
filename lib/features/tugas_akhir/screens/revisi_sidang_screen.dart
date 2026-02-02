import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../services/revisi_service.dart';
import '../../../main.dart'; // untuk mengakses storageService
import '../../pendaftartan_sidang/constants/sidang_colors.dart'; // Import warna biru dari halaman sidang
import '../../../core/services/api_service.dart'; // Import ApiService

class RevisiSidangScreen extends StatefulWidget {
  final String token;
  final List<Map<String, dynamic>>? revisiList;

  const RevisiSidangScreen({
    Key? key,
    required this.token,
    this.revisiList,
  }) : super(key: key);

  @override
  State<RevisiSidangScreen> createState() => _RevisiSidangScreenState();
}

class _RevisiSidangScreenState extends State<RevisiSidangScreen> {
  List<Map<String, dynamic>>? _revisiList;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRevisiData();
  }

  Future<void> _loadRevisiData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Jika revisiList sudah disediakan dari parameter, gunakan itu
      if (widget.revisiList != null) {
        _revisiList = widget.revisiList;
      } else {
        // Jika tidak, ambil dari API
        final data = await RevisiService.getRevisiData(widget.token);
        _revisiList = data;
      }

      // Urutkan berdasarkan updated_at terbaru
      if (_revisiList != null) {
        _revisiList!.sort((a, b) {
          final updatedAtA = DateTime.parse(a['updated_at']);
          final updatedAtB = DateTime.parse(b['updated_at']);
          return updatedAtB.compareTo(updatedAtA);
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol kembali
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: SidangColors.headerTextBlue,
                      size: 24,
                    ),
                  ),
                  // Judul
                  const Text(
                    'Detail Revisi',
                    style: TextStyle(
                      color: SidangColors.headerTextBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  // Spacer untuk menjaga keseimbangan layout
                  const SizedBox(width: 24), // Lebar sesuai dengan ikon
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadRevisiData,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 60,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Gagal memuat data revisi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _error!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _loadRevisiData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          )
                        : _revisiList == null || _revisiList!.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.grey,
                                        size: 60,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Belum ada data revisi',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Detail revisi akan muncul setelah dosen memberikan penilaian',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16.0),
                                itemCount: _revisiList!.length,
                                itemBuilder: (context, index) {
                                  final revisi = _revisiList![index];
                                  return _buildRevisiCard(revisi, index);
                                },
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevisiCard(Map<String, dynamic> revisi, int index) {
    final status = revisi['status_revisi'];
    final statusDescription = RevisiService.getStatusDescription(status);
    final statusColor = Color(int.parse(RevisiService.getStatusColor(status).substring(1), radix: 16) + 0xFF000000);
    final updatedAt = DateTime.parse(revisi['updated_at']);
    final formattedDate = _formatTanggal(updatedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
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
              color: SidangColors.cardTopBorderBlue,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: statusColor,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          _getStatusIcon(status),
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              statusDescription,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Tanggal', formattedDate),
                  _buildInfoRow('Sekretaris', _getDosenNama(revisi)),
                  // _buildInfoRow('NIP Dosen', _getDosenNip(revisi)),
                  if (revisi['catatan_revisi'] != null && revisi['catatan_revisi'].isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        const Text(
                          'Catatan Revisi:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            revisi['catatan_revisi'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (revisi['file_revisi'] != null && revisi['file_revisi'].isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        const Text(
                          'File Revisi:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue[300]!,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  revisi['file_revisi'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  // Tampilkan tombol upload file revisi hanya jika status adalah "Revisi" (case 3)
                  if (status == 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            print('Debug - Tombol upload ditekan!');
                            _uploadFileRevisi(revisi);
                          },
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Upload File Revisi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 0, 170, 255),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF455A64),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF263238),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTanggal(DateTime dateTime) {
    const List<String> namaBulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${dateTime.day} ${namaBulan[dateTime.month]} ${dateTime.year}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  IconData _getStatusIcon(int? status) {
    switch (status) {
      case 0: // Terjadwal
        return Icons.schedule;
      case 1: // Lulus
        return Icons.check_circle;
      case 2: // Lulus dengan Revisi
        return Icons.warning;
      case 3: // Revisi
        return Icons.edit;
      case 4: // Tidak Lulus
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getDosenNama(Map<String, dynamic> revisi) {
    // Coba beberapa kemungkinan struktur data
    if (revisi['dosen'] != null) {
      if (revisi['dosen'] is Map) {
        // Struktur: revisi['dosen']['dosen_nama'] atau revisi['dosen']['nama']
        return revisi['dosen']['dosen_nama'] ??
               revisi['dosen']['nama'] ??
               revisi['dosen']['name'] ??
               revisi['dosen']['full_name'] ??
               'Tidak diketahui';
      } else {
        // Jika dosen bukan objek, mungkin hanya string
        return revisi['dosen'].toString();
      }
    }
    // Coba field langsung di revisi
    return revisi['dosen_nama'] ??
           revisi['nama_dosen'] ??
           'Tidak diketahui';
  }

  String _getDosenNip(Map<String, dynamic> revisi) {
    // Coba beberapa kemungkinan struktur data
    if (revisi['dosen'] != null && revisi['dosen'] is Map) {
      // Struktur: revisi['dosen']['dosen_nip'] atau revisi['dosen']['nip']
      return revisi['dosen']['dosen_nip'] ??
             revisi['dosen']['nip'] ??
             revisi['dosen']['NIP'] ??
             revisi['dosen']['nip_dosen'] ??
             'Tidak diketahui';
    }
    // Coba field langsung di revisi
    return revisi['dosen_nip'] ??
           revisi['nip_dosen'] ??
           'Tidak diketahui';
  }

  // Fungsi untuk upload file revisi ke API
  void _uploadFileRevisi(Map<String, dynamic> revisiData) async {
    // Debug log untuk melihat struktur data revisi
    print('Debug - Data revisi: $revisiData');

    // Pilih file dari perangkat - dengan opsi untuk membaca data langsung
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Sesuaikan ekstensi yang diizinkan
      withData: true, // Membaca file sebagai bytes langsung
    );

    if (result != null) {
      PlatformFile platformFile = result.files.first;

      // Ambil token dari storage
      String? token = await storageService.getToken();
      if (token == null) {
        _showErrorDialog('Token autentikasi tidak ditemukan. Silakan login kembali.');
        return;
      }

      print('Debug - Token: ${token.substring(0, 20)}...'); // Cuma nampilin awal token

      // Ambil ID revisi dari data
      String? revisiId = revisiData['id']?.toString();
      print('Debug - ID Revisi: $revisiId');

      if (revisiId == null) {
        // Coba cari field ID yang mungkin punya nama beda
        List<String> possibleIdFields = ['id_revisi', 'revisi_id', '_id', 'id_tugas_akhir', 'tugas_akhir_id'];
        for (String field in possibleIdFields) {
          if (revisiData.containsKey(field)) {
            revisiId = revisiData[field]?.toString();
            print('Debug - Ditemukan ID di field: $field, nilai: $revisiId');
            break;
          }
        }
      }

      if (revisiId == null) {
        _showErrorDialog('ID revisi tidak ditemukan di data. Field yang tersedia: ${revisiData.keys.join(", ")}');
        return;
      }

      // Cek apakah file bisa diakses - coba dengan path jika bytes null
      List<int>? fileBytes;

      if (platformFile.bytes != null) {
        // Jika bytes tersedia, gunakan langsung
        fileBytes = platformFile.bytes;
      } else if (platformFile.path != null) {
        // Jika bytes null, coba baca file dari path
        try {
          File file = File(platformFile.path!);
          fileBytes = await file.readAsBytes();
        } catch (e) {
          _showErrorDialog('Gagal membaca file dari penyimpanan. Silakan pilih file dari penyimpanan internal. Error: $e');
          return; // Hentikan proses upload
        }
      } else {
        _showErrorDialog('Gagal membaca file. Tidak ada data file atau path yang tersedia.');
        return; // Hentikan proses upload
      }

      print('Debug - File dipilih: ${platformFile.name}, ukuran: ${platformFile.size} bytes');

      try {
        // Tampilkan loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("Mengupload file..."),
                ],
              ),
            );
          },
        );

        print('Debug - Memulai upload file ke API...');

        // Buat request multipart dari bytes yang sudah dibaca
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(ApiService.uploadRevisiUrl),
        );

        request.headers['Authorization'] = 'Bearer $token';

        // Tambahkan ID revisi ke request
        request.fields['revisi_id'] = revisiId;

        // Tambahkan file ke request dari bytes yang sudah dibaca
        request.files.add(
          http.MultipartFile.fromBytes(
            'file_revisi',
            fileBytes!,
            filename: platformFile.name,
          ),
        );

        // Kirim request
        var response = await request.send();
        var responseJson = await response.stream.bytesToString();

        print('Debug - Response status: ${response.statusCode}');
        print('Debug - Response body: $responseJson');

        // Tutup loading indicator
        Navigator.of(context).pop();

        if (response.statusCode == 200) {
          // Upload berhasil
          _showSuccessDialog('File revisi berhasil diupload.');

          // Refresh data revisi
          _loadRevisiData();
        } else {
          // Upload gagal
          _showErrorDialog('Gagal mengupload file revisi. Status: ${response.statusCode}\n${responseJson}');
        }
      } catch (e) {
        // Tutup loading indicator jika terjadi error
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        print('Debug - Error saat upload: $e');
        _showErrorDialog('Terjadi kesalahan saat mengupload file: $e');
      }
    } else {
      // User batal memilih file
      print('Pemilihan file dibatalkan');
    }
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sukses"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                Navigator.of(context).pop(); // Kembali ke halaman sebelumnya jika perlu
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}