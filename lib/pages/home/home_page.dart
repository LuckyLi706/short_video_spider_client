import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:short_video_spider_client/pages/mobile/download_page.dart';
import 'package:short_video_spider_client/utils/short_video_util.dart';
import 'package:short_video_spider_client/utils/sp_util.dart';
import 'package:short_video_spider_client/utils/widget_util.dart';

import '../../config/constants.dart';
import '../../model/douyin_list.dart';
import '../../model/douyin_single.dart';
import '../../utils/screen_util.dart';

var imageList = [];
var urlDownloadList = [];
var md5UrlDownloadList = [];

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() {
    return HomePageState();
  }
}

//获取当前的界面大小
_getWidthHeight(BuildContext context) {
  final size = MediaQuery.of(context).size;
  ScreenUtils.width = size.width;
  ScreenUtils.height = size.height;
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
    _getWidthHeight(context);
    return Scaffold(
        resizeToAvoidBottomInset: false,
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
          child: WidgetUtils.getListView(
              imageList, md5UrlDownloadList, urlDownloadList),
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
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                child: _getBehaviorWidget(),
              ),
            )),
      ]);
    }
  }

  final TextEditingController _logTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _maxCursorTextController =
      TextEditingController(text: "0");
  final TextEditingController _shareUrlTextController = TextEditingController();

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
          height: 10,
        ),
        Row(children: [
          Expanded(
              child: TextButton(
                  onPressed: () async {
                    String text = _shareUrlTextController.text;
                    if (Constants.BASE_URL.isEmpty) {
                      showLog("baseUrl不能为空，请先在设置里面去配置");
                      return;
                    }
                    if (_shareUrlTextController.text.isEmpty) {
                      showLog("url不能为空");
                      return;
                    }
                    if (currentShortVideoDownloadType ==
                        shortVideoDownloadType[0]) {
                      //单个视频
                      String url = ShortVideoUtil.getDouYinUrl(text);
                      if (url.isEmpty) {
                        showLog("解析URL失败，请重新复制");
                        return;
                      }
                      Response result = await dio
                          .get("${Constants.BASE_URL}/douyin/single?url=$url");
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
                          showLog("获取视频地址成功");
                        } else {
                          showLog("获取视频地址成功：${result.data.toString()}");
                        }
                      });
                    } else if (currentShortVideoDownloadType ==
                        shortVideoDownloadType[1]) {
                      if (_maxCursorTextController.text.isEmpty) {
                        showLog("max_cursor不能为空");
                        return;
                      }
                      String url = ShortVideoUtil.getDouYinUrl(text);
                      Response result = await dio.get(
                          "${Constants.BASE_URL}/douyin/list?url=$url&max_cursor=${_maxCursorTextController.text}");
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
                          showLog("获取视频地址成功,一共${urlDownloadList.length}个视频");
                        } else {
                          showLog("获取视频地址失败：${result.data.toString()}");
                        }
                      });
                    }
                  },
                  child: const Text("获取下载地址"))),
          Expanded(
              child: TextButton(
                  onPressed: () async {
                    if (Constants.CACHE_PATH.isEmpty) {
                      showLog("缓存地址为空，请先去设置进行配置");
                      return;
                    }
                    if (urlDownloadList.isEmpty) {
                      showLog("请先获取视频地址");
                      return;
                    }
                    if (ScreenUtils.height > ScreenUtils.width) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return DownloadPage(
                            imageList, urlDownloadList, md5UrlDownloadList);
                      }));
                      return;
                    }
                    for (int i = 0; i < urlDownloadList.length; i++) {
                      String end = urlDownloadList[i].toString().endsWith("mp3")
                          ? "mp3"
                          : "mp4";
                      print(end);
                      String filePath =
                          "${Constants.CACHE_PATH + Platform.pathSeparator + md5UrlDownloadList[i]}.$end";
                      if (File(filePath).existsSync()) {
                        showLog(
                            "一共${urlDownloadList.length}个视频：第${i + 1}个视频已存在,跳过");
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
        Expanded(
            child:
                WidgetUtils.getLogWidget(_scrollController, _logTextController))
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
      showLogText = "";
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

  TextEditingController downLoadUrlController = TextEditingController();

  var shortVideoDownloadType = ["单个", "多个"];
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

  void _showSettingDialog(BuildContext context) async {
    cacheController.text = await SpUtil.getCachePath() ?? '';
    urlController.text = await SpUtil.getBaseUrl() ?? '';
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
