class ShortVideoUtil {
  static String getDouYinUrl(String texts) {
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
}
