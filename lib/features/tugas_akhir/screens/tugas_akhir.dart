import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pendaftaran Tugas Akhir',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7F9FF),
        useMaterial3: true,
      ),
      home: const ThesisRegistrationScreen(),
    );
  }
}

class ThesisRegistrationScreen extends StatefulWidget {
  const ThesisRegistrationScreen({super.key});

  @override
  State<ThesisRegistrationScreen> createState() =>
      _ThesisRegistrationScreenState();
}

class _ThesisRegistrationScreenState extends State<ThesisRegistrationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  List<String> daftarNama = [
    'Rivan Dwi Cahyanto',
    'Suko Tyas',
    'Bagas',
    'Dimas',
    'Nanda',
    'Cahya',
    'Rafi',
    'Tiara',
    'Aulia',
  ];

  List<TextEditingController> anggotaControllers = [
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();

    anggotaControllers[0].addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (var c in anggotaControllers) {
      c.dispose();
    }
    super.dispose();
  }

  /// ============================================================
  ///  KONFIRMASI PENGAJUAN
  /// ============================================================
  void _submitTitle() {
    String title = _titleController.text.trim();
    String desc = _descController.text.trim();

    List<String> members = anggotaControllers
        .where((c) => c.text.trim().isNotEmpty)
        .map((c) => c.text.trim())
        .toList();

    if (title.isEmpty || desc.isEmpty || members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap isi semua data terlebih dahulu!")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),

          // HEADER BIRU
          title: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Text(
              "Konfirmasi Pengajuan",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Judul:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Deskripsi:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                desc,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Anggota Kelompok:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              ...members.map(
                (m) => Text("- $m", style: const TextStyle(fontSize: 14)),
              ),

              const SizedBox(height: 12),
            ],
          ),

          actionsPadding: const EdgeInsets.only(right: 12, bottom: 10),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.black87),
              ),
            ),

            // === PERUBAHAN DI SINI: push dengan showSuccess: true
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                // PUSH HALAMAN INFO TA dan kirim flag showSuccess = true
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ThesisInfoScreen(
                      title: title,
                      description: desc,
                      members: members,
                      showSuccess: true,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text("Kirim"),
            ),
          ],
        );
      },
    );
  }

  /// ============================================================
  ///  UI LAYAR
  /// ============================================================
  @override
  Widget build(BuildContext context) {
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
                  'Suko Tyas',
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
              'Suko Tyas',
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
                        maxLines: 5,
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
                      ),

                      const SizedBox(height: 20),

                      /// ANGGOTA
                      const Text(
                        'Anggota Kelompok',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Column(
                        children:
                            List.generate(anggotaControllers.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Autocomplete<String>(
                                    optionsBuilder: (value) {
                                      if (value.text.isEmpty) {
                                        return [];
                                      }
                                      return daftarNama.where((name) => name
                                          .toLowerCase()
                                          .contains(value.text.toLowerCase()));
                                    },
                                    fieldViewBuilder: (context, controller,
                                        focusNode, onEditingComplete) {
                                      controller.text =
                                          anggotaControllers[index].text;

                                      controller.addListener(() {
                                        anggotaControllers[index].text =
                                            controller.text;
                                        setState(() {});
                                      });

                                      return TextField(
                                        controller: controller,
                                        focusNode: focusNode,
                                        decoration: InputDecoration(
                                          hintText:
                                              'Masukkan nama rekan kelompok',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade400),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 12),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                      );
                                    },
                                    onSelected: (value) {
                                      anggotaControllers[index].text = value;
                                      setState(() {});
                                    },
                                  ),
                                ),

                                const SizedBox(width: 10),

                                (index == anggotaControllers.length - 1)
                                    ? InkWell(
                                        onTap: () {
                                          if (anggotaControllers[index]
                                              .text
                                              .trim()
                                              .isNotEmpty) {
                                            setState(() {
                                              final c =
                                                  TextEditingController();
                                              c.addListener(() {
                                                setState(() {});
                                              });
                                              anggotaControllers.add(c);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: anggotaControllers[index]
                                                    .text
                                                    .trim()
                                                    .isNotEmpty
                                                ? Colors.blue
                                                : Colors.grey,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.add,
                                              color: Colors.white),
                                        ),
                                      )
                                    : InkWell(
                                        onTap: () {
                                          if (index > 0) {
                                            setState(() {
                                              anggotaControllers
                                                  .removeAt(index);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: index == 0
                                                ? Colors.grey
                                                : Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.remove,
                                            color: index == 0
                                                ? Colors.white54
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 30),

                      Center(
                        child: ElevatedButton(
                          onPressed: _submitTitle,
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
                            'Ajukan Judul',
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

/// ============================================================
///  HALAMAN INFO TUGAS AKHIR (DESAIN SAMA DENGAN GAMBAR)
/// ============================================================

class ThesisInfoScreen extends StatelessWidget {
  final String title;
  final String description;
  final List<String> members;
  final bool showSuccess; // tambahan flag

  const ThesisInfoScreen({
    super.key,
    required this.title,
    required this.description,
    required this.members,
    this.showSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    // tampilkan snackbar setelah frame pertama jika flag true
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (showSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Judul berhasil diajukan!"),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xffF3F6FD),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff1976D2), // warna biru yang sama
        title: const Text(
          "Info Tugas Akhir",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCard(
              title: "Judul Tugas Akhir",
              content: title,
            ),
            _buildCard(
              title: "Deskripsi",
              content: description,
            ),
            _buildCard(
              title: "Anggota Kelompok",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < members.length; i++)
                    Text(
                      "${i + 1}. ${members[i]}",
                      style: const TextStyle(fontSize: 15),
                    ),
                ],
              ),
            ),
            _buildCard(
  title: "Dosen Pembimbing",
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text(
        "1. Belum ditentukan",
        style: TextStyle(fontSize: 15),
      ),
      SizedBox(height: 6),
      Text(
        "2. Belum ditentukan",
        style: TextStyle(fontSize: 15),
      ),
      SizedBox(height: 10),
      Text(
        "Menunggu penetapan dari sekretaris jurusan.",
        style: TextStyle(color: Colors.black54, fontSize: 13),
      ),
    ],
  ),
),

          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, String? content, Widget? child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xff1976D2), width: 1), // garis biru sama
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          if (content != null)
            Text(
              content!,
              style: const TextStyle(fontSize: 15),
            ),
          if (child != null) child,
        ],
      ),
    );
  }
}
