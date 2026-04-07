import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventree_app/core/network/dio_client.dart';

class SettingsNotifier extends ChangeNotifier {
  final SharedPreferences prefs;
  SettingsNotifier(this.prefs);

  String get baseUrl =>
      prefs.getString('base_url') ?? 'http://localhost:8000/api/';
  String get token => prefs.getString('auth_token') ?? '';

  Future<void> saveSettings(String url, String token) async {
    // Ensure URL ends with a slash for Dio
    String formattedUrl = url.endsWith('/') ? url : '$url/';
    if (!formattedUrl.endsWith('api/')) {
      formattedUrl = formattedUrl.endsWith('/')
          ? '${formattedUrl}api/'
          : '$formattedUrl/api/';
    }

    await prefs.setString('base_url', formattedUrl);
    await prefs.setString('auth_token', token);

    // Update the live Dio client
    DioClient.setBaseUrl(formattedUrl);
    DioClient.setToken(token);

    notifyListeners();
  }
}

// This provider is globally accessible but must be overridden in main.dart
// with the actual SharedPreferences instance.
final settingsNotifierProvider = ChangeNotifierProvider<SettingsNotifier>((
  ref,
) {
  throw UnimplementedError(
    'settingsNotifierProvider must be overridden in ProviderScope',
  );
});
