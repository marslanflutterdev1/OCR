import 'package:ai_ocr/home/components/items_list.dart';
import 'package:ai_ocr/home/components/pdf_controller.dart';
import 'package:ai_ocr/home/components/word_controller.dart';
import 'package:ai_ocr/home/components/word_screen.dart';
import 'package:ai_ocr/home/home_controller.dart';
import 'package:ai_ocr/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'components/pdf_screen.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.put(HomeController(), permanent: true);
  final PdfController pdfController = Get.put(PdfController(), permanent: true);
  final WordController wordController =
      Get.put(WordController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 30),
              width: double.infinity,
              height: 210,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/banner.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: GridView.count(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 1.2,
                children: List.generate(itemsList.length, (index) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      if (index == 0) {
                        await controller.pickFromCamera().then((v) {
                          if (controller.pickedImage.value != null) {
                            Get.toNamed(RouteNames.uploadFileScreen);
                          }
                        });
                      }
                      if (index == 1) {
                        await controller.pickFromGallery().then((v) {
                          if (controller.pickedImage.value != null) {
                            Get.toNamed(RouteNames.uploadFileScreen);
                          }
                        });
                      }
                      if (index == 2) {
                        await wordController.pickImages();
                        if (wordController.docImages.isNotEmpty) {
                          Get.to(() => const WordScreen());
                        }
                      }

                      if (index == 3) {
                        await pdfController.pickImages();
                        if (pdfController.pdfImages.isNotEmpty) {
                          Get.to(() => PdfScreen());
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: itemsList[index].iconBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Image.asset(itemsList[index].icon!),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            itemsList[index].title ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
