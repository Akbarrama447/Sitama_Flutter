import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';

import '../../../main.dart';
import '../../../widgets/schedule_detail_dialog.dart';
import '../../auth/screens/login_screen.dart';

enum FilterType { none, room, time }

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  FilterType _activeFilter = FilterType.none;
  late Future<List<dynamic>> _jadwalFuture;
  final String _baseUrl = 'http://172.16.161.241:8000';
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _focusedDay = now;
    _jadwalFuture = _fetchJadwal(_selectedDay!);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final token = await storageService.getToken();
      if (token == null) {
        _forceLogout();
        return;
      }

      final url = Uri.parse('$_baseUrl/api/user');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        setState(() {
          _userName = userData['nama'] ?? 'User';
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<List<dynamic>> _fetchJadwal(DateTime tanggal) async {
    final token = await storageService.getToken();
    if (token == null) {
      _forceLogout();
      return [];
    }

    final formattedDate = "${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}";
    final url = Uri.parse('$_baseUrl/api/jadwal-sidang?tanggal=$formattedDate');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data;
      } else if (response.statusCode == 401) {
        _forceLogout();
        return [];
      } else {
        throw Exception('Gagal memuat jadwal. Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Network Error: $e');
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
    final dailySchedules = List.from(list);
    switch (_activeFilter) {
      case FilterType.room:
        dailySchedules.sort((a, b) {
          final String tempatA = (a['tempat'] as String?) ?? '';
          final String tempatB = (b['tempat'] as String?) ?? '';
          return tempatA.compareTo(tempatB);
        });
        break;
      case FilterType.time:
        dailySchedules.sort((a, b) {
          try {
            final String jamA = (a['jam'] as String?) ?? '';
            final String jamB = (b['jam'] as String?) ?? '';
            String timeA = jamA.split(' ')[0];
            String timeB = jamB.split(' ')[0];
            
            if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(timeA)) timeA = '00:00';
            if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(timeB)) timeB = '00:00';
            
            return timeA.compareTo(timeB);
          } catch (e) {
            debugPrint('Error comparing times: $e');
            return 0;
          }
        });
        break;
      case FilterType.none:
        break;
    }
    return dailySchedules;
  }

  String _selectedMonthLabel(DateTime d) {
    return [
      'JANUARI', 'FEBRUARI', 'MARET', 'APRIL', 'MEI', 'JUNI',
      'JULI', 'AGUSTUS', 'SEPTEMBER', 'OKTOBER', 'NOVEMBER', 'DESEMBER',
    ][d.month - 1];
  }

  void _selectMonth(BuildContext context) async {
    final int? pickedMonth = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Pilih Bulan'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          children: List.generate(12, (index) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, index + 1);
              },
              child: Text(_selectedMonthLabel(DateTime(0, index + 1))),
            );
          }),
        );
      },
    );
    if (pickedMonth != null) {
      setState(() {
        _focusedDay = DateTime(_focusedDay.year, pickedMonth, 1);
      });
    }
  }

  void _selectYear(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _focusedDay = DateTime(picked.year, _focusedDay.month, 1);
      });
    }
  }

  void _showDetail(dynamic jadwalItem) {
    try {
      if (jadwalItem == null) return;
      
      final jadwalMap = Map<String, dynamic>.from(jadwalItem);
      try {
        jadwalMap['pembimbing'] = List<String>.from(jadwalMap['pembimbing'] ?? []);
        jadwalMap['penguji'] = List<String>.from(jadwalMap['penguji'] ?? []);
      } catch (e) {
        jadwalMap['pembimbing'] = <String>[];
        jadwalMap['penguji'] = <String>[];
      }

      showDialog(
        context: context,
        builder: (_) => ScheduleDetailDialog(schedule: jadwalMap),
      );
    } catch (e) {
      debugPrint('Error showing detail dialog: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maaf, gagal menampilkan detail jadwal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color blueMain = Color(0xFF1E88E5);
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: _jadwalFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final jadwalList = snapshot.data ?? [];
          final jadwalTampil = _filterAndSortList(jadwalList);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang,',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userName,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: blueMain,
                        ),
                      ),
                    ],
                  ),
                ),

                // Calendar Card
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.08),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          // Date Selectors
                          Row(
                            children: [
                              InkWell(
                                onTap: () => _selectMonth(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: blueMain,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        _selectedMonthLabel(_focusedDay),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => _selectYear(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: blueMain,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        _focusedDay.year.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Calendar
                          TableCalendar(
                            locale: 'id_ID',
                            rowHeight: 40,
                            daysOfWeekHeight: 24,
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
                                  _jadwalFuture = _fetchJadwal(selectedDay);
                                });
                              }
                            },
                            onPageChanged: (focusedDay) {
                              setState(() {
                                _focusedDay = focusedDay;
                              });
                            },
                            daysOfWeekStyle: const DaysOfWeekStyle(
                              weekdayStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                              weekendStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            calendarStyle: const CalendarStyle(
                              weekendTextStyle: TextStyle(color: Colors.black54),
                              todayDecoration: BoxDecoration(
                                color: blueMain,
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: blueMain,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Schedule Section Title and Filter
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Jadwal Sidang Tugas Akhir',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      PopupMenuButton<FilterType>(
                        onSelected: (FilterType result) {
                          setState(() {
                            _activeFilter = result;
                          });
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<FilterType>>[
                          const PopupMenuItem<FilterType>(
                            value: FilterType.time,
                            child: Text('Urutkan berdasarkan Waktu'),
                          ),
                          const PopupMenuItem<FilterType>(
                            value: FilterType.room,
                            child: Text('Urutkan berdasarkan Ruangan'),
                          ),
                          if (_activeFilter != FilterType.none) const PopupMenuDivider(),
                          if (_activeFilter != FilterType.none)
                            const PopupMenuItem<FilterType>(
                              value: FilterType.none,
                              child: Text('Hapus Pengurutan'),
                            ),
                        ],
                        icon: Icon(
                          Icons.filter_list,
                          color: _activeFilter != FilterType.none
                              ? blueMain
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                // Schedule List or Empty State
                if (jadwalTampil.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.calendar_month_outlined, size: 100, color: Colors.grey),
                          SizedBox(height: 24),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              'Tidak ditemukan jadwal\\nsidang Tugas Akhir',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: jadwalTampil.length,
                      itemBuilder: (context, index) {
                        final jadwal = jadwalTampil[index] as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                                        Text(
                                          jadwal['nama'] ?? 'N/A',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          jadwal['judul'] ?? 'N/A',
                                          style: const TextStyle(color: Colors.black54),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          jadwal['tempat'] ?? 'N/A',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 48,
                                    width: 1,
                                    color: Colors.grey.shade200,
                                    margin: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  Text(
                                    jadwal['jam'] ?? 'N/A',
                                    style: const TextStyle(
                                      color: blueMain,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}