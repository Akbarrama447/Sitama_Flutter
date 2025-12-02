import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Import InfoRevisiScreen yang sudah kita buat
import 'info_revisi_screen.dart'; 
// Asumsi ini sudah ada di file terpisah
import '../../../main.dart'; 
import '../../auth/screens/login_screen.dart';

// ✅ BAGIAN YANG HILANG SEBELUMNYA (WAJIB ADA)
class DaftarTugasAkhirScreen extends StatefulWidget {
  const DaftarTugasAkhirScreen({super.key});

  @override
  State<DaftarTugasAkhirScreen> createState() => _DaftarTugasAkhirScreenState();
}

// ---------------------------------------------------------

class _DaftarTugasAkhirScreenState extends State<DaftarTugasAkhirScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController(); 
  final _anggotaController = TextEditingController();
  
  bool _isLoading = false;
  
  // LOGIKA FETCHING DATA
  late Future<Map<String, dynamic>?> _tugasAkhirStatusFuture;
  Map<String, dynamic>? _taData; 

  final String _baseUrl = 'http://172.16.165.144:8000';
  
  static const Color _primaryColor = Color(0xFF03A9F4);
  static const Color _backgroundColor = Color(0xFFF0F4F8); 
  static const Color _lightBlueGradientStart = Color(0xFFE3F2FD); 
  static const Color _lightBlueGradientEnd = Color(0xFFF0F8FF); 

  @override
  void initState() {
    super.initState();
    _tugasAkhirStatusFuture = _fetchTugasAkhirStatus();
  }
  
  Future<Map<String, dynamic>?> _fetchTugasAkhirStatus() async {
    // --- MOCKUP DATA (Untuk Test Logika Revisi) ---
    await Future.delayed(const Duration(seconds: 1));
    return {
      'id': 1,
      'judulTA': 'Sensor Pendeteksi Semut',
      'deskripsiTA': 'Alat sensor pendeteksi',
      'namaMahasiswa': 'FARHAN DWI CAHYANTO',
      'nimProdi': '3.34.24.2.11 - D3 Teknik Informatika',
      'dosenPembimbing': ['Pak Suko', 'Pak Amran'],
      'dosenPenguji': ['Pak Suko', 'Pak Amran'],
      'sekretaris': 'Wiktasari',
      'labSidang': 'Lab Multimedia SB II/D4',
      'waktuSidang': '08:00 WIB',
      'namaDosen': 'Suko Tyas', 
      'hasilSidang': 'Revisi', // Status: Revisi (Akan memunculkan tombol biru)
    };
  }
  
  Future<void> _submitTugasAkhir() async { /* Logika Submit Anda */ }
  void _forceLogout() { 
     storageService.deleteToken();
     Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
  }

  // --- WIDGET HELPERS ---

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
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(labelText, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 0.5)),
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 0.5)),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: _primaryColor, width: 2.0)),
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

  Widget _buildCardHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          const Divider(),
        ],
      ),
    );
  }

  // VIEW 1: FORMULIR PENDAFTARAN (Jika Data Null)
  Widget _buildPendaftaranFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardHeader("Pendaftaran Tugas Akhir"),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMinimalistTextField(controller: _judulController, hintText: 'Masukan Judul', labelText: 'Judul Tugas Akhir *', isRequired: true),
                const SizedBox(height: 24), 
                _buildMinimalistTextField(controller: _deskripsiController, hintText: 'Masukan deskripsi', labelText: 'Deskripsi Tugas Akhir *', isRequired: true, maxLines: 3),
                const SizedBox(height: 24),
                _buildMinimalistTextField(controller: _anggotaController, hintText: 'Nama rekan', labelText: 'Anggota Kelompok', suffixIcon: const Icon(Icons.person_add_alt_1)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitTugasAkhir,
                    style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Ajukan Judul'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // VIEW 2: DETAIL TUGAS AKHIR (Jika Data Ada)
  Widget _buildDetailTugasAkhirView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader("Detail Tugas Akhir"),
          const SizedBox(height: 16),
          _buildDetailItem('Judul', _taData!['judulTA']),
          _buildDetailItem('Status Sidang', _taData!['hasilSidang']),
          _buildDetailItem('Pembimbing 1', _taData!['dosenPembimbing'][0]),

          const SizedBox(height: 32),

          // TOMBOL KE INFO REVISI
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Hasil Sidang & Detail Revisi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green.shade700,
                side: BorderSide(color: Colors.green.shade300, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                if (_taData != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Mengirim data ke InfoRevisiScreen
                      builder: (context) => InfoRevisiScreen(
                        dataSidang: _taData!, 
                        hasilSidang: _taData!['hasilSidang'], 
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Header Custom
    final customAppBar = PreferredSize(
      preferredSize: const Size.fromHeight(150.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 10.0),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [Text('Suko Tyas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade700))],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_lightBlueGradientStart, _lightBlueGradientEnd]),
              ),
              child: Align(alignment: Alignment.bottomCenter, child: Container(height: 4.0, width: double.infinity, color: _primaryColor)),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: _backgroundColor, 
      appBar: customAppBar,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _tugasAkhirStatusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          
          _taData = snapshot.data;

          return SingleChildScrollView(
            child: Container(
              color: Colors.white,
              child: _taData == null 
                  ? _buildPendaftaranFormView() 
                  : _buildDetailTugasAkhirView(),
            ),
          );
        },
      ),
    );
  }
}