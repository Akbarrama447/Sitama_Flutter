// file: lib/features/tugas_akhir/screens/file_preview_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FilePreviewScreen extends StatelessWidget {
  final String fileUrl;
  const FilePreviewScreen({super.key, required this.fileUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview File', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF03A9F4)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Icon(Icons.picture_as_pdf, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(fileUrl, textAlign: TextAlign.center),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: fileUrl));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link file disalin ke clipboard')));
            },
            icon: const Icon(Icons.copy),
            label: const Text('Salin link'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF03A9F4)),
          ),
        ]),
      ),
    );
  }
}
