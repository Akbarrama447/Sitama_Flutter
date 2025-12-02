import 'package:flutter/material.dart';

// Definisi Warna (Sesuaikan dengan tema aplikasi Anda)
const Color _primaryColor = Color(0xFF149BF6);
const Color _uploadButtonColor = Color(0xFF03A9F4); 

class FormRevisiScreen extends StatefulWidget {
  const FormRevisiScreen({super.key});

  @override
  State<FormRevisiScreen> createState() => _FormRevisiScreenState();
}

class _FormRevisiScreenState extends State<FormRevisiScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _revisianController = TextEditingController(); 
  
  bool _isUploading = false;
  String _fileName = ''; // Nama file kosong di awal

  @override
  void dispose() {
    _judulController.dispose();
    _revisianController.dispose();
    super.dispose();
  }

  // --- LOGIKA UPLOAD ---
  Future<void> _handleUpload() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validasi tambahan untuk file
    if (_fileName.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih file revisi terlebih dahulu.')),
       );
       return;
    }

    setState(() => _isUploading = true);
    
    // Simulasikan proses upload ke server (Delay 2 detik)
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisi berhasil diupload!')),
      );
      
      // ✅ KUNCI PENTING: Kirim nilai 'true' saat kembali
      // Ini memberi tahu halaman sebelumnya bahwa upload SUKSES
      Navigator.pop(context, true); 
    }
  }

  // Simulasi pilih file
  void _pickFile() {
    setState(() {
      _fileName = 'Dokumen_Revisi_Final_v1.pdf'; // Simulasi nama file
      _revisianController.text = _fileName;
    });
  }

  // --- WIDGET HELPER ---

  Widget _buildTopHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 10.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.w600, 
              color: Colors.grey.shade700
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String hint = '',
    bool readOnly = false,
    Widget? suffixIcon,
    VoidCallback? onSuffixTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: _primaryColor, width: 1.5),
            ),
            suffixIcon: suffixIcon != null
                ? InkWell(
                    onTap: onSuffixTap,
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: suffixIcon,
                    ),
                  )
                : null,
          ),
          validator: (value) {
            if (label == 'Judul' && (value == null || value.isEmpty)) {
              return 'Judul tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryColor, // Latar belakang biru
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: _buildTopHeader('Suko Tyas'), 
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Card Putih Form
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Upload Revisi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Input Judul
                        _buildTextField(
                          controller: _judulController,
                          label: 'Judul',
                          hint: 'Masukkan judul revisi',
                        ),

                        // Input File Revisian
                        _buildTextField(
                          controller: _revisianController,
                          label: 'Revisian',
                          hint: 'revisian.pdf',
                          readOnly: true,
                          suffixIcon: const Icon(Icons.note_add_outlined, color: _primaryColor),
                          onSuffixTap: _pickFile,
                        ),
                        
                        const SizedBox(height: 30),

                        // Tombol Upload
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isUploading ? null : _handleUpload,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _uploadButtonColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: _isUploading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Upload',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Padding bawah agar tidak tertutup nav bar
                const SizedBox(height: 100), 
              ],
            ),
          ),
          
          // Bottom Navigation Bar (Visual Saja)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 65, 
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                border: Border.all(color: Colors.grey.shade300)
              ),
              margin: const EdgeInsets.only(bottom: 20, left: 40, right: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  IconButton(icon: const Icon(Icons.home_outlined, size: 28), color: Colors.grey, onPressed: () {}),
                  IconButton(icon: const Icon(Icons.school_outlined, size: 28), color: _primaryColor, onPressed: () {}),
                  IconButton(icon: const Icon(Icons.person_outline, size: 28), color: Colors.grey, onPressed: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}