import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _baseUrlKey = 'base_url';
  static const String _tokenKey = 'auth_token';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  String? get baseUrl => _prefs.getString(_baseUrlKey);
  String? get token => _prefs.getString(_tokenKey);

  Future<void> setBaseUrl(String url) async {
    await _prefs.setString(_baseUrlKey, url);
  }

  Future<void> setToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  bool get isConfigured => baseUrl != null && token != null;
}
