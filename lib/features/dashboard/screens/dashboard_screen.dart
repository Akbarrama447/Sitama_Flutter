import 'package:flutter/material.dart';
import '../../../main.dart'; // Untuk akses storageService
import '../../auth/screens/login_screen.dart'; // Untuk halaman login

// --- IMPORT TAB KITA ---
import '../../profile/screens/profile_tab.dart';
import '../../home/screens/home_tab.dart'; // <-- BARU
import '../../tugas_akhir/screens/tugas_akhir_tab.dart'; // <-- BARU

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Halaman yang sedang aktif

  // --- REVISI: GANTI PLACEHOLDER DENGAN WIDGET ASLI ---
  static final List<Widget> _widgetOptions = <Widget>[
    // Index 0: Home
    const HomeTab(), // <-- DIGANTI

    // Index 1: Tugas Akhir
    const TugasAkhirTab(), // <-- DIGANTI

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
      // Logika AppBar (tetap sama)
      appBar: _selectedIndex == 2
          ? null // Jangan tampilkan AppBar di Halaman Profil
          : AppBar(
              title: const Text('Sitama - Sistem Tugas Akhir Mahasiswa'),
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              titleTextStyle: const TextStyle(
                color: Color.fromARGB(131, 14, 14, 14),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _logout,
                  tooltip: 'Logout',
                ),
              ],
            ),
      
      // REVISI: Ganti body ke IndexedStack
      // Ini penting agar state tiap tab (posisi scroll, data API)
      // tidak hilang saat ganti tab
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),

      // BottomNavigationBar (tetap sama)
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
            elevation: 0, 
          ),
        ),
      ),
    );
  }
}