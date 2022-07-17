import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    // return ScreenUtilInit(   ///屏幕适配的工具库
    //     designSize: const Size(1920, 1080), //屏幕适配，设定设计图给的尺寸1920*1080
    //     minTextAdapt: true,
    //     splitScreenMode: true,
    //     builder: (context, child) {
    return GetMaterialApp(
      ///所有的路由文件
      //getPages: RoutesPage.pages,
      ///不展示右上角的debug标记
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

      ///国际化支持-备用语言
      defaultTransition: Transition.fade, //默认的路由切换动画,淡入淡出
      home: HomePage(),
      //initialBinding: SplashBinding(),
    );
    //});
  }
}

///提前注入
///存储和请求初始化
class Injection {
  static Future<void> init() async {
    // shared_preferences
    await SharedPreferences.getInstance();
    if (await SpUtil.getBaseUrl() == null) {
      SpUtil.updateBaseUrl("http://192.168.1.103");
    }
    if (await SpUtil.getCachePath() == null) {
      SpUtil.updateCachePath(await FileUtils.getFileDirectory());
    }
    //Get.lazyPut(() =>RequestRepository());
  }
}

// void _incrementCounter() async {
//   dio.options = BaseOptions(headers: {
//     "user-agent":
//     "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1"
//   });
//
//   await dio.download(
//       "https://aweme.snssdk.com/aweme/v1/play/?video_id=v0200fg10000cb6l3ojc77u09nmstov0&ratio=720p&line=0",
//       "./77.mp4", onReceiveProgress: (int count, int total) {
//     print("$count,$total");
//   });
