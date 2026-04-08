import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:inventree_app/core/network/dio_client.dart';
import 'package:inventree_app/features/parts/data/models/part_model.dart';

class PartApiService {
  final _cacheBox = Hive.box('parts_cache');

  Future<List<PartModel>> getParts() async {
    try {
      final response = await DioClient.dio.get("part/");
      final data = response.data as List;

      // Save to cache
      await _cacheBox.put('all_parts', jsonEncode(data));

      return data.map((e) => PartModel.fromJson(e)).toList();
    } catch (e) {
      // Load from cache if network fails
      final cachedData = _cacheBox.get('all_parts');
      if (cachedData != null) {
        final List decoded = jsonDecode(cachedData);
        return decoded.map((e) => PartModel.fromJson(e)).toList();
      }
      rethrow;
    }
  }
}
