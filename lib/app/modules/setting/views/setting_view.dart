import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vision_aid_app/app/routes/app_pages.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../controllers/setting_controller.dart';

class SettingView extends GetView<SettingController> {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(currentIndex: 3),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow[700],
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.account_circle, size: 64),
              const SizedBox(height: 10),
              const Text.rich(
                TextSpan(
                  text: 'Halo ',
                  style: TextStyle(fontSize: 22),
                  children: [
                    TextSpan(
                      text: 'name!', // static text sementara
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Divider(thickness: 1),
              ListTile(
                title: const Text(
                  "edit profile",
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () => Get.toNamed(Routes.USER_PROFILE),
              ),
              const Divider(thickness: 1),
              ListTile(
                title: const Text("Pengaturan", style: TextStyle(fontSize: 16)),
                onTap: () => Get.toNamed(Routes.APP_SETTINGS),
              ),
              const Divider(thickness: 1),
              ListTile(
                title: const Text("logout", style: TextStyle(fontSize: 16)),
                onTap: () => Get.toNamed(Routes.AUTH_LOGIN),
              ),
              const Divider(thickness: 1),
            ],
          ),
        ),
      ),
    );
  }
}
