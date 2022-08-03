import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<String> getFileDirectory() async {
    if (Platform.isAndroid) {
      //存储位置/storage/emulated/0/Android/data/myapp.name/files
      Directory? dir = await getExternalStorageDirectory();
      return dir!.path;
    } else if (Platform.isIOS) {
      Directory? dir = await getTemporaryDirectory();
      return dir.path;
    } else {
      Directory dir = await getApplicationDocumentsDirectory();
      return dir.path;
    }
  }

  static String replaceFileName(String text) {
    return text
        .replaceAll("\n", "")
        .replaceAll("?", "")
        .replaceAll(">", "")
        .replaceAll(" ", "")
        .replaceAll("\\", "")
        .replaceAll("\\", "")
        .replaceAll("*", "")
        .replaceAll(":", "")
        .replaceAll("<", "")
        .replaceAll("|", "");
  }
}
