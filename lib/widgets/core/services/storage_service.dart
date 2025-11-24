import 'package:shared_preferences/shared_preferences.dart';

// Service ini adalah "brankas" simpel untuk simpan dan baca token dan nama
class StorageService {
  final SharedPreferences _prefs;
  static const String _tokenKey = 'auth_token';
  static const String _nameKey = 'user_name';

  StorageService(this._prefs);

  // Token
  Future<void> saveToken(String token) async => await _prefs.setString(_tokenKey, token);
  Future<String?> getToken() async => _prefs.getString(_tokenKey);
  Future<void> deleteToken() async => await _prefs.remove(_tokenKey);

  // Nama user
  Future<void> saveUserName(String name) async => await _prefs.setString(_nameKey, name);
  Future<String?> getUserName() async => _prefs.getString(_nameKey);

  // Clear all (logout)
  Future<void> clearAll() async => await _prefs.clear();
}
