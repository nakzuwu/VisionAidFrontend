import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vision_aid_app/app/modules/note_detail/controllers/note_detail_controller.dart';

class NoteDetailView extends GetView<NoteDetailController> {
  const NoteDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notepad'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() => Column(
          children: [
            Expanded(
              child: TextField(
                controller: controller.textController,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Ketik catatan Anda di sini...',
                ),
                style: TextStyle(
                  fontWeight: controller.isBold.value ? FontWeight.bold : FontWeight.normal,
                  fontStyle: controller.isItalic.value ? FontStyle.italic : FontStyle.normal,
                  decoration: controller.isUnderline.value ? TextDecoration.underline : TextDecoration.none,
                  backgroundColor: controller.isHighlighted.value ? Colors.yellow : Colors.transparent,
                ),
              ),
            ),
            // Tampilkan gambar yang sudah dipilih
            ...controller.images.map((imagePath) {
              return Image.file(File(imagePath));
            }).toList(),
          ],
        )),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFFFFEB3B),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          items: controller.bottomNavItems,
        ),
      ),
    );
  }
}