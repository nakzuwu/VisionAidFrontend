import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpController extends GetxController {
  final otpController = TextEditingController();

  void verifyOtp() {
    String otp = otpController.text.trim();
    if (otp.isEmpty) {
      Get.snackbar('Error', 'Kode OTP tidak boleh kosong');
    } else {
      // Panggil API verifikasi di sini
      Get.snackbar('Sukses', 'Kode OTP diverifikasi');
    }
  }

  void resendOtp() {
    // Panggil API untuk kirim ulang OTP di sini
    Get.snackbar('Info', 'Kode OTP baru telah dikirim');
  }
}
