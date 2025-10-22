import 'dart:developer';
import 'dart:io';
// flutter material not required in controller
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/crop_image.dart';

class HomeController extends GetxController {
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set setIsLoading(bool value) => _isLoading.value = value;

  final Rx<File?> pickedImage = Rx<File?>(null);
  final RxList<File> images = <File>[].obs;
  final RxList<File> selectedImages = <File>[].obs;

  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  Future<void> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final croppedFile = await cropImage(imageFile: File(image.path));
      if (croppedFile != null) {
        pickedImage.value = croppedFile;
        images.add(croppedFile);
      }
    }
  }

  /// Pick image from camera
  Future<void> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final croppedFile = await cropImage(imageFile: File(image.path));
      if (croppedFile != null) {
        pickedImage.value = croppedFile;
        images.add(croppedFile);
      }
    }
  }

  /// Remove a single image
  void removeImage(File image) {
    images.remove(image);
  }

  /// Clear all images
  void clearAllImages() {
    images.clear();
    pickedImage.value = null;
  }

  void toggleImageSelection(File image) {
    try {
      setIsLoading = true;
      if (selectedImages.contains(image)) {
        selectedImages.remove(image);
      } else {
        if (selectedImages.length < 5) {
          selectedImages.add(image);
        } else {
          Get.snackbar(
            'Limit Reached',
            'You can only select up to 5 images',
            snackPosition: SnackPosition.TOP,
          );
        }
      }
      setIsLoading = false;
    } catch (e, s) {
      log(e.toString(), stackTrace: s);
      setIsLoading = false;
    }
  }

  void clearSelection() {
    selectedImages.clear();
  }

  void clearAll() {
    images.clear();
    selectedImages.clear();
    pickedImage.value = null;
  }
}
