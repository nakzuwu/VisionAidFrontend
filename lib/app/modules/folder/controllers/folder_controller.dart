import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class FolderController extends GetxController {
  final storage = GetStorage();
  var folders = <String, List<String>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final saved = storage.read('folders') ?? {};
    folders.value = Map<String, List<String>>.from(saved.map(
      (key, value) => MapEntry(key, List<String>.from(value)),
    ));
  }

  void addFolder(String name) {
    if (name.trim().isEmpty || folders.containsKey(name)) return;
    folders[name] = [];
    storage.write('folders', folders);
  }

  void refreshFolders() {
    final saved = storage.read('folders') ?? {};
    folders.value = Map<String, List<String>>.from(saved.map(
      (key, value) => MapEntry(key, List<String>.from(value)),
    ));
  }
}
