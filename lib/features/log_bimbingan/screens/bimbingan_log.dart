// file: lib/features/tugas_akhir/screens/tugas_akhir_tab.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../main.dart'; // storageService
import '../../auth/screens/login_screen.dart';
import 'add_log_screen.dart';
import 'edit_log_screen.dart';
import 'detail_bimbingan_dialog.dart';
import 'file_preview_screen.dart';
import '../../../core/services/auth_service.dart';

class TugasAkhirTab extends StatefulWidget {
  const TugasAkhirTab({super.key});

  @override
  State<TugasAkhirTab> createState() => _TugasAkhirTabState();
}

class _TugasAkhirTabState extends State<TugasAkhirTab> {
  final String _baseUrl = 'https://sitamanext.informatikapolines.id';
  final int _targetBimbingan = 8;

  late Future<void> _initFuture;
  List<Map<String, dynamic>> _pembimbingList = [];
  final Map<dynamic, List<dynamic>> _logsPerPembimbing = {};

  int _currentIndex = 0;
  final PageController _pageController = PageController();
  String _selectedFilter = 'Semua Bimbingan';

  @override
  void initState() {
    super.initState();
    _initFuture = _initialize();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _fetchPembimbing();
    if (_pembimbingList.isNotEmpty) {
      await _fetchLogsForUrutan(_pembimbingList[_currentIndex]['urutan']);
    }
  }

  Future<void> _fetchPembimbing() async {
    try {
      final token = await storageService.getToken();
      if (token == null) return _forceLogout();

      final url = '$_baseUrl/api/pembimbing';
      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        setState(() {
          _pembimbingList = list.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      } else if (res.statusCode == 401) {
        _forceLogout();
      }
    } catch (e) {
      debugPrint('Error fetching pembimbing: $e');
    }
  }

  Future<void> _fetchLogsForUrutan(dynamic urutan) async {
    try {
      final token = await storageService.getToken();
      if (token == null) return _forceLogout();

      final url = '$_baseUrl/api/log-bimbingan?urutan=$urutan';
      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        setState(() => _logsPerPembimbing[urutan] = list);
      } else if (res.statusCode == 401) {
        _forceLogout();
      }
    } catch (e) {
      debugPrint('Error fetching logs: $e');
    }
  }

  Future<void> _refreshLogsForUrutan(dynamic urutan) async {
    await _fetchLogsForUrutan(urutan);
  }

  void _forceLogout() {
    // Gunakan service auth untuk logout
    AuthService.instance.logout(context);
  }

