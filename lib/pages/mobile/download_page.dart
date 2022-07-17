import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:short_video_spider_client/utils/sp_util.dart';

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
    return Scaffold(
      appBar: AppBar(),
      body: _getBodyWidget(),
    );
  }
}

String? cachePath = "";

void test() {
  var dio = Dio();
  Future(() => () async {
        String? cachePath = await SpUtil.getCachePath();
        for (int i = 0; i < urlDownloadList.length; i++) {
          String filePath =
              "${cachePath! + Platform.pathSeparator + md5UrlDownloadList[i]}.mp4";
          if (File(filePath).existsSync()) {
            showLog("一共${urlDownloadList.length}个视频：\n第${i + 1}个视频已存在,跳过");
            continue;
          }
          dio.options = BaseOptions(headers: {
            "user-agent":
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36"
          });
          await dio.download(urlDownloadList[i],
              "${cachePath + Platform.pathSeparator + md5UrlDownloadList[i]}.mp4",
              onReceiveProgress: (int count, int total) {
            showLog(
                "一共${urlDownloadList.length}个视频：\n正在下载第${i + 1}个视频：${(count / total * 100).toInt()}%",
                isAppend: false);
          }).catchError((e) {
            showLog("出现异常：${e.toString()}");
          });
        }
      });
}

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
        child: Stack(
      alignment: Alignment.topLeft,
      //fit: StackFit.expand, //未定位widget占满Stack整个空间
      children: <Widget>[
        Positioned(
          top: 20.0,
          bottom: 0,
          left: 0,
          right: 0,
          child: TextField(
            scrollController: _scrollDownloadController,
            controller: _logDownloadTextController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            //不限制行数
            autofocus: false,
            // 长按输入的文本, 设置是否显示剪切，复制，粘贴按钮, 默认是显示的
            enableInteractiveSelection: true,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              labelText: "日志信息",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: const BorderSide()),
            ),
          ),
        )
      ],
    )),
    Expanded(
        flex: 1,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            child: _getListView(),
          ),
        )),
  ]);
}

Widget _getListView() {
  return ListView.builder(
    itemCount: imageList.length,
    //列表项构造器
    itemBuilder: (BuildContext context, int index) {
      return Card(
        elevation: 1.0,
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 200,
              margin: const EdgeInsets.all(10),
              child: Image.network(
                imageList[index],
                fit: BoxFit.cover,
              ),
            ),
            Text(
                "文件：$cachePath${Platform.pathSeparator}${md5UrlDownloadList[index]}.mp4"),
            Text("地址：${urlDownloadList[index]}")
          ],
        ),
      );
    },
    //分割器构造器
  );
}
