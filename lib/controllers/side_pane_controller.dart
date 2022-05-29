import 'package:get/get.dart';
import 'package:maa_gui/controllers/maa_controller.dart';



class SidePaneController extends GetxController {
  final selecedIndex = 0.obs;
  final currentInstance = ''.obs;
  List<String> get instanceNames =>
      Get.find<InstanceManagerService>().instanceNames;
}
