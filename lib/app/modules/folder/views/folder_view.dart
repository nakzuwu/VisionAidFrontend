// folder_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:vision_aid_app/app/modules/note_detail/views/note_detail_view.dart';
import '../controllers/folder_controller.dart';

class FolderView extends GetView<FolderController> {
  FolderView({super.key});

  final storage = GetStorage();

  void showAddFolderDialog() {
    final TextEditingController folderController = TextEditingController();

    Get.defaultDialog(
      title: 'Tambah Folder',
      content: Column(
        children: [
          TextField(
            controller: folderController,
            decoration: const InputDecoration(labelText: 'Nama folder'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              controller.addFolder(folderController.text);
              Get.back();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Folder')),
      body: Obx(() {
        if (controller.folders.isEmpty) {
          return const Center(child: Text('Belum ada folder'));
        }

        return ListView(
          children: controller.folders.entries.map((entry) {
            final folderName = entry.key;
            final noteIds = entry.value;

            return ExpansionTile(
              title: Text(folderName),
              children: noteIds.map((noteId) {
                final note = storage.read(noteId);
                return ListTile(
                  title: Text(note?['content'] ?? 'Tanpa isi'),
                  subtitle: Text(note?['updated_at'] ?? ''),
                  onTap: () {
                  },
                );
              }).toList(),
            );
          }).toList(),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddFolderDialog,
        backgroundColor: Colors.yellow[700],
        child: const Icon(Icons.create_new_folder),
      ),
    );
  }
}
