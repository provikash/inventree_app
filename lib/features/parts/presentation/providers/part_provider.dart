import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventree_app/features/parts/data/models/part_model.dart';
import 'package:inventree_app/features/parts/data/repositories/part_repository.dart';
import 'package:inventree_app/features/parts/data/services/part_api_service.dart';

final partApiServiceProvider = Provider<PartApiService>(
  (ref) => PartApiService(),
);

final partRepositoryProvider = Provider<PartRepository>((ref) {
  final apiService = ref.watch(partApiServiceProvider);
  return PartRepository(apiService);
});

final partsProvider = FutureProvider<List<PartModel>>((ref) async {
  final repository = ref.watch(partRepositoryProvider);
  return repository.getParts();
});
