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
        title: const Text("创建新实例"),
        content: const NewInstanceFormBody(),
        actions: [fui.Button(onPressed: Get.back, child: const Text("OK"))]);
  }
}

class NewInstanceFormBody extends StatefulWidget {
  const NewInstanceFormBody({Key? key}) : super(key: key);

  @override
  State<NewInstanceFormBody> createState() => _NewInstanceFormBodyState();
}

class _NewInstanceFormBodyState extends State<NewInstanceFormBody> {
  final adbController = TextEditingController();
  final addrController = TextEditingController();
  final config = 'General';
  @override
  void dispose() {
    adbController.dispose();
    addrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: fui.TextBox(
            controller: adbController,
            header: 'ADB路径',
            placeholder: 'adb',
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: fui.TextBox(
                  controller: addrController,
                  header: '地址',
                  placeholder: 'localhost:8888',
                ),
              ),
            ),
             Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: fui.TextBox(
                  controller: addrController,
                  header: '地址',
                  placeholder: 'localhost:8888',
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
