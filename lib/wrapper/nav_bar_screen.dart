import 'package:ai_ocr/history/history_screen.dart';
import 'package:ai_ocr/home/home_screen.dart';
import 'package:ai_ocr/setting/setting_screen.dart';
import 'package:ai_ocr/wrapper/nav_bar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavBarScreen extends StatefulWidget {
  const NavBarScreen({super.key});

  @override
  State<NavBarScreen> createState() => _NavBarScreenState();
}

class _NavBarScreenState extends State<NavBarScreen> {
  final controller = Get.put(NavBarController(), permanent: true);
  final List<Widget> _pages = [
    HomeScreen(),
    HistoryScreen(),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => _pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xff9FA8B3),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              // selectedItemColor: Color(0xff000000),
              // unselectedItemColor: Color(0xff9FA8B3),
              currentIndex: controller.currentIndex.value,
              onTap: (index) => controller.setCurrentIndex(index),
              elevation: 10,
              items: [
                BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Image.asset(
                        'assets/images/home_icon.png',
                        width: 24,
                        height: 24,
                        color: controller.currentIndex.value == 0
                            ? Color(0xff000000)
                            : Color(0xff9FA8B3),
                      ),
                    ),
                    label: ''),
                BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Image.asset(
                        'assets/images/histry_icon.png',
                        width: 24,
                        height: 24,
                        color: controller.currentIndex.value == 1
                            ? Color(0xff000000)
                            : Color(0xff9FA8B3),
                      ),
                    ),
                    label: ''),
                BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Image.asset(
                        'assets/images/setting_icon.png',
                        width: 24,
                        height: 24,
                        color: controller.currentIndex.value == 2
                            ? Color(0xff000000)
                            : Color(0xff9FA8B3),
                      ),
                    ),
                    label: ''),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
