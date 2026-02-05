import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GantiPasswordScreen extends StatefulWidget {
  const GantiPasswordScreen({Key? key}) : super(key: key);

  @override
  State<GantiPasswordScreen> createState() => _GantiPasswordScreenState();
}

class _GantiPasswordScreenState extends State<GantiPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk masing-masing step
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  // State untuk flow
  int _currentStep = 0; // 0: email, 1: otp, 2: password, 3: success
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  // Simpan email yang sudah dimasukkan
  String _email = '';

  Future<void> _sendForgotPasswordRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://sitamanext.informatikapolines.id/api/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': _emailController.text,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _email = _emailController.text;
          _currentStep = 1; // Pindah ke step OTP
        });
      } else {
        final body = jsonDecode(response.body);
        String message = body['message'] ?? 'Gagal mengirim email reset password';

        // Periksa apakah error karena email tidak valid/terdaftar
        if (message.contains('invalid') || message.contains('terdaftar')) {
          setState(() => _errorMessage = 'Email tidak terdaftar. Silakan gunakan email yang terdaftar di sistem.');
        } else {
          setState(() => _errorMessage = message);
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'Terjadi kesalahan: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://sitamanext.informatikapolines.id/api/reset-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'otp': int.tryParse(_otpController.text) ?? 0,
          'email': _email,
          'password': _passwordController.text,
          'password_confirmation': _confirmController.text,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _currentStep = 3; // Pindah ke step success
        });
      } else {
        final body = jsonDecode(response.body);
        String message = body['message'] ?? 'Gagal mereset password';

        // Periksa apakah error karena OTP tidak valid
        if (message.contains('OTP') && (message.contains('invalid') || message.contains('tidak valid'))) {
          setState(() => _errorMessage = 'Kode OTP tidak valid. Silakan cek kembali kode yang dikirim ke email Anda.');
        } else {
          setState(() => _errorMessage = message);
        }
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
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Center(
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
              child: _getStepWidget(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getStepWidget() {
    switch (_currentStep) {
      case 0:
        return _buildEmailForm();
      case 1:
        return _buildOtpForm();
      case 2:
        return _buildPasswordForm();
      case 3:
        return _buildSuccess();
      default:
        return _buildEmailForm();
    }
  }

  Widget _buildEmailForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/google.png', height: 80),
        SizedBox(height: 16),
        Text('SITAMA', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
        SizedBox(height: 32),
        Text('Masukkan Email', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        const Text('Hanya email terdaftar yang dapat digunakan untuk reset password',
            style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
        SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Email', style: TextStyle(fontSize: 14)),
              SizedBox(height: 4),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'email_terdaftar@contoh.com',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Email wajib diisi';
                  }
                  // Validasi sederhana untuk format email
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendForgotPasswordRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Kirim Kode Verifikasi', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/google.png', height: 80),
        SizedBox(height: 16),
        Text('SITAMA', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
        SizedBox(height: 32),
        Text('Verifikasi OTP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Silakan masukkan kode OTP yang telah dikirim ke email Anda', textAlign: TextAlign.center),
        SizedBox(height: 4),
        const Text('Pastikan kode OTP sesuai dengan yang dikirim ke email Anda',
            style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
        SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Kode OTP', style: TextStyle(fontSize: 14)),
              SizedBox(height: 4),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Masukkan kode OTP',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Kode OTP wajib diisi';
                  }
                  if (val.length != 6) {
                    return 'Kode OTP harus 6 digit';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () {
                    setState(() {
                      _currentStep = 2; // Pindah ke step password
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Lanjutkan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/google.png', height: 80),
        SizedBox(height: 16),
        Text('SITAMA', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
        SizedBox(height: 32),
        Text('Atur Ulang Kata Sandi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        Text('Masukkan kata sandi baru Anda', textAlign: TextAlign.center),
        SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Password Baru', style: TextStyle(fontSize: 14)),
              SizedBox(height: 4),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Password Baru',
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                validator: (val) => val == null || val.length < 6 ? 'Minimal 6 karakter' : null,
              ),
              SizedBox(height: 16),
              Text('Konfirmasi Password Baru', style: TextStyle(fontSize: 14)),
              SizedBox(height: 4),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  hintText: 'Konfirmasi Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                validator: (val) => val != _passwordController.text ? 'Password tidak sama' : null,
              ),
              SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Reset Password', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/google.png', height: 80),
        SizedBox(height: 16),
        Text('SITAMA', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
        SizedBox(height: 32),
        Text('Berhasil melakukan reset password', style: TextStyle(fontSize: 15)),
        SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Kembali ke Login', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
