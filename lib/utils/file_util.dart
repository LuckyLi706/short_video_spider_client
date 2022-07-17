import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<String> getFileDirectory() async {
    // if (GetPlatform.isDesktop) {
    //   Directory dir = await getApplicationDocumentsDirectory();
    //   return dir.path;
    // } else {
    //
    Directory dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }
}
