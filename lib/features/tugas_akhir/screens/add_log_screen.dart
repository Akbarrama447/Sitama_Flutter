import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../main.dart';
import '../../auth/screens/login_screen.dart';

class AddLogScreen extends StatefulWidget {
  const AddLogScreen({super.key});

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dosenController = TextEditingController();
  final _catatanController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  final String _baseUrl = 'http://192.168.55.21:8000';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitLog() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal bimbingan')),
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

      final url = '$_baseUrl/api/log-bimbingan';
      final body = jsonEncode({
        'dosen': _dosenController.text.trim(),
        'tanggal': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'catatan': _catatanController.text.trim(),
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
          const SnackBar(content: Text('Log bimbingan berhasil ditambahkan')),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } else if (response.statusCode == 401) {
        _forceLogout();
      } else {
        throw Exception('Gagal menambah log: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error submitting log: $e');
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
        title: const Text('Tambah Log Bimbingan'),
        backgroundColor: const Color(0xFF03A9F4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _dosenController,
                decoration: const InputDecoration(
                  labelText: 'Nama Dosen',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama dosen tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Bimbingan',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Pilih tanggal'
                        : DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _catatanController,
                decoration: const InputDecoration(
                  labelText: 'Catatan',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Catatan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
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
