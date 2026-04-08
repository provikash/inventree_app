import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:inventree_app/core/network/dio_client.dart';
import 'package:inventree_app/features/stock/data/models/stock_item_model.dart';

class StockApiService {
  final _cacheBox = Hive.box('stock_cache');

  Future<List<StockItemModel>> getStockItems() async {
    try {
      final response = await DioClient.dio.get("stock/");
      final data = response.data as List;

      // Save to cache
      await _cacheBox.put('all_stock', jsonEncode(data));

      return data.map((e) => StockItemModel.fromJson(e)).toList();
    } catch (e) {
      // Load from cache if network fails
      final cachedData = _cacheBox.get('all_stock');
      if (cachedData != null) {
        final List decoded = jsonDecode(cachedData);
        return decoded.map((e) => StockItemModel.fromJson(e)).toList();
      }
      rethrow;
    }
  }

  /// Adjusts the stock level of a specific item
  Future<void> adjustStock(int itemPk, double quantity, String action) async {
    // InvenTree API endpoint for stock adjustment
    // action can be 'add', 'remove', 'count'
    final endpoint = "stock/$itemPk/adjust/";
    await DioClient.dio.post(
      endpoint,
      data: {
        "quantity": quantity,
        "action": action,
        "notes": "Adjusted via Flutter Desktop Client",
      },
    );
  }
}
