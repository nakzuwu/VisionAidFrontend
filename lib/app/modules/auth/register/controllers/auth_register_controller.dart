import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  final usernameC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final confirmPasswordC = TextEditingController();

  RxBool agreeTerms = false.obs;

  void toggleAgreeTerms(bool? value) {
    agreeTerms.value = value ?? false;
  }

  void register() {
    if (!agreeTerms.value) {
      Get.snackbar("Error", "You must agree to the terms and conditions");
      return;
    }

    // Tambahkan validasi lainnya sesuai kebutuhan
    if (passwordC.text != confirmPasswordC.text) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    // Simulasi register sukses
    Get.toNamed('/home');
  }

  @override
  void onClose() {
    usernameC.dispose();
    emailC.dispose();
    passwordC.dispose();
    confirmPasswordC.dispose();
    super.onClose();
  }
}
