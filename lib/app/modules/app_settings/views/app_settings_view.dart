import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vision_aid_app/app/widgets/bottom_nav_bar.dart';
import '../controllers/app_settings_controller.dart';

class AppSettingsView extends GetView<AppSettingsController> {
  const AppSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Aplikasi'),
        backgroundColor: Colors.yellow[700],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 3),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow[700],
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang Aplikasi'),
            subtitle: const Text('Versi 1.0.0'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Kirim Masukan'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
