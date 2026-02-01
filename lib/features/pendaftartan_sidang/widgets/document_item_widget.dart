import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/foundation.dart';
import '../../../main.dart'; // untuk mengakses storageService
import '../models/document_model.dart';
import '../constants/sidang_colors.dart';
import '../services/document_upload_service.dart';

// WIDGET ITEM DOKUMEN
class DocumentItemWidget extends StatelessWidget {
  final DocumentItemModel item;
  final VoidCallback? onDocumentUpdate;
  const DocumentItemWidget({super.key, required this.item, this.onDocumentUpdate});

  void _showUploadDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            bool isUploading = false;
            return AlertDialog(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text("Upload ${item.label}",
                  style:
                      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              content: isUploading
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text("Mengupload ${item.label}..."),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_upload_outlined, size: 60, color: Colors.blue),
                        const SizedBox(height: 15),
                        Text("Pilih file dari penyimpanan Anda."),
                        const SizedBox(height: 5),
                        Text("(Format: PDF, DOC, DOCX - Maks. 2 MB)",
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
              actions: isUploading
                  ? null // Tidak ada tombol action saat upload sedang berlangsung
                  : [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Update UI untuk menunjukkan proses upload sedang berlangsung
                          setState(() {
                            isUploading = true;
                          });

                          // Beri sedikit delay agar UI loading muncul sebelum file picker muncul
                          await Future.delayed(const Duration(milliseconds: 100));

                          // Validasi ekstensi file yang diizinkan
                          List<String> allowedExtensions = ['pdf', 'doc', 'docx'];

                          // Gunakan file_picker untuk memilih file dari perangkat
                          FilePickerResult? result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: allowedExtensions,
                            withData: kIsWeb ? true : false,  // Di web, kita perlu data file
                            withReadStream: false,
                          );

                          if (result != null) {
                            // Di web, kita tidak bisa mengakses path secara langsung
                            // Jadi kita perlu membuat File dengan pendekatan berbeda
                            PlatformFile platformFile = result.files.single;

                            // Cek apakah kita sedang di web atau platform lain
                            if (kIsWeb) {
                              // Di web, kita tidak bisa membuat File seperti biasa
                              // Kita hanya bisa mengakses name dan bytes
                              if (platformFile.name.isNotEmpty) {
                                print('Starting upload process for: ${item.label}'); // Debug log

                                // Validasi ekstensi file di sisi klien
                                String fileName = platformFile.name.toLowerCase();
                                bool isValidExtension = allowedExtensions.any((ext) => fileName.endsWith('.$ext'));
                                if (!isValidExtension) {
                                  Navigator.of(context).pop();
                                  item.status = DocumentStatus.error;
                                  if (onDocumentUpdate != null) {
                                    onDocumentUpdate!();
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Format file tidak didukung. Gunakan format: ${allowedExtensions.join(", ")}'),
                                        backgroundColor: Colors.orange),
                                  );
                                  return;
                                }

                                // Di web, kita perlu pastikan bytes tidak null sebelum menggunakannya
                                Uint8List? fileBytes = platformFile.bytes;
                                if (fileBytes == null) {
                                  Navigator.of(context).pop();
                                  item.status = DocumentStatus.error;
                                  if (onDocumentUpdate != null) {
                                    onDocumentUpdate!();
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Gagal mengupload: file tidak memiliki data'),
                                        backgroundColor: Colors.red),
                                  );
                                  return; // Keluar dari fungsi
                                }

                                // Update status menjadi uploading sebelum mulai upload
                                item.status = DocumentStatus.uploading;
                                if (onDocumentUpdate != null) {
                                  onDocumentUpdate!();
                                }

                                // Tambahkan delay kecil agar UI status update terlihat
                                await Future.delayed(const Duration(milliseconds: 100));

                                // Kita tidak bisa membuat File di web, jadi kita buat object File dari bytes
                                // Tapi untuk sekarang, kita panggil service langsung dengan informasi yang tersedia
                                Map<String, dynamic>? uploadResult = await DocumentUploadService.uploadFileWeb(
                                  fileName: platformFile.name,
                                  fileBytes: fileBytes,
                                  documentId: item.id,
                                  token: await storageService.getToken(), // Ambil token dari storage
                                );
                                print('Upload result: $uploadResult'); // Debug log

                                Navigator.of(context).pop(); // Tutup dialog

                                if (uploadResult != null && uploadResult['success']) {
                                  print('Upload successful, updating state'); // Debug log
                                  // Update status dokumen
                                  item.filename = uploadResult['filename'] ?? platformFile.name;
                                  item.status = DocumentStatus.verified;

                                  print('Updated filename: ${item.filename}, status: ${item.status}'); // Debug log

                                  print('Calling onDocumentUpdate callback'); // Debug log
                                  // Panggil callback untuk memberi tahu parent widget
                                  if (onDocumentUpdate != null) {
                                    onDocumentUpdate!();
                                  }

                                  // Tambahkan delay kecil sebelum mengecek status upload
                                  // untuk memastikan UI sudah diperbarui
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (onDocumentUpdate != null) {
                                      onDocumentUpdate!();
                                    }
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Berhasil mengupload ${item.label}'),
                                        duration: const Duration(seconds: 2),
                                        backgroundColor: Colors.green),
                                  );
                                } else {
                                  print('Upload failed'); // Debug log
                                  // Jika upload gagal, status ditetapkan ke error
                                  item.status = DocumentStatus.error;

                                  String errorMessage = uploadResult?['message'] ?? 'Unknown error';
                                  Color snackbarColor = Colors.red;

                                  // Jika error karena ukuran file terlalu besar, tampilkan dengan warna oranje
                                  if (errorMessage.contains('ukuran file terlalu besar') ||
                                      errorMessage.contains('terlalu besar')) {
                                    snackbarColor = Colors.orange;
                                  }

                                  if (onDocumentUpdate != null) {
                                    onDocumentUpdate!();
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Gagal mengupload ${item.label}: $errorMessage'),
                                        backgroundColor: snackbarColor),
                                  );
                                }
                              } else {
                                // Nama file kosong
                                Navigator.of(context).pop();
                                item.status = DocumentStatus.error;
                                if (onDocumentUpdate != null) {
                                  onDocumentUpdate!();
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('File tidak valid atau tidak bisa diakses'),
                                      backgroundColor: Colors.orange),
                                );
                              }
                            } else {
                              // Di mobile/desktop, kita bisa menggunakan path seperti sebelumnya
                              if (platformFile.path != null) {
                                String filePath = platformFile.path!;
                                String fileName = Path.basename(filePath).toLowerCase();

                                // Validasi ekstensi file di sisi klien
                                bool isValidExtension = allowedExtensions.any((ext) => fileName.endsWith('.$ext'));
                                if (!isValidExtension) {
                                  Navigator.of(context).pop();
                                  item.status = DocumentStatus.error;
                                  if (onDocumentUpdate != null) {
                                    onDocumentUpdate!();
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Format file tidak didukung. Gunakan format: ${allowedExtensions.join(", ")}'),
                                        backgroundColor: Colors.orange),
                                  );
                                  return;
                                }

                                File file = File(filePath);

                                print('Starting upload process for: ${item.label}'); // Debug log

                                // Update status menjadi uploading sebelum mulai upload
                                item.status = DocumentStatus.uploading;
                                if (onDocumentUpdate != null) {
                                  onDocumentUpdate!();
                                }

                                // Tambahkan delay kecil agar UI status update terlihat
                                await Future.delayed(const Duration(milliseconds: 100));

                                Map<String, dynamic>? uploadResult = await DocumentUploadService.uploadFile(
                                  file: file,
                                  documentId: item.id,
                                  token: await storageService.getToken(), // Ambil token dari storage
                                );
                                print('Upload result: $uploadResult'); // Debug log

                                Navigator.of(context).pop(); // Tutup dialog

                                if (uploadResult != null && uploadResult['success']) {
                                  print('Upload successful, updating state'); // Debug log
                                  // Update status dokumen
                                  item.filename = uploadResult['filename'] ?? Path.basename(filePath);
                                  item.status = DocumentStatus.verified;

                                  print('Updated filename: ${item.filename}, status: ${item.status}'); // Debug log

                                  print('Calling onDocumentUpdate callback'); // Debug log
                                  // Panggil callback untuk memberi tahu parent widget
                                  if (onDocumentUpdate != null) {
                                    onDocumentUpdate!();
                                  }

                                  // Tambahkan delay kecil sebelum mengecek status upload
                                  // untuk memastikan UI sudah diperbarui
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (onDocumentUpdate != null) {
                                      onDocumentUpdate!();
                                    }
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Berhasil mengupload ${item.label}'),
                                        duration: const Duration(seconds: 2),
                                        backgroundColor: Colors.green),
                                  );
                                } else {
                                  print('Upload failed'); // Debug log
                                  // Jika upload gagal, status ditetapkan ke error
                                  item.status = DocumentStatus.error;

                                  String errorMessage = uploadResult?['message'] ?? 'Unknown error';
                                  Color snackbarColor = Colors.red;

                                  // Jika error karena ukuran file terlalu besar, tampilkan dengan warna oranje
                                  if (errorMessage.contains('ukuran file terlalu besar') ||
                                      errorMessage.contains('terlalu besar')) {
                                    snackbarColor = Colors.orange;
                                  }

                                  if (onDocumentUpdate != null) {
                                    onDocumentUpdate!();
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Gagal mengupload ${item.label}: $errorMessage'),
                                        backgroundColor: snackbarColor),
                                  );
                                }
                              } else {
                                // Path kosong, artinya file tidak valid atau tidak bisa diakses
                                Navigator.of(context).pop();
                                item.status = DocumentStatus.error;
                                if (onDocumentUpdate != null) {
                                  onDocumentUpdate!();
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('File tidak valid atau tidak bisa diakses'),
                                      backgroundColor: Colors.orange),
                                );
                              }
                            }
                          } else {
                            // Pengguna tidak memilih file
                            Navigator.of(context).pop();
                            // Tidak perlu ubah status jika hanya batal memilih file
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Pemilihan file dibatalkan'),
                                  backgroundColor: Colors.orange),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: const Text("Pilih File",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color fillColor;
    Color textColor;
    Color borderColor;
    Widget statusIcon;

    switch (item.status) {
      case DocumentStatus.rejected:
        fillColor = SidangColors.statusRedBg;
        textColor = SidangColors.statusRedText;
        borderColor = Colors.transparent;
        statusIcon = const Icon(Icons.close, color: SidangColors.statusRedText, size: 16);
        break;
      case DocumentStatus.verified:
        fillColor = SidangColors.statusBlueBg;
        textColor = SidangColors.statusBlueText;
        borderColor = Colors.transparent;
        statusIcon = const Icon(Icons.check_circle, color: SidangColors.statusBlueText, size: 16);
        break;
      case DocumentStatus.uploaded:
        fillColor = Colors.white;
        textColor = SidangColors.statusGrayText;
        borderColor = SidangColors.statusGrayBorder;
        statusIcon = Container(); // Tidak ada icon untuk uploaded
        break;
      case DocumentStatus.uploading:
        fillColor = SidangColors.statusOrangeBg; // Warna untuk status uploading
        textColor = SidangColors.statusOrangeText;
        borderColor = Colors.transparent;
        statusIcon = Container(
          width: 16,
          height: 16,
          child: const CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(SidangColors.statusOrangeText)),
        );
        break;
      case DocumentStatus.error:
        fillColor = SidangColors.statusRedBg;
        textColor = SidangColors.statusRedText;
        borderColor = Colors.transparent;
        statusIcon = const Icon(Icons.error, color: SidangColors.statusRedText, size: 16);
        break;
      case DocumentStatus.waiting:
      default:
        fillColor = Colors.white;
        textColor = SidangColors.statusGrayText;
        borderColor = SidangColors.statusGrayBorder;
        statusIcon = Container(); // Tidak ada icon untuk waiting
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF455A64))),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: borderColor,
                        width: 1.0,
                        style: item.status == DocumentStatus.waiting
                            ? BorderStyle.solid
                            : BorderStyle.none),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.filename.isEmpty ? "Belum ada file" : item.filename,
                          style: TextStyle(
                            color:
                                (item.filename.isEmpty && item.status != DocumentStatus.uploaded && item.status != DocumentStatus.rejected) ? Colors.grey[400] : textColor,
                            fontSize: 14,
                            fontStyle: (item.filename.isEmpty && item.status != DocumentStatus.uploaded && item.status != DocumentStatus.rejected)
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (item.status == DocumentStatus.uploaded)
                        Text(
                          "(Tunggu Verifikasi)",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      if (item.status == DocumentStatus.rejected)
                        Text(
                          "(Dokumen Tidak Disetujui)",
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                child: InkWell(
                  onTap: () => _showUploadDialog(context),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 45,
                    width: 45,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: SidangColors.statusGrayBorder),
                    ),
                    child: item.status == DocumentStatus.uploading
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : const Icon(Icons.file_upload_outlined,
                            color: SidangColors.statusGrayText,
                            size: 24),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}