import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fui;
import 'package:maa_core/maa_core.dart';
import 'package:maa_gui/controllers/maa_controller.dart';
import 'package:maa_gui/controllers/state_controller.dart';
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
    Get.put(InstanceController(p.join(p.current, 'runtime')));
    Get.put(StateController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return fui.FluentApp(
      title: "Maa Flutter",
      home: FutureBuilder<void>(future: Future(() async {
        final InstanceController controller = Get.find();
        await controller.initialize();
        await controller.initMaaCore();
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

class MaaGuiRoot extends StatefulWidget {
  const MaaGuiRoot({Key? key}) : super(key: key);

  @override
  State<MaaGuiRoot> createState() => _MaaGuiRootState();
}

class _MaaGuiRootState extends State<MaaGuiRoot> {
  int activeIndex = 0;
  @override
  Widget build(BuildContext context) {
    final typography = fui.FluentTheme.of(context).typography;
    return fui.NavigationView(
      appBar: fui.NavigationAppBar(
        title: Text("MeoAssistant", style: typography.title),
        leading: const FlutterLogo(size: 50),
      ),
      pane: fui.NavigationPane(
          displayMode: fui.PaneDisplayMode.auto,
          selected: activeIndex,
          onChanged: (index) {
            setState(() {
              activeIndex = index;
            });
          },
          header: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: fui.IconButton(
                  icon: const Icon(fui.FluentIcons.refresh),
                  onPressed: () {},
                ),
              ),
              Expanded(
                child: fui.Combobox<String>(
                  value: "Looooooooooong",
                  items: const [
                    fui.ComboboxItem<String>(
                      child: Text('Looooooooooong'),
                      value: "Looooooooooong",
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: fui.IconButton(
                  icon: Icon(fui.FluentIcons.add),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          items: [
            fui.PaneItemSeparator(),
            fui.PaneItem(
              icon: const Icon(fui.FluentIcons.check_list),
              title: const Text('任务'),
            ),
            fui.PaneItem(
              icon: const Icon(fui.FluentIcons.check_list),
              title: const Text('抄作业'),
            ),
          ],
          footerItems: [
            fui.PaneItemSeparator(),
            fui.PaneItem(
              icon: const Icon(fui.FluentIcons.settings),
              title: const Text('Settings'),
            ),
          ]),
    );
  }
}
