import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:vision_aid_app/app/data/services/auth_service.dart';

class UserProfileController extends GetxController {
  final usernameController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final loginHistory = <Map<String, dynamic>>[].obs;

  final box = GetStorage();

  final _authService = AuthService();

  Future<void> updateUsername() async {
    await _authService.updateUsername(usernameController.text.trim());
  }

  Future<void> updatePassword() async {
    await _authService.updatePassword(
      oldPasswordController.text.trim(),
      newPasswordController.text.trim(),
    );
  }


  Future<void> loadLoginHistory() async {
    final data = await _authService.fetchLoginHistory();
    loginHistory.value = data;
  }

  void logout() {
    _authService.logoutUser();
  }

  @override
  void onInit() {
    usernameController.text = box.read('username') ?? '';
    super.onInit();
  }
}
