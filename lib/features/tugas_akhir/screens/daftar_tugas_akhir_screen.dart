import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../core/services/api_service.dart';
import 'detail_tugas_akhir_screen.dart';
import '../../../widgets/modern_back_button.dart';
import '../../../main.dart'; 

class DaftarTugasAkhirScreen extends StatefulWidget {
  const DaftarTugasAkhirScreen({super.key});

  @override
  State<DaftarTugasAkhirScreen> createState() => _DaftarTugasAkhirScreenState();
}

class _DaftarTugasAkhirScreenState extends State<DaftarTugasAkhirScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  bool _isLoading = false;
  bool _checkingThesisStatus = true;
  bool _hasThesis = false;
  String? _token;

  final List<TextEditingController> _anggotaControllers = [
    TextEditingController()
  ];

  List<Map<String, dynamic>> _daftarMahasiswa = [
    {'name': 'Budi', 'nim': '12345'},
    {'name': 'Siti Aminah', 'nim': '67890'},
  ];

  @override
  void initState() {
    super.initState();
    _checkThesisStatus();
  }

  Future<void> _fetchDaftarMahasiswa(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.apiHost}/api/mahasiswa'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            _daftarMahasiswa =
                data.map((e) => Map<String, dynamic>.from(e)).toList();
          });
        }
      } else {
        debugPrint("Gagal Fetch Mahasiswa: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error Fetch Mahasiswa: $e");
    }
  }

  Future<void> _checkThesisStatus() async {
    String? token = await storageService.getToken();
    if (token == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Sesi habis, silakan login kembali."),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pushReplacementNamed('/login');
        }
      });

      return;
    }

    if (mounted) {
      setState(() {
        _token = token;
      });
    }

    _fetchDaftarMahasiswa(token);

    try {
      final response = await ApiService.getThesis(token);
      if (mounted) {
        if (response['status'] == 'success' && response['data'] != null) {
          setState(() {
            _hasThesis = true;
            _checkingThesisStatus = false;
          });
        } else {
          setState(() {
            _hasThesis = false;
            _checkingThesisStatus = false;
          });
        }
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _hasThesis = false;
          _checkingThesisStatus = false;
        });
    }
  }

  void _tambahAnggotaField() {
    setState(() {
      _anggotaControllers.add(TextEditingController());
    });
  }

  void _hapusAnggotaField(int index) {
    if (index > 0)
      setState(() {
        _anggotaControllers.removeAt(index).dispose();
      });
  }

  // --- 3. SUBMIT DATA (SUDAH DIPERBAIKI) ---
  Future<void> _submitTugasAkhir() async {
    // Cek Token lagi untuk keamanan ganda
    if (_token == null) {
      _showSnackBar("Token invalid. Silakan login ulang.", Colors.red);
      return;
    }

    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      _showSnackBar("Judul dan deskripsi wajib diisi!", Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<String> memberNims = [];

      // [FIX 2] Logic Loop yang sebelumnya hilang, sekarang dikembalikan
      for (var controller in _anggotaControllers) {
        String input = controller.text.trim();

        if (input.isNotEmpty) {
          // Cari mahasiswa di list
          final foundMhs = _daftarMahasiswa.firstWhere(
            (m) =>
                m['name'].toString().toLowerCase() == input.toLowerCase() ||
                m['nim'].toString() == input,
            orElse: () => {}, // Return map kosong kalau tidak ketemu
          );

          if (foundMhs.isNotEmpty) {
            // Jika ketemu di list (pilih dari autocomplete)
            memberNims.add(foundMhs['nim'].toString());
          } else if (RegExp(r'^\d+$').hasMatch(input)) {
            // Jika tidak ketemu di list TAPI inputnya angka (NIM manual), tetap masukkan
            memberNims.add(input);
          } else {
            // Jika input nama asal-asalan dan tidak ada di database
            throw 'Mahasiswa "$input" tidak ditemukan di database.';
          }
        }
      }

      await ApiService.createThesis(
        token: _token!,
        title: _titleController.text,
        description: _descController.text,
        members: memberNims,
      );

      if (mounted) {
        _showSnackBar("Tugas akhir berhasil diajukan!", Colors.green);
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), Colors.red);
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    // Loading awal cek status
    if (_checkingThesisStatus) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Jika sudah punya TA, redirect
    if (_hasThesis) {
      if (_token != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (c) => DetailTugasAkhirScreen(token: _token!)));
        });
      }
      return const Scaffold(); // Kosongkan layar saat redirect
    }

    // Tampilan Form Pendaftaran
    return Scaffold(
      body: Stack(
        children: [
          // Header Background
          Column(children: [
            Container(
              height: 130,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.white, Color(0xFFB3D9FF)]),
              ),
            ),
          ]),

          Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 80.0),
              child: Card(
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pendaftaran Tugas Akhir',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      const SizedBox(height: 25),
                      const Text('Judul Tugas Akhir *',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextFormField(
                          controller: _titleController,
                          decoration: _inputDecoration('Masukkan Judul'),
                          maxLines: 2),
                      const SizedBox(height: 20),
                      const Text('Deskripsi Tugas Akhir *',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextFormField(
                          controller: _descController,
                          decoration: _inputDecoration('Masukkan deskripsi...'),
                          maxLines: 5),
                      const SizedBox(height: 20),
                      const Text('Anggota Kelompok (Opsional)',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),

                      // List Input Anggota
                      Column(
                        children: List.generate(
                          _anggotaControllers.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: AnggotaInputRow(
                                    controller: _anggotaControllers[index],
                                    daftarMahasiswa: _daftarMahasiswa,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: _actionButton(Icons.add, Colors.blue,
                                      _tambahAnggotaField),
                                ),
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: index > 0
                                      ? _actionButton(Icons.remove, Colors.red,
                                          () => _hapusAnggotaField(index))
                                      : _actionButton(
                                          Icons.remove, Colors.grey, null),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Tombol Submit
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
                                child: const Text('Ajukan Tugas Akhir',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const ModernBackButton(),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade400)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback? action) {
    return InkWell(
      onTap: action,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// --- WIDGET TAMBAHAN: AUTOCOMPLETE ---

class AnggotaInputRow extends StatefulWidget {
  final TextEditingController controller;
  final List<Map<String, dynamic>> daftarMahasiswa;

  const AnggotaInputRow({
    super.key,
    required this.controller,
    required this.daftarMahasiswa,
  });

  @override
  State<AnggotaInputRow> createState() => _AnggotaInputRowState();
}

class _AnggotaInputRowState extends State<AnggotaInputRow> {
  final LayerLink _layerLink = LayerLink();
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CompositedTransformTarget(
          link: _layerLink,
          child: RawAutocomplete<Map<String, dynamic>>(
            textEditingController: widget.controller,
            focusNode: _focusNode,
            optionsBuilder: (TextEditingValue val) {
              if (val.text.isEmpty) return const Iterable.empty();
              return widget.daftarMahasiswa.where((m) {
                final String name = m['name']?.toString().toLowerCase() ?? '';
                final String nim = m['nim']?.toString().toLowerCase() ?? '';
                final String search = val.text.toLowerCase();
                return name.contains(search) || nim.contains(search);
              });
            },
            displayStringForOption: (opt) => opt['name'].toString(),
            fieldViewBuilder: (ctx, ctrl, focusNode, submit) {
              return TextFormField(
                controller: ctrl,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: 'Cari Nama/NIM Teman',
                  hintText: 'Ketik nama...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onFieldSubmitted: (value) => submit(),
              );
            },
            optionsViewBuilder: (ctx, onSelect, options) {
              return CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                targetAnchor: Alignment.bottomLeft,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: 200,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (ctx, i) {
                          final opt = options.elementAt(i);
                          return ListTile(
                            title: Text(opt['name'].toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(opt['nim'].toString()),
                            onTap: () => onSelect(opt),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
