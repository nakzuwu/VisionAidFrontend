import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vision_aid_app/app/data/services/api_service.dart';
import '../../../../data/services/auth_service.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  final usernameC = TextEditingController();
  final passwordC = TextEditingController();

  final isLoading = false.obs;
  final AuthService _authService = AuthService();
  final GetStorage box = GetStorage();
  var rememberMe = false.obs;

  void login() async {
    isLoading.value = true;

    try {
      await box.erase();

      final result = await _authService.login(
        username: usernameC.text.trim(),
        password: passwordC.text.trim(),
      );

      final token = result['token'];
      final user = result['user'];

      box.write('token', token);
      box.write('username', user['username']);
      box.write('email', user['email']);
      box.write('api_key', user['api_key']);

      // Sync NOTE
      final notes = await ApiService.fetchAllNotes();
      for (final note in notes) {
        box.write(note.id, note.toJson());

        final folders = box.read('folders') ?? {};
        if (!folders.containsKey(note.folder)) {
          folders[note.folder] = [];
        }
        final List<dynamic> folderNotes = folders[note.folder];
        if (!folderNotes.contains(note.id)) {
          folderNotes.add(note.id);
        }
        box.write('folders', folders);
      }

      final reminders = await ApiService.fetchAllReminders();
      final reminderMap = <String, List<Map<String, dynamic>>>{};

      for (final reminder in reminders) {
        final dayKey =
            DateTime(
              reminder.day.year,
              reminder.day.month,
              reminder.day.day,
            ).toIso8601String();

        if (!reminderMap.containsKey(dayKey)) {
          reminderMap[dayKey] = [];
        }

        reminderMap[dayKey]!.add(reminder.toJson());
      }

      box.write('events', json.encode(reminderMap));

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
