import 'dart:io';
import 'package:ai_ocr/history/history_controller.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DropDownMenuFb1 extends StatefulWidget {
  final Color color;
  final Widget icon;
  final int? index;
  final String type;
  const DropDownMenuFb1(
      {this.color = Colors.white,
        this.icon = const Icon(Icons.more_vert),
        this.index,
  this.type = 'image',
        super.key});

  @override
  State<DropDownMenuFb1> createState() => _DropDownMenuFb1State();
}

class _DropDownMenuFb1State extends State<DropDownMenuFb1> {
  final controller = Get.find<HistoryController>();
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      color: Theme.of(context).colorScheme.surface,
      icon: widget.icon,
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        PopupMenuItem(
          child: Center(
            child: Text(
              'History',
              style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,),
            ),
          )
        ),
        const PopupMenuDivider(),
        // PopupMenuItem(
        //   child: ListTile(
        //     leading: Text(
        //       'Open',
        //       style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        //     ),
        //     trailing: const Icon(Icons.open_with, color: Colors.deepPurple),
        //     onTap: () async {
        //       try {
        //         final list = controller.getListByType(widget.type);
        //         final item = list[widget.index!];
        //         final path = item['path'] ?? '';
        //         if (path.isNotEmpty && File(path).existsSync()) {
        //           await OpenFilex.open(path);
        //         }
        //       } catch (_) {}
        //       Get.back();
        //     },
        //   ),
        // ),
        PopupMenuItem(
            child: ListTile(
              leading: Text(
                'Delete',
                style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,),
              ),
              trailing: const Icon(Icons.delete_forever_sharp, color: Colors.redAccent,),
              onTap: ()async{
                await controller.removeHistoryItem(widget.type, widget.index!);
                Get.back();
              },
            ),
        ),
      ],
    );
  }
}
