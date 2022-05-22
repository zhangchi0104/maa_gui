import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fui;
import 'package:get/get.dart';
import 'package:maa_gui/controllers/maa_controller.dart';
import 'package:maa_gui/dialogs/new_instance_dialog.dart';

class NavigationHeader extends StatelessWidget {
  const NavigationHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final addButton = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: fui.IconButton(
        icon: const Icon(fui.FluentIcons.add),
        onPressed: () {
          fui.showDialog(
            context: context,
            builder: (_) => NewInstanceDialog(),
          );
        },
      ),
    );
    final refreshButton = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: fui.IconButton(
        icon: const Icon(fui.FluentIcons.refresh),
        onPressed: () {},
      ),
    );
    const instanceSelector = Expanded(
      child: InstanceSelector(),
    );
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        refreshButton,
        instanceSelector,
        addButton,
      ],
    );
  }
}

class InstanceSelector extends StatefulWidget {
  const InstanceSelector({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _InstanceSelectorState();
  }
}

class _InstanceSelectorState extends State<InstanceSelector> {
  bool expanded = false;

  List<fui.ComboboxItem<String>> buildComboboxItems(List<String> instances) {
    return instances.isEmpty
        ? const [
            fui.ComboboxItem<String>(
              value: "当前无实例",
              child: Text("当前无实例"),
            )
          ]
        : instances
            .map(
              (v) => fui.ComboboxItem<String>(
                value: v,
                child: Text(v),
              ),
            )
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InstanceController>(
      builder: (controller) => fui.Combobox<String>(
        value: controller.instanceNames.isEmpty
            ? "当前无实例"
            : controller.currentInstance,
        isExpanded: expanded,
        onChanged: (v) => {controller.currentInstance = v!},
        items: buildComboboxItems(controller.instanceNames),
        onTap: () {
          setState(() {
            expanded = !expanded;
          });
        },
      ),
    );
  }
}
