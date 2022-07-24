import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/constants.dart';
import '../../../utils/screen_util.dart';
import '../../../utils/sp_util.dart';

void showDownloadDialog(BuildContext context) {
  showDialog(
      barrierDismissible: false, //表示点击灰色背景的时候是否消失弹出框
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("下载"),
          content: const Text("当前正在下载，请等待下载完成。"),
          actions: <Widget>[
            TextButton(
              child: const Text("确定"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      });
}

Future<void> _launchUrl(Uri uri) async {
  if (!await launchUrl(uri)) {
    print("链接无法跳转");
  }
}

showInfoDialog(BuildContext context) {
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
                  child: const Text('确定'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
              title: const Text("关于", style: TextStyle(fontSize: 20)),
              content: SizedBox(
                  width: 0.5 * ScreenUtils.width,
                  height: 0.3 * ScreenUtils.height,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("当前版本：${Constants.APP_VERSION}"),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                              child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: '客户端地址： ',
                                  style: TextStyle(color: Colors.black),
                                ),
                                TextSpan(
                                  text:
                                      '\nhttps://github.com/LuckyLi706/short_video_spider_client',
                                  style: const TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      _launchUrl(Uri.parse(
                                          "https://github.com/LuckyLi706/short_video_spider_client"));
                                    },
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: '服务端地址： ',
                                  style: TextStyle(color: Colors.black),
                                ),
                                TextSpan(
                                  text:
                                      '\nhttps://github.com/LuckyLi706/ShortVideoSpider',
                                  style: const TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      _launchUrl(Uri.parse(
                                          "https://github.com/LuckyLi706/ShortVideoSpider"));
                                    },
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ],
                  )),
            ),
          ),
        );
      });
}

TextEditingController cacheController = TextEditingController();
TextEditingController urlController = TextEditingController();

void showSettingDialog(BuildContext context) async {
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
                      Constants.BASE_URL = urlController.text;
                    }
                    if (cacheController.text.isNotEmpty) {
                      SpUtil.updateCachePath(cacheController.text);
                      Constants.CACHE_PATH = cacheController.text;
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
                                    String? selectedDirectory = await FilePicker
                                        .platform
                                        .getDirectoryPath();
                                    if (selectedDirectory == null) {
                                    } else {
                                      cacheController.text = selectedDirectory;
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
