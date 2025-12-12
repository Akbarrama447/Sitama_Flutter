import 'package:shared_preferences/shared_preferences.dart';

class UploadStatusService {
  static const String _key = 'all_documents_uploaded';

  Future<void> setAllDocumentsUploaded(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, status);
  }

  Future<bool> getAllDocumentsUploaded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }
}