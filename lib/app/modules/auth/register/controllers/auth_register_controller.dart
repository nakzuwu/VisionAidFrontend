import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterController extends GetxController {
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final usernameC = TextEditingController();
  final nameC = TextEditingController();

  void register() async {
    final res = await http.post(
      Uri.parse("http://10.0.2.2:5000/api/auth/register"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": emailC.text,
        "password": passwordC.text,
        "confirm": passwordC.text,
        "username": usernameC.text,
        "name": nameC.text,
      }),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 201) {
      Get.snackbar("Sukses", "Akun berhasil dibuat");
      Get.toNamed('/login');
    } else {
      Get.snackbar("Error", data["msg"]);
    }
  }
}
