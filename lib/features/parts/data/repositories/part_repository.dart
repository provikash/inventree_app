import 'package:inventree_app/features/parts/data/models/part_model.dart';
import 'package:inventree_app/features/parts/data/services/part_api_service.dart';

class PartRepository {
  final PartApiService _apiService;

  PartRepository(this._apiService);

  Future<List<PartModel>> getParts() {
    return _apiService.getParts();
  }

  Future<PartModel> createPart(Map<String, dynamic> data) =>
      _apiService.createPart(data);

  Future<void> deletePart(int pk) => _apiService.deletePart(pk);
}
