import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vision_aid_app/app/data/model/note_model.dart';
import 'package:vision_aid_app/app/modules/note_detail/controllers/note_detail_controller.dart';

class HomeController extends GetxController {
  final count = 0.obs;

  final storage = GetStorage();
  final recentNotes = <Note>[].obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadRecentNotes();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<NoteDetailController>()) {
        Get.find<NoteDetailController>().loadAllNotes();
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    recentNotes.clear();
  }

  void loadRecentNotes() {
    final keys = storage.getKeys();
    final all =
        keys
            .map((key) {
              final raw = storage.read(key);
              if (raw is Map) {
                try {
                  return Note.fromMap(Map<String, dynamic>.from(raw));
                } catch (e) {
                  return null;
                }
              }
              return null;
            })
            .whereType<Note>()
            .toList();
    final sorted =
        all.where((note) => note.lastOpened != null).toList()
          ..sort((Note a, Note b) {
            if (a.lastOpened == null) return 1;
            if (b.lastOpened == null) return -1;
            return b.lastOpened!.compareTo(a.lastOpened!);
          });

    recentNotes.value = sorted.take(3).toList();
  }

  void refreshRecentNotes() {
    loadRecentNotes();
  }
}
