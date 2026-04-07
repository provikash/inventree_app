import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventree_app/features/stock/data/models/stock_item_model.dart';
import 'package:inventree_app/features/stock/data/repositories/stock_repository.dart';
import 'package:inventree_app/features/stock/data/services/stock_api_service.dart';

final stockApiServiceProvider = Provider<StockApiService>(
  (ref) => StockApiService(),
);

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  final apiService = ref.watch(stockApiServiceProvider);
  return StockRepository(apiService);
});

final stockItemsProvider = FutureProvider<List<StockItemModel>>((ref) async {
  final repository = ref.watch(stockRepositoryProvider);
  return repository.getStockItems();
});
