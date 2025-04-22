import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  var rememberMe = false.obs;

  void login() {
    Get.toNamed('/home');
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
