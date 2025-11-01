import 'package:flutter/material.dart';
// imports trimmed: dashboard doesn't directly use storageService or LoginScreen anymore
import '../../profile/screens/profile_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // State untuk melacak tab mana yang aktif

  // --- FUNGSI LOGOUT SEKARANG PINDAH KE 'profile_tab.dart' ---
  // --- KITA BISA HAPUS FUNGSI _logout DARI SINI ---
  // Future<void> _logout() async { ... } // <-- HAPUS BLOK INI

  static const List<Widget> _widgetOptions = <Widget>[
    const Center(
      child: Text('Halaman Home (Index 0)'),
    ),
    const Center(
      child: Text('Halaman Jadwal (Index 1)'),
    ),
    const Center(
      child: Text('Halaman TA (Index 2)'),
    ),
    const ProfileTab(), // Halaman Profil baru kita
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const List<String> appBarTitles = [
      'Home',
      'Jadwal',
      'Tugas Akhir',
      'Profil Mahasiswa', // Judul ini GAK AKAN KEPAMPIL, tapi biarin aja
    ];

    return Scaffold(
      // --- PERUBAHAN UTAMA DI SINI ---
      // Bikin AppBar jadi null (hilang) kalo lagi di tab Profil (index 3)
      appBar: _selectedIndex == 3
          ? null // <-- HILANGKAN APPBAR UNTUK PROFIL
          : AppBar(
              title: Text(appBarTitles[_selectedIndex]),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              // Kita pindahin tombol logout ke halaman profil
              // jadi 'actions' di sini bisa dikosongin
              actions: const [],
            ),
      // --- BATAS PERUBAHAN ---

      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined), // Ganti ikon
            activeIcon: Icon(Icons.description),
            label: 'Jadwal', // Ganti label (sesuai desainmu)
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined), // Ganti ikon
            activeIcon: Icon(Icons.school),
            label: 'Tugas Akhir', // Ganti label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

