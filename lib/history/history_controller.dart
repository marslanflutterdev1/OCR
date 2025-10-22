import 'package:get/get.dart';
import 'package:ai_ocr/local.dart';
import 'dart:convert';

class HistoryController extends GetxController {
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set setIsLoading(bool value) => _isLoading.value = value;

  // Three separate history lists
  var imageHistory = <Map<String, dynamic>>[].obs;
  var pdfHistory = <Map<String, dynamic>>[].obs;
  var docHistory = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHistories();
  }

  /// Load all three histories from local storage
  Future<void> loadHistories() async {
    await MyLocalStorage.init();
    setIsLoading = true;

    Future<List<Map<String, dynamic>>> _loadList(String key) async {
      try {
        final data = await MyLocalStorage.getData(key);
        if (data is String && data.isNotEmpty) {
          final decoded = jsonDecode(data);
          if (decoded is List) {
            final list = List<Map<String, dynamic>>.from(decoded);
            list.sort((a, b) {
              try {
                final da = DateTime.tryParse(a['datetime'] ?? '');
                final db = DateTime.tryParse(b['datetime'] ?? '');
                if (da != null && db != null) return db.compareTo(da);
              } catch (_) {}
              return 0;
            });
            return list;
          }
        }
      } catch (_) {}
      return <Map<String, dynamic>>[];
    }

    imageHistory.value = await _loadList('image_history');
    pdfHistory.value = await _loadList('pdf_history');
    docHistory.value = await _loadList('docx_history');

    setIsLoading = false;
  }

  /// Add an entry to a specific history and persist it.
  Future<void> addHistoryItem(String type, Map<String, dynamic> item) async {
    List<Map<String, dynamic>> list;
    String key;
    if (type == 'pdf') {
      list = List.from(pdfHistory);
      key = 'pdf_history';
    } else if (type == 'docx') {
      list = List.from(docHistory);
      key = 'docx_history';
    } else {
      list = List.from(imageHistory);
      key = 'image_history';
    }

    list.insert(0, item);
    await MyLocalStorage.setData(key, jsonEncode(list));
    if (type == 'pdf') {
      pdfHistory.value = list;
    } else if (type == 'docx') {
      docHistory.value = list;
    } else {
      imageHistory.value = list;
    }
  }

  /// Remove item by type and index
  Future<void> removeHistoryItem(String type, int index) async {
    if (index < 0) return;
    if (type == 'pdf') {
      if (index >= pdfHistory.length) return;
      pdfHistory.removeAt(index);
      await MyLocalStorage.setData('pdf_history', jsonEncode(pdfHistory));
    } else if (type == 'docx') {
      if (index >= docHistory.length) return;
      docHistory.removeAt(index);
      await MyLocalStorage.setData('docx_history', jsonEncode(docHistory));
    } else {
      if (index >= imageHistory.length) return;
      imageHistory.removeAt(index);
      await MyLocalStorage.setData('image_history', jsonEncode(imageHistory));
    }
  }

  /// Helper to expose list by type
  List<Map<String, dynamic>> getListByType(String type) {
    if (type == 'pdf') return pdfHistory;
    if (type == 'docx') return docHistory;
    return imageHistory;
  }

  /// Legacy helper if needed
  Future<void> loadImageHistory() async {
    await loadHistories();
  }
}
