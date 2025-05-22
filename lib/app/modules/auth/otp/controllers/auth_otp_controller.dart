import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/auth_service.dart';

class OtpController extends GetxController {
  final otpC = TextEditingController();
  late String email;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args == null || args['email'] == null) {
      Get.snackbar("Error", "Email tidak ditemukan");
      return;
    }
    email = args['email'];
  }

  void verifyOtp() async {
    if (otpC.text.isEmpty) {
      Get.snackbar('Error', 'OTP tidak boleh kosong');
      return;
    }

    isLoading.value = true;
    try {
      final result = await AuthService().verifyOtp(
        email: email,
        otp: otpC.text.trim(),
      );

      Get.snackbar('Berhasil', result['msg']);
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Gagal', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }
  void resendOtp() {
    Get.snackbar('Info', 'Kode OTP baru telah dikirim');
  }
  @override
  void onClose() {
    otpC.dispose();
    super.onClose();
  }
}
