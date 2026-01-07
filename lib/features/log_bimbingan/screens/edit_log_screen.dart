// file: lib/features/tugas_akhir/screens/edit_log_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../../main.dart'; // storageService
import '../../auth/screens/login_screen.dart';
import '../../../core/services/auth_service.dart';

class EditLogScreen extends StatefulWidget {
  final Map<String, dynamic> log;
  const EditLogScreen({super.key, required this.log});

  @override
  State<EditLogScreen> createState() => _EditLogScreenState();
}

class _EditLogScreenState extends State<EditLogScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _deskripsiController;
  DateTime? _selectedDate;
  PlatformFile? _pickedPlatformFile;
  late String _fileName; // nama file backend (tidak null)
  bool _isLoading = false;
  final String _baseUrl = 'http://localhost:8000';

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.log['judul']?.toString() ?? '');
    _deskripsiController = TextEditingController(text: widget.log['deskripsi']?.toString() ?? '');
    
    // parsing tanggal
    final raw = widget.log['tanggal'];
    try {
      _selectedDate = raw != null ? DateTime.parse(raw.toString()) : null;
    } catch (_) {
      _selectedDate = null;
    }

    // inisialisasi nama file backend
    final filePath = widget.log['file_url']?.toString() ?? 'File tidak ditemukan';
    _fileName = filePath != '-' ? filePath.split('/').last : '-';
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null) {
      setState(() => _pickedPlatformFile = result.files.first);
    }
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final token = await storageService.getToken();
      if (token == null) {
        _forceLogout();
        return;
      }

      final id = widget.log['id'] ?? widget.log['log_id'] ?? widget.log['kode'];
      if (id == null) throw Exception('ID log tidak tersedia');

      final url = Uri.parse('$_baseUrl/api/log-bimbingan/$id');
      final req = http.MultipartRequest('POST', url);
      req.fields['_method'] = 'PUT';
      req.fields['judul'] = _judulController.text.trim();
      req.fields['deskripsi'] = _deskripsiController.text.trim();
      if (_selectedDate != null) req.fields['tanggal'] = DateFormat('yyyy-MM-dd').format(_selectedDate!);

      // file jika dipilih
      if (_pickedPlatformFile != null && _pickedPlatformFile!.bytes != null) {
        req.files.add(http.MultipartFile.fromBytes(
          'file_path',
          _pickedPlatformFile!.bytes!,
          filename: _pickedPlatformFile!.name,
        ));
      }

      req.headers['Authorization'] = 'Bearer $token';
      req.headers['Accept'] = 'application/json';

      final streamed = await req.send();
      final resStr = await streamed.stream.bytesToString();

      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perubahan berhasil disimpan')),
        );
        Navigator.pop(context, true);
      } else if (streamed.statusCode == 401) {
        _forceLogout();
      } else {
        throw Exception('Gagal update: ${streamed.statusCode} - $resStr');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error update: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteLog() async {
  setState(() => _isLoading = true);

  try {
    final token = await storageService.getToken();
    if (token == null) {
      _forceLogout();
      return;
    }

    final id = widget.log['id'] ?? widget.log['log_id'] ?? widget.log['kode'];
    if (id == null) throw Exception('ID log tidak tersedia');

    final res = await http.delete(
      Uri.parse('$_baseUrl/api/log-bimbingan/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (res.statusCode == 200 || res.statusCode == 204) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log bimbingan berhasil dihapus')),
      );
      Navigator.pop(context, true); // ⬅️ balik + refresh list
    } else if (res.statusCode == 401) {
      _forceLogout();
    } else {
      throw Exception('Gagal menghapus log');
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  
  void _confirmDelete() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hapus Log Bimbingan'),
      content: const Text(
        'Apakah kamu yakin ingin menghapus log bimbingan ini?\n\n'
        'Tindakan ini tidak dapat dibatalkan.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _deleteLog();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
}


  void _forceLogout() {
    AuthService.instance.logout(context);
  }

  @override
  Widget build(BuildContext context) {
    final pembimbingText = widget.log['pembimbing'] ?? widget.log['dosen_nama'] ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisi Log Bimbingan', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF03A9F4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul Bimbingan',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: TextEditingController(text: pembimbingText.toString()),
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Nama Pembimbing',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (v) => v == null || v.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
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
                        : DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate!),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Tombol file aman
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file),
                label: Text(
                  _pickedPlatformFile?.name ?? _fileName,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                ),
              ),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF03A9F4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan Perubahan'),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _confirmDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Hapus Log Bimbingan'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
