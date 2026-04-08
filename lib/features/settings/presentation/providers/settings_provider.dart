import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventree_app/core/network/dio_client.dart';

class SettingsNotifier extends ChangeNotifier {
  final SharedPreferences prefs;
  SettingsNotifier(this.prefs);

  // --- Theme Management ---
  ThemeMode get themeMode {
    final mode = prefs.getString('theme_mode') ?? 'system';
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await prefs.setString('theme_mode', mode.name);
    notifyListeners();
  }

  // --- Auth & API Settings ---
  String get baseUrl =>
      prefs.getString('base_url') ?? 'http://127.0.0.1:8000/api/';
  String get token => prefs.getString('auth_token') ?? '';
  bool get isAuthenticated => token.isNotEmpty && baseUrl.isNotEmpty;

  Future<void> saveSettings(String url, String token) async {
    String formattedUrl = url.endsWith('/') ? url : '$url/';
    if (!formattedUrl.endsWith('api/')) {
      formattedUrl = formattedUrl.endsWith('/')
          ? '${formattedUrl}api/'
          : '$formattedUrl/api/';
    }

    await prefs.setString('base_url', formattedUrl);
    await prefs.setString('auth_token', token);

    DioClient.setBaseUrl(formattedUrl);
    DioClient.setToken(token);

    notifyListeners();
  }

  Future<void> logout() async {
    await prefs.remove('auth_token');
    DioClient.setToken('');
    notifyListeners();
  }
}

final settingsNotifierProvider = ChangeNotifierProvider<SettingsNotifier>((
  ref,
) {
  throw UnimplementedError(
    'settingsNotifierProvider must be overridden in ProviderScope',
  );
});
