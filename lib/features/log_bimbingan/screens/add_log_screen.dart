// file: lib/features/tugas_akhir/screens/add_log_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../../main.dart';
import '../../auth/screens/login_screen.dart';
import '../../../core/services/auth_service.dart';

class AddLogScreen extends StatefulWidget {
  final String pembimbingNama;
  final int pembimbingUrutan;

  const AddLogScreen({super.key, required this.pembimbingNama, required this.pembimbingUrutan});

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> {
  final _formKey = GlobalKey<FormState>();

  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _pembimbingController = TextEditingController();

  DateTime? _selectedDate;
  PlatformFile? _pickedPlatformFile;
  bool _isLoading = false;

  // Base URL backend
  final String _baseUrl = 'http://localhost:8000';

  @override
  void initState() {
    super.initState();
    // Auto-fill nama pembimbing
    _pembimbingController.text = widget.pembimbingNama;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null) {
      setState(() {
        _pickedPlatformFile = result.files.first;
      });
      if (kDebugMode) print("Picked: ${_pickedPlatformFile!.name}");
    }
  }

  Future<void> _submitLog() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jadwal bimbingan')),
      );
      return;
    }

    if (_pickedPlatformFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File wajib diupload')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await storageService.getToken();
      if (token == null) {
        _forceLogout();
        return;
      }

      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/log-bimbingan'));

      // --- Fields ---
      request.fields['judul'] = _judulController.text.trim();
      request.fields['deskripsi'] = _deskripsiController.text.trim();
      request.fields['pembimbing_urutan'] = widget.pembimbingUrutan.toString();
      request.fields['pembimbing'] = _pembimbingController.text.trim();
      request.fields['tanggal'] = DateFormat('yyyy-MM-dd').format(_selectedDate!);

      // --- File upload ---
      request.files.add(
        http.MultipartFile.fromBytes(
          'file_path',
          _pickedPlatformFile!.bytes!,
          filename: _pickedPlatformFile!.name,
        ),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log bimbingan berhasil ditambahkan')),
        );
        Navigator.pop(context, true);
      } else if (response.statusCode == 401) {
        _forceLogout();
      } else {
        throw Exception("Gagal: ${response.statusCode} - $responseString");
      }
    } catch (e) {
      debugPrint("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _forceLogout() {
    // Gunakan service auth untuk logout
    AuthService.instance.logout(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Log Bimbingan', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF03A9F4),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Judul
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(labelText: 'Judul Bimbingan', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              // Pembimbing (read-only)
              TextFormField(
                controller: _pembimbingController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Nama Pembimbing', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Nama pembimbing wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Deskripsi
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
                maxLines: 4,
                validator: (v) => v == null || v.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              // Jadwal
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Jadwal Bimbingan', border: OutlineInputBorder()),
                  child: Text(
                    _selectedDate == null
                        ? 'Pilih tanggal'
                        : DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Upload file
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file),
                label: Text(
                  _pickedPlatformFile == null ? "Upload File" : _pickedPlatformFile!.name, overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                ),
              ),
              const SizedBox(height: 24),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitLog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF03A9F4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
