import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../../main.dart';
import '../../auth/screens/login_screen.dart';

class AddLogScreen extends StatefulWidget {
  const AddLogScreen({super.key});

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> {
  final _formKey = GlobalKey<FormState>();

  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _dosenNipController = TextEditingController();

  DateTime? _selectedDate;
  File? _selectedFile;

  bool _isLoading = false;

  final String _baseUrl = 'http://localhost:8000';

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

  PlatformFile? _pickedPlatformFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null) {
      setState(() {
        _pickedPlatformFile = result.files.first;
      });
      print("Picked: ${_pickedPlatformFile!.name}");
    }
  }


  // ================================
  //   FIXED SUBMIT (VALE VALID)
  // ================================
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

      final url = Uri.parse('$_baseUrl/api/log-bimbingan');

      var request = http.MultipartRequest('POST', url);

      // field biasa
      request.fields['judul'] = _judulController.text.trim();
      request.fields['deskripsi'] = _deskripsiController.text.trim();
      request.fields['dosen_nip'] = _dosenNipController.text.trim();
      request.fields['tanggal'] =
          DateFormat('yyyy-MM-dd').format(_selectedDate!);

      // FILE UPLOAD (WEB + ANDROID)
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log bimbingan berhasil ditambahkan')),
        );
        Navigator.pop(context, true);
      } else if (response.statusCode == 401) {
        _forceLogout();
      } else {
        final resStr = await response.stream.bytesToString();
        throw Exception("Gagal: ${response.statusCode} - $resStr");
      }
    } catch (e) {
      debugPrint("Error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _forceLogout() {
    storageService.deleteToken();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Log Bimbingan',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF03A9F4),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // JUDUL
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul Bimbingan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              // NIP DOSEN PEMBIMBING
              TextFormField(
                controller: _dosenNipController,
                decoration: const InputDecoration(
                  labelText: 'NIP Dosen Pembimbing',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'NIP dosen wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // DESKRIPSI
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) =>
                    value!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              // JADWAL
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Jadwal Bimbingan',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Pilih tanggal'
                        : DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                            .format(_selectedDate!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // FILE UPLOAD
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file),
                label: Text(
                  _pickedPlatformFile == null ? "Upload File" : "File dipilih ✔️",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                ),
              ),
              const SizedBox(height: 24),

              // SIMPAN
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
