import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/auth_service.dart';

class AuthResetPasswordController extends GetxController {
  final newPasswordC = TextEditingController();
  final confirmPasswordC = TextEditingController();
  final token = ''.obs;

  @override
  void onInit() {
    token.value = Get.arguments ?? '';
    super.onInit();
  }

  void resetPassword() async {
    final newPassword = newPasswordC.text.trim();
    final confirmPassword = confirmPasswordC.text.trim();

    if (newPassword != confirmPassword) {
      Get.snackbar('Gagal', 'Password tidak cocok');
      return;
    }

    final result = await AuthService.resetPassword(
      token: token.value,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    if (result['msg'] == 'Password berhasil direset') {
      Get.snackbar('Berhasil', 'Password berhasil direset');
      Get.offAllNamed('/login');
    } else {
      Get.snackbar('Gagal', result['msg'] ?? 'Reset password gagal');
    }
  }

  @override
  void onClose() {
    newPasswordC.dispose();
    confirmPasswordC.dispose();
    super.onClose();
  }
}
