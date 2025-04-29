import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
              Obx(() => Text.rich(
                    TextSpan(
                      text: 'Halo ',
                      style: const TextStyle(fontSize: 22),
                      children: [
                        TextSpan(
                          // text: controller.username.value + '!',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 40),
              const Divider(thickness: 1),
              ListTile(
                title: const Text("edit profile", style: TextStyle(fontSize: 16)),
                // onTap: controller.onEditProfile,
              ),
              const Divider(thickness: 1),
              ListTile(
                title: const Text("Pengaturan", style: TextStyle(fontSize: 16)),
                // onTap: controller.onSettings,
              ),
              const Divider(thickness: 1),
              ListTile(
                title: const Text("logout", style: TextStyle(fontSize: 16)),
                // onTap: controller.onLogout,
              ),
              const Divider(thickness: 1),
            ],
          ),
        ),
      ),
    );
  }
}
