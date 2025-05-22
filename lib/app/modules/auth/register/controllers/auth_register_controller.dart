import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/auth_service.dart';

class RegisterController extends GetxController {
  final usernameC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final confirmPasswordC = TextEditingController();

  RxBool agreeTerms = false.obs;
  RxBool isLoading = false.obs;

  void toggleAgreeTerms(bool? value) {
    agreeTerms.value = value ?? false;
  }

  Future<void> register() async {
    if (!agreeTerms.value) {
      Get.snackbar("Error", "Anda harus menyetujui syarat dan ketentuan");
      return;
    }

    if (passwordC.text != confirmPasswordC.text) {
      Get.snackbar("Error", "Password tidak cocok");
      return;
    }

    isLoading.value = true;

    try {
      final response = await AuthService.register(
        username: usernameC.text.trim(),
        email: emailC.text.trim(),
        password: passwordC.text,
        confirm: confirmPasswordC.text,
      );

      Get.snackbar("Berhasil", response['msg'] ?? "Registrasi berhasil");
      Get.toNamed('/otp', arguments: {'email': emailC.text.trim()});
    } catch (e) {
      Get.snackbar("Gagal", e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
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
