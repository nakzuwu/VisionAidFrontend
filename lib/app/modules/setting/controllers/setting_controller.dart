import 'package:get/get.dart';
import 'package:vision_aid_app/app/data/services/auth_service.dart';

class SettingController extends GetxController {

  final AuthService _authService = Get.find<AuthService>();

  void logout() {
    _authService.logoutUser();
  }

  final count = 0.obs;



  void increment() => count.value++;
}
