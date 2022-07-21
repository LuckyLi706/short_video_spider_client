import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:short_video_spider_client/config/constants.dart';
import 'package:short_video_spider_client/pages/home/home_page.dart';
import 'package:short_video_spider_client/utils/file_util.dart';
import 'package:short_video_spider_client/utils/keyboard_util.dart';
import 'package:short_video_spider_client/utils/sp_util.dart';

var dio = Dio();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Injection.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) => Scaffold(
        // 全局点击隐藏软键盘
        body: GestureDetector(
          onTap: () {
            KeyboardUtils.hideKeyboard(context);
          },
          child: child,
        ),
      ),
      home: const HomePage(),
    );
  }
}

///提前注入
///存储和请求初始化
class Injection {
  static Future<void> init() async {
    String? baseUrl = await SpUtil.getBaseUrl();
    if (baseUrl == null) {
      SpUtil.updateBaseUrl(Constants.BASE_URL);
    } else {
      Constants.BASE_URL = baseUrl;
    }
    if (Platform.isIOS) {
      String dir = await FileUtils.getFileDirectory();
      Constants.CACHE_PATH = dir;
      return;
    }
    String? cachePath = await SpUtil.getCachePath();
    if (cachePath == null) {
      String dir = await FileUtils.getFileDirectory();
      SpUtil.updateCachePath(dir);
      Constants.CACHE_PATH = dir;
    } else {
      Constants.CACHE_PATH = cachePath;
    }

    String? appVersion = await SpUtil.getAppVersion();
    if (appVersion == null) {
      SpUtil.updateAppVersion(Constants.APP_VERSION);
    } else {
      if (Constants.APP_VERSION != appVersion) {
        //可以做一些更新配置的操作
        SpUtil.updateAppVersion(Constants.APP_VERSION);
      }
    }
  }
}
