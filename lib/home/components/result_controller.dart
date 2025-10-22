import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:ai_ocr/local.dart';

class ResultController extends GetxController {
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set setIsLoading(bool value) => _isLoading.value = value;
  final results = <OcrResult>[].obs;

  Future<void> processImages(List<File> imageList) async {
    if (imageList.isEmpty) return;
    results.clear();

    final textRecognizer = TextRecognizer();

    try {
      setIsLoading = true;
      final List<OcrResult> tempResults = [];

      final List<String> recognizedTexts = await Future.wait(
        imageList.map((image) async {
          final inputImage = InputImage.fromFile(image);
          final recognized = await textRecognizer.processImage(inputImage);
          return recognized.text.isNotEmpty
              ? recognized.text
              : 'No text found.';
        }),
      );

      for (int i = 0; i < imageList.length; i++) {
        tempResults.add(OcrResult(
          imageFile: imageList[i],
          text: recognizedTexts[i],
        ));
      }

      results.assignAll(tempResults);
      try {
        await MyLocalStorage.init();
        final stored = await MyLocalStorage.getData('image_history');
        List<dynamic> existing = [];
        if (stored is String && stored.isNotEmpty) {
          try {
            final decoded = jsonDecode(stored);
            if (decoded is List) existing = decoded;
          } catch (_) {
            existing = [];
          }
        }
        final now = DateTime.now().toIso8601String();
        final newEntries = tempResults
            .map((r) => {'path': r.imageFile.path, 'datetime': now})
            .toList();
        // Insert new entries at the front so latest images appear first in history
        if (newEntries.isNotEmpty) {
          existing.insertAll(0, newEntries);
        }
        await MyLocalStorage.setData('image_history', jsonEncode(existing));
      } catch (_) {}
    } catch (e) {
      Get.snackbar('Error', 'Failed to extract text: $e');
      setIsLoading = false;
    } finally {
      textRecognizer.close();
      setIsLoading = false;
    }
  }
}

class OcrResult {
  final File imageFile;
  final String text;

  OcrResult({
    required this.imageFile,
    required this.text,
  });
}
