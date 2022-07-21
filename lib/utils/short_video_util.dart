import '../config/constants.dart';

class ShortVideoUtil {
  static String _analyseUrl(String texts) {
    String url = "";
    List<String> text = texts.split(" ");
    for (var element in text) {
      if (element.startsWith("http") && element.contains("douyin")) {
        url = element;
        break;
      }
    }
    return url;
  }

  static const String _DOU_YIN = "douyin";

  // @status 0表示单个，1表示多个
  static String getRequestUrl(int status, String url, {String maxCursor = ""}) {
    String realUrl = _analyseUrl(url);
    if (realUrl.isEmpty) {
      return "";
    }
    if (status == 0) {
      if (url.contains(_DOU_YIN)) {
        return "${Constants.BASE_URL}/douyin/single?url=$realUrl";
      }
      return "";
    } else {
      if (url.contains(_DOU_YIN)) {
        return "${Constants.BASE_URL}/douyin/list?url=$realUrl&max_cursor=$maxCursor";
      }
      return "";
    }
  }
}

// enum ShortVideo{
//
// }
