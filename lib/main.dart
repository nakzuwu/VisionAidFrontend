import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'package:uni_links/uni_links.dart';

void main() {
  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
void initDeepLinkListener() async {
  try {
    uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.path == '/reset-password') {
        final token = uri.queryParameters['token'];
        if (token != null) {
          Get.toNamed('/reset-password', arguments: token);
        }
      }
    });
  } on PlatformException {
    print('Gagal inisialisasi deep link');
  }
}
