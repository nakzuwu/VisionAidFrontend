import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vision_aid_app/app/routes/app_pages.dart';

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final token = box.read('token');

    Future.delayed(const Duration(seconds: 2), () {
      if (token != null && token.toString().isNotEmpty) {
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.offAllNamed(Routes.AUTH_LOGIN);
      }
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
