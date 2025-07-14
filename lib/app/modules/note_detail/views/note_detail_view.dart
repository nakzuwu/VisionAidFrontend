import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vision_aid_app/app/modules/note_detail/controllers/note_detail_controller.dart';

class NoteDetailView extends StatelessWidget {
  const NoteDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final noteId = Get.arguments as String?;
    final controller = Get.put(
      NoteDetailController(), 
      tag: noteId?.toString(), 
    );
    final noteController = Get.find<NoteDetailController>(tag: noteId);
    final id = Get.arguments;
    final recent = GetStorage().read<List>('recent_notes') ?? [];

    if (id != null) {
      recent.remove(id);
      recent.insert(0, id);

      if (recent.length > 3) recent.removeRange(3, recent.length);

      GetStorage().write('recent_notes', recent);
    }

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(controller.isLoading.value ? 'Loading...' : 'Notepad'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.summarize),
            tooltip: 'Ringkas Catatan',
            onPressed: () async {
              final fullText = controller.textController.text.trim();
              if (fullText.isEmpty) {
                Get.snackbar('Gagal', 'Catatan kosong');
                return;
              }

              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );

              final summary = await controller.summarizeText(fullText);
              Get.back(); 

              if (summary == null) {
                Get.snackbar('Gagal', 'Gagal merangkum catatan');
                return;
              }

              final TextEditingController summaryController =
                  TextEditingController(text: summary);

              Get.defaultDialog(
                title: 'Hasil Ringkasan',
                content: Column(
                  children: [
                    TextField(
                      controller: summaryController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Hasil ringkasan...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        controller.textController.text = summaryController.text;
                        Get.back(); 
                      },
                      child: const Text('Gunakan Ringkasan'),
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Batal'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            tooltip: 'Scan Gambar untuk OCR',
            onPressed: controller.pickImageForOCR,
          ),
          IconButton(
            icon: const Icon(Icons.mic),
            tooltip: 'Transkripsi Audio',
            onPressed: controller.showAudioOptions,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: controller.saveNoteLocally,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value:
                    controller.folderList.contains(
                          controller.selectedFolder.value,
                        )
                        ? controller.selectedFolder.value
                        : null, 
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedFolder.value = value;
                  }
                },
                hint: const Text('Pilih Folder'),
                items:
                    controller.folderList.toSet().toList().map((folderName) {
                      return DropdownMenuItem(
                        value: folderName,
                        child: Text(folderName),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
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
                ),
              ),
              ...controller.images.map((imagePath) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.file(File(imagePath)),
                );
              }),
              ...controller.remoteImages.map((imageUrl) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.network(imageUrl),
                );
              }),
            ],
          ),
        );
      }),
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
