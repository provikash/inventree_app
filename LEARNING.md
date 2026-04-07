# InvenTree Desktop App: Learning Guide

This document explains the core technologies and architectural patterns used to build this Flutter Windows application.

---

## 1. Project Architecture (Clean & Feature-First)
We use a **Feature-First Architecture**. Instead of grouping by type (all screens in one folder, all models in another), we group by **Feature**.

### Folder Breakdown:
- **`lib/core`**: Contains logic shared across the entire app (Networking, Utils, Constants).
- **`lib/features/{feature_name}`**: Each feature (Parts, Stock, Settings) has its own directory.
  - **`data/`**: Handles data retrieval.
    - `models/`: Plain Dart classes that represent JSON data.
    - `services/`: Low-level API calls (using Dio).
    - `repositories/`: Abstracts the data source (can switch between API and Mock data easily).
  - **`presentation/`**: Handles the UI and State.
    - `pages/`: The actual Widgets/Screens.
    - `providers/`: The logic that connects Data to UI (Riverpod).

---

## 2. State Management: Riverpod
Riverpod is used to manage data flow. It ensures that when data changes, the UI updates automatically.

### Example: `partsProvider`
Located in `lib/features/parts/presentation/providers/part_provider.dart`:
```dart
final partsProvider = FutureProvider<List<PartModel>>((ref) async {
  final repository = ref.watch(partRepositoryProvider);
  return repository.getParts(); // Fetches data from the server
});
```
**How it works in the UI:**
```dart
final partsAsync = ref.watch(partsProvider);

// return partsAsync.when(
//   data: (parts) => ListView(...), // Show list when data arrives
//   loading: () => CircularProgressIndicator(), // Show spinner while waiting
//   error: (err, stack) => Text('Error: $err'), // Show error if something fails
// );
```

---

## 3. Networking: Dio
Dio is a powerful HTTP client for Dart. We wrapped it in a `DioClient` class (`lib/core/network/dio_client.dart`) to provide global access to a single instance.

### Key Workings:
- **`setBaseUrl`**: Updates the server address dynamically.
- **`setToken`**: Adds the `Authorization: Token <your_token>` header to every request.
- **Interceptors**: Can be added to log requests or handle 401 Unauthorized errors globally.

---

## 4. Local Storage: SharedPreferences
We use `shared_preferences` to persist your API settings so you don't have to re-enter them every time the app starts.

### The Flow:
1. **Startup**: `main.dart` reads the URL and Token from disk.
2. **Initialization**: These values are injected into the `DioClient`.
3. **Change**: When you click "Save" in `SettingsScreen`, the `SettingsNotifier` updates the disk AND the `DioClient` simultaneously.

---

## 5. UI: Material 3 & Desktop Optimization
Since this is a Windows app, we use:
- **`NavigationRail`**: Better for wide screens than a bottom navigation bar.
- **`LayoutBuilder`**: Changes the number of columns in the Dashboard grid based on how wide the window is.
- **`ThemeData`**: Supports both Light and Dark modes automatically.

---

## Summary of Learning Path
To dive deeper into these topics, I recommend these official resources:
1. [Riverpod Documentation](https://riverpod.dev)
2. [Dio Documentation](https://pub.dev/packages/dio)
3. [Flutter Desktop Support](https://docs.flutter.dev/desktop)
