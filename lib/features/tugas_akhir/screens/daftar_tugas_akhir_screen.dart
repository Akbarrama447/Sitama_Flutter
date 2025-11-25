import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Asumsi ini sudah ada di file terpisah
import '../../../main.dart'; 
import '../../auth/screens/login_screen.dart';

class DaftarTugasAkhirScreen extends StatefulWidget {
  const DaftarTugasAkhirScreen({super.key});

  @override
  State<DaftarTugasAkhirScreen> createState() => _DaftarTugasAkhirScreenState();
}

class _DaftarTugasAkhirScreenState extends State<DaftarTugasAkhirScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController(); // Tetap dipertahankan
  final _anggotaController = TextEditingController();
  bool _isLoading = false;

  final String _baseUrl = 'http://172.16.163.244:8000';

  // Warna utama yang digunakan
  static const Color _primaryColor = Color(0xFF03A9F4);
  static const Color _backgroundColor = Color(0xFFF0F4F8); // Background di luar card
  // Warna untuk gradient biru tipis di atas
  static const Color _lightBlueGradientStart = Color(0xFFE3F2FD); // Sangat muda
  static const Color _lightBlueGradientEnd = Color(0xFFF0F8FF);   // Hampir putih

  // Logika _submitTugasAkhir (TIDAK BERUBAH dari kode asli Anda)
  Future<void> _submitTugasAkhir() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final token = await storageService.getToken();
      if (token == null) {
        _forceLogout();
        return;
      }

      // Parse anggota kelompok - extract names as array of strings
      final anggotaList = _anggotaController.text.trim().split(',');
      final anggota = anggotaList.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      final url = '$_baseUrl/api/tugas-akhir';
      final body = jsonEncode({
        'judul': _judulController.text.trim(),
        'deskripsi': _deskripsiController.text.trim(),
        'anggota': anggota,
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tugas akhir berhasil didaftarkan')),
        );
        Navigator.of(context).pop(true);
      } else if (response.statusCode == 401) {
        _forceLogout();
      } else {
        throw Exception('Gagal mendaftarkan tugas akhir: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error submitting tugas akhir: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _forceLogout() {
    storageService.deleteToken();
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // ------------------------------------------------------------------
  // WIDGET KUSTOM UNTUK MENYESUAIKAN TAMPILAN (UI/UX)
  // ------------------------------------------------------------------

  // Widget untuk meniru input field minimalis dari screenshot
  Widget _buildMinimalistTextField({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    bool isRequired = false,
    int maxLines = 1,
    String? validatorMessage,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Judul Tugas Akhir * / Anggota Kelompok
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            labelText,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Text Field
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            // Border yang terlihat minimalis, seperti di screenshot
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 0.5),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 0.5),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: _primaryColor, width: 2.0),
            ),
            suffixIcon: suffixIcon,
          ),
          validator: (value) {
            if (isRequired && (value == null || value.trim().isEmpty)) {
              return validatorMessage ?? '$labelText tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Widget Card Header untuk "Pendaftaran Tugas Akhir"
  Widget _buildCardHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: const Text(
        'Pendaftaran Tugas Akhir',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // BUILD METHOD UTAMA
  // ------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Header Suko Tyas
    final topHeader = Container(
      padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 10.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '', 
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.w600, 
              color: Colors.grey.shade700
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: _backgroundColor, 
      body: Column(
        children: [
          // Bagian atas yang putih dengan nama Suko Tyas
          topHeader,
          
          // Bagian dengan gradient biru tipis
          Container(
            height: 100, // Tinggi area gradient, bisa disesuaikan
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_lightBlueGradientStart, _lightBlueGradientEnd],
              ),
            ),
            child: Align( // Menempatkan garis biru di bagian paling bawah gradient
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 4.0, 
                width: double.infinity, 
                color: _primaryColor,
              ),
            ),
          ),

          // Formulir utama (yang merupakan "card" putih)
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(0), // Tidak ada margin horizontal
                color: Colors.white, // Simulasi Card/Kontainer Putih
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCardHeader(), // "Pendaftaran Tugas Akhir" header

                      // Padding untuk konten form
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Field Judul Tugas Akhir (Wajib)
                            _buildMinimalistTextField(
                              controller: _judulController,
                              hintText: 'Masukan Judul Tugas Akhir',
                              labelText: 'Judul Tugas Akhir *', // Menambahkan tanda bintang
                              isRequired: true,
                              validatorMessage: 'Judul tugas akhir tidak boleh kosong',
                            ),
                            
                            const SizedBox(height: 24), 
                            
                            // 2. Field Deskripsi Tugas Akhir (Wajib, multi-line)
                             _buildMinimalistTextField(
                              controller: _deskripsiController,
                              hintText: 'Masukan deskripsi singkat tugas akhir Anda',
                              labelText: 'Deskripsi Tugas Akhir *', // Menambahkan tanda bintang
                              isRequired: true,
                              maxLines: 3,
                              validatorMessage: 'Deskripsi tugas akhir tidak boleh kosong',
                            ),

                            const SizedBox(height: 24),

                            // 3. Field Anggota Kelompok (Opsional/Jika ada)
                            _buildMinimalistTextField(
                              controller: _anggotaController,
                              hintText: 'Masukan nama rekan kelompok (Jika ada)',
                              labelText: 'Anggota Kelompok',
                              isRequired: false, 
                              suffixIcon: const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                              maxLines: 2,
                            ),
                            
                            const SizedBox(height: 32),

                            // Tombol "Ajukan Judul"
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submitTugasAkhir,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryColor,
                                  foregroundColor: Colors.white, 
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 2, 
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Ajukan Judul',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          ),
        ],
      ),
    );
  }
}