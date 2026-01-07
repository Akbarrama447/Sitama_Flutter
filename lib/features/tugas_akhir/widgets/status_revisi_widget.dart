import 'package:flutter/material.dart';
import 'revisi_service.dart';
import '../screens/revisi_sidang_screen.dart';

class StatusRevisiWidget extends StatefulWidget {
  final String token;

  const StatusRevisiWidget({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<StatusRevisiWidget> createState() => _StatusRevisiWidgetState();
}

class _StatusRevisiWidgetState extends State<StatusRevisiWidget> {
  List<Map<String, dynamic>>? _revisiList;
  int? _latestStatus;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRevisiData();
  }

  Future<void> _loadRevisiData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await RevisiService.getRevisiData(widget.token);
      if (data != null) {
        setState(() {
          _revisiList = data;
          _latestStatus = RevisiService.getLatestRevisiStatus(data);
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadRevisiData,
      child: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          : _error != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Gagal memuat data status revisi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _error!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _loadRevisiData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : _revisiList == null || _revisiList!.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        color: Colors.grey[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.grey,
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Belum ada data revisi',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Status revisi akan muncul setelah dosen memberikan penilaian',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(_latestStatus).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _getStatusColor(_latestStatus),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      _getStatusIcon(_latestStatus),
                                      color: _getStatusColor(_latestStatus),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Status Revisi Tugas Akhir',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        Text(
                                          RevisiService.getStatusDescription(_latestStatus),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: _getStatusColor(_latestStatus),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (RevisiService.isRevisiRequired(_latestStatus))
                                ElevatedButton(
                                  onPressed: () {
                                    // Navigasi ke screen revisi sidang
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RevisiSidangScreen(
                                          token: widget.token,
                                          revisiList: _revisiList,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _getStatusColor(_latestStatus),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Lihat Detail Revisi'),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
    );
  }

  IconData _getStatusIcon(int? status) {
    switch (status) {
      case 0: // Terjadwal
        return Icons.schedule;
      case 1: // Lulus
        return Icons.check_circle;
      case 2: // Lulus dengan Revisi
        return Icons.warning;
      case 3: // Revisi
        return Icons.edit;
      case 4: // Tidak Lulus
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(int? status) {
    String colorHex = RevisiService.getStatusColor(status);
    return Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);
  }
}