import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vision_aid_app/app/data/services/api_service.dart';
import 'package:vision_aid_app/app/data/services/auth_service.dart';
import '../controllers/auth_login_controller.dart';
import 'package:get_storage/get_storage.dart';

class LoginView extends StatelessWidget {
  late final LoginController controller;

  LoginView({super.key}) {
    if (Get.isRegistered<LoginController>()) {
      Get.delete<LoginController>();
    }
    controller = Get.put(LoginController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 120),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text('Nama Pengguna'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: controller.usernameC,
                      decoration: _inputDecoration(),
                    ),
                    const SizedBox(height: 16),

                    const Text('Kata Sandi'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: controller.passwordC,
                      obscureText: true,
                      decoration: _inputDecoration(),
                    ),

                    const SizedBox(height: 12),
                    Obx(
                      () => Row(
                        children: [
                          Checkbox(
                            value: controller.rememberMe.value,
                            onChanged: controller.toggleRememberMe,
                          ),
                          const Text('Ingat Kata Sandi Saya'),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Get.toNamed('/forgot-password'),
                          child: const Text(
                            'Lupa Sandi',
                            style: TextStyle(color: Colors.lightBlue),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF9D93D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: controller.login,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Login',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final box = GetStorage();
                  await box.erase();
                  final result =
                      await Get.find<AuthService>().loginWithGoogle();
                  if (result['success']) {
                    final token = result['token'];
                    final user = result['user'];

                    box.write('token', token);
                    box.write('username', user['username']);
                    box.write('email', user['email']);
                    box.write('api_key', user['api_key']);

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

                    // Get.snackbar(
                    //   "Berhasil",
                    //   "Login Google berhasil",
                    //   snackPosition: SnackPosition.BOTTOM,
                    // );
                  } else {
                    Get.snackbar(
                      "Gagal",
                      result['message'] ?? 'Terjadi kesalahan',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );
                  }
                },
                icon: Image.asset('assets/google_icon.png', height: 24),
                label: const Text('Login dengan Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum punya akun? '),
                  GestureDetector(
                    onTap: () => Get.toNamed('/register'),
                    child: const Text(
                      'register',
                      style: TextStyle(color: Colors.lightBlue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      fillColor: const Color(0xFFE0E0E0),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}
