import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_reset_password_controller.dart';

class AuthResetPasswordView extends StatelessWidget {
  final controller = Get.find<AuthResetPasswordController>();

  AuthResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final token = Get.parameters['token'] ?? '';
    controller.token.value = token;

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Password Baru'),
            const SizedBox(height: 8),
            TextField(
              controller: controller.newPasswordC,
              obscureText: true,
              decoration: _inputDecoration(),
            ),
            const SizedBox(height: 16),
            const Text('Konfirmasi Password'),
            const SizedBox(height: 8),
            TextField(
              controller: controller.confirmPasswordC,
              obscureText: true,
              decoration: _inputDecoration(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Reset Password'),
            ),
          ],
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