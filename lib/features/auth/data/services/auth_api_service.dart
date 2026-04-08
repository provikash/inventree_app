import 'package:inventree_app/core/network/dio_client.dart';

class AuthApiService {
  Future<String> login(String username, String password) async {
    try {
      // InvenTree standard token endpoint
      final response = await DioClient.dio.post(
        "user/token/",
        data: {"username": username, "password": password},
      );

      return response.data['token'];
    } catch (e) {
      rethrow;
    }
  }
}
