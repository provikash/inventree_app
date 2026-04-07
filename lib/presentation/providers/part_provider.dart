import 'package:riverpod/riverpod.dart';

import '/services/api_service.dart';

final apiProvider = Provider((ref) => ApiService());

final partsProvider = FutureProvider((ref) async {
  final api = ref.read(apiProvider);
  return api.getParts();
});
