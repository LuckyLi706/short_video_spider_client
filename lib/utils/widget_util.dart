import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../pages/widget/copy_text.dart';

class WidgetUtils {
  static Widget getListView(
      var imageList, var md5UrlDownloadList, var urlDownloadList) {
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
              Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text("第${index + 1}个视频")),
              Container(
                height: 200,
                margin: const EdgeInsets.all(10),
                child: Image.network(
                  imageList[index],
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: CopyText(
                    "存储位置：${Constants.CACHE_PATH}${Platform.pathSeparator}${md5UrlDownloadList[index]}.${urlDownloadList[index].toString().endsWith("mp3") ? "mp3" : "mp4"}"),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: CopyText("文件真实地址：${urlDownloadList[index]}")),
            ],
          ),
        );
      },
      //分割器构造器
    );
  }

  static Widget getLogWidget(var scrollController, var logTextController) {
    return Stack(
      alignment: Alignment.topLeft,
      //fit: StackFit.expand, //未定位widget占满Stack整个空间
      children: <Widget>[
        Positioned(
          top: 20.0,
          bottom: 0,
          left: 0,
          right: 0,
          child: TextField(
            scrollController: scrollController,
            controller: logTextController,
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
    );
  }
}
