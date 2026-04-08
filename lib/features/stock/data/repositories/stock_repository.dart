import 'package:inventree_app/features/stock/data/models/stock_item_model.dart';
import 'package:inventree_app/features/stock/data/services/stock_api_service.dart';

class StockRepository {
  final StockApiService _apiService;

  StockRepository(this._apiService);

  Future<List<StockItemModel>> getStockItems() {
    return _apiService.getStockItems();
  }

  Future<void> adjustStock(int itemPk, double quantity, String action) {
    return _apiService.adjustStock(itemPk, quantity, action);
  }

  Future<void> createStockItem(Map<String, dynamic> data) {
    return _apiService.createStockItem(data);
  }

  Future<void> deleteStockItem(int pk) {
    return _apiService.deleteStockItem(pk);
  }
}
