import 'package:ai_ocr/home/components/upload_file_screen.dart';
import 'package:ai_ocr/wrapper/nav_bar_screen.dart';
import 'package:get/get.dart';
import '../routes/route_names.dart';
import '../wrapper/splash_screen.dart';


class Routes {

  static routes() => [
    GetPage(
      name: RouteNames.splashScreen,
      page: () => SplashScreen() ,
      transitionDuration: Duration(milliseconds: 250),
      transition: Transition.leftToRightWithFade ,
    ) ,
    GetPage(
      name: RouteNames.navBarScreen,
      page: () => NavBarScreen() ,
      transitionDuration: Duration(milliseconds: 250),
      transition: Transition.leftToRightWithFade ,
    ) ,
    GetPage(
      name: RouteNames.uploadFileScreen,
      page: () => UploadFileScreen() ,
      transitionDuration: Duration(milliseconds: 250),
      transition: Transition.leftToRightWithFade ,
    ) ,
  ];

}
