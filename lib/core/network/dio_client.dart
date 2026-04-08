import 'package:dio/dio.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000/api/",
      headers: {
        "Authorization":
            "Token inv-264af3e031dd43b91f7f93b6152a3e0f7dec2554-20260406",
      },
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  static Dio get dio => _dio;

  static void setToken(String token) {
    _dio.options.headers["Authorization"] = "Token $token";
    print(_dio.options.headers);
  }

  static void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }
}
