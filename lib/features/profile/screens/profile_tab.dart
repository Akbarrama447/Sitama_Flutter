import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../main.dart'; // Untuk akses storageService
import '../../../core/services/api_service.dart';
import '../../auth/screens/login_screen.dart'; // Untuk halaman login
import 'ubah_password_screen.dart';
import '../../../core/services/auth_service.dart';

// (Model UserProfile-nya masih sama persis)
class UserProfile {
  final String nama;
  final String email;
  final int nim;
  final String prodi;
  final String? fotoUrl;
  final Map<String, dynamic>? thesisData;

  UserProfile({
    required this.nama,
    required this.email,
    required this.nim,
    required this.prodi,
    this.fotoUrl,
    this.thesisData,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nama: json['nama'] ?? 'Nama tidak ditemukan',
      email: json['email'] ?? 'Email tidak ditemukan',
      nim: json['nim'] ?? 0,
      prodi: json['prodi'] ?? 'Prodi tidak ditemukan',
      fotoUrl: json['foto_profil'],
      thesisData: null,
    );
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Future<UserProfile>? _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfile();
  }

  // Fungsi manggil API (Logika sama persis)
  Future<UserProfile> _fetchProfile() async {
    try {
      final token = await storageService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      final url = Uri.parse(ApiService.profileUrl);
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final userProfile = UserProfile.fromJson(responseBody['data']);

        // Simpan data profil ke storage
        await storageService.saveProfile({
          'nama': userProfile.nama,
          'nim': userProfile.nim.toString(), // Konversi ke string agar konsisten
          'prodi': userProfile.prodi,
          'email': userProfile.email,
          'foto_profil': userProfile.fotoUrl,
        });

        // Fetch thesis data
        try {
          final thesisResponse = await ApiService.getThesis(token);
          final thesisData = thesisResponse['data'];

          // Return user profile with thesis data
          return UserProfile(
            nama: userProfile.nama,
            email: userProfile.email,
            nim: userProfile.nim,
            prodi: userProfile.prodi,
            fotoUrl: userProfile.fotoUrl,
            thesisData: thesisData, // Add thesis data if available
          );
        } catch (e) {
          // If thesis data fetch fails (e.g., user doesn't have thesis), return profile without thesis
          // This could happen with 404 "Tugas akhir tidak ditemukan" error
          return UserProfile(
            nama: userProfile.nama,
            email: userProfile.email,
            nim: userProfile.nim,
            prodi: userProfile.prodi,
            fotoUrl: userProfile.fotoUrl,
            thesisData: null, // No thesis data
          );
        }
      } else if (response.statusCode == 401) {
        // Token expired, auto logout
        _logout(true); // Panggil logout
        throw Exception('Sesi Anda telah berakhir. Silakan login ulang.');
      } else {
        throw Exception('Gagal memuat profil. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Fungsi untuk refresh
  Future<void> _onRefresh() async {
    setState(() {
      _profileFuture = _fetchProfile();
    });
  }

  // --- FUNGSI LOGOUT (PINDAH KE SINI) ---
  Future<void> _logout(bool isTokenExpired) async {
    // Gunakan service auth untuk logout
    await AuthService.instance.logout(context);

    // Tampilkan notifikasi jika token expired
    if (isTokenExpired && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi Anda telah berakhir. Silakan login ulang.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kita nggak pakai Scaffold di sini,
    // karena dia "tab" yang nempel di DashboardScreen
    return Container(
      color: Colors.grey[100], // Warna background body
      child: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          // --- 1. Saat LOADING ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- 2. Saat ERROR ---
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Oops! Terjadi kesalahan:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _onRefresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    )
                  ],
                ),
              ),
            );
          }

          // --- 3. Saat SUKSES ---
          if (snapshot.hasData) {
            final profile = snapshot.data!;
            // Tampilkan UI sesuai desainmu
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: _buildProfileUI(context, profile), // UI baru
            );
          }

          return const Center(child: Text('Tidak ada data.'));
        },
      ),
    );
  }

  // --- WIDGET UI BARU (SESUAI DESAIN) ---
  Widget _buildProfileUI(BuildContext context, UserProfile profile) {
    final theme = Theme.of(context);
    // Mendapatkan inisial nama, contoh: "Gennaro Kutch" -> "GK"
    String getInitials(String name) {
      List<String> names = name.split(" ");
      String initials = "";
      if (names.isNotEmpty) {
        initials += names[0][0];
        if (names.length > 1) {
          initials += names[names.length - 1][0];
        }
      }
      return initials.toUpperCase();
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // --- HEADER BIRU (disesuaikan warna & melengkung) ---
        Container(
          padding: const EdgeInsets.only(top: 48, bottom: 32),
          decoration: BoxDecoration(
            // Samakan dengan warna tombol Logout supaya konsisten
            color: Colors.blue,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Avatar (Foto Profil)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: profile.fotoUrl != null
                      ? Image.network(
                          profile.fotoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(
                              getInitials(profile.nama),
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            'H',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              // Nama
              Text(
                profile.nama,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Email
              Text(
                profile.email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // --- KONTEN DI BAWAH HEADER ---
        Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Info
              Text(
                'Detail Mahasiswa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                icon: Icons.badge_outlined,
                label: 'NIM',
                value: profile.nim.toString(),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                icon: Icons.school_outlined,
                label: 'Program Studi',
                value: profile.prodi,
              ),

              // Show thesis data if available
              if (profile.thesisData != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50], // Light blue background
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!, width: 1), // Blue border
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.assignment_outlined, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Tugas Akhir',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        icon: Icons.book_outlined,
                        label: 'Judul Tugas Akhir',
                        value: profile.thesisData!['judul'] ?? 'Tidak ada judul',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        icon: Icons.description_outlined,
                        label: 'Deskripsi',
                        value: profile.thesisData!['deskripsi'] ?? 'Tidak ada deskripsi',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        icon: Icons.flag_outlined,
                        label: 'Status',
                        value: profile.thesisData!['status'] ?? '-',
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // If no thesis data, just show a message
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100], // Light grey background
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!, width: 1), // Grey border
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outlined, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'Tugas Akhir',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Anda belum mendaftar Tugas Akhir',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Tombol Ubah Password
              Container(
                width: double.infinity,
                height: 55,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const UbahPasswordScreen(),
                        ),
                      );
                    },
                  icon: const Icon(Icons.key_outlined),
                  label: const Text('Ubah password'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    backgroundColor: Colors.grey[200],
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Tombol Logout
              Container(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => _logout(false),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper untuk card info (Label & Value)
  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // End of class
}