import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:ai_ocr/history/history_controller.dart';
import 'package:ai_ocr/local.dart';

class PdfController extends GetxController {
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set setIsLoading(bool value) => _isLoading.value = value;

  final RxList<File> pdfImages = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  /// Pick multiple images
  Future<void> pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      pdfImages.addAll(pickedFiles.map((e) => File(e.path)));
    }
  }

  /// Generate PDF from selected images
  Future<void> createPdf() async {
    if (pdfImages.isEmpty) {
      Get.snackbar("Error", "Please select at least one image",
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: const Duration(seconds: 10));
      return;
    }

    setIsLoading = true;
    try {
      final pdf = pw.Document();

      for (var imageFile in pdfImages) {
        final image = pw.MemoryImage(await imageFile.readAsBytes());
        pdf.addPage(
          pw.Page(build: (pw.Context context) {
            return pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain));
          }),
        );
      }

      final outputDir = await getApplicationDocumentsDirectory();
      final file = File(
        "${outputDir.path}/converted_${DateTime.now().millisecondsSinceEpoch}.pdf",
      );
      await file.writeAsBytes(await pdf.save());

      // persist history to local storage (always) and update controller if present
      final entry = {
        'path': file.path,
        'datetime': DateTime.now().toIso8601String()
      };
      try {
        // append to stored list
        await MyLocalStorage.init();
        final existing = await MyLocalStorage.getData('pdf_history');
        List<Map<String, dynamic>> list = [];
        if (existing is String && existing.isNotEmpty) {
          try {
            final dec = jsonDecode(existing);
            if (dec is List) list = List<Map<String, dynamic>>.from(dec);
          } catch (_) {}
        }
        list.insert(0, entry);
        await MyLocalStorage.setData('pdf_history', jsonEncode(list));
      } catch (_) {}

      try {
        final hc = Get.find<HistoryController>();
        await hc.addHistoryItem('pdf', entry);
      } catch (_) {}

      setIsLoading = false;
      Get.snackbar("Success", "PDF saved successfully!",
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: const Duration(seconds: 10));
      await OpenFilex.open(file.path);
    } catch (e) {
      setIsLoading = false;
      Get.snackbar("Error", "Failed to create PDF: $e",
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: const Duration(seconds: 10));
    }
  }

  void removeImage(File index) {
    pdfImages.remove(index);
  }

  void clearAll() {
    pdfImages.clear();
  }
}
