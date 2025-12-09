import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Import wajib untuk pilih file

// Definisi Warna
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
  String _fileName = '';

  @override
  void dispose() {
    _judulController.dispose();
    _revisianController.dispose();
    super.dispose();
  }

  // --- LOGIKA PILIH FILE (BARU) ---
  Future<void> _pickFile() async {
    // Membuka dialog pilih file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'], // Hanya boleh pilih PDF/Word
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      setState(() {
        _fileName = file.name; // Ambil nama file
        _revisianController.text = _fileName; // Tampilkan di inputan
      });
      
      // Info: File aslinya ada di 'file.bytes' (Web) atau 'file.path' (HP)
    } else {
      // User batal memilih
    }
  }

  // --- LOGIKA UPLOAD ---
  Future<void> _handleUpload() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fileName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih file revisi terlebih dahulu.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    // Simulasikan proses upload
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisi berhasil diupload!')),
      );

      // Kirim sinyal sukses ke halaman sebelumnya
      Navigator.pop(context, true);
    }
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
                color: Colors.grey.shade700),
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

  // --- BUILD UTAMA ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: _buildTopHeader('Suko Tyas'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 60, 16, 16),
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

                    // Input File Revisian (DENGAN FILE PICKER)
                    _buildTextField(
                      controller: _revisianController,
                      label: 'Revisian',
                      hint: 'Pilih file PDF/Doc...',
                      readOnly: true, // Tidak bisa diketik manual
                      suffixIcon: const Icon(Icons.note_add_outlined,
                          color: _primaryColor),
                      onSuffixTap: _pickFile, // Panggil fungsi pilih file
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
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
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}