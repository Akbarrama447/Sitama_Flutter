import 'package:flutter/material.dart';
import '../core/theme/colors.dart';

class ScheduleDetailDialog extends StatelessWidget {
  final Map<String, dynamic> schedule;

  const ScheduleDetailDialog({
    Key? key,
    required this.schedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              schedule['nama']?.toString() ?? '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              schedule['nim']?.toString() ?? '',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Jurusan', schedule['jurusan']?.toString() ?? ''),
            _buildDetailRow('Judul', schedule['judul']?.toString() ?? ''),
            _buildDetailRow('Waktu', schedule['jam']?.toString() ?? ''),
            _buildDetailRow('Tempat', schedule['tempat']?.toString() ?? ''),
            _buildDetailRow('Pembimbing', (schedule['pembimbing'] as List?)?.join(', ') ?? ''),
            _buildDetailRow('Penguji', (schedule['penguji'] as List?)?.join(', ') ?? ''),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Tutup',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),  
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}