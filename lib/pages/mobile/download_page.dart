import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:short_video_spider_client/config/constants.dart';
import 'package:short_video_spider_client/utils/widget_util.dart';

import '../../utils/toast_util.dart';

var imageList = [];
var urlDownloadList = [];
var md5UrlDownloadList = [];

class DownloadPage extends StatefulWidget {
  DownloadPage(var imageListD, var urlDownloadListD, var md5UrlDownloadListD,
      {Key? key})
      : super(key: key) {
    imageList = imageListD;
    urlDownloadList = urlDownloadListD;
    md5UrlDownloadList = md5UrlDownloadListD;
  }

  @override
  State<DownloadPage> createState() {
    return DownloadPageState();
  }
}

class DownloadPageState extends State<DownloadPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //必须放在状态可变的组件下面
      onWillPop: () async {
        if (!isFinish) {
          ToastUtils.showToast("当前下载未完成,请等待下载完成");
          return false;
        }
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
        ),
        body: _getBodyWidget(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _logDownloadTextController.text = "";
    showLogTextD = "";
  }
}

bool isFinish = true;

final TextEditingController _logDownloadTextController =
    TextEditingController();
final ScrollController _scrollDownloadController = ScrollController();
String showLogTextD = "";

void showLog(String msg, {bool isAppend = true}) {
  if (msg.isEmpty) {
    return;
  }
  if (!isAppend) {
    _logDownloadTextController.text = "${msg.trim()}\n";
    return;
  }
  if (showLogTextD.isEmpty) {
    showLogTextD = ">>>>>>>$showLogTextD${msg.trim()}";
  } else {
    showLogTextD = "$showLogTextD\n>>>>>>>${msg.trim()}";
  }
  _logDownloadTextController.text = showLogTextD;
  Future.delayed(const Duration(milliseconds: 200), () {
    _scrollDownloadController.animateTo(
      _scrollDownloadController.position.maxScrollExtent, //滚动到底部
      //滚动到底部
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    //FocusScope.of(leftPanelState.context).requestFocus(leftPanelFocus);
  });
}

Widget _getBodyWidget() {
  return Column(children: [
    Expanded(
        flex: 2,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            child: WidgetUtils.getListView(
                imageList, md5UrlDownloadList, urlDownloadList),
          ),
        )),
    TextButton(
        onPressed: () async {
          var dio = Dio();
          isFinish = false;
          for (int i = 0; i < urlDownloadList.length; i++) {
            String end =
                urlDownloadList[i].toString().endsWith("mp3") ? "mp3" : "mp4";
            String filePath =
                "${Constants.CACHE_PATH + Platform.pathSeparator + md5UrlDownloadList[i]}.$end";
            if (File(filePath).existsSync()) {
              showLog("一共${urlDownloadList.length}个视频：第${i + 1}个视频已存在,跳过");
              if (i == urlDownloadList.length - 1) {
                isFinish = true;
              }
              continue;
            }
            dio.options = BaseOptions(headers: {
              "user-agent":
                  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36"
            });
            await dio.download(urlDownloadList[i], filePath,
                onReceiveProgress: (int count, int total) {
              showLog(
                  "一共${urlDownloadList.length}个视频：\n正在下载第${i + 1}个视频：${(count / total * 100).toInt()}%",
                  isAppend: false);
              if (i == urlDownloadList.length - 1) {
                isFinish = true;
                showLog("所有视频下载完成", isAppend: false);
              }
            }).catchError((e) {
              showLog("出现异常：${e.toString()}");
            });
            final result = await ImageGallerySaver.saveFile(filePath);
            print(result);
          }
        },
        child: const Text("开始下载")),
    Expanded(
        flex: 1,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 5),
          child: WidgetUtils.getLogWidget(
              _scrollDownloadController, _logDownloadTextController),
        )),
  ]);
}
