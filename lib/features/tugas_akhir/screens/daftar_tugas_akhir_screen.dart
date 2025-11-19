import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  final _deskripsiController = TextEditingController();
  final _anggotaController = TextEditingController();
  bool _isLoading = false;

  final String _baseUrl = 'http://192.168.1.9:8000';

  Future<void> _submitTugasAkhir() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final token = await storageService.getToken();
      if (token == null) {
        _forceLogout();
        return;
      }

      // Parse anggota kelompok - extract NIMs only
      final anggotaList = _anggotaController.text.trim().split(',');
      final anggota = anggotaList.map((e) {
        final nim = int.tryParse(e.trim());
        return nim;
      }).where((e) => e != null).toList();

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
        Navigator.of(context).pop(true); // Return true to indicate success
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas Akhir'),
        backgroundColor: const Color(0xFF03A9F4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul Tugas Akhir',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tugas akhir tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Tugas Akhir',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi tugas akhir tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _anggotaController,
                decoration: const InputDecoration(
                  labelText: 'Anggota Kelompok (format: NIM Nama, pisahkan dengan koma)',
                  border: OutlineInputBorder(),
                  hintText: 'Contoh: 110126447 Joel O\'Kon, 110126448 John Doe',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Anggota kelompok tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitTugasAkhir,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF03A9F4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Daftar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
