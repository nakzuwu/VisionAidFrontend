import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:vision_aid_app/app/routes/app_pages.dart';
import 'dart:convert';

class AuthService extends GetxService {
  static const String baseUrl = 'https://visionaid.lolihunter.my.id/api/auth';

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final box = GetStorage();

  Future<AuthService> init() async {
    await GetStorage.init();
    return this;
  }

  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String confirm,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    final body = jsonEncode({
      'username': username,
      'email': email,
      'password': password,
      'confirm': confirm,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['msg']);
      }
    } catch (e) {
      throw Exception('Gagal registrasi: $e');
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/verify-otp');
    final body = jsonEncode({'email': email, 'otp': otp});

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['msg'] ?? 'OTP verification failed');
    }
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    final body = jsonEncode({'username': username, 'password': password});

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await box.write('token', data['token']); // ✅ simpan token
      return data;
    } else {
      throw Exception(data['msg'] ?? 'Login gagal');
    }
  }

  static Future<Map<String, dynamic>> requestReset(String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/request-reset"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return {"success": true, "message": jsonDecode(response.body)['msg']};
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body)['msg'] ?? 'Terjadi kesalahan',
      };
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['msg'] ?? 'Terjadi kesalahan');
    }
  }

  Future<void> logoutUser() async {
    final token = box.read("token");
    if (token == null) {
      Get.snackbar("Logout gagal", "Token tidak ditemukan");
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      await box.remove("token");
      Get.offAllNamed(Routes.AUTH_LOGIN);
    } else {
      Get.snackbar("Logout gagal", "Gagal logout dari server");
    }
  }

  String? get token => box.read<String>('token');

  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'Login dibatalkan pengguna'};
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final idToken = await userCredential.user?.getIdToken();

      print("=== Google Login Debug ===");
      print("ID Token: $idToken");
      print("URL: $baseUrl/oauth/login");
      print("===========================");

      final response = await http.post(
        Uri.parse('$baseUrl/oauth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'token': data['token'], 'user': data['user']};
      } else {
        return {'success': false, 'message': data['msg']};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
