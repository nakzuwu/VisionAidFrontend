import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vision_aid_app/app/routes/app_pages.dart';
import 'package:vision_aid_app/app/widgets/bottom_nav_bar.dart';
import '../controllers/user_profile_controller.dart';

class UserProfileView extends GetView<UserProfileController> {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: Colors.yellow[700],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 3),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow[700],
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: controller.usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: controller.updateUsername,
              child: const Text('Ubah Username'),
            ),
            const Divider(height: 32),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ganti Password',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Lama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Baru',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: controller.updatePassword,
              child: const Text('Ubah Password'),
            ),

            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: controller.logout,
            ),
            
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: Icon(Icons.history),
              label: Text("Riwayat Login"),
              onPressed: () {
                Get.toNamed(Routes.LOGIN_HISTORY);
              },
            ),
          ],
        ),
      ),
    );
  }
}
