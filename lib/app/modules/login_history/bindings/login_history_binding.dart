import 'package:get/get.dart';
import '../controllers/login_history_controller.dart';

class LoginHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginHistoryController>(() => LoginHistoryController());
  }
}
