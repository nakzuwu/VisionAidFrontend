import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vision_aid_app/app/routes/app_pages.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../controllers/setting_controller.dart';

class SettingView extends GetView<SettingController> {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final username = GetStorage().read('username') ?? 'User';

    return Scaffold(
      bottomNavigationBar: BottomNavBar(currentIndex: 3),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow[700],
        onPressed: () => Get.toNamed(Routes.NOTE_DETAIL),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo $username!',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Kelola akun dan pengaturan aplikasi kamu.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.black87),
                title: const Text("Edit Profile", style: TextStyle(fontSize: 16)),
                onTap: () => Get.toNamed(Routes.USER_PROFILE),
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: Colors.black87),
                title: const Text("Pengaturan", style: TextStyle(fontSize: 16)),
                onTap: () => Get.toNamed(Routes.APP_SETTINGS),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text("Logout", style: TextStyle(fontSize: 16)),
                onTap: controller.logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
