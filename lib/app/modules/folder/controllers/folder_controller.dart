import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vision_aid_app/app/modules/home/controllers/home_controller.dart';

class FolderController extends GetxController {
  final storage = GetStorage();
  var folders = <String, List<String>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final saved = storage.read('folders') ?? {};
    folders.value = Map<String, List<String>>.from(
      saved.map((key, value) => MapEntry(key, List<String>.from(value))),
    );
  }

  void addFolder(String name) {
    if (name.trim().isEmpty || folders.containsKey(name)) return;
    folders[name] = [];
    _saveFolders();
    _triggerHomeRefresh(); // Tambahkan ini
  }

  void refreshFolders() {
    final saved = storage.read('folders') ?? {};
    folders.value = Map<String, List<String>>.from(
      saved.map((key, value) => MapEntry(key, List<String>.from(value))),
    );
    _triggerHomeRefresh(); // Tambahkan ini
  }

  void _saveFolders() {
    storage.write('folders', folders);
    _triggerHomeRefresh(); // Tambahkan ini
  }

  void _triggerHomeRefresh() {
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      homeController.loadRecentNotes();
    }
  }
}
