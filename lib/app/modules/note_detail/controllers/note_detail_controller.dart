import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class NoteDetailController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final RxInt currentIndex = 0.obs;
  final RxBool isBold = false.obs;
  final RxBool isItalic = false.obs;
  final RxBool isUnderline = false.obs;
  final RxBool isHighlighted = false.obs;
  final RxList<String> images = <String>[].obs;

  final List<BottomNavigationBarItem> bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.format_bold),
      label: 'Format',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.highlight),
      label: 'Highlight',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.check_box),
      label: 'Checkmark',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.image),
      label: 'Image',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.format_list_numbered),
      label: 'List',
    ),
  ];

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  void changeTab(int index) {
    currentIndex.value = index;
    switch (index) {
      case 0: // Format
        showFormatOptions();
        break;
      case 1: // Highlight
        toggleHighlight();
        break;
      case 2: // Checkmark
        addCheckmark();
        break;
      case 3: // Image
        pickImage();
        break;
      case 4: // List
        addNumberedList();
        break;
    }
    Future.delayed(const Duration(milliseconds: 300), () => currentIndex.value = 0);
  }

  void showFormatOptions() {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.format_bold),
              color: isBold.value ? Colors.blue : Colors.black,
              onPressed: toggleBold,
            ),
            IconButton(
              icon: const Icon(Icons.format_italic),
              color: isItalic.value ? Colors.blue : Colors.black,
              onPressed: toggleItalic,
            ),
            IconButton(
              icon: const Icon(Icons.format_underline),
              color: isUnderline.value ? Colors.blue : Colors.black,
              onPressed: toggleUnderline,
            ),
          ],
        ),
      ),
    );
  }

  void toggleBold() {
    isBold.toggle();
    updateTextStyle();
  }

  void toggleItalic() {
    isItalic.toggle();
    updateTextStyle();
  }

  void toggleUnderline() {
    isUnderline.toggle();
    updateTextStyle();
  }

  void toggleHighlight() {
    isHighlighted.toggle();
    updateTextStyle();
  }

  void updateTextStyle() {
    // Akan diimplementasikan di view
    update();
  }

  void addCheckmark() {
    final text = textController.text;
    final selection = textController.selection;
    textController.text = '${text.substring(0, selection.start)}[ ] ${text.substring(selection.start)}';
    textController.selection = TextSelection.collapsed(offset: selection.start + 3);
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      images.add(pickedFile.path);
      final text = textController.text;
      final selection = textController.selection;
      textController.text = '${text.substring(0, selection.start)}\n[Image: ${pickedFile.path}]\n${text.substring(selection.start)}';
      textController.selection = TextSelection.collapsed(offset: selection.start + 20);
    }
  }

  void addNumberedList() {
    final text = textController.text;
    final selection = textController.selection;
    textController.text = '${text.substring(0, selection.start)}1. ${text.substring(selection.start)}';
    textController.selection = TextSelection.collapsed(offset: selection.start + 3);
  }
}