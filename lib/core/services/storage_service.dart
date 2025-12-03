import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // keys
  static const String _tokenKey = 'auth_token';

  static const String _nameKey = 'user_name';
  static const String _nimKey = 'user_nim';
  static const String _prodiKey = 'user_prodi';
  static const String _jurusanKey = 'user_jurusan';
  static const String _emailKey = 'user_email';
  static const String _tahunMasukKey = 'user_tahun_masuk';

  // TOKEN
  Future<void> saveToken(String token) async =>
      await _prefs.setString(_tokenKey, token);
  Future<String?> getToken() async => _prefs.getString(_tokenKey);
  Future<void> deleteToken() async => await _prefs.remove(_tokenKey);

  // PROFIL
  Future<void> saveProfile(Map<String, dynamic> data) async {
    if (data['nama'] != null) await _prefs.setString(_nameKey, data['nama']);
    if (data['nim'] != null) await _prefs.setString(_nimKey, data['nim']);
    if (data['prodi'] != null) await _prefs.setString(_prodiKey, data['prodi']);
    if (data['jurusan'] != null) await _prefs.setString(_jurusanKey, data['jurusan']);
    if (data['email'] != null) await _prefs.setString(_emailKey, data['email']);
    if (data['tahun_masuk'] != null)
      await _prefs.setString(_tahunMasukKey, data['tahun_masuk'].toString());
  }

  Future<Map<String, dynamic>> getProfile() async {
    return {
      'nama': _prefs.getString(_nameKey),
      'nim': _prefs.getString(_nimKey),
      'prodi': _prefs.getString(_prodiKey),
      'jurusan': _prefs.getString(_jurusanKey),
      'email': _prefs.getString(_emailKey),
      'tahun_masuk': _prefs.getString(_tahunMasukKey),
    };
  }

  // CLEAR
  Future<void> clearAll() async => await _prefs.clear();
}
