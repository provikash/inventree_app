import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventree_app/core/network/dio_client.dart';
import 'package:inventree_app/screens/main_screen.dart';
import 'package:inventree_app/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Initialize Dio with saved settings
  final baseUrl = prefs.getString('base_url') ?? 'http://localhost:8000/api/';
  final token = prefs.getString('auth_token') ?? '';

  DioClient.setBaseUrl(baseUrl);
  if (token.isNotEmpty) {
    DioClient.setToken(token);
  }

  runApp(
    ProviderScope(
      overrides: [
        settingsNotifierProvider.overrideWithValue(SettingsNotifier(prefs)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InvenTree Desktop',
      debugShowCheckedModeBanner: false,
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
