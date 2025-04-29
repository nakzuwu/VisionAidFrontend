import 'package:get/get.dart';

import '../controllers/note_detail_controller.dart';

class NoteDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NoteDetailController>(
      () => NoteDetailController(),
    );
  }
}
