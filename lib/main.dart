import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fui;
import 'package:maa_gui/controllers/maa_controller.dart';
import 'package:path/path.dart' as p;
import 'package:get/get.dart';

import 'components/navigation_header.dart';
import 'package:desktop_window/desktop_window.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DesktopWindow.setMinWindowSize(Size(800, 600));
  runApp(const GetMaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final hasError = false;
  @override
  void initState() {
    Get.put(InstanceManagerService(p.join(p.current, 'runtime')));
    super.initState();
  }

  @override
  void dispose() {
    final controller = Get.find<InstanceManagerService>();
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return fui.FluentApp(
      title: "Maa Flutter",
      home: FutureBuilder<void>(future: Future(() async {
        final InstanceManagerService controller = Get.find();
        await controller.initialize();
        await controller.initMaaCore();
      }), builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('has error');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.snackbar(
              "Error",
              "核心资源加载失败",
              duration: Duration(seconds: 3),
              icon: const Icon(Icons.error),
              isDismissible: true,
              margin: EdgeInsets.all(8),
            );
          });
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return const MaaGuiRoot();
        }
        return const LoadingScreen();
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

class MaaGuiRoot extends StatefulWidget {
  const MaaGuiRoot({Key? key}) : super(key: key);

  @override
  State<MaaGuiRoot> createState() => _MaaGuiRootState();
}

class _MaaGuiRootState extends State<MaaGuiRoot> {
  int activeIndex = 0;
  List<fui.NavigationPaneItem> get paneItems => [
        fui.PaneItemSeparator(),
        fui.PaneItem(
          icon: const Icon(fui.FluentIcons.check_list),
          title: const Text('一键长草'),
        ),
        fui.PaneItem(
          icon: const Icon(fui.FluentIcons.check_list),
          title: const Text('抄作业'),
        ),
        fui.PaneItem(
          icon: const Icon(fui.FluentIcons.check_list),
          title: const Text('公共招募'),
        ),
      ];

  fui.NavigationPane get navigationPane => fui.NavigationPane(
        displayMode: fui.PaneDisplayMode.auto,
        selected: activeIndex,
        onChanged: (index) {
          setState(() {
            activeIndex = index;
          });
        },
        header: const NavigationHeader(),
        items: paneItems,
        footerItems: [
          fui.PaneItemSeparator(),
          fui.PaneItem(
            icon: const Icon(fui.FluentIcons.settings),
            title: const Text('设置'),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final typography = fui.FluentTheme.of(context).typography;
    return fui.NavigationView(
      appBar: fui.NavigationAppBar(
        title: Text("MeoAssistant", style: typography.title),
        leading: const FlutterLogo(size: 50),
      ),
      pane: navigationPane,
    );
  }
}
