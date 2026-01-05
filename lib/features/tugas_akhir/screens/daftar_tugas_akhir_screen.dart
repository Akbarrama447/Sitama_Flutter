import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart'; // Untuk akses storageService
import '../../../core/services/api_service.dart';
import 'detail_tugas_akhir_screen.dart';

class DaftarTugasAkhirScreen extends StatefulWidget {
  const DaftarTugasAkhirScreen({super.key});

  @override
  State<DaftarTugasAkhirScreen> createState() => _DaftarTugasAkhirScreenState();
}

class _DaftarTugasAkhirScreenState extends State<DaftarTugasAkhirScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isLoading = false;
  bool _checkingThesisStatus =
      true; // Menandai apakah sedang memeriksa status tugas akhir
  bool _hasThesis = false; // Menandai apakah user sudah memiliki tugas akhir

  // Daftar mahasiswa
  final List<Map<String, String>> _daftarMahasiswa = [
    {'nim': '110124421', 'nama': 'Rivan Dwi Cahyanto'},
    {'nim': '110124422', 'nama': 'Suko Tyas'},
    {'nim': '110124423', 'nama': 'Bagas'},
    {'nim': '110124424', 'nama': 'Dimas'},
    {'nim': '110124425', 'nama': 'Nanda'},
    {'nim': '110124426', 'nama': 'Cahya'},
    {'nim': '110124427', 'nama': 'Rafi'},
    {'nim': '110124428', 'nama': 'Tiara'},
    {'nim': '110124429', 'nama': 'Aulia'},
  ];

  // Daftar controller untuk setiap field anggota
  List<TextEditingController> _anggotaControllers = [TextEditingController()];

  @override
  void initState() {
    super.initState();
    _checkThesisStatus(); // Memeriksa apakah user sudah memiliki tugas akhir saat layar dimuat
  }

  // Fungsi untuk memeriksa status tugas akhir user
  Future<void> _checkThesisStatus() async {
    try {
      String? token = await storageService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }
      final response = await ApiService.getThesis(token);
      if (response['status'] == 'success') {
        // Jika respons sukses, periksa apakah data null atau tidak
        if (response['data'] != null) {
          // Jika data tidak null, berarti user sudah memiliki tugas akhir
          if (mounted) {
            setState(() {
              _hasThesis = true;
              _checkingThesisStatus = false;
            });
          }
        } else {
          // Jika data null, berarti user belum memiliki tugas akhir
          if (mounted) {
            setState(() {
              _hasThesis = false;
              _checkingThesisStatus = false;
            });
          }
        }
      } else {
        // Jika respons bukan success, user belum memiliki tugas akhir
        if (mounted) {
          setState(() {
            _hasThesis = false;
            _checkingThesisStatus = false;
          });
        }
      }
    } catch (e) {
      // Jika terjadi error (termasuk 404), user belum memiliki tugas akhir
      if (mounted) {
        setState(() {
          _hasThesis = false;
          _checkingThesisStatus = false;
        });
      }
    }
  }

  // Fungsi untuk menambah field anggota
  void _tambahAnggotaField() {
    setState(() {
      _anggotaControllers.add(TextEditingController());
    });
  }

  // Fungsi untuk menghapus field anggota
  void _hapusAnggotaField(int index) {
    if (index > 0 && _anggotaControllers.length > 1) {
      setState(() {
        _anggotaControllers.removeAt(index).dispose();
      });
    }
  }

  Future<void> _submitTugasAkhir() async {
    String title = _titleController.text.trim();
    String desc = _descController.text.trim();

    // Kumpulkan semua NIM dari field-field anggota
    List<String> memberNims = [];

    print('Jumlah field anggota: ${_anggotaControllers.length}'); // Debug log

    for (int i = 0; i < _anggotaControllers.length; i++) {
      String inputText = _anggotaControllers[i].text.trim();
      print('Field[$i]: "$inputText"'); // Debug log

      if (inputText.isNotEmpty) {
        // Cek apakah input cocok dengan nama di daftar
        String? foundNim;
        for (var mhs in _daftarMahasiswa) {
          if (mhs['nama'] == inputText) {
            foundNim = mhs['nim'];
            break;
          }
        }

        if (foundNim != null) {
          memberNims.add(foundNim);
          print('Menambahkan NIM: $foundNim'); // Debug log
        } else {
          // Cek apakah input adalah format NIM
          bool isNimFormat = RegExp(r'^\d{6,9}$').hasMatch(inputText);
          if (isNimFormat) {
            memberNims.add(inputText);
            print('Menambahkan NIM langsung: $inputText'); // Debug log
          } else {
            // Tampilkan error jika nama tidak ditemukan
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Anggota "$inputText" tidak ditemukan dalam daftar mahasiswa.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
        }
      }
    }

    print('Member NIMs sebelum dikirim ke API: $memberNims'); // Debug log

    if (title.isEmpty || desc.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Harap isi judul dan deskripsi terlebih dahulu!"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Tampilkan loading
    setState(() {
      _isLoading = true;
    });

    try {
      print('Title: $title'); // Debug log
      print('Description: $desc'); // Debug log
      print('Member NIMs: $memberNims'); // Debug log
      print('Total members: ${memberNims.length}'); // Debug log

      // Ambil token dari storage
      String? token = await storageService.getToken();

      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      // Panggil API untuk membuat tugas akhir
      await ApiService.createThesis(
        token: token,
        title: title,
        description: desc,
        members: memberNims, // kirim array of NIM
      );

      // Reset form
      _titleController.clear();
      _descController.clear();
      for (var controller in _anggotaControllers) {
        controller.clear();
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Tampilkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tugas akhir berhasil diajukan!"),
            backgroundColor: Colors.green,
          ),
        );

        // Kembali ke halaman sebelumnya
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Tampilkan pesan error
        String errorMessage = 'Gagal mengajukan tugas akhir: ';
        if (e is String) {
          errorMessage += e;
        } else if (e.toString().contains('SocketException')) {
          errorMessage =
              'Tidak dapat terhubung ke server. Periksa koneksi internet.';
        } else if (e.toString().contains('401')) {
          errorMessage = 'Sesi Anda telah berakhir. Silakan login kembali.';
        } else if (e.toString().contains('403')) {
          errorMessage = 'Akses ditolak. Silakan coba lagi.';
        } else if (e.toString().contains('422')) {
          errorMessage = 'Data tidak valid. Periksa kembali inputan Anda.';
        } else {
          errorMessage += e.toString();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (var controller in _anggotaControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingThesisStatus) {
      // Menampilkan loading saat memeriksa status tugas akhir
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tugas Akhir'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memeriksa status tugas akhir...'),
            ],
          ),
        ),
      );
    }

    // Jika user sudah memiliki tugas akhir, navigasi ke detail tugas akhir
    if (_hasThesis) {
      // Navigasi ke detail tugas akhir
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DetailTugasAkhirScreen(),
            ),
          );
        });
      }

      // Tampilkan loading sementara navigasi terjadi
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tugas Akhir'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Menuju detail tugas akhir...'),
            ],
          ),
        ),
      );
    }

    // Tampilkan form pendaftaran jika user belum memiliki tugas akhir
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 55,
                color: Colors.white,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                child: const Text(
                  'Mahasiswa',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                height: 130,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white,
                      Color(0xFFB3D9FF),
                    ],
                  ),
                ),
              ),
            ],
          ),

          /// PANAH KEMBALI
          Positioned(
            top: 40.0,
            left: 16.0,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back,
                size: 28,
                color: Colors.black87,
              ),
            ),
          ),

          Positioned(
            top: 40.0,
            right: 16.0,
            child: const Text(
              'Mahasiswa',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 80.0),
              child: Card(
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pendaftaran Tugas Akhir',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// JUDUL
                      const Text(
                        'Judul Tugas Akhir *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Masukkan Judul Tugas Akhir',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLines: 2,
                      ),

                      const SizedBox(height: 20),

                      /// DESKRIPSI
                      const Text(
                        'Deskripsi Tugas Akhir *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descController,
                        decoration: InputDecoration(
                          hintText: 'Masukkan deskripsi tugas akhir...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLines: 5,
                      ),

                      const SizedBox(height: 20),

                      /// ANGGOTA
                      const Text(
                        'Anggota Kelompok (Opsional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Column(
                        children: List.generate(
                          _anggotaControllers.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _anggotaControllers[index],
                                    decoration: InputDecoration(
                                      hintText: 'Masukkan NIM mahasiswa...',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    // Tambahkan validator jika diperlukan
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    _tambahAnggotaField();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _anggotaControllers[index]
                                              .text
                                              .trim()
                                              .isNotEmpty
                                          ? Colors.blue
                                          : Colors.grey,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                index > 0
                                    ? InkWell(
                                        onTap: () {
                                          _hapusAnggotaField(index);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.remove,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.remove,
                                          color: Colors.white54,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Center(
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed:
                                    _isLoading ? null : _submitTugasAkhir,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  minimumSize: const Size(200, 48),
                                ),
                                child: const Text(
                                  'Ajukan Tugas Akhir',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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
    );
  }
}
