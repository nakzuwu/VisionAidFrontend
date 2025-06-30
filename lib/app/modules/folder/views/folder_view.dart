import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vision_aid_app/app/modules/note_detail/views/note_detail_view.dart';
import 'package:vision_aid_app/app/routes/app_pages.dart';
import 'package:vision_aid_app/app/widgets/bottom_nav_bar.dart';
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
      bottomNavigationBar: BottomNavBar(currentIndex: 2),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow[700],
        onPressed: () => Get.toNamed(Routes.NOTE_DETAIL),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Folder',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            SizedBox(height: 2),
            Text(
              'Atur filemu sepuasnya',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder),
            onPressed: showAddFolderDialog,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.folders.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.folder_off, size: 100, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'Belum ada folder',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: ListView(
            children:
                controller.folders.entries.map((entry) {
                  final folderName = entry.key;
                  final noteIds = entry.value;

                  return ExpansionTile(
                    leading: const Icon(Icons.folder, color: Colors.orange),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            folderName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            if (value == 'edit') {
                              final TextEditingController editController =
                                  TextEditingController(text: folderName);
                              Get.defaultDialog(
                                title: 'Edit Nama Folder',
                                content: Column(
                                  children: [
                                    TextField(
                                      controller: editController,
                                      decoration: const InputDecoration(
                                        labelText: 'Nama baru',
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        final newName =
                                            editController.text.trim();
                                        if (newName.isNotEmpty &&
                                            newName != folderName) {
                                          final notes = controller.folders
                                              .remove(folderName);
                                          controller.folders[newName] = notes!;
                                          storage.write(
                                            'folders',
                                            controller.folders,
                                          );
                                          controller.folders.refresh();
                                          Get.back();
                                        }
                                      },
                                      child: const Text('Simpan'),
                                    ),
                                  ],
                                ),
                              );
                            } else if (value == 'delete') {
                              Get.defaultDialog(
                                title: 'Hapus Folder',
                                middleText:
                                    'Yakin ingin menghapus folder "$folderName"? Semua catatan di dalamnya akan dihapus.',
                                textCancel: 'Batal',
                                textConfirm: 'Hapus',
                                confirmTextColor: Colors.white,
                                onConfirm: () {
                                  for (var id
                                      in controller.folders[folderName]!) {
                                    storage.remove(id);
                                  }
                                  controller.folders.remove(folderName);
                                  storage.write('folders', controller.folders);
                                  controller.folders.refresh();
                                  Get.back();
                                },
                              );
                            }
                          },
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Hapus'),
                                ),
                              ],
                        ),
                      ],
                    ),
                    children:
                        noteIds.map((noteId) {
                          final note = storage.read(noteId);
                          if (note == null) return const SizedBox.shrink();

                          return ListTile(
                            leading: const Icon(Icons.note, color: Colors.blue),
                            title: Text(
                              note['content'] ?? 'Tanpa isi',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                            subtitle: Text(note['updated_at'] ?? ''),
                            onTap: () {
                              Get.to(
                                () => const NoteDetailView(),
                                arguments: noteId,
                              );
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    Get.to(
                                      () => const NoteDetailView(),
                                      arguments: noteId,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    Get.defaultDialog(
                                      title: 'Hapus Catatan',
                                      middleText:
                                          'Yakin ingin menghapus catatan ini?',
                                      textCancel: 'Batal',
                                      textConfirm: 'Hapus',
                                      confirmTextColor: Colors.white,
                                      onConfirm: () {
                                        storage.remove(noteId);
                                        controller.folders[folderName]?.remove(
                                          noteId,
                                        );
                                        if (controller
                                            .folders[folderName]!
                                            .isEmpty) {
                                          controller.folders.remove(folderName);
                                        }
                                        storage.write(
                                          'folders',
                                          controller.folders,
                                        );
                                        controller.folders.refresh();
                                        Get.back();
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  );
                }).toList(),
          ),
        );
      }),
    );
  }
}
