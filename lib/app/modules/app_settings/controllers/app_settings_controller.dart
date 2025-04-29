import 'package:get/get.dart';

class AppSettingsController extends GetxController {
  var isDarkMode = false.obs;

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    // Tambahkan penyimpanan lokal jika perlu
  }
}