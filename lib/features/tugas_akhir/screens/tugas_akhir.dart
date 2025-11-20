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
        // Latar belakang scaffold utama abu-abu terang, untuk blending
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
  final TextEditingController _groupMemberController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _groupMemberController.dispose();
    super.dispose();
  }

  void _submitTitle() {
    String title = _titleController.text;
    String members = _groupMemberController.text;

    print('Judul yang Diajukan: $title');
    print('Anggota Kelompok: $members');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Judul telah diajukan!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Container Utama Gradasi (Menciptakan efek "blur" di bawah)
          // --- HEADER (SAMA PERSIS SEPERTI GAMBAR) ---
Column(
  children: [
    // Bar putih + tulisan
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

    // Gradasi biru kayak gambar
    Container(
      height: 130,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white,
            Color(0xFFB3D9FF), // biru muda estetik
          ],
        ),
      ),
    ),
  ],
),


          // 2. Teks "Suko Tyas" di Pojok Kanan Atas
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

          // 3. Konten Formulir (Card) - Diletakkan di tengah
          Center(
            child: SingleChildScrollView(
              // Padding vertikal agar Card melayang di atas area transisi
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 80.0,
              ),
              child: Card(
                elevation: 4,
                color: Colors.white, // Form Card warna putih
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Formulir
                      const Text(
                        'Pendaftaran Tugas Akhir',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // --- Input Judul Tugas Akhir ---
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
                            horizontal: 16,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- Input Anggota Kelompok ---
                      const Text(
                        'Anggota Kelompok',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _groupMemberController,
                        decoration: InputDecoration(
                          hintText: 'Masukkan nama rekan kelompok (Jika ada)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // --- Tombol Ajukan Judul ---
                      Center(
                        child: ElevatedButton(
                          onPressed: _submitTitle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
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

      // --- Bottom Navigation Bar ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Ikon Rumah (Home)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.shade100, width: 1.5),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.home_outlined,
                color: Colors.blue,
                size: 28,
              ),
            ),

            // Ikon Akademik (Topi)
            const Icon(Icons.school_outlined, color: Colors.blue, size: 28),

            // Ikon Profil (Orang)
            const Icon(Icons.person_outline, color: Colors.blue, size: 28),
          ],
        ),
      ),
    );
  }
}