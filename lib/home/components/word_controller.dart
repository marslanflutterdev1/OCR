import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:image/image.dart' as img_pkg;
import 'dart:convert';
import 'package:ai_ocr/history/history_controller.dart';
import 'package:ai_ocr/local.dart';

class WordController extends GetxController {
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set setIsLoading(bool value) => _isLoading.value = value;

  final RxList<File> docImages = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      docImages.addAll(pickedFiles.map((e) => File(e.path)));
    }
  }

  void removeImage(File file) => docImages.remove(file);
  void clearAll() => docImages.clear();

  /// Build a very small .docx (Office Open XML) document that contains each image on its own paragraph.
  /// This implementation creates the minimum set of files: [content types], _rels/.rels, word/document.xml,
  /// word/_rels/document.xml.rels and places images under word/media/. It does not add complex relationships or
  /// styling — it's intended for simple image-to-docx conversion.
  Future<void> createDocx() async {
    if (docImages.isEmpty) {
      Get.snackbar('Error', 'Please select at least one image',
          backgroundColor: Colors.black, colorText: Colors.white);
      return;
    }

    setIsLoading = true;
    try {
      final archive = Archive();

      final contentTypes = '''<?xml version="1.0" encoding="UTF-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Default Extension="jpeg" ContentType="image/jpeg"/>
  <Default Extension="jpg" ContentType="image/jpeg"/>
  <Default Extension="png" ContentType="image/png"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
</Types>''';
      archive.addFile(ArchiveFile('[Content_Types].xml', contentTypes.length,
          Uint8List.fromList(contentTypes.codeUnits)));

      // _rels/.rels
      final rels = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="/word/document.xml"/>
</Relationships>''';
      archive.addFile(ArchiveFile(
          '_rels/.rels', rels.length, Uint8List.fromList(rels.codeUnits)));

      final bufferRels = StringBuffer();
      bufferRels
          .writeln('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
      bufferRels.writeln(
          '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">');

      final bufferDoc = StringBuffer();
      bufferDoc
          .writeln('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
      bufferDoc.writeln(
          '<w:document xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"');
      bufferDoc.writeln(
          ' xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"');
      bufferDoc.writeln(' xmlns:o="urn:schemas-microsoft-com:office:office"');
      bufferDoc.writeln(
          ' xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"');
      bufferDoc.writeln(
          ' xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"');
      bufferDoc.writeln(' xmlns:v="urn:schemas-microsoft-com:vml"');
      bufferDoc.writeln(
          ' xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"');
      bufferDoc.writeln(
          ' xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"');
      bufferDoc.writeln(' xmlns:w10="urn:schemas-microsoft-com:office:word"');
      bufferDoc.writeln(
          ' xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"');
      bufferDoc.writeln(
          ' xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"');
      bufferDoc.writeln(
          ' xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"');
      bufferDoc.writeln(
          ' xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk"');
      bufferDoc.writeln(
          ' xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"');
      bufferDoc.writeln(
          ' xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape">');
      bufferDoc.writeln('<w:body>');

      for (var i = 0; i < docImages.length; i++) {
        final file = docImages[i];
        final bytes = await file.readAsBytes();
        final ext = file.path.split('.').last.toLowerCase();
        final name = 'image$i.$ext';
        final mediaPath = 'word/media/$name';

        // add image file into archive
        archive.addFile(ArchiveFile(mediaPath, bytes.length, bytes));

        // add rel entry
        bufferRels.writeln(
            '  <Relationship Id="rId${i + 1}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/$name"/>');

        // decode image to get dimensions
        int pxW = 600;
        int pxH = 400;
        try {
          final decoded = img_pkg.decodeImage(bytes);
          if (decoded != null) {
            pxW = decoded.width;
            pxH = decoded.height;
          }
        } catch (_) {}

        const int EMU_PER_INCH = 914400;
        const int DEFAULT_DPI = 96;
        final int emuW = ((pxW * EMU_PER_INCH) / DEFAULT_DPI).round();
        final int emuH = ((pxH * EMU_PER_INCH) / DEFAULT_DPI).round();

        bufferDoc.writeln('<w:p>');
        bufferDoc.writeln('<w:r>');
        bufferDoc.writeln('<w:drawing>');
        bufferDoc
            .writeln('<wp:inline distT="0" distB="0" distL="0" distR="0">');
        bufferDoc.writeln('<wp:extent cx="$emuW" cy="$emuH"/>');
        bufferDoc.writeln('<wp:docPr id="${i + 1}" name="Picture ${i + 1}"/>');
        bufferDoc.writeln('<wp:cNvGraphicFramePr>');
        bufferDoc.writeln(
            '<a:graphicFrameLocks xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" noChangeAspect="1"/>');
        bufferDoc.writeln('</wp:cNvGraphicFramePr>');
        bufferDoc.writeln(
            '<a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">');
        bufferDoc.writeln(
            '<a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">');
        bufferDoc.writeln(
            '<pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">');
        bufferDoc.writeln('<pic:nvPicPr>');
        bufferDoc.writeln('<pic:cNvPr id="${i + 1}" name="$name"/>');
        bufferDoc.writeln('<pic:cNvPicPr/>');
        bufferDoc.writeln('</pic:nvPicPr>');
        bufferDoc.writeln('<pic:blipFill>');
        bufferDoc.writeln('<a:blip r:embed="rId${i + 1}"/>');
        bufferDoc.writeln('<a:stretch>');
        bufferDoc.writeln('<a:fillRect/>');
        bufferDoc.writeln('</a:stretch>');
        bufferDoc.writeln('</pic:blipFill>');
        bufferDoc.writeln('<pic:spPr>');
        bufferDoc.writeln('<a:xfrm>');
        bufferDoc.writeln('<a:off x="0" y="0"/>');
        bufferDoc.writeln('<a:ext cx="$emuW" cy="$emuH"/>');
        bufferDoc.writeln('</a:xfrm>');
        bufferDoc.writeln('<a:prstGeom prst="rect">');
        bufferDoc.writeln('<a:avLst/>');
        bufferDoc.writeln('</a:prstGeom>');
        bufferDoc.writeln('</pic:spPr>');
        bufferDoc.writeln('</pic:pic>');
        bufferDoc.writeln('</a:graphicData>');
        bufferDoc.writeln('</a:graphic>');
        bufferDoc.writeln('</wp:inline>');
        bufferDoc.writeln('</w:drawing>');
        bufferDoc.writeln('</w:r>');
        bufferDoc.writeln('</w:p>');
      }

      bufferDoc.writeln('<w:sectPr>');
      bufferDoc.writeln('<w:pgSz w:w="11906" w:h="16838"/>');
      bufferDoc.writeln('</w:sectPr>');
      bufferDoc.writeln('</w:body>');
      bufferDoc.writeln('</w:document>');

      bufferRels.writeln('</Relationships>');

      archive.addFile(ArchiveFile(
          'word/_rels/document.xml.rels',
          bufferRels.length,
          Uint8List.fromList(bufferRels.toString().codeUnits)));
      archive.addFile(ArchiveFile('word/document.xml', bufferDoc.length,
          Uint8List.fromList(bufferDoc.toString().codeUnits)));

      // write archive to file
      final outputDir = await getApplicationDocumentsDirectory();
      final outFile = File(
          '${outputDir.path}/converted_${DateTime.now().millisecondsSinceEpoch}.docx');
      final encoder = ZipEncoder();
      final bytes = encoder.encode(archive)!;
      await outFile.writeAsBytes(bytes);

      // persist history to local storage (always) and update controller if present
      final entry = {
        'path': outFile.path,
        'datetime': DateTime.now().toIso8601String()
      };
      try {
        await MyLocalStorage.init();
        final existing = await MyLocalStorage.getData('docx_history');
        List<Map<String, dynamic>> list = [];
        if (existing is String && existing.isNotEmpty) {
          try {
            final dec = jsonDecode(existing);
            if (dec is List) list = List<Map<String, dynamic>>.from(dec);
          } catch (_) {}
        }
        list.insert(0, entry);
        await MyLocalStorage.setData('docx_history', jsonEncode(list));
      } catch (_) {}

      try {
        final hc = Get.find<HistoryController>();
        await hc.addHistoryItem('docx', entry);
      } catch (_) {}

      setIsLoading = false;
      Get.snackbar('Success', 'DOCX saved successfully!',
          backgroundColor: Colors.black, colorText: Colors.white);
      await OpenFilex.open(outFile.path);
    } catch (e) {
      setIsLoading = false;
      Get.snackbar('Error', 'Failed to create DOCX: $e',
          backgroundColor: Colors.black, colorText: Colors.white);
    }
  }
}
