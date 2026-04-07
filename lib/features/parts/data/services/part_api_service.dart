import 'package:inventree_app/core/network/dio_client.dart';
import 'package:inventree_app/features/parts/data/models/part_model.dart';

class PartApiService {
  Future<List<PartModel>> getParts() async {
    try {
      final response = await DioClient.dio.get("part/");
      return (response.data as List).map((e) => PartModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
