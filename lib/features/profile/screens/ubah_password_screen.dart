import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/services/api_service.dart';
import '../../../main.dart'; // Untuk akses storageService
import '../../auth/screens/login_screen.dart';
import '../../../core/services/auth_service.dart';

class UbahPasswordScreen extends StatefulWidget {
  const UbahPasswordScreen({Key? key}) : super(key: key);

  @override
  State<UbahPasswordScreen> createState() => _UbahPasswordScreenState();
}

class _UbahPasswordScreenState extends State<UbahPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _submit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final token = await storageService.getToken();

      final url = ApiService.gantiPasswordUrl;
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Tambahkan Bearer token
      };
      final bodyMap = {
        'password_lama': _oldController.text,
        'password_baru': _newController.text,
        'password_baru_confirmation': _confirmController.text,
      };
      final bodyJson = jsonEncode(bodyMap);

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: bodyJson,
      ).timeout(const Duration(seconds: 10));

      print('DEBUG: Status: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() => _successMessage = body['message'] ?? 'Password berhasil diubah!');
      } else {
        final body = jsonDecode(response.body);
        setState(() => _errorMessage = body['message'] ?? 'Gagal mengubah password');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Terjadi kesalahan: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Password'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8F9FD),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 370,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _successMessage != null ? _buildSuccess() : _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Password Lama', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          TextFormField(
            controller: _oldController,
            obscureText: _obscureOld,
            decoration: InputDecoration(
              hintText: 'Password lama',
              suffixIcon: IconButton(
                icon: Icon(_obscureOld ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureOld = !_obscureOld),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 16),
          const Text('Password Baru', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          TextFormField(
            controller: _newController,
            obscureText: _obscureNew,
            decoration: InputDecoration(
              hintText: 'Password baru',
              suffixIcon: IconButton(
                icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            validator: (val) => val == null || val.length < 6 ? 'Minimal 6 karakter' : null,
          ),
          const SizedBox(height: 16),
          const Text('Konfirmasi Password Baru', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          TextFormField(
            controller: _confirmController,
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              hintText: 'Konfirmasi password baru',
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            validator: (val) => val != _newController.text ? 'Password tidak sama' : null,
          ),
          const SizedBox(height: 24),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Ubah password', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 60),
        const SizedBox(height: 16),
        const Text('Password berhasil diubah!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Kembali', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
