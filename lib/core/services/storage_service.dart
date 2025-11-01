import 'package:shared_preferences/shared_preferences.dart';

// Service ini adalah "brankas" simpel untuk simpan dan baca token
class StorageService {
  final SharedPreferences _prefs;
  static const String _tokenKey = 'auth_token'; // Kunci untuk simpan token

  StorageService(this._prefs);

  // Fungsi untuk menyimpan token
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  // Fungsi untuk membaca token
  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  // Fungsi untuk menghapus token (untuk logout)
  Future<void> deleteToken() async {
    await _prefs.remove(_tokenKey);
  }
}
