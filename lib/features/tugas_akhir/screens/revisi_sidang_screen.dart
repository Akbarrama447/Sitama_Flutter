import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../services/revisi_service.dart';
import '../../../main.dart'; // untuk mengakses storageService

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
      appBar: AppBar(
        title: const Text('Detail Revisi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: RefreshIndicator(
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
    );
  }

  Widget _buildRevisiCard(Map<String, dynamic> revisi, int index) {
    final status = revisi['status_revisi'];
    final statusDescription = RevisiService.getStatusDescription(status);
    final statusColor = Color(int.parse(RevisiService.getStatusColor(status).substring(1), radix: 16) + 0xFF000000);
    final updatedAt = DateTime.parse(revisi['updated_at']);
    final formattedDate = _formatTanggal(updatedAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                        'Status #${index + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        statusDescription,
                        style: TextStyle(
                          fontSize: 18,
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
            _buildInfoRow('Sekertaris', _getDosenNama(revisi)),
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
                  const SizedBox(height: 4),
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
                padding: const EdgeInsets.only(top: 12.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implementasi fungsi upload file revisi
                    _uploadFileRevisi(revisi);
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload File Revisi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
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
    // Pilih file dari perangkat
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Sesuaikan ekstensi yang diizinkan
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      // Ambil token dari storage
      String? token = await storageService.getToken();
      if (token == null) {
        _showErrorDialog('Token autentikasi tidak ditemukan. Silakan login kembali.');
        return;
      }

      // Buat request multipart
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://sitamanext.informatikapolines.id/api/upload-revisi-file'), // Ganti dengan base URL yang sesuai
      );
      request.headers['Authorization'] = 'Bearer $token';

      // Tambahkan file ke request
      // Pastikan file.bytes tidak null sebelum digunakan
      if (file.bytes == null) {
        _showErrorDialog('Gagal membaca file. Silakan pilih file dari penyimpanan internal.');
        return; // Hentikan proses upload
      }

      request.files.add(
        http.MultipartFile(
          'file_revisi', // Sesuaikan dengan field name di backend
          Stream.value(file.bytes!), // Gunakan Stream.value untuk Uint8List
          file.size,
          filename: file.name,
        ),
      );

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

        // Kirim request
        var response = await request.send();
        var responseJson = await response.stream.bytesToString();

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