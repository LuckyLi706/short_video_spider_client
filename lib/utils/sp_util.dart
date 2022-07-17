import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';

/// @description :键值对存储
class SpUtil {
  static updateBaseUrl(String baseUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(Constants.SP_KEY_BASE_URL);
    prefs.setString(Constants.SP_KEY_BASE_URL, baseUrl);
  }

  static Future<String?> getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var baseUrl = prefs.getString(Constants.SP_KEY_BASE_URL);
    return baseUrl;
  }

  static updateCachePath(String cachePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(Constants.SP_KEY_CACHE_PATH);
    prefs.setString(Constants.SP_KEY_CACHE_PATH, cachePath);
  }

  static Future<String?> getCachePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachePath = prefs.getString(Constants.SP_KEY_CACHE_PATH);
    return cachePath;
  }
}
