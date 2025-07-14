import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vision_aid_app/app/data/services/auth_service.dart';
import 'package:vision_aid_app/app/routes/app_pages.dart';
import '../controllers/auth_register_controller.dart';

class RegisterView extends StatelessWidget {
  RegisterView({super.key});
  final controller = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset("assets/logo.png", height: 100),
              const SizedBox(height: 16),
              Container(
                width: 380,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: "Nama Pengguna",
                      controller: controller.usernameC,
                    ),
                    _buildTextField(
                      label: "Email",
                      controller: controller.emailC,
                    ),
                    _buildTextField(
                      label: "Password",
                      controller: controller.passwordC,
                      obscureText: true,
                    ),
                    _buildTextField(
                      label: "Confirm Password",
                      controller: controller.confirmPasswordC,
                      obscureText: true,
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Row(
                        children: [
                          Checkbox(
                            value: controller.agreeTerms.value,
                            onChanged: controller.toggleAgreeTerms,
                          ),
                          const Text("I agree to the "),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              "terms & conditions",
                              style: TextStyle(color: Colors.lightBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: controller.register,
                        child: const Text("Register"),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final result =
                      await Get.find<AuthService>().loginWithGoogle();
                  if (result['success']) {
                    Get.snackbar("Berhasil", "Login Google berhasil");
                  } else {
                    Get.snackbar(
                      "Gagal",
                      result['message'] ?? 'Terjadi kesalahan',
                    );
                  }
                },
                icon: Image.asset(
                  'assets/google_icon.png',
                  height: 24,
                ),
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
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sudah punya akun? "),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.AUTH_LOGIN),
                    child: const Text(
                      "Login",
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade300,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
