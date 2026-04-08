import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

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
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('System Default'),
                  value: ThemeMode.system,
                  groupValue: settings.themeMode,
                  onChanged: (mode) =>
                      ref.read(settingsNotifierProvider).setThemeMode(mode!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Light Mode'),
                  value: ThemeMode.light,
                  groupValue: settings.themeMode,
                  onChanged: (mode) =>
                      ref.read(settingsNotifierProvider).setThemeMode(mode!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark Mode'),
                  value: ThemeMode.dark,
                  groupValue: settings.themeMode,
                  onChanged: (mode) =>
                      ref.read(settingsNotifierProvider).setThemeMode(mode!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'API Configuration',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(settingsNotifierProvider)
                  .saveSettings(_urlController.text, _tokenController.text);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings saved successfully')),
                );
              }
            },
            child: const Text('Save Settings'),
          ),
          if (settings.isAuthenticated) ...[
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => ref.read(settingsNotifierProvider).logout(),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Logout / Clear Token',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
