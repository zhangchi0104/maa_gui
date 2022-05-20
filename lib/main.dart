import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fui;
import 'package:maa_core/maa_core.dart';
import 'package:maa_gui/maa_controller.dart';
import 'package:path/path.dart' as p;
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

final routes = {
  "/": (context) => const MaaGuiRoot(),
};

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    Get.put(MaaController(p.join(p.current, 'runtime')));
    super.initState(); 
  }
  
  @override
  Widget build(BuildContext context) {
    return fui.FluentApp(
      title: "Maa Flutter",
      home: FutureBuilder<void>(future: Future(() async {
        final MaaController controller = Get.find();
        await controller.initialize();
        await controller.initMaaCore();
        await controller.createInstance(
            adb: 'adb', address: 'invalid-address', callback: print, alias: 'test');
        print(await controller.getAllInstanceNames());
      }), builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const MaaGuiRoot();
        } else {
          return const LoadingScreen();
        }
      }),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const fui.NavigationView(
      content: SizedBox.expand(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class MaaGuiRoot extends StatelessWidget {
  const MaaGuiRoot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return fui.NavigationView(
      pane: fui.NavigationPane(
        displayMode: fui.PaneDisplayMode.auto,
        header: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text("MeoAssistantArknights"),
        ),
      ),
    );
  }
}
