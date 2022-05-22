import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fui;
import 'package:get/get.dart';

class NewInstanceDialog extends StatefulWidget {
  const NewInstanceDialog({Key? key}) : super(key: key);

  @override
  State<NewInstanceDialog> createState() => _NewInstanceDialogState();
}

class _NewInstanceDialogState extends State<NewInstanceDialog> {
  @override
  Widget build(BuildContext context) {
    return fui.ContentDialog(
        title: Text("创建新实例"),
        content: Text("tests"),
        actions: [fui.Button(child: Text("OK"), onPressed: Get.back)]);
  }
}
