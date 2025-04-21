import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginController extends GetxController {
  final usernameC = TextEditingController();
  final passwordC = TextEditingController();

  void login() async {
    final res = await http.post(
      Uri.parse("http://10.0.2.2:5000/api/auth/login"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": usernameC.text,
        "password": passwordC.text,
      }),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      Get.snackbar("Berhasil", "Selamat datang ${data['username']}");
      // Simpan token dan api key kalau perlu
    } else {
      Get.snackbar("Gagal", data["msg"]);
    }
  }
}
