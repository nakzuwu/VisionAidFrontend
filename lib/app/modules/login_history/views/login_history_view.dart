import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vision_aid_app/app/routes/app_pages.dart';
import '../controllers/login_history_controller.dart';

class LoginHistoryView extends GetView<LoginHistoryController> {
  const LoginHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Login')),
      body: Obx(() {
        final history = controller.loginHistory;

        if (history.isEmpty) {
          return const Center(child: Text("Belum ada riwayat login"));
        }

        return ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];
            final date = DateFormat(
              'dd MMM yyyy – HH:mm',
            ).format(DateTime.parse(item['login_time']));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.device_hub),
                  title: Text(item['device'] ?? 'Perangkat tidak diketahui'),
                  subtitle: Text(
                    'IP: ${item['ip'] ?? 'Tidak tersedia'}\n$date',
                  ),
                  isThreeLine: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextButton.icon(
                    onPressed: () {
                      Get.toNamed(Routes.USER_PROFILE);
                    },
                    icon: const Icon(Icons.warning_amber, color: Colors.red),
                    label: const Text(
                      "Jika bukan perangkat Anda, ganti password",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                const Divider(), // Batas antar item history
              ],
            );
          },
        );
      }),
    );
  }
}
