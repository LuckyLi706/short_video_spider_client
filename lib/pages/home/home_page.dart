import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:short_video_spider_client/utils/sp_util.dart';

import '../../config/constants.dart';
import '../../model/douyin_list.dart';
import '../../model/douyin_single.dart';
import '../../utils/screen_util.dart';

var imageList = [];
var urlDownloadList = [];
var md5UrlDownloadList = [];

class UrlListView extends StatelessWidget {
  const UrlListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //下划线widget预定义以供复用。
    return ListView.builder(
      itemCount: imageList.length,
      //列表项构造器
      itemBuilder: (BuildContext context, int index) {
        return Card(
          elevation: 1.0,
          margin: const EdgeInsets.all(10),
          child: Wrap(
            children: <Widget>[
              Container(
                height: 100,
                width: 100,
                margin: const EdgeInsets.all(10),
                child: Image.network(
                  imageList[index],
                  fit: BoxFit.cover,
                ),
              ),
              Wrap(direction: Axis.vertical, children: [
                Text(
                    "文件路径：${SpUtil.getBaseUrl()}/${md5UrlDownloadList[index]}"),
                Text("真实路径：${urlDownloadList[index]}"),
              ])
            ],
          ),
        );
      },
      //分割器构造器
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  var dio = Dio();

  @override
  void initState() {
    super.initState();
    _initShortVideoDownloadType();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(Constants.APP_NAME),
          actions: [
            IconButton(
                onPressed: () {
                  _showSettingDialog(context);
                },
                icon: const Icon(Icons.settings))
          ],
        ),
        body: _getBodyWidget());
  }

  Widget _getBodyWidget() {
    if (ScreenUtils.width > ScreenUtils.height) {
      return Row(children: [
        Expanded(
          child: _getListView(),
        ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            child: _getBehaviorWidget(),
          ),
        )),
      ]);
    } else {
      return Column(children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            child: _getBehaviorWidget(),
          ),
        )),
        Expanded(
          child: _getListView(),
        )
      ]);
    }
  }

  final TextEditingController _logTextController = TextEditingController();
  final TextEditingController _maxCursorTextController =
      TextEditingController(text: "0");
  final TextEditingController _shareUrlTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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
                  "文件：${SpUtil.getCachePath()}${Platform.pathSeparator}${md5UrlDownloadList[index]}.mp4"),
              Text("地址：${urlDownloadList[index]}")
            ],
          ),
        );
      },
      //分割器构造器
    );
  }

  Widget _getBehaviorWidget() {
    return Column(
      //mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButton<String>(
          isExpanded: true,
          value: currentShortVideoDownloadType,
          onChanged: (String? newValue) {
            setState(() {
              currentShortVideoDownloadType = newValue!;
            });
          },
          items: shortVideoDownloadDdmi,
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          controller: _shareUrlTextController,
          keyboardType: TextInputType.multiline,
          maxLines: 1,
          // 长按输入的文本, 设置是否显示剪切，复制，粘贴按钮, 默认是显示的
          enableInteractiveSelection: true,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: "分享的地址",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: const BorderSide()),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          controller: _maxCursorTextController,
          keyboardType: TextInputType.multiline,
          maxLines: 1,
          // 长按输入的文本, 设置是否显示剪切，复制，粘贴按钮, 默认是显示的
          enableInteractiveSelection: true,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: "max_cursor",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: const BorderSide()),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(children: [
          Expanded(
              child: TextButton(
                  onPressed: () async {
                    String? baseUrl = SpUtil.getBaseUrl();
                    if (baseUrl == null) {
                      showLog("baseUrl不能为空，请先在设置里面去配置");
                      return;
                    }
                    if (_shareUrlTextController.text.isEmpty) {
                      showLog("url不能为空");
                      return;
                    }
                    if (currentShortVideoDownloadType ==
                        shortVideoDownloadType[0]) {
                      String url = "";
                      List<String> text =
                          _shareUrlTextController.text.split(" ");
                      for (var element in text) {
                        if (element.startsWith("http") &&
                            element.contains("douyin")) {
                          url = element;
                          break;
                        }
                      }
                      Response result =
                          await dio.get("$baseUrl/douyin/single?url=${url}");
                      print(result.data);
                      setState(() {
                        imageList.clear();
                        urlDownloadList.clear();
                        md5UrlDownloadList.clear();
                        if (result.data.toString().contains("200")) {
                          DouYinSingle single =
                              DouYinSingle.fromJson(result.data);
                          md5UrlDownloadList.add(_getMd5(single.videoUrl!));
                          urlDownloadList.add(single.videoUrl!);
                          imageList.add(single.coverImageUrl!);
                        } else {
                          showLog("获取真实地址失败：${result.data.toString()}");
                        }
                      });
                    } else if (currentShortVideoDownloadType ==
                        shortVideoDownloadType[1]) {
                      if (_maxCursorTextController.text.isEmpty) {
                        showLog("max_cursor不能为空");
                        return;
                      }
                      String url = "";
                      List<String> text =
                          _shareUrlTextController.text.split(" ");
                      for (var element in text) {
                        if (element.startsWith("http") &&
                            element.contains("douyin")) {
                          url = element;
                          break;
                        }
                      }
                      Response result = await dio.get(
                          "$baseUrl/douyin/list?url=${url}&max_cursor=${_maxCursorTextController.text}");
                      setState(() {
                        imageList.clear();
                        urlDownloadList.clear();
                        md5UrlDownloadList.clear();
                        if (result.data.toString().contains("200")) {
                          DouYinList list = DouYinList.fromJson(result.data);
                          showLog("有更多数据");
                          _maxCursorTextController.text =
                              list.maxCursor.toString();
                          for (int i = 0;
                              i < list.coverImageUrlList.length;
                              i++) {
                            md5UrlDownloadList
                                .add(_getMd5(list.videoUrlList[i]));
                            urlDownloadList.add(list.videoUrlList[i]);
                            imageList.add(list.coverImageUrlList[i]);
                          }
                        } else {
                          showLog("获取真实地址失败：${result.data.toString()}");
                        }
                      });
                    }
                  },
                  child: const Text("获取下载地址"))),
          Expanded(
              child: TextButton(
                  onPressed: () async {
                    String? cachePath = SpUtil.getCachePath();
                    if (cachePath == null) {
                      showLog("缓存地址为空，请先去设置进行配置");
                      return;
                    }
                    if (urlDownloadList.isEmpty) {
                      showLog("请先获取真实地址");
                      return;
                    }
                    for (int i = 0; i < urlDownloadList.length; i++) {
                      String filePath =
                          "${cachePath + Platform.pathSeparator + md5UrlDownloadList[i]}.mp4";
                      if (File(filePath).existsSync()) {
                        showLog(
                            "一共${urlDownloadList.length}个视频：\n第${i + 1}个视频已存在,跳过");
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
                  },
                  child: const Text("下载视频"))),
          Expanded(
              child: TextButton(
                  onPressed: () {
                    _logTextController.text = "";
                  },
                  child: const Text("清除日志")))
        ]),
        SizedBox(
          height: 200,
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
                  scrollController: _scrollController,
                  controller: _logTextController,
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
          ),
        )
      ],
    );
  }

  String _getMd5(String origin) {
    // 待加密字符串
    var content = const Utf8Encoder().convert(origin);
    var digest = md5.convert(content);
    return digest.toString();
  }

  String showLogText = "";

  void showLog(String msg, {bool isAppend = true}) {
    if (msg.isEmpty) {
      return;
    }
    if (!isAppend) {
      _logTextController.text = "${msg.trim()}\n";
      return;
    }
    if (showLogText.isEmpty) {
      showLogText = ">>>>>>>$showLogText${msg.trim()}";
    } else {
      showLogText = "$showLogText\n>>>>>>>${msg.trim()}";
    }
    _logTextController.text = showLogText;
    Future.delayed(const Duration(milliseconds: 200), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent, //滚动到底部
        //滚动到底部
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      //FocusScope.of(leftPanelState.context).requestFocus(leftPanelFocus);
    });
  }

  /**

   */

  /**
      TextButton(
      onPressed: () async {
      var dio = learn.Dio();
      learn.Response result = await dio.get(
      "http://192.168.1.109:8080/douyin/list?url=https://www.douyin.com/user/MS4wLjABAAAAg5Y5_VVZMSCOSoOYeF0wpHhX2x4f6ZyckCQ0ZQJk9ls&is_origin=0&max_cursor=0");
      print(result.data);

      DouYinList list = DouYinList.fromJson(result.data);
      setState(() {
      imageList.clear();
      urlDownloadList.clear();
      md5UrlDownloadList.clear();
      for (int i = 0;
      i < list.coverImageUrlList.length;
      i++) {
      md5UrlDownloadList.add(list.videoUrlList[i]);
      urlDownloadList.add(list.videoUrlList[i]);
      imageList.add(list.coverImageUrlList[i]);
      }

      // md5UrlDownloadList.add(singl);
      // urlDownloadList.add(single.videoUrl!);
      // imageList.add(single.coverImageUrl!);
      });
      },
      child: Text("下载数据"))
   */

  TextEditingController downLoadUrlController = TextEditingController();

  var shortVideoDownloadType = ["单个", "多个", "用户信息"];
  List<DropdownMenuItem<String>> shortVideoDownloadDdmi = [];
  var currentShortVideoDownloadType = '';

  //初始化短视频下载类型
  _initShortVideoDownloadType() {
    for (var element in shortVideoDownloadType) {
      shortVideoDownloadDdmi.add(DropdownMenuItem(
          value: element,
          child: Text(
            element,
            // style: _dropDownTextStyle(),
          )));
    }
    currentShortVideoDownloadType = shortVideoDownloadType[0];
    return shortVideoDownloadDdmi;
  }

  TextEditingController cacheController = TextEditingController();
  TextEditingController urlController = TextEditingController();

  void _showSettingDialog(BuildContext context) {
    cacheController.text = SpUtil.getCachePath() ?? '';
    urlController.text = SpUtil.getBaseUrl() ?? '';
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return UnconstrainedBox(
            //在Dialog的外层添加一层UnconstrainedBox
            //constrainedAxis: Axis.vertical,
            child: SizedBox(
              //再用SizeBox指定宽度new Dialog(
              child: AlertDialog(
                scrollable: true,
                actions: [
                  TextButton(
                    child: const Text('取消'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('确定'),
                    onPressed: () {
                      if (urlController.text.isNotEmpty) {
                        SpUtil.updateBaseUrl(urlController.text);
                      }
                      if (cacheController.text.isNotEmpty) {
                        SpUtil.updateCachePath(cacheController.text);
                      }
                      Navigator.of(context).pop();
                    },
                  )
                ],
                title: const Text("设置", style: TextStyle(fontSize: 20)),
                content: Center(
                    child: SizedBox(
                        width: 0.5 * ScreenUtils.width,
                        height: 0.4 * ScreenUtils.height,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                TextButton(
                                    onPressed: () async {
                                      String? selectedDirectory =
                                          await FilePicker.platform
                                              .getDirectoryPath();
                                      if (selectedDirectory == null) {
                                      } else {
                                        cacheController.text =
                                            selectedDirectory;
                                      }
                                    },
                                    child: const Text("手动选择存储目录")),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: TextField(
                                  controller: cacheController,
                                  maxLines: 1,
                                  enableInteractiveSelection: true,
                                  decoration: const InputDecoration(
                                    labelText: 'CACHE_PATH',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.pink,
                                      ),
                                    ),
                                  ),
                                )),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: TextField(
                                  controller: urlController,
                                  maxLines: 1,
                                  enableInteractiveSelection: true,
                                  decoration: const InputDecoration(
                                    enabled: true,
                                    labelText: 'BASE_URL',
                                    // 长按输入的文本, 设置是否显示剪切，复制，粘贴按钮, 默认是显示的
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.pink,
                                      ),
                                    ),
                                  ),
                                )),
                              ],
                            ),
                          ],
                        ))),
              ),
            ),
          );
        });
  }
}
