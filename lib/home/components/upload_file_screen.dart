import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_ocr/home/home_controller.dart';
import '../../widgets/custom_button.dart';
import 'items_list.dart';
import 'result_screen.dart';

class UploadFileScreen extends StatelessWidget {
  UploadFileScreen({super.key});

  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'File Upload',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Column(
          children: [
            Obx(() {
              return Align(
                alignment: Alignment.topRight,
                child: Text(
                  "Upload ${controller.images.length} File",
                ),
              );
            }),
            const SizedBox(height: 5),
            Expanded(
              child: Obx(() {
                final images = controller.images;
                return GridView.builder(
                  itemCount: images.length + 1,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return GestureDetector(
                        onTap: () => _showPickDialog(context),
                        child: const DottedBorderCard(),
                      );
                    } else {
                      final image = images[index - 1];
                      return Obx(() {
                        final isSelected =
                            controller.selectedImages.contains(image);
                        return GestureDetector(
                          onTap: () {
                            controller.toggleImageSelection(image);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: isSelected
                                  ? Border.all(
                                      color: Colors.green,
                                      width: 3,
                                    )
                                  : Border.all(
                                      color: Colors.transparent,
                                      width: 3,
                                    ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(
                                    image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.error,
                                            color: Colors.red),
                                      );
                                    },
                                  ),
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: GestureDetector(
                                      onTap: () =>
                                          controller.removeImage(image),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close,
                                            color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      top: 5,
                                      left: 5,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check,
                                            color: Colors.white, size: 14),
                                      ),
                                    ),
                                  if (isSelected)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.2),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                    }
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            Obx(() {
              final hasSelectedImages = controller.selectedImages.isNotEmpty;
              return CustomButton(
                isLoading: controller.isLoading,
                text: "Submit ${controller.selectedImages.length} File",
                color:
                    hasSelectedImages ? Colors.deepPurpleAccent : Colors.grey,
                onPressed: () {
                  if (hasSelectedImages) {
                    _submitFiles(context);
                    Get.to(() => ResultScreen(imageList: controller.selectedImages));
                  } else {
                    _unsubmitFiles(context);
                  }
                },
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showPickDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade400,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDialogOption(
                index: 0,
                onTap: () {
                  Navigator.pop(context);
                  controller.pickFromCamera();
                },
              ),
              _buildDialogOption(
                index: 1,
                onTap: () {
                  Navigator.pop(context);
                  controller.pickFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialogOption({
    VoidCallback? onTap,
    required int index,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
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
    );
  }

  void _submitFiles(BuildContext context) {
    final selectedCount = controller.selectedImages.length;
    log('List of selected images: $selectedCount');
    Get.snackbar('Success', '$selectedCount files submitted successfully!',
    );

    // Optional: Clear selection after submit
    // controller.clearSelection();
  }

  void _unsubmitFiles(BuildContext context) {
    Get.snackbar('Select Image',
        'No files submitted!.\nPlease select at least one file.',
    );

    // Optional: Clear selection after submit
    // controller.clearSelection();
  }
}

class DottedBorderCard extends StatelessWidget {
  const DottedBorderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade400,
          style: BorderStyle.solid,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text("Add Image",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
