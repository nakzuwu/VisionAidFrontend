import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vision_aid_app/app/routes/app_pages.dart';

class OtpController extends GetxController {
  final otpController = TextEditingController();

  void verifyOtp() {
    String otp = otpController.text.trim();
    if (otp.isEmpty) {
      Get.snackbar('Error', 'Kode OTP tidak boleh kosong');
      Get.toNamed(Routes.HOME);
    } else {
      // Panggil API verifikasi di sini
      Get.snackbar('Sukses', 'Kode OTP diverifikasi');
      Get.toNamed(Routes.HOME);
    }
  }

  void resendOtp() {
    // Panggil API untuk kirim ulang OTP di sini
    Get.snackbar('Info', 'Kode OTP baru telah dikirim');
  }
}
