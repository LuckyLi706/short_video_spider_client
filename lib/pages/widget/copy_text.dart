import 'package:flutter/material.dart';

class CopyText extends SelectableText {
  const CopyText(
    String text, {
    Key? key,
  }) : super(text,
            key: key,
            toolbarOptions: const ToolbarOptions(
                copy: true, paste: false, cut: false, selectAll: true));
}
