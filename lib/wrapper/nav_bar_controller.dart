import 'package:get/get.dart';

class NavBarController extends GetxController {
  var currentIndex = 0.obs;

  void setCurrentIndex(int value) {
    currentIndex.value = value;
  }
}
