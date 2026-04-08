import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventree_app/features/parts/presentation/providers/part_provider.dart';
import 'package:inventree_app/features/stock/presentation/providers/stock_provider.dart';

class DashboardStats {
  final int totalParts;
  final int totalStockItems;
  final int lowStockCount;
  final Map<String, int> stockByCategory;

  DashboardStats({
    required this.totalParts,
    required this.totalStockItems,
    required this.lowStockCount,
    required this.stockByCategory,
  });
}

// Auto-refresh logic: Refresh every 30 seconds
final dashboardAutoRefreshProvider = StreamProvider<void>((ref) {
  return Stream.periodic(const Duration(seconds: 30), (_) {
    ref.invalidate(partsProvider);
    ref.invalidate(stockItemsProvider);
  });
});

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  // We don't need to listen to the stream, just trigger it
  ref.watch(dashboardAutoRefreshProvider);

  final parts = ref.watch(partsProvider).value ?? [];
  final stockItems = ref.watch(stockItemsProvider).value ?? [];

  final lowStock = parts.where((p) => (p.stock ?? 0) < 5).length;

  // Categorize stock for the chart
  final Map<String, int> categories = {};
  for (var part in parts) {
    final cat = part.categoryName ?? 'Uncategorized';
    categories[cat] = (categories[cat] ?? 0) + (part.stock?.toInt() ?? 0);
  }

  return DashboardStats(
    totalParts: parts.length,
    totalStockItems: stockItems.length,
    lowStockCount: lowStock,
    stockByCategory: categories,
  );
});
