import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:short_video_spider_client/config/constants.dart';
import 'package:short_video_spider_client/utils/dio_util.dart';
import 'package:short_video_spider_client/utils/widget_util.dart';

import '../../utils/toast_util.dart';
import '../widget/dialog/dialog.dart';

var imageList = [];
var urlDownloadList = [];
var videoDescList = [];

class DownloadPage extends StatefulWidget {
  DownloadPage(var imageListD, var urlDownloadListD, var videoDescListD,
      {Key? key})
      : super(key: key) {
    imageList = imageListD;
    urlDownloadList = urlDownloadListD;
    videoDescList = videoDescListD;
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
          leading: IconButton(
              onPressed: () {
                if (!isFinish) {
                  ToastUtils.showToast("当前下载未完成,请等待下载完成");
                  return;
                }
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back)),
        ),
        body: _getBodyWidget(context),
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

Widget _getBodyWidget(BuildContext context) {
  return Column(children: [
    Expanded(
        flex: 2,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            child: WidgetUtils.getListView(
                imageList, videoDescList, urlDownloadList),
          ),
        )),
    TextButton(
        onPressed: () async {
          if (!isFinish) {
            showDownloadDialog(context);
            return;
          }
          for (int i = 0; i < urlDownloadList.length; i++) {
            isFinish = false;
            if (videoDescList[i].toString().endsWith('jpeg')) {
              if (File(videoDescList[i]).existsSync()) {
                showLog("一共${urlDownloadList.length}个图片：第${i + 1}个图片已存在,跳过");
                if (i == urlDownloadList.length - 1) {
                  isFinish = true;
                }
                continue;
              }
              await DioUtils.getDio()
                  .download(urlDownloadList[i], videoDescList[i],
                      onReceiveProgress: (int count, int total) {
                showLog(
                    "一共${urlDownloadList.length}个图片：\n正在下载第${i + 1}个图片：${(count / total * 100).toInt()}%",
                    isAppend: false);
                if (i == urlDownloadList.length - 1 && count == total) {
                  showLog("所有图片下载完成");
                  isFinish = true;
                }
              }).catchError((e) {
                showLog("出现异常：${e.toString()}");
                isFinish = true;
              });
              final result =
                  await ImageGallerySaver.saveFile(videoDescList[i]); //保存到相册里面去
              print(result);
            } else {
              String end =
                  urlDownloadList[i].toString().endsWith("mp3") ? "mp3" : "mp4";
              String filePath = Constants.CACHE_PATH +
                  Platform.pathSeparator +
                  videoDescList[i];
              //安卓文件路径有限制,大约127个字符
              //参考：https://stackoverflow.com/questions/13204807/max-file-name-length-in-android
              if (filePath.length > 120) {
                filePath = "${filePath.substring(0, 120)}.$end";
              } else {
                filePath = "$filePath.$end";
              }
              if (File(filePath).existsSync()) {
                showLog("一共${urlDownloadList.length}个视频：第${i + 1}个视频已存在,跳过");
                if (i == urlDownloadList.length - 1) {
                  isFinish = true;
                }
                continue;
              }
              await DioUtils.getDio().download(urlDownloadList[i], filePath,
                  onReceiveProgress: (int count, int total) {
                isFinish = false;
                showLog(
                    "一共${urlDownloadList.length}个视频：\n正在下载第${i + 1}个视频：${(count / total * 100).toInt()}%",
                    isAppend: false);
                if (i == urlDownloadList.length - 1) {
                  isFinish = true;
                  showLog("所有视频下载完成", isAppend: false);
                }
              }).catchError((e) {
                isFinish = true;
                showLog("出现异常：${e.toString()}");
              });
              final result =
                  await ImageGallerySaver.saveFile(filePath); //保存到相册里面去
              print(result);
            }
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
