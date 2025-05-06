import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vision_aid_app/app/routes/app_pages.dart';
import '../controllers/note_detail_controller.dart';

class NoteDetailView extends GetView<NoteDetailController> {
  const NoteDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(  
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              // controller: controller.titleController,
              decoration: const InputDecoration(
                hintText: "Judul Catatan",
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 20, color: Colors.grey),
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 8),
            TextField(
              // controller: controller.titleController,
              decoration: const InputDecoration(
                hintText: "Catatan",
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            // Kamu bisa ganti dengan TextField nanti
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.MEDIA),
        backgroundColor: Colors.yellow[700],
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              IconButton(icon: Icon(Icons.edit), onPressed: null),
              IconButton(icon: Icon(Icons.text_fields), onPressed: null),
              SizedBox(width: 40), // for FAB
              IconButton(icon: Icon(Icons.image), onPressed: null),
              IconButton(icon: Icon(Icons.check_box_outlined), onPressed: null),
            ],
          ),
        ),
      ),
    );
  }
}
