import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventree_app/features/parts/presentation/providers/part_provider.dart';
import 'package:inventree_app/features/stock/presentation/providers/stock_provider.dart';

class DashboardStats {
  final int totalParts;
  final int totalStockItems;
  final int lowStockCount;

  DashboardStats({
    required this.totalParts,
    required this.totalStockItems,
    required this.lowStockCount,
  });
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final parts = ref.watch(partsProvider).value ?? [];
  final stockItems = ref.watch(stockItemsProvider).value ?? [];

  // Logic for low stock: count parts where stock is less than some threshold or
  // simply parts that have some flag (InvenTree has many fields for this,
  // but let's use a simple check on the part's stock field)
  final lowStock = parts.where((p) => (p.stock ?? 0) < 5).length;

  return DashboardStats(
    totalParts: parts.length,
    totalStockItems: stockItems.length,
    lowStockCount: lowStock,
  );
});
