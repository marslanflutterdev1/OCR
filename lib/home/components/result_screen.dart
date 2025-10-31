import 'dart:developer';
import 'dart:io';
import 'package:ai_ocr/home/components/result_controller.dart';
import 'package:ai_ocr/widgets/size_format.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResultScreen extends StatefulWidget {
  final List<File>? imageList;
  const ResultScreen({super.key, this.imageList});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {

  final ResultController controller = Get.put(ResultController(), permanent: true);

  @override
  void initState() {
    super.initState();
    if (widget.imageList != null) {
      controller.processImages(widget.imageList!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Result',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple,
              ));
        }
        if (controller.results.isEmpty) {
          return const Center(child: Text('No results found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: controller.results.length,
          itemBuilder: (BuildContext context, int index) {
            final result = controller.results[index];
            int fileSizeInBytes = result.imageFile.lengthSync();
            String fileSize = fileSizeInBytes.readableFileSize();
            log('File size: $fileSize');

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.deepPurple, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        result.imageFile,
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                      ),
                    ),
                    title: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        result.imageFile.path.split('/').last,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey.shade800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    subtitle: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: (controller.isLoading == true ||
                          result.text.trim().isEmpty)
                          ? const LinearProgressIndicator(
                        color: Colors.deepPurple,
                        minHeight: 3,
                      )
                          : Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          fileSize,
                          textAlign: TextAlign.start,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!(controller.isLoading == true ||
                      result.text.trim().isEmpty))
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Text(result.text, style: textTheme.bodyMedium),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () => controller.copyText(result.text),
                          icon: Image.asset('assets/images/copy_icon.png', height: 24, width: 24,
                          )),
                      IconButton(
                          onPressed: () => controller.downloadText(result),
                          icon: Image.asset('assets/images/download_icon.png',
                              height: 24, width: 24)),
                      IconButton(
                          onPressed: () => controller.shareText(result.text),
                          icon: Image.asset('assets/images/share_icon.png',
                              height: 24, width: 24))
                    ],
                  ),
                  SizedBox(height: 5),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}