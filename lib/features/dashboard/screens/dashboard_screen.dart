import 'package:flutter/material.dart';
import '../../../main.dart'; // Untuk akses storageService
import '../../auth/screens/login_screen.dart'; // Untuk halaman login

// --- IMPORT TAB PROFIL KITA ---
import '../../profile/screens/profile_tab.dart';

// TODO: Nanti kita import tab TA di sini
// import '../../tugas_akhir/screens/tugas_akhir_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Halaman yang sedang aktif

  // --- REVISI 1: Hapus 'Halaman Jadwal' ---
  // Daftar halaman/tab yang akan ditampilkan (sekarang jadi 3)
  // Jangan gunakan `const` di sini karena `ProfileTab()` kemungkinan bukan const.
  static final List<Widget> _widgetOptions = <Widget>[
    // Index 0: Home
    const Center(
      child: Text('Halaman Home'),
    ),
    // Index 1: Tugas Akhir
    const Center(
      child: Text('Halaman TA'),
      // TODO: Nanti ganti ini dengan:
      // TugasAkhirTab(),
    ),
    // Index 2: Profil
    ProfileTab(),
  ];

  // Fungsi untuk pindah tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Fungsi logout (tetap sama)
  void _logout() async {
    await storageService.deleteToken();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- REVISI 2: Logika AppBar diubah ke index 2 ---
      // Tampilkan AppBar di semua halaman KECUALI Halaman Profil (Index 2)
      appBar: _selectedIndex == 2
          ? null // Jangan tampilkan AppBar di Halaman Profil
          : AppBar(
              title: const Text('SISTEM TA'),
              backgroundColor: const Color(0xFF1565C0),
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                // Tombol logout HANYA muncul di AppBar
                // (di halaman profil, tombol logout ada di dalam halaman)
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _logout,
                  tooltip: 'Logout',
                ),
              ],
            ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: BottomNavigationBar(
            // --- REVISI 3: Hapus item 'Jadwal' ---
            // Daftar tombol di navbar (sekarang jadi 3)
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school_outlined), // Ikon TA
                activeIcon: Icon(Icons.school),
                label: 'TA',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFF1565C0), // Warna ikon aktif
            unselectedItemColor: Colors.grey, // Warna ikon non-aktif
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
            showSelectedLabels: true, // Tampilkan label
            showUnselectedLabels: false, // Sembunyikan label non-aktif
            elevation: 0, // Hapus bayangan default (kita pakai custom)
          ),
        ),
      ),
    );
  }
}

