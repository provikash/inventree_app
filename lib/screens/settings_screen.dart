import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventree_app/core/network/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider = Provider<SettingsNotifier>(
  (ref) => throw UnimplementedError(),
);

class SettingsNotifier extends ChangeNotifier {
  final SharedPreferences prefs;
  SettingsNotifier(this.prefs);

  String get baseUrl =>
      prefs.getString('base_url') ?? 'http://localhost:8000/api/';
  String get token => prefs.getString('auth_token') ?? '';

  Future<void> saveSettings(String url, String token) async {
    await prefs.setString('base_url', url);
    await prefs.setString('auth_token', token);

    DioClient.setBaseUrl(url);
    DioClient.setToken(token);

    notifyListeners();
  }
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _urlController;
  late TextEditingController _tokenController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsNotifierProvider);
    _urlController = TextEditingController(text: settings.baseUrl);
    _tokenController = TextEditingController(text: settings.token);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'InvenTree API URL',
                hintText: 'http://localhost:8000/api/',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'API Token',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(settingsNotifierProvider)
                    .saveSettings(_urlController.text, _tokenController.text);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings saved successfully'),
                    ),
                  );
                }
              },
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

final settingsNotifierProvider = ChangeNotifierProvider<SettingsNotifier>((
  ref,
) {
  // This will be overridden in main.dart
  throw UnimplementedError();
});
