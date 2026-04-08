import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:inventree_app/core/network/dio_client.dart';
import 'package:inventree_app/features/dashboard/presentation/screens/main_screen.dart';
import 'package:inventree_app/features/settings/presentation/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for Caching
  await Hive.initFlutter();
  await Hive.openBox('parts_cache');
  await Hive.openBox('stock_cache');

  final prefs = await SharedPreferences.getInstance();

  // Initialize Dio with saved settings
  final baseUrl = prefs.getString('base_url') ?? 'http://127.0.0.1:8000/api/';
  final token = prefs.getString('auth_token') ?? '';

  DioClient.setBaseUrl(baseUrl);
  if (token.isNotEmpty) {
    DioClient.setToken(token);
  }

  runApp(
    ProviderScope(
      overrides: [
        settingsNotifierProvider.overrideWith((ref) => SettingsNotifier(prefs)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);

    return MaterialApp(
      title: 'InvenTree Desktop',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const MainScreen(),
    );
  }
}
