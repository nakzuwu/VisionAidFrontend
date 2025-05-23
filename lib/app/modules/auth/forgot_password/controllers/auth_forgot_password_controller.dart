import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/auth_service.dart'; 

class AuthForgotPasswordController extends GetxController {
  final emailC = TextEditingController();
  var isLoading = false.obs;

  void sendResetRequest() async {
    if (emailC.text.isEmpty) {
      Get.snackbar("Error", "Email tidak boleh kosong");
      return;
    }

    isLoading.value = true;

    final response = await AuthService.requestReset(emailC.text);
    isLoading.value = false;

    if (response['success']) {
      Get.snackbar("Berhasil", response['message']);
    } else {
      Get.snackbar("Gagal", response['message']);
    }
  }

  @override
  void onClose() {
    emailC.dispose();
    super.onClose();
  }
}
