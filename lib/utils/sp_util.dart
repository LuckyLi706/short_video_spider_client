import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';

/// @description :键值对存储
class SpUtil {
  static updateBaseUrl(String baseUrl) {
    Get.find<SharedPreferences>().remove(Constants.SP_KEY_BASE_URL);
    Get.find<SharedPreferences>().setString(Constants.SP_KEY_BASE_URL, baseUrl);
  }

  static String? getBaseUrl() {
    SharedPreferences sp = Get.find<SharedPreferences>();
    try {
      var baseUrl = sp.getString(Constants.SP_KEY_BASE_URL);
      if (baseUrl == null) {
        return null;
      }
      return baseUrl;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static updateCachePath(String cachePath) {
    Get.find<SharedPreferences>().remove(Constants.SP_KEY_CACHE_PATH);
    Get.find<SharedPreferences>()
        .setString(Constants.SP_KEY_CACHE_PATH, cachePath);
  }

  static String? getCachePath() {
    SharedPreferences sp = Get.find<SharedPreferences>();
    try {
      var cachePath = sp.getString(Constants.SP_KEY_CACHE_PATH);
      if (cachePath == null) {
        return null;
      }
      return cachePath;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
