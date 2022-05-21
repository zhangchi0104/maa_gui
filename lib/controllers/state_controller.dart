import 'package:get/get.dart';

class StateController extends GetxController {
  PaneState sidebar = PaneState();
}

class PaneState extends GetxController {
  String _currentIntsanceName = '';

  void setInstanceName(String newName) {
    _currentIntsanceName = newName;
    update();
  }

  String get currentInstanceName => _currentIntsanceName;
}
