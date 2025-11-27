import 'package:flutter/material.dart';

// Halaman dummy
class DummyPage extends StatelessWidget {
  final String title;
  const DummyPage({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Center(
        child: Text('Ini adalah halaman $title',
            style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}

class PendaftaranSidangPage extends StatefulWidget {
  const PendaftaranSidangPage({super.key});

  @override
  State<PendaftaranSidangPage> createState() =>
      _PendaftaranSidangPageState();
}

class _PendaftaranSidangPageState
    extends State<PendaftaranSidangPage> {
  String? _selectedJadwal;
  int _selectedIndex = 0; // Default ke index pertama (Home)

  final List<String> _listJadwal = [
    '01-12-2025, Senin 13.00-15.00 GKT - 806',
    '02-12-2025, Selasa 09.00-11.00 R. Dosen 1',
    '03-12-2025, Rabu 15.00-17.00 R. Sidang Utama',
  ];

  static const Color darkBlue = Color(0xFF1976D2);
  static const Color lightBlue = Color(0xFF03A9F4);
  static const Color lightBlueBg = Color(0xFFE3F2FD);
  static const Color scaffoldBg = Colors.white;
  static const Color primaryTextColor = Color(0xFF333333);
  static const Color dividerColor = Color(0xFFEEEEEE);
  static const Color greyTextColor = Color(0xFF6B6B6B);

  void _showKonfirmasiDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child:
                        const Icon(Icons.close, color: Colors.grey, size: 28),
                  ),
                ),
                const SizedBox(height: 10),
                const Icon(
                  Icons.error_outline,
                  color: darkBlue,
                  size: 80,
                ),
                const SizedBox(height: 20),
                const Text(
                  'APAKAH ANDA YAKIN?!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _daftarSidang();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Ya',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _daftarSidang() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const DummyPage(title: 'Pendaftaran Sidang Berhasil!'),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: <Widget>[
          // Area Gradasi
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenSize.height * 0.25,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, lightBlueBg],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.7],
                ),
              ),
            ),
          ),

          // Custom "AppBar" / Header HANYA dengan Suko Tyas dan Garis Tipis
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 50,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Text(
                      'Suko Tyas',
                      style: TextStyle(
                          color: darkBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  // Garis horizontal tipis di bawah Suko Tyas
                  Container(
                    height: 1.0,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
            ),
          ),

          // Card "Pendaftaran Sidang" (Kotak Putih Besar)
          Positioned(
            top: screenSize.height * 0.22,
            left: 8,
            right: 8,
            bottom: 290,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    spreadRadius: 1,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Area Judul "Pendaftaran Sidang" (Paling Atas Kotak Putih)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
                        child: const Text(
                          'Pendaftaran Sidang',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                      ),

                      // Garis Pemisah Tipis di bawah Judul
                      const Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Divider(
                          color: dividerColor,
                          thickness: 1.0,
                          height: 1.0,
                          indent: 0,
                          endIndent: 0,
                        ),
                      ),

                      // Konten Form (Judul Tugas Akhir & Jadwal)
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Judul Final Tugas Akhir Field
                            _buildLabelWithStar(
                                label: 'Judul Final Tugas Akhir'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              hintText: 'Masukkan Judul Final Tugas Akhir',
                            ),
                            const SizedBox(height: 20),

                            // Pilih Jadwal Sidang (Dropdown)
                            _buildLabel(label: 'Pilih Jadwal Sidang'),
                            const SizedBox(height: 8),
                            _buildDropdownField(), // Menggunakan Dropdown standar
                            const SizedBox(height: 15), // Jarak sebelum garis
                          ],
                        ),
                      ),

                      // Garis Pemisah Tipis di atas Tombol
                      const Divider(
                        color: dividerColor,
                        thickness: 1.0,
                        height: 1.0,
                        indent: 0,
                        endIndent: 0,
                      ),

                      // Tombol Daftar Sidang Area
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: _showKonfirmasiDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: lightBlue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 70, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              'Daftar Sidang',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Tombol Kembali
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: darkBlue,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget kustom untuk Label dengan Bintang Merah
  Widget _buildLabelWithStar({required String label}) {
    return Row(
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: primaryTextColor,
          ),
        ),
        const Text(
          ' *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  // Widget kustom untuk Label tanpa Bintang
  Widget _buildLabel({required String label}) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
    );
  }

  // Widget kustom untuk TextField (PERBAIKAN PADDING)
  Widget _buildTextField({required String hintText}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: greyTextColor, fontSize: 14),
          // PERUBAHAN PENTING: contentPadding Vertikal dikurangi menjadi 10
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  // Dropdown Standard (PERBAIKAN PADDING)
  Widget _buildDropdownField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedJadwal,
          hint: Padding(
            // PERBAIKAN PADDING: Mengurangi padding vertikal menjadi 10
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: Text(
              'Pilih jadwal yang tersedia',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ),
          isExpanded: true,
          icon: const Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: Icon(Icons.keyboard_arrow_down,
                color: Colors.grey, size: 24), // Ukuran ikon disesuaikan
          ),
          elevation: 0,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          onChanged: (String? newValue) {
            setState(() {
              _selectedJadwal = newValue;
            });
          },
          items: _listJadwal.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(value),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Widget kustom untuk setiap item Bottom Nav Bar (Sesuai capsule design)
  Widget _buildBottomNavItem(
      IconData iconDataOutline, IconData iconDataFilled, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 25, vertical: 8)
            : const EdgeInsets.all(8),
        decoration: isSelected
            ? BoxDecoration(
                color: lightBlueBg,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: darkBlue, width: 1.5),
              )
            : null,
        child: Icon(
          isSelected ? iconDataFilled : iconDataOutline,
          color: isSelected ? darkBlue : Colors.grey.shade600,
          size: isSelected ? 28 : 28,
        ),
      ),
    );
  }
}

// Main App untuk menjalankan Halaman Pendaftaran Sidang
void main() {
  runApp(const MaterialApp(
    title: 'Menu Sidang',
    home: PendaftaranSidangPage(),
    debugShowCheckedModeBanner: false,
  ));
}
