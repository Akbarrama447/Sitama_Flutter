import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';

import '../../../main.dart';
import '../../../widgets/schedule_detail_dialog.dart';
import '../../auth/screens/login_screen.dart';
import '../../tugas_akhir/screens/daftar_tugas_akhir_screen.dart';
import '../../pendaftartan_sidang/screens/pendaftaran_sidang_page.dart';
import '../../pendaftartan_sidang/screens/persyaratan_sidang_screen.dart';
import '../../../core/services/auth_service.dart';

enum FilterType { none, room, time }

const Color blueMain = Color.fromARGB(255, 125, 186, 255);

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  FilterType _activeFilter = FilterType.none;
  String _searchQuery = '';
  late Future<List<dynamic>> _jadwalFuture;
  final String _baseUrl = 'https://sitamanext.informatikapolines.id';
  String _userName = 'User';

  // --- LOGIKA CONSTRAINT BIMBINGAN ---
  // Inisialisasi awal false agar tidak error "Null is not subtype of bool"
  bool _canRegisterSidang = false;
  String _sidangMessage = "Jumlah bimbingan belum mencukupi.";

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _focusedDay = now;
    _jadwalFuture = _fetchJadwal(_selectedDay!);
    debugPrint('DEBUG: initState dipanggil, memanggil _loadUserData');

    // Set status kelayakan sidang ke true sejak awal
    _canRegisterSidang = true;
    _sidangMessage = "Silakan lanjutkan ke proses pendaftaran sidang.";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  // Fungsi untuk memperbarui status kelayakan sidang secara manual
  void refreshSidangEligibility() {
    debugPrint('DEBUG: Memperbarui status kelayakan sidang secara manual');
    _checkSidangEligibility();
  }

  void _showTugasAkhirMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: Color.fromARGB(255, 116, 165, 250)),
                  title: const Text(
                    'Daftar Tugas Akhir',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DaftarTugasAkhirScreen()),
                    );
                  },
                ),
                const Divider(height: 1),

                // --- TOMBOL DAFTAR SIDANG (CONSTRAINT LOGIC) ---
                ListTile(
                  enabled: _canRegisterSidang, // Tombol tidak bisa diklik jika belum 8 bimbingan per dosen
                  leading: Icon(
                    Icons.school_outlined,
                    // Warna jadi Hitam/Abu jika tidak memenuhi syarat
                    color: _canRegisterSidang
                        ? const Color.fromARGB(255, 116, 165, 250)
                        : Colors.black45,
                  ),
                  title: Text(
                    'Daftar Sidang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      // Teks jadi Hitam/Abu jika tidak memenuhi syarat
                      color: _canRegisterSidang ? Colors.black87 : Colors.black45,
                    ),
                  ),
                  // Tampilkan pesan alasan (Contoh: "Bimbingan baru 5 dari minimal 8")
                  subtitle: !_canRegisterSidang
                    ? Text(_sidangMessage, style: const TextStyle(fontSize: 10, color: Colors.red))
                    : null,
                  onTap: _canRegisterSidang ? () async {
                    // Cek apakah pengguna sudah mendaftar sidang
                    final token = await storageService.getToken();
                    if (token == null) {
                      _forceLogout();
                      return;
                    }

                    final pendaftaranUrl = Uri.parse('$_baseUrl/api/pendaftaran-sidang');
                    final pendaftaranResponse = await http.get(pendaftaranUrl, headers: {
                      'Authorization': 'Bearer $token',
                      'Accept': 'application/json',
                    });

                    if (pendaftaranResponse.statusCode == 200) {
                      final pendaftaranData = jsonDecode(pendaftaranResponse.body);
                      if (pendaftaranData['status'] == 'success' && pendaftaranData['data'] != null) {
                        // Jika sudah mendaftar sidang, arahkan ke detail pendaftaran
                        Navigator.pop(context);
                        // Kita perlu impor screen detail sidang jika belum
                        // Untuk sekarang kita arahkan ke pendaftaran sidang page yang akan menangani redirect
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PendaftaranSidangPage()),
                        );
                      } else {
                        // Jika belum mendaftar sidang, arahkan ke persyaratan
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PersyaratanSidangScreen()),
                        );
                      }
                    } else if (pendaftaranResponse.statusCode == 404) {
                      // 404 berarti belum ada pendaftaran sidang, arahkan ke persyaratan
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PersyaratanSidangScreen()),
                      );
                    } else if (pendaftaranResponse.statusCode == 401) {
                      // Token expired
                      _forceLogout();
                    } else {
                      // Jika gagal cek status karena alasan lain, asumsikan belum mendaftar
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PersyaratanSidangScreen()),
                      );
                    }
                  } : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _checkSidangEligibility() async {
    try {
      final token = await storageService.getToken();
      if (token == null) {
        debugPrint('DEBUG: Token tidak ditemukan saat cek kelayakan sidang');
        return _forceLogout();
      }

      // Cek apakah pengguna sudah mendaftar sidang terlebih dahulu
      final pendaftaranUrl = Uri.parse('$_baseUrl/api/pendaftaran-sidang');
      final pendaftaranResponse = await http.get(pendaftaranUrl, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (pendaftaranResponse.statusCode == 200) {
        final pendaftaranData = jsonDecode(pendaftaranResponse.body);
        if (pendaftaranData['status'] == 'success' && pendaftaranData['data'] != null) {
          // Jika sudah mendaftar sidang, tombol tetap aktif untuk melihat detail
          setState(() {
            _canRegisterSidang = true;
            _sidangMessage = "Anda sudah mendaftar sidang. Tekan tombol untuk melihat detail.";
          });
          debugPrint('DEBUG: Pengguna sudah mendaftar sidang');
          return;
        }
      } else if (pendaftaranResponse.statusCode == 401) {
        debugPrint('DEBUG: Token expired saat cek pendaftaran sidang');
        return _forceLogout();
      } else if (pendaftaranResponse.statusCode == 404) {
        // 404 berarti belum ada pendaftaran sidang, ini normal, lanjutkan ke pengecekan tugas akhir dan bimbingan
        debugPrint('DEBUG: Belum ada pendaftaran sidang, lanjutkan ke pengecekan tugas akhir dan bimbingan');
      } else {
        debugPrint('DEBUG: Gagal mengambil data pendaftaran sidang, status: ${pendaftaranResponse.statusCode}');
        // Jika gagal mengambil data pendaftaran karena alasan lain, lanjutkan ke pengecekan tugas akhir dan bimbingan
      }

      // Cek apakah pengguna sudah memiliki tugas akhir
      final thesisUrl = Uri.parse('$_baseUrl/api/thesis');
      final thesisResponse = await http.get(thesisUrl, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (thesisResponse.statusCode == 200) {
        final thesisData = jsonDecode(thesisResponse.body);
        if (thesisData['status'] != 'success' || thesisData['data'] == null) {
          // Jika tidak ada tugas akhir, maka tidak eligible untuk daftar sidang
          setState(() {
            _canRegisterSidang = false;
            _sidangMessage = "Anda belum memiliki tugas akhir. Harap daftar tugas akhir terlebih dahulu.";
          });
          debugPrint('DEBUG: Pengguna belum memiliki tugas akhir');
          return;
        }
      } else if (thesisResponse.statusCode == 401) {
        debugPrint('DEBUG: Token expired saat cek tugas akhir');
        return _forceLogout();
      } else if (thesisResponse.statusCode == 404) {
        // 404 berarti tidak ada tugas akhir, ini adalah kondisi normal
        setState(() {
          _canRegisterSidang = false;
          _sidangMessage = "Anda belum memiliki tugas akhir. Harap daftar tugas akhir terlebih dahulu.";
        });
        debugPrint('DEBUG: Pengguna belum memiliki tugas akhir (404)');
        return;
      } else {
        debugPrint('DEBUG: Gagal mengambil data tugas akhir, status: ${thesisResponse.statusCode}');
        setState(() {
          _canRegisterSidang = false;
          _sidangMessage = "Gagal memeriksa data tugas akhir";
        });
        return;
      }

      // Ambil data pembimbing dan log bimbingan
      final pembimbingUrl = Uri.parse('$_baseUrl/api/pembimbing');
      final pembimbingResponse = await http.get(pembimbingUrl, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (pembimbingResponse.statusCode == 200) {
        final pembimbingList = jsonDecode(pembimbingResponse.body) as List<dynamic>;

        bool allPembimbingMeetRequirement = true;
        List<String> incompleteRequirements = [];

        for (final pembimbing in pembimbingList) {
          final urutan = pembimbing['urutan'];
          final logUrl = Uri.parse('$_baseUrl/api/log-bimbingan?urutan=$urutan');
          final logResponse = await http.get(logUrl, headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          });

          if (logResponse.statusCode == 200) {
            final logs = jsonDecode(logResponse.body) as List<dynamic>;
            // Hitung jumlah log bimbingan yang disetujui (status = 1)
            final approvedLogs = logs.where((log) =>
              (log['status'] as int?) == 1
            ).length;

            debugPrint('DEBUG: Pembimbing $urutan memiliki $approvedLogs bimbingan disetujui');

            // Jika pembimbing belum mencapai 8 bimbingan, tambahkan ke daftar yang belum lengkap
            if (approvedLogs < 8) {
              allPembimbingMeetRequirement = false;
              incompleteRequirements.add("${pembimbing['dosen_nama']}: $approvedLogs/8");
            }
          } else if (logResponse.statusCode == 401) {
            debugPrint('DEBUG: Token expired saat cek log bimbingan');
            return _forceLogout();
          }
        }

        String eligibilityMessage = "";
        if (!allPembimbingMeetRequirement) {
          eligibilityMessage = "Bimbingan belum lengkap: ${incompleteRequirements.join(', ')}";
        }

        setState(() {
          _canRegisterSidang = allPembimbingMeetRequirement;
          _sidangMessage = allPembimbingMeetRequirement
              ? "Silakan lanjutkan ke proses pendaftaran sidang."
              : eligibilityMessage;
        });

        debugPrint('DEBUG: Kelayakan sidang diperbarui: can_register=${_canRegisterSidang}, message=$_sidangMessage');
      } else if (pembimbingResponse.statusCode == 401) {
        debugPrint('DEBUG: Token expired saat cek pembimbing');
        return _forceLogout();
      } else if (pembimbingResponse.statusCode == 404) {
        // 404 berarti belum ada pembimbing, ini bisa terjadi jika tugas akhir belum disetujui
        debugPrint('DEBUG: Tidak ada data pembimbing ditemukan (404)');
        setState(() {
          _canRegisterSidang = false;
          _sidangMessage = "Belum ada data pembimbing yang terdaftar.";
        });
      } else {
        debugPrint('DEBUG: Gagal mengambil data pembimbing, status: ${pembimbingResponse.statusCode}');
        setState(() {
          _canRegisterSidang = false;
          _sidangMessage = "Gagal memeriksa kelayakan sidang";
        });
      }
    } catch (e) {
      debugPrint('Error saat cek kelayakan sidang: $e');
      setState(() {
        _canRegisterSidang = false;
        _sidangMessage = "Terjadi kesalahan saat memeriksa kelayakan sidang";
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      debugPrint('DEBUG: Memulai proses _loadUserData');

      // 1. Ambil nama dari storage dulu (Cepat)
      final storedName = await storageService.getUserName();
      debugPrint('DEBUG: Nama dari storage: $storedName');
      if (storedName != null && storedName != 'Memuat...') {
        setState(() {
          _userName = storedName;
          debugPrint('DEBUG: Nama diubah dari storage: $_userName');
        });
      }

      final token = await storageService.getToken();
      debugPrint('DEBUG: Token ditemukan: ${token != null}');
      if (token == null) {
        debugPrint('DEBUG: Token tidak ditemukan, melakukan logout');
        return _forceLogout();
      }

      // 2. Ambil Profil dari API
      final url = Uri.parse('$_baseUrl/api/profil');
      debugPrint('DEBUG: Mengambil data user dari: $url');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      debugPrint('DEBUG: Status response API user: ${response.statusCode}');
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        debugPrint('DEBUG: Data user dari API: $userData');

        // Coba berbagai kemungkinan struktur data untuk mendapatkan nama
        final nameFromApi = userData['name'] ??
                           userData['nama'] ??
                           (userData['user'] as Map<String, dynamic>?)?['nama'] ??
                           (userData['data'] as Map<String, dynamic>?)?['nama'] ??
                           'User';

        setState(() {
          _userName = nameFromApi;
          debugPrint('DEBUG: Nama diubah dari API: $_userName');
        });
        await storageService.saveUserName(_userName);
        debugPrint('DEBUG: Nama disimpan ke storage: $_userName');
      } else {
        debugPrint('DEBUG: Gagal mengambil data user dari API, status: ${response.statusCode}');
        debugPrint('DEBUG: Response body: ${response.body}');

        // Jika API gagal, coba gunakan nama dari storage
        final storedName = await storageService.getUserName();
        if (storedName != null && storedName != 'Memuat...') {
          setState(() {
            _userName = storedName;
          });
        }
      }

      // 3. CEK KELAYAKAN SIDANG (PENTING!)
      await _checkSidangEligibility();

    } catch (e) {
      debugPrint('Error loading data: $e');

      // Jika terjadi error, coba gunakan nama dari storage
      try {
        final storedName = await storageService.getUserName();
        if (storedName != null && storedName != 'Memuat...') {
          setState(() {
            _userName = storedName;
          });
        }
      } catch (storageError) {
        debugPrint('Error saat mengambil nama dari storage: $storageError');
      }
    }
  }

  Future<List<dynamic>> _fetchJadwal(DateTime tanggal) async {
    final formattedDate =
        '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';

    try {
      final token = await storageService.getToken();
      if (token == null) {
        _forceLogout();
        return [];
      }

      final url = Uri.parse('$_baseUrl/api/jadwal-sidang?tanggal=$formattedDate');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else if (response.statusCode == 401) {
        debugPrint('Token expired or unauthorized access to schedule data');
        // Tampilkan notifikasi bahwa sesi telah berakhir
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sesi Anda telah berakhir. Silakan login kembali.'),
                  backgroundColor: Colors.orange,
                  action: SnackBarAction(
                    label: 'Login',
                    onPressed: () {
                      AuthService.instance.logout(context);
                    },
                  ),
                ),
              );
            }
          });
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  void _forceLogout() {
    // Gunakan service auth untuk logout
    AuthService.instance.logout(context);
  }

  List<dynamic> _filterAndSortList(List<dynamic> list) {
    List<dynamic> filteredList = _searchQuery.isEmpty
        ? List.from(list)
        : list.where((jadwal) {
            final String nama = (jadwal['nama'] as String?)?.toLowerCase() ?? '';
            final String judul = (jadwal['judul'] as String?)?.toLowerCase() ?? '';
            final String tempat = (jadwal['tempat'] as String?)?.toLowerCase() ?? '';
            final String jam = (jadwal['jam'] as String?)?.toLowerCase() ?? '';

            return nama.contains(_searchQuery.toLowerCase()) ||
                   judul.contains(_searchQuery.toLowerCase()) ||
                   tempat.contains(_searchQuery.toLowerCase()) ||
                   jam.contains(_searchQuery.toLowerCase());
          }).toList();

    switch (_activeFilter) {
      case FilterType.room:
        filteredList.sort((a, b) => (a['tempat'] ?? '').compareTo(b['tempat'] ?? ''));
        break;
      case FilterType.time:
        filteredList.sort((a, b) {
          try {
            final String jamA = (a['jam'] as String?) ?? '';
            final String jamB = (b['jam'] as String?) ?? '';
            return jamA.split(' ').first.compareTo(jamB.split(' ').first);
          } catch (e) { return 0; }
        });
        break;
      case FilterType.none:
        break;
    }
    return filteredList;
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cari Kegiatan'),
          content: TextField(
            decoration: const InputDecoration(
              hintText: 'Masukkan nama, judul, tempat atau waktu...',
              prefixIcon: Icon(Icons.search),
            ),
            autofocus: true,
            onSubmitted: (value) {
              setState(() { _searchQuery = value; });
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() { _searchQuery = ''; });
                Navigator.of(context).pop();
              },
              child: const Text('Hapus'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String _selectedMonthLabel(DateTime d) {
    const months = [
      'JANUARI', 'FEBRUARI', 'MARET', 'APRIL', 'MEI', 'JUNI',
      'JULI', 'AGUSTUS', 'SEPTEMBER', 'OKTOBER', 'NOVEMBER', 'DESEMBER',
    ];
    return months[d.month - 1];
  }

  Future<void> _selectMonth(BuildContext context) async {
    final chosen = await showDialog<int>(
      context: context,
      builder: (c) => SimpleDialog(
        title: const Text('Pilih Bulan'),
        children: List.generate(12, (i) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(c, i + 1),
            child: Text(_selectedMonthLabel(DateTime(0, i + 1))),
          );
        }),
      ),
    );
    if (chosen != null) {
      setState(() {
        _focusedDay = DateTime(_focusedDay.year, chosen, _focusedDay.day);
        _jadwalFuture = _fetchJadwal(_focusedDay);
      });
    }
  }

  Future<void> _selectYear(BuildContext context) async {
    final current = DateTime.now().year;
    final years = List<int>.generate(11, (i) => current - 5 + i);
    final chosen = await showDialog<int>(
      context: context,
      builder: (c) => SimpleDialog(
        title: const Text('Pilih Tahun'),
        children: years.map((y) => SimpleDialogOption(onPressed: () => Navigator.pop(c, y), child: Text(y.toString()))).toList(),
      ),
    );
    if (chosen != null) {
      setState(() {
        _focusedDay = DateTime(chosen, _focusedDay.month, _focusedDay.day);
        _jadwalFuture = _fetchJadwal(_focusedDay);
      });
    }
  }

  void _showDetail(dynamic jadwal) {
    showDialog(context: context, builder: (c) => ScheduleDetailDialog(schedule: jadwal));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Panggil _loadUserData() dan _checkSidangEligibility() saat widget tampil di layar
    // Ini akan memperbarui status kelayakan sidang
    debugPrint('DEBUG: didChangeDependencies dipanggil, memperbarui data');
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTugasAkhirMenu(context),
        backgroundColor: const Color.fromARGB(255, 116, 165, 250),
        elevation: 4,
        child: const Icon(Icons.school_outlined, color: Colors.white),
      ),
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: _jadwalFuture,
          builder: (context, snapshot) {
            final jadwalData = snapshot.data ?? [];
            final jadwalTampil = _filterAndSortList(jadwalData);

            final Widget scheduleSection = jadwalTampil.isEmpty
                ? LayoutBuilder(builder: (context, constraints) {
                    return ConstrainedBox(
                      constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.35),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.calendar_month_outlined, size: 120, color: Color(0xFFB6A4E6)),
                            SizedBox(height: 24),
                            Text('Tidak ditemukan jadwal\nsidang Tugas Akhir', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5)),
                          ],
                        ),
                      ),
                    );
                  })
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: jadwalTampil.length,
                      itemBuilder: (context, index) {
                        final jadwal = jadwalTampil[index] as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 2,
                          child: InkWell(
                            onTap: () => _showDetail(jadwal),
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(jadwal['nama']?.toString() ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 6),
                                        Text(jadwal['judul'] ?? 'N/A', style: const TextStyle(color: Colors.black54)),
                                        const SizedBox(height: 6),
                                        Text(jadwal['tempat'] ?? 'N/A', style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Container(height: 48, width: 1, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 12)),
                                  Text(jadwal['jam'] ?? 'N/A', style: const TextStyle(color: blueMain, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header (Tampilan Tetap Sama)
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [const Color(0xFFE8F2FF), Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Selamat Datang,', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[700])),
                        const SizedBox(height: 4),
                        Text(_userName, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: blueMain)),
                      ]),
                    ),
                  ),

                  // Calendar card overlapping header
                  Transform.translate(
                    offset: const Offset(0, -36),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.08), blurRadius: 14, offset: Offset(0, 6))]),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Expanded(child: InkWell(onTap: () => _selectMonth(context), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: blueMain, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color.fromRGBO(30, 136, 229, 0.15), blurRadius: 6, offset: Offset(0, 2))]), child: Row(mainAxisSize: MainAxisSize.min, children: [Text(_selectedMonthLabel(_focusedDay), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const SizedBox(width: 6), const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20)])))),
                              const SizedBox(width: 10),
                              Expanded(child: InkWell(onTap: () => _selectYear(context), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: blueMain, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color.fromRGBO(30, 136, 229, 0.15), blurRadius: 6, offset: Offset(0, 2))]), child: Row(mainAxisSize: MainAxisSize.min, children: [Text(_focusedDay.year.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const SizedBox(width: 6), const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20)])))),
                            ]),
                            const SizedBox(height: 12),
                            TableCalendar(
                              locale: 'id_ID',
                              rowHeight: 46,
                              daysOfWeekHeight: 26,
                              headerVisible: false,
                              firstDay: DateTime.utc(2020, 1, 1),
                              lastDay: DateTime.utc(2030, 12, 31),
                              focusedDay: _focusedDay,
                              calendarFormat: CalendarFormat.month,
                              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                              onDaySelected: (selectedDay, focusedDay) {
                                if (!isSameDay(_selectedDay, selectedDay)) {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                    _searchQuery = ''; // Reset search query saat tanggal berubah
                                    _jadwalFuture = _fetchJadwal(selectedDay);
                                  });
                                }
                              },
                              onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
                              daysOfWeekStyle: const DaysOfWeekStyle(weekdayStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54), weekendStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                              calendarStyle: CalendarStyle(
                                weekendTextStyle: const TextStyle(color: Colors.black54),
                                todayDecoration: const BoxDecoration(color: Color(0xFFE8F5FF), shape: BoxShape.circle),
                                todayTextStyle: const TextStyle(color: Colors.black87),
                                selectedDecoration: const BoxDecoration(color: blueMain, shape: BoxShape.circle),
                                selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Title and filter
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Jadwal Sidang Tugas Akhir',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: Icon(Icons.search, color: _searchQuery.isNotEmpty ? blueMain : Colors.black54),
                              onPressed: () => _showSearchDialog(),
                            ),
                            PopupMenuButton<FilterType>(
                              onSelected: (FilterType result) => setState(() => _activeFilter = result),
                              itemBuilder: (BuildContext context) {
                                final items = <PopupMenuEntry<FilterType>>[
                                  const PopupMenuItem<FilterType>(value: FilterType.time, child: Text('Urutkan berdasarkan Waktu')),
                                  const PopupMenuItem<FilterType>(value: FilterType.room, child: Text('Urutkan berdasarkan Ruangan')),
                                ];
                                if (_activeFilter != FilterType.none || _searchQuery.isNotEmpty) {
                                  items.add(const PopupMenuDivider());
                                  items.add(const PopupMenuItem<FilterType>(value: FilterType.none, child: Text('Hapus Pengurutan')));
                                }
                                return items;
                              },
                              icon: Icon(Icons.filter_list, color: _activeFilter != FilterType.none || _searchQuery.isNotEmpty ? blueMain : Colors.black54),
                            ),
                          ],
                        ),
                        if (_searchQuery.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: blueMain.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Mencari: "$_searchQuery"',
                                      style: TextStyle(
                                        color: blueMain,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                    child: Icon(
                                      Icons.clear,
                                      size: 16,
                                      color: blueMain,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Schedule
                  scheduleSection,

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
