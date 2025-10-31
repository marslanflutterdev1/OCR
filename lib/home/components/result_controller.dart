import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:ai_ocr/local.dart';
import 'package:share_plus/share_plus.dart';

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
      await _saveToHistory(tempResults);
    } catch (e) {
      Get.snackbar('Error', 'Failed to extract text: $e');
    } finally {
      textRecognizer.close();
      setIsLoading = false;
    }
  }

  Future<void> _saveToHistory(List<OcrResult> tempResults) async {
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
      if (newEntries.isNotEmpty) {
        existing.insertAll(0, newEntries);
      }
      await MyLocalStorage.setData('image_history', jsonEncode(existing));
    } catch (_) {}
  }

  /// Copy given text to the clipboard and show a feedback snackbar.
  Future<void> copyText(String? text) async {
    final t = text ?? '';
    if (t
        .trim()
        .isEmpty) {
      Get.snackbar('Nothing to copy', 'The selected result contains no text.');
      return;
    }
    try {
      await Clipboard.setData(ClipboardData(text: t));
      Get.snackbar('Copied', 'Text copied to clipboard');
    } catch (e) {
      Get.snackbar('Error', 'Failed to copy text: $e');
    }
  }

  /// For download
  Future<String?> downloadText(OcrResult result) async {
    final t = result.text;
    if (t.trim().isEmpty) {
      Get.snackbar('Nothing to save', 'The selected result contains no text.');
      return null;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final String imageName = result.imageFile.path.split(Platform.pathSeparator).last;
      final String baseName = imageName.split('.').first;
      final String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = '${baseName}_$timeStamp.txt';
      final File tempFile = File('${tempDir.path}/$fileName');

      await tempFile.writeAsString(t);

      // Share both the image and text file
      await Share.shareXFiles(
        [
          XFile(result.imageFile.path),
          XFile(tempFile.path),
        ],
        text: 'OCR Extracted Text from $baseName',
      );

      Get.snackbar(
        'Share File',
        'Save file successfully!',
        duration: Duration(seconds: 3),
      );

      return tempFile.path;
    } catch (e) {
      Get.snackbar('Error', 'Failed to save: $e');
      return null;
    }
  }

  /// Share the provided text via platform share sheet.
  Future<void> shareText(String? text) async {
    final t = text ?? '';
    if (t
        .trim()
        .isEmpty) {
      Get.snackbar('Nothing to share', 'The selected result contains no text.');
      return;
    }
    try {
      await Share.share(t);
    } catch (e) {
      Get.snackbar('Error', 'Failed to share text: $e');
    }
  }

// Alternative share method using platform channels (if share_plus doesn't work)
// Future<void> shareText(String? text) async {
//   final t = text ?? '';
//   if (t.trim().isEmpty) {
//     Get.snackbar('Nothing to share', 'The selected result contains no text.');
//     return;
//   }
//   try {
//     const platform = MethodChannel('com.example.ai_ocr/share');
//     await platform.invokeMethod('shareText', {'text': t});
//   } on PlatformException catch (e) {
//     Get.snackbar('Error', 'Failed to share: ${e.message}');
//   } catch (e) {
//     Get.snackbar('Error', 'Failed to share text: $e');
//   }
// }

}


// This class represents the result of OCR extraction.
// Model
class OcrResult {
  final File imageFile;
  final String text;

  OcrResult({
    required this.imageFile,
    required this.text,
  });
}
