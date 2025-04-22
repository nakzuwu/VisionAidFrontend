import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/folder_controller.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Optional

class FolderView extends GetView<FolderController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        currentIndex: 2,
        selectedItemColor: Colors.yellow[700],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
        backgroundColor: Colors.yellow[700],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() => ListView(
            children: [
              const Text("Halo user!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text("Apa yang kau lakukan hari ini?"),
              const SizedBox(height: 10),
              const TextField(
                decoration: InputDecoration(
                  hintText: "🔍 Cari...",
                  filled: true,
                  fillColor: Color(0xFFEFEFEF),
                  border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),
              const SizedBox(height: 20),
              ...controller.folders.map((folder) => Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      folder.isExpanded = !folder.isExpanded;
                      controller.folders.refresh(); // refresh UI
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.folder, size: 24),
                          const SizedBox(width: 10),
                          Text(folder.title, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  if (folder.isExpanded)
                    ...folder.notes.map((note) => Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${note.time} - ${note.title}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text("${note.date}", style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(height: 4),
                          Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    )),
                ],
              )),
            ],
          )),
        ),
      ),
    );
  }
}
