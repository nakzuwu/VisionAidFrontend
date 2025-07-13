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
      if (response.statusCode == 200 || response.statusCode == 201) {
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

    // Tetap hapus data lokal walau token invalid
    Future<void> cleanLogout() async {
      await box.remove("token");
      await box.remove("username");
      // Hapus data lain jika ada (misal: API key)
      Get.offAllNamed(Routes.AUTH_LOGIN);
    }

    if (token == null) {
      Get.snackbar("Logout", "Token tidak ditemukan. Mengarahkan ke login.");
      await cleanLogout();
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar("Logout", "Berhasil logout");
      } else {
        Get.snackbar("Logout", "Token kadaluarsa, logout lokal dijalankan");
      }
    } catch (e) {
      Get.snackbar("Logout Error", "Terjadi kesalahan koneksi");
    }

    await cleanLogout();
  }

  String? get token => box.read<String>('token');
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      // ✅ Pastikan selalu muncul pemilihan akun Google
      await _googleSignIn.signOut();

      // Step 1: Munculkan popup login akun Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'Login dibatalkan oleh pengguna'};
      }

      // Step 2: Ambil token Google Auth
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Step 3: Buat credential dari Google token
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 4: Login ke Firebase pakai credential tersebut
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Step 5: Ambil ID Token dari Firebase user
      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        return {
          'success': false,
          'message': 'Gagal mengambil ID Token dari Firebase',
        };
      }

      // Step 6: Kirim token ke backend kamu untuk diverifikasi
      final response = await http.post(
        Uri.parse('$baseUrl/oauth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'token': data['token'], 'user': data['user']};
      } else {
        return {
          'success': false,
          'message': data['msg'] ?? 'Login Google gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  Future<bool> updateUsername(String newUsername) async {
    final token = box.read('token');

    if (newUsername.isEmpty) {
      Get.snackbar('Error', 'Username tidak boleh kosong');
      return false;
    }

    final res = await http.put(
      Uri.parse('$baseUrl/username'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'username': newUsername}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final newToken = data['token'];
      if (newToken != null) {
        box.write('token', newToken);
      }

      box.write('username', newUsername);
      return true;
    }

    Get.snackbar('Gagal', 'Gagal mengubah username');
    return false; // <= wajib ditambahkan agar return selalu ada
  }

  Future<bool> updatePassword(String oldPassword, String newPassword) async {
    final token = box.read('token');

    if (oldPassword.isEmpty || newPassword.isEmpty) {
      Get.snackbar('Error', 'Semua field harus diisi');
      return false;
    }

    final res = await http.put(
      Uri.parse('$baseUrl/password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final newToken = data['token'];
      if (newToken != null) {
        box.write('token', newToken);
      }

      Get.snackbar(
        'Berhasil',
        'Password berhasil diubah. Silakan login ulang.',
      );
      return true;
    } else {
      final errorMsg =
          jsonDecode(res.body)['error'] ?? 'Gagal mengubah password';
      Get.snackbar('Gagal', errorMsg);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchLoginHistory() async {
    final token = box.read('token');

    final res = await http.get(
      Uri.parse('$baseUrl/history'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      Get.snackbar("Error", "Gagal mengambil riwayat login");
      return [];
    }
  }
}
