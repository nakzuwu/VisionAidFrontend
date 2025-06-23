import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController

  final count = 0.obs;
  final RxList<String> recentNoteIds = <String>[].obs;

  void loadRecentNotes() {
    final list = GetStorage().read<List>('recent_notes') ?? [];
    recentNoteIds.assignAll(list.map((e) => e.toString()));
  }

  void increment() => count.value++;
}