  void _goPrevious() {
    if (_currentIndex > 0) {
      final newIndex = _currentIndex - 1;
      _pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentIndex = newIndex);
      _fetchLogsForUrutan(_pembimbingList[newIndex]['urutan']);
    }
  }

  void _goNext() {
    if (_currentIndex < _pembimbingList.length - 1) {
      final newIndex = _currentIndex + 1;
      _pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentIndex = newIndex);
      _fetchLogsForUrutan(_pembimbingList[newIndex]['urutan']);
    }
  }

  // Map backend status (0/1/2) to string key
  String _mapStatus(dynamic raw) {
    final val = raw?.toString() ?? '0';
    switch (val) {
      case '1':
        return 'approve';
      case '2':
        return 'ditolak';
      default:
        return 'pending';
    }
  }

  // Return display label for status
  String _labelStatus(String key) {
    switch (key) {
      case 'approve':
        return 'Disetujui';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Menunggu';
    }
  }

  // Icon and color for status
  Map<String, dynamic> _statusIconAndColor(String key) {
    if (key == 'approve') {
      return {'icon': Icons.check_circle, 'color': Colors.green};
    } else if (key == 'ditolak') {
      return {'icon': Icons.warning, 'color': Colors.red};
    } else {
      return {'icon': Icons.edit, 'color': Colors.orange};
    }
  }

    Color _statusBackgroundColor(String key) {
    switch (key) {
      case 'approve':
        return Colors.green.withOpacity(0.08);
      case 'ditolak':
        return Colors.red.withOpacity(0.08);
      default:
        return Colors.orange.withOpacity(0.10);
    }
  }


  void _onStatusTap(Map<String, dynamic> log) async {
    final statusKey = _mapStatus(log['status']);
    if (statusKey == 'pending') {
      // pending => open edit screen (full screen)
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EditLogScreen(log: log)),
      );
      if (result == true) {
        // if edited successfully, refresh
        final urutan = log['pembimbing_urutan'] ?? log['urutan'] ?? _pembimbingList[_currentIndex]['urutan'];
        await _refreshLogsForUrutan(urutan);
      }
    } else {
      // approve OR ditolak => show popup dialog (blur/dim background)
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) => DetailBimbinganDialog(data: log),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_pembimbingList.isEmpty) {
            return const Center(child: Text('Tidak ada pembimbing terdaftar.'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildStatusCardForIndex(_currentIndex),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pembimbingList.length,
                  onPageChanged: (idx) async {
                    setState(() => _currentIndex = idx);
                    await _fetchLogsForUrutan(_pembimbingList[idx]['urutan']);
                  },
                  itemBuilder: (context, index) {
                    final pembimbing = _pembimbingList[index];
                    final urutan = pembimbing['urutan'];
                    final logs = _logsPerPembimbing[urutan] ?? [];

                    final filtered = _selectedFilter == 'Semua Bimbingan'
                        ? logs
                        : _selectedFilter == 'Disetujui'
                            ? logs.where((l) => _mapStatus(l['status']) == 'approve').toList()
                            : _selectedFilter == 'Menunggu'
                                ? logs.where((l) => _mapStatus(l['status']) == 'pending').toList()
                                : logs.where((l) => _mapStatus(l['status']) == 'ditolak').toList();


                    final progressCount = logs.length;
                    final progressValue = (progressCount / _targetBimbingan).clamp(0.0, 1.0);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pembimbingan',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                          ),
                          const SizedBox(height: 12),
                          _buildControls(pembimbing, urutan, progressCount, progressValue),
                          const SizedBox(height: 16),
                          filtered.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filtered.length,
                                  itemBuilder: (_, i) => _buildLogItem(filtered[i]),
                                ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusCardForIndex(int index) {
    final pembimbing = _pembimbingList[index];
    final urutan = pembimbing['urutan'];
    final name = pembimbing['dosen_nama'] ?? 'Pembimbing';

    final logs = _logsPerPembimbing[urutan] ?? [];
    final progressCount = logs.length;
    final progressValue = (progressCount / _targetBimbingan).clamp(0.0, 1.0);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Positioned(
            left: -5,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 20), onPressed: _currentIndex > 0 ? _goPrevious : null),
            ),
          ),
          Positioned(
            right: -10,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 20), onPressed: _currentIndex < _pembimbingList.length - 1 ? _goNext : null),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
                Text("Status Bimbingan", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                Text("Cetak lembar persetujuan", style: TextStyle(fontSize: 12)),
              ]),
              const SizedBox(height: 7),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 7),
                    Row(children: [
                      Expanded(
                        child: Stack(alignment: Alignment.centerRight, children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progressValue,
                              minHeight: 16,
                              backgroundColor: Colors.grey[300],
                              color: Colors.blue,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8), // beri jarak 8px dari kanan
                            child: Text(
                              "$progressCount/$_targetBimbingan",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.description_outlined, color: Colors.white, size: 22),
                      ),
                    ]),
                  ]),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(Map<String, dynamic> pembimbing, int urutan, int progressCount, double progressValue) {
    return Row(children: [
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedFilter,
              isExpanded: true,
              items: ['Semua Bimbingan', 'Menunggu', 'Ditolak', 'Disetujui'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _selectedFilter = v!),
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      ElevatedButton(
        onPressed: () async {
          final nama = pembimbing['dosen_nama'] ?? pembimbing['dosen_nip'] ?? '';
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddLogScreen(pembimbingNama: nama, pembimbingUrutan: urutan)));
          if (result == true) _refreshLogsForUrutan(urutan);
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
        child: const Text("Tambah"),
      ),
    ]);
  }

  Widget _buildLogItem(dynamic logData) {
    final log = (logData is Map) ? Map<String, dynamic>.from(logData) : <String, dynamic>{};

    // safe date parse
    DateTime date;
    try {
      date = DateTime.parse(log['tanggal'].toString());
    } catch (_) {
      date = DateTime.now();
    }
    final formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);

    final namaPembimbing = log['dosen_nama'] ?? log['pembimbing_nama'] ?? log['pembimbing'] ?? 'Pembimbing';

    final statusKey = _mapStatus(log['status']);
    final iconAndColor = _statusIconAndColor(statusKey);
    final icon = iconAndColor['icon'] as IconData;
    final color = iconAndColor['color'] as Color;
    final bgColor = _statusBackgroundColor(statusKey);
    final statusLabel = _labelStatus(statusKey);

    return InkWell(
      onTap: () => _onStatusTap(log), // 🔑 KLIK DI MANA SAJA
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              child: Text(
                formattedDate.replaceFirst(', ', '\n'),
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey.shade300,
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    namaPembimbing,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    log['judul']?.toString() ?? '-',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),

            // 🔵 InkWell ICON (boleh tetap ada)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: InkWell(
                onTap: () => _onStatusTap(log),
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 18, color: color),
                      const SizedBox(height: 2),
                      Text(
                        statusLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }

    Widget _buildEmptyState() {
    return SizedBox(
      height: 300, // tinggi minimum agar terlihat di tengah area kosong
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.history_edu_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Belum ada riwayat bimbingan.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

}
