import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../features/pendaftartan_sidang/models/document_model.dart';

class UploadStatusManager {
  static const String _key = 'all_documents_uploaded';
  static const String _documentsKey = 'documents_status';

  static Future<void> setAllDocumentsUploaded(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, status);
  }

  static Future<bool> getAllDocumentsUploaded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> setDocumentsStatus(List<DocumentItemModel> documents) async {
    final prefs = await SharedPreferences.getInstance();
    // Hanya simpan dokumen yang statusnya sudah uploaded atau verified
    List<DocumentItemModel> uploadedDocuments = documents.where((doc) =>
        doc.status == DocumentStatus.uploaded || doc.status == DocumentStatus.verified
    ).toList();

    List<Map<String, dynamic>> documentsMap = uploadedDocuments.map((doc) => doc.toJson()).toList();
    await prefs.setString(_documentsKey, jsonEncode(documentsMap));
  }

  static Future<List<DocumentItemModel>> getDocumentsStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final documentsJson = prefs.getString(_documentsKey);

    if (documentsJson == null) {
      return [];
    }

    List<dynamic> decodedJson = jsonDecode(documentsJson);
    return decodedJson.map((doc) => DocumentItemModel.fromJson(doc)).toList();
  }

  static Future<void> clearUploadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await prefs.remove(_documentsKey);
  }

  static Future<void> resetDocumentStatus(int documentId) async {
    final prefs = await SharedPreferences.getInstance();
    final documentsJson = prefs.getString(_documentsKey);

    if (documentsJson == null) {
      return; // Tidak ada dokumen untuk direset
    }

    List<dynamic> decodedJson = jsonDecode(documentsJson);
    List<Map<String, dynamic>> updatedDocuments = [];

    for (var doc in decodedJson) {
      if (doc['id'] != documentId) {
        updatedDocuments.add(doc);
      }
      // Jika ID cocok, kita tidak tambahkan ke updatedDocuments (artinya dihapus/reset)
    }

    await prefs.setString(_documentsKey, jsonEncode(updatedDocuments));
  }

  static Future<void> updateDocumentStatus(int documentId, String filename, DocumentStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    final documentsJson = prefs.getString(_documentsKey);

    List<DocumentItemModel> documents = [];

    if (documentsJson != null) {
      List<dynamic> decodedJson = jsonDecode(documentsJson);
      documents = decodedJson.map((doc) => DocumentItemModel.fromJson(doc)).toList();
    }

    // Cek apakah dokumen sudah ada
    int existingIndex = documents.indexWhere((doc) => doc.id == documentId);

    if (existingIndex != -1) {
      // Update dokumen yang sudah ada
      documents[existingIndex] = DocumentItemModel(
        documentId,
        documents[existingIndex].label, // Gunakan label yang sudah ada
        filename,
        status
      );
    } else {
      // Tambahkan dokumen baru jika belum ada
      // Kita tidak bisa menambahkan karena kita tidak tahu label-nya
      // Maka dari itu kita hanya update jika dokumen sudah ada
    }

    List<Map<String, dynamic>> documentsMap = documents.map((doc) => doc.toJson()).toList();
    await prefs.setString(_documentsKey, jsonEncode(documentsMap));
  }
}