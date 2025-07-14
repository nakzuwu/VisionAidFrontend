import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vision_aid_app/app/modules/note_detail/controllers/note_detail_controller.dart';

// ... import tetap
import 'package:flutter/services.dart';

class NoteDetailView extends StatelessWidget {
  const NoteDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final noteId = Get.arguments as String?;
    final controller = Get.put(NoteDetailController(), tag: noteId?.toString());
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

        return Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                    controller.showPreview.value
                        ? SingleChildScrollView(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              textAlign: TextAlign.left,
                              text: controller.parseRichText(
                                controller.textController.text,
                              ),
                            ),
                          ),
                        )
                        : TextField(
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
            ),
            ...controller.images.map((imagePath) {
              return Stack(
                children: [
                  Image.file(File(imagePath)),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => controller.images.remove(imagePath),
                    ),
                  ),
                ],
              );
            }),
            ...controller.remoteImages.map((imageUrl) {
              return Stack(
                children: [
                  Image.network(imageUrl),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => controller.remoteImages.remove(imageUrl),
                    ),
                  ),
                ],
              );
            }),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.showPreview.value) return const SizedBox.shrink();

        return BottomAppBar(
          color: Colors.grey[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                tooltip: 'Bold',
                icon: const Icon(Icons.format_bold),
                onPressed: () => controller.insertFormat('**', '**'),
              ),
              IconButton(
                tooltip: 'Italic',
                icon: const Icon(Icons.format_italic),
                onPressed: () => controller.insertFormat('__', '__'),
              ),
              IconButton(
                tooltip: 'Strikethrough',
                icon: const Icon(Icons.format_strikethrough),
                onPressed: () => controller.insertFormat('~~', '~~'),
              ),
              IconButton(
                tooltip: 'Highlight',
                icon: const Icon(Icons.highlight),
                onPressed: () => controller.insertFormat('==', '=='),
              ),
              IconButton(
                tooltip: 'List',
                icon: const Icon(Icons.format_list_bulleted),
                onPressed: () => controller.insertListItem(),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: Obx(
        () => FloatingActionButton.extended(
          onPressed: () => controller.showPreview.toggle(),
          icon: Icon(
            controller.showPreview.value ? Icons.edit : Icons.remove_red_eye,
          ),
          label: Text(controller.showPreview.value ? 'Edit' : 'Preview'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
