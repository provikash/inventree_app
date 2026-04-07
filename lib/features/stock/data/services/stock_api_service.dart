import 'package:inventree_app/core/network/dio_client.dart';
import 'package:inventree_app/features/stock/data/models/stock_item_model.dart';

class StockApiService {
  Future<List<StockItemModel>> getStockItems() async {
    try {
      final response = await DioClient.dio.get("stock/");
      return (response.data as List)
          .map((e) => StockItemModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
