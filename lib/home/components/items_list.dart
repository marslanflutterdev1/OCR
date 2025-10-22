import 'dart:ui';

class ItemsList {
  String? title;
  Color? iconBg;
  String? icon;

  ItemsList({this.title, this.iconBg, this.icon});
}

List<ItemsList> itemsList = [
  ItemsList(
    title: 'Camera',
    iconBg: Color(0xffF4F0FD),
    icon: 'assets/images/camera_icon.png',
  ),
  ItemsList(
    title: 'Gallery',
    iconBg: Color(0xffDEEEFF),
    icon: 'assets/images/gallery_icon.png',
  ),
  ItemsList(
    title: 'Image To Word',
    iconBg: Color(0xffDEEEFF),
    icon: 'assets/images/word_icon.png',
  ),
  ItemsList(
    title: 'Image To PDF',
    iconBg: Color(0xffFFEAEA),
    icon: 'assets/images/pdf_icon.png',
  ),
];
