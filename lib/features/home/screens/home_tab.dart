import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';

import '../../../main.dart';
import '../../../widgets/schedule_detail_dialog.dart';
import '../../auth/screens/login_screen.dart';
import '../../tugas_akhir/screens/daftar_tugas_akhir_screen.dart';
import '../../pendaftartan_sidang/screens/pendaftaransidang.dart';

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
  final String _baseUrl = 'http://localhost:8000';
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
    _loadUserData();
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
                  onTap: _canRegisterSidang ? () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PersyaratanSidangScreen()),
                    );
                  } : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadUserData() async {
    try {
      // 1. Ambil nama dari storage dulu (Cepat)
      final storedName = await storageService.getUserName(); 
      if (storedName != null) {
        setState(() {
          _userName = storedName;
        });
      }

      final token = await storageService.getToken();
      if (token == null) return _forceLogout();

      // 2. Ambil Profil dari API
      final url = Uri.parse('$_baseUrl/api/user');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        setState(() {
          _userName = userData['name'] ?? userData['nama'] ?? 'User';
        });
        await storageService.saveUserName(_userName);
      }

      // 3. CEK KELAYAKAN SIDANG (PENTING!)
      // Mengambil data bimbingan dari backend berdasarkan min_bimbingan di configs
      final eligibilityUrl = Uri.parse('$_baseUrl/api/check-sidang-eligibility');
      final resEligible = await http.get(eligibilityUrl, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (resEligible.statusCode == 200) {
        final data = jsonDecode(resEligible.body);
        setState(() {
          _canRegisterSidang = data['can_register'] ?? false;
          _sidangMessage = data['message'] ?? "";
        });
      }

    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  Future<List<dynamic>> _fetchJadwal(DateTime tanggal) async {
    final token = await storageService.getToken();
    if (token == null) {
      _forceLogout();
      return [];
    }

    final formattedDate =
        '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';
    final url = Uri.parse('$_baseUrl/api/jadwal-sidang?tanggal=$formattedDate');

    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else if (response.statusCode == 401) {
        _forceLogout();
        return [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  void _forceLogout() {
    storageService.deleteToken();
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
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
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTugasAkhirMenu(context),
        backgroundColor: const Color.fromARGB(255, 116, 165, 250),
        elevation: 4,
        child: const Icon(Icons.school_outlined, color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
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

                // Calendar (Tampilan Tetap Sama)
                Transform.translate(
                  offset: const Offset(0, -36),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.08), blurRadius: 14, offset: Offset(0, 6))]),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
                        child: Column(children: [
                          Row(children: [
                            Expanded(child: InkWell(onTap: () => _selectMonth(context), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: blueMain, borderRadius: BorderRadius.circular(24)), child: Row(mainAxisSize: MainAxisSize.min, children: [Text(_selectedMonthLabel(_focusedDay), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20)])))),
                            const SizedBox(width: 10),
                            Expanded(child: InkWell(onTap: () => _selectYear(context), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: blueMain, borderRadius: BorderRadius.circular(24)), child: Row(mainAxisSize: MainAxisSize.min, children: [Text(_focusedDay.year.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20)])))),
                          ]),
                          const SizedBox(height: 12),
                          TableCalendar(
                            locale: 'id_ID', rowHeight: 46, daysOfWeekHeight: 26, headerVisible: false,
                            firstDay: DateTime.utc(2020, 1, 1), lastDay: DateTime.utc(2030, 12, 31), focusedDay: _focusedDay,
                            calendarFormat: CalendarFormat.month,
                            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                            onDaySelected: (selectedDay, focusedDay) {
                              if (!isSameDay(_selectedDay, selectedDay)) {
                                setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; _searchQuery = ''; _jadwalFuture = _fetchJadwal(selectedDay); });
                              }
                            },
                            calendarStyle: CalendarStyle(
                              selectedDecoration: const BoxDecoration(color: blueMain, shape: BoxShape.circle),
                              todayDecoration: const BoxDecoration(color: Color(0xFFE8F5FF), shape: BoxShape.circle),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),

                // Filters & List (Tampilan Tetap Sama)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Jadwal Sidang Tugas Akhir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        Row(children: [
                          IconButton(icon: Icon(Icons.search, color: _searchQuery.isNotEmpty ? blueMain : Colors.black54), onPressed: () => _showSearchDialog()),
                          PopupMenuButton<FilterType>(
                            onSelected: (result) => setState(() => _activeFilter = result),
                            itemBuilder: (c) => [
                              const PopupMenuItem(value: FilterType.time, child: Text('Urutkan berdasarkan Waktu')),
                              const PopupMenuItem(value: FilterType.room, child: Text('Urutkan berdasarkan Ruangan')),
                            ],
                            icon: Icon(Icons.filter_list, color: _activeFilter != FilterType.none ? blueMain : Colors.black54),
                          ),
                        ])
                      ]),
                      if (_searchQuery.isNotEmpty)
                        Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: blueMain.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: Text('Mencari: "$_searchQuery"', style: const TextStyle(color: blueMain, fontSize: 12))),
                    ],
                  ),
                ),
                scheduleSection,
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}