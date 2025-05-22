import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/auth_service.dart';
import 'package:get_storage/get_storage.dart'; // untuk simpan token

class LoginController extends GetxController {
  final usernameC = TextEditingController();
  final passwordC = TextEditingController();

  final isLoading = false.obs;
  final AuthService _authService = AuthService();
  final GetStorage box = GetStorage(); // untuk menyimpan token
  var rememberMe = false.obs;

  void login() async {
    isLoading.value = true;

    try {
      final result = await _authService.login(
        username: usernameC.text.trim(),
        password: passwordC.text.trim(),
      );

      final token = result['token'];
      final user = result['user'];

      // Simpan token dan user info ke local storage
      box.write('token', token);
      box.write('username', user['username']);
      box.write('email', user['email']);
      box.write('api_key', user['api_key']);

      // Navigasi ke halaman home
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar("Login Gagal", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  @override
  void onClose() {
    usernameC.dispose();
    passwordC.dispose();
    super.onClose();
  }
}
