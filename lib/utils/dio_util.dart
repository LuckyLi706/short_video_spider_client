import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';
import 'package:short_video_spider_client/config/constants.dart';

class DioUtils {
  static Dio? dio;
  static Dio? dioProxy;

  static String proxyUrl = "";

  static Dio getDio() {
    dio ??= Dio(BaseOptions(headers: {
      "user-agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36"
    }, connectTimeout: 5000, sendTimeout: 5000));
    return dio!;
  }

  static Dio getDioProxy() {
    dioProxy = Dio(BaseOptions(headers: {
      "user-agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36"
    }, connectTimeout: 5000, sendTimeout: 5000));

    (dioProxy?.httpClientAdapter as DefaultHttpClientAdapter)
        .onHttpClientCreate = (client) {
      // config the http client
      client.findProxy = (uri) {
        //proxy all request to localhost:8888
        return 'PROXY ${Constants.PROXY_URL}';
      };
      // you can also create a new HttpClient to dio
      // return HttpClient();
    };
    return dioProxy!;
  }
}
