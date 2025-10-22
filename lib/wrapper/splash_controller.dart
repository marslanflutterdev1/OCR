import '../routes/route_names.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  Future<void> move(context) async {
    Future.delayed(Duration(seconds: 3), () {
      Get.toNamed(RouteNames.navBarScreen);
    });
  }
}
