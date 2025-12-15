import 'package:flutter/material.dart';
import '../constants/sidang_colors.dart';
import '../models/jadwal_sidang_model.dart';
import '../services/jadwal_sidang_service.dart';

class PendaftaranSidangForm extends StatefulWidget {
  const PendaftaranSidangForm({super.key});

  @override
  State<PendaftaranSidangForm> createState() => _PendaftaranSidangFormState();
}

class _PendaftaranSidangFormState extends State<PendaftaranSidangForm> {
  final TextEditingController _judulController = TextEditingController();
  JadwalSidang? _selectedJadwal;
  List<JadwalSidang> _jadwalList = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadJadwalTersedia();
  }

  Future<void> _loadJadwalTersedia() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<JadwalSidang>? jadwalTersedia = await JadwalSidangService.getJadwalTersedia();
      
      if (jadwalTersedia != null) {
        setState(() {
          _jadwalList = jadwalTersedia;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Gagal memuat jadwal sidang. Silakan coba lagi nanti.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _submitPendaftaran() async {
    if (_judulController.text.trim().isEmpty) {
      _showErrorDialog('Judul tugas akhir harus diisi.');
      return;
    }

    if (_selectedJadwal == null) {
      _showErrorDialog('Silakan pilih jadwal sidang terlebih dahulu.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      PendaftaranResponse? response = await JadwalSidangService.daftarSidang(
        judul: _judulController.text.trim(),
        jadwalSidangId: _selectedJadwal!.id,
      );

      if (response != null && response.status == 'success') {
        _showSuccessDialog(response.message);
      } else {
        _showErrorDialog(response?.message ?? 'Gagal mendaftar sidang');
      }
    } catch (e) {
      _showErrorDialog('Terjadi kesalahan: ${e.toString()}');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Berhasil"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Memuat jadwal sidang...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 20),
                Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 200,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _loadJadwalTersedia,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SidangColors.buttonBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Coba Lagi',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: const Align(
                  alignment: Alignment.centerRight,
                  child: Text('Suko Tyas',
                      style: TextStyle(
                          color: SidangColors.headerTextBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14))),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 250,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFE3F2FD), Colors.white]),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  width: double.infinity,
                                  height: 4,
                                  color: SidangColors.cardTopBorderBlue),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(20, 20, 20, 15),
                                  child: Text('Pendaftaran Sidang',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF37474F)))),
                              const Divider(
                                  height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel(
                                        label: 'Judul Final Tugas Akhir',
                                        isRequired: true),
                                    const SizedBox(height: 8),
                                    _buildTextField(
                                        controller: _judulController,
                                        hintText:
                                            'Masukan Judul Final Tugas Akhir'),
                                    const SizedBox(height: 20),
                                    _buildLabel(
                                        label: 'Pilih Jadwal Sidang',
                                        isRequired: true),
                                    const SizedBox(height: 8),
                                    _buildDropdown(),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(
                                  height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 25.0),
                                child: Center(
                                  child: SizedBox(
                                    width: 150,
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: _isSubmitting ? null : _submitPendaftaran,
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: _isSubmitting 
                                              ? Colors.grey 
                                              : SidangColors.buttonBlue,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6))),
                                      child: _isSubmitting 
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Text('Daftar Sidang',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel({required String label, required bool isRequired}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF455A64),
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto'),
        children: isRequired
            ? const [
                TextSpan(
                    text: ' *',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold))
              ]
            : [],
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller, required String hintText}) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: SidangColors.borderColor)),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 12)),
      ),
    );
  }

  Widget _buildDropdown() {
    if (_jadwalList.isEmpty) {
      return Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: SidangColors.borderColor)),
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text("Tidak ada jadwal tersedia",
              style: TextStyle(color: Colors.grey, fontSize: 13)),
        ),
      );
    }

    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: SidangColors.borderColor)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<JadwalSidang>(
          value: _selectedJadwal,
          hint: const Text("Pilih jadwal sidang",
              style: TextStyle(color: Colors.grey, fontSize: 13)),
          icon: const Icon(Icons.arrow_drop_down),
          isExpanded: true,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          onChanged: _isSubmitting 
              ? null 
              : (JadwalSidang? value) {
                  setState(() {
                    _selectedJadwal = value;
                  });
                },
          items: _jadwalList
              .map((jadwal) => DropdownMenuItem(
                    value: jadwal,
                    child: Text(
                      '${jadwal.tanggal} ${jadwal.sesi.jamMulai}-${jadwal.sesi.jamSelesai} (${jadwal.ruangan.namaRuangan})',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _judulController.dispose();
    super.dispose();
  }
}