import 'package:get/get.dart';

import '../controllers/auth_otp_controller.dart';

class AuthOtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpController>(
      () => OtpController(),
    );
  }
}
