import 'dart:io';
import 'dart:developer';
import 'package:ai_ocr/widgets/date_time_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_ocr/history/history_controller.dart';
import 'package:open_filex/open_filex.dart';
import '../widgets/drop_down_menu_fb1.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  final HistoryController controller =
      Get.put(HistoryController(), permanent: true);
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    controller.loadImageHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildList(String type) {
    return Obx(() {
      if (controller.isLoading) {
        return const Center(
            child: CircularProgressIndicator(
          color: Colors.deepPurple,
        ));
      }

      final list = controller.getListByType(type);
      if (list.isEmpty) {
        Future.delayed(Duration(seconds: 3),(){
          controller.loadImageHistory();
          CircularProgressIndicator(color: Colors.deepPurple);
        });
        return const Center(child: Text('No history found.'));
      }

      return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          final path = item['path'] ?? '';
          final datetimeStr = item['datetime'] ?? '';

          log('path: $path, datetime: $datetimeStr');
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              try {
                final list = controller.getListByType(type);
                final item = list[index];
                final path = item['path'] ?? '';
                if (path.isNotEmpty && File(path).existsSync()) {
                  await OpenFilex.open(path);
                } else {
                  Get.snackbar('', 'File not found');
                }
              } catch (e) {
                log('Error opening file: $e');
                Get.snackbar('', 'Error opening file');

              }
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.grey, width: 1),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 10, top: 10, bottom: 10, right: 0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: type == 'pdf' || type == 'docx'
                          ? Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey.shade100,
                              alignment: Alignment.center,
                              child: type == 'pdf'
                                  ? const Icon(Icons.picture_as_pdf_rounded,
                                      color: Colors.deepPurple, size: 28)
                                  : const Icon(Icons.description_rounded,
                                      color: Colors.deepPurple, size: 26),
                            )
                          : Image.file(
                              File(path),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            path.split('/').last,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            DateTimeUtils.formatTimestamp(datetimeStr),
                            style: const TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    DropDownMenuFb1(type: type, index: index),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.deepPurple,
          labelColor: Colors.black,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Images'),
            Tab(text: 'PDF'),
            Tab(text: 'Docx'),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList('image'),
          _buildList('pdf'),
          _buildList('docx'),
        ],
      ),
    );
  }
}
