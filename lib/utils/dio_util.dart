import 'package:dio/dio.dart';

class DioUtils {
  static Dio? dio;

  static Dio getDio() {
    dio ??= Dio(BaseOptions(headers: {
      "user-agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36"
    }, connectTimeout: 5000, sendTimeout: 5000));
    return dio!;
  }
}
