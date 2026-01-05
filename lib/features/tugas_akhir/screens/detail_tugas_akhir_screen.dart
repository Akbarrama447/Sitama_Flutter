import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import 'daftar_tugas_akhir_screen.dart';
import '../../../widgets/modern_back_button.dart';
import '../../../main.dart'; // Import for storageService

class DetailTugasAkhirScreen extends StatefulWidget {
  final String token;

  const DetailTugasAkhirScreen({super.key, required this.token});

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
      final response = await ApiService.getThesis(widget.token);
      if (response['status'] == 'success') {
        if (response['data'] != null) {
          // Store the thesis data
          setState(() {
            thesisData = response['data'];
            isLoading = false;
          });
        } else {
          // If data is null, user doesn't have a thesis
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
      body: Stack(
        children: [
          // Background content
          SafeArea(
            child: isLoading
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
                                  color: Colors.black87,
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
                                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                ),
                                child: const Text('Daftar Tugas Akhir',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : thesisData == null
                        ? const Center(
                            child: Text('Data tugas akhir tidak ditemukan'))
                        : _buildContent(context),
          ),
          // Positioned back button with proper spacing from the top
          Positioned(
            top: 20, // Add proper spacing from top
            left: 16,
            child: ModernBackButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Konten Detail (di dalam Card)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), // Added vertical padding
            child: Card(
              elevation: 3, // Increased elevation for better visual
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0), // More rounded corners
                side: BorderSide(color: Colors.grey.shade200, width: 0.5), // Subtle border
              ),
              child: Padding(
                padding: const EdgeInsets.all(28.0), // Slightly more padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul Tugas Akhir
                    _buildDetailItem(
                      'Judul Tugas Akhir',
                      Text(thesisData?['judul'] ?? 'Judul tidak tersedia',
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      Colors.transparent, // Tidak ada container di sekeliling judul
                    ),

                    // Deskripsi Tugas Akhir
                    _buildDetailItem(
                      'Deskripsi',
                      Text(
                        thesisData?['deskripsi'] ?? 'Deskripsi tidak tersedia',
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      Colors.grey.shade100, // Lighter grey for better contrast
                    ),

                    // Status with modern badge
                    _buildStatusItem(
                      'Status Tugas Akhir',
                      thesisData?['status'] ?? '-',
                    ),

                    // Dosen Pembimbing
                    _buildDetailItem(
                      'Dosen Pembimbing',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('1. ${thesisData?['pembimbing_1'] ?? "-"}',
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text('2. ${thesisData?['pembimbing_2'] ?? "-"}',
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
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
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              '${index + 1}. NIP: ${penguji['nip']} - ${penguji['nama']}',
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                          );
                        }).toList(),
                      ),
                      Colors.grey.shade100, // Lighter grey
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
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              '${index + 1}. NIM: ${anggota['nim']} - ${anggota['nama']}',
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                          );
                        }).toList(),
                      ),
                      Colors.grey.shade100, // Lighter grey
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // 3. Tombol Lulus (sesuai desain)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10), // Add horizontal padding to match card
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
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16), // Increased vertical padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // More rounded corners
                ),
                elevation: 2, // Add subtle elevation
              ),
              child: const Text(
                'Lulus',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), // Consistent font size
              ),
            ),
          ),
          const SizedBox(height: 30), // Reduced bottom spacing
        ],
      ),
    );
  }

  // Widget untuk Status dengan badge modern
  Widget _buildStatusItem(String title, String status) {
    // Determine color based on status
    Color statusColor;
    if (status.toLowerCase().contains('lulus') || status.toLowerCase().contains('selesai')) {
      statusColor = Colors.green.shade600;
    } else if (status.toLowerCase().contains('revisi') || status.toLowerCase().contains('perbaikan')) {
      statusColor = Colors.orange.shade600;
    } else if (status.toLowerCase().contains('diterima') || status.toLowerCase().contains('acc')) {
      statusColor = Colors.blue.shade600;
    } else {
      statusColor = Colors.grey.shade600;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget untuk setiap baris detail
  Widget _buildDetailItem(
      String title, Widget contentWidget, Color containerColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0), // Increased bottom padding for better spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600, // Consistent boldness
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12), // Increased spacing between label and content
          Container(
            width: double.infinity,
            padding: containerColor != Colors.transparent
                ? const EdgeInsets.all(16.0) // Increased padding for better readability
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(12.0), // Increased border radius for modern look
              border: Border.all(
                color: containerColor != Colors.transparent
                    ? Colors.grey.shade300
                    : Colors.transparent,
                width: 0.8,
              ),
              boxShadow: containerColor != Colors.transparent
                  ? [BoxShadow(
                      color: Colors.black.withOpacity(0.05), // Subtle shadow for depth
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )]
                  : null,
            ),
            child: contentWidget,
          ),
        ],
      ),
    );
  }
}
