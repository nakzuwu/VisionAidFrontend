import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vision_aid_app/app/middleware/auth_checker.dart';
import 'package:vision_aid_app/app/routes/app_pages.dart';
import 'package:vision_aid_app/app/data/services/auth_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.web,
    );
  } else {
    await Firebase.initializeApp(); // Android/iOS
  }
  await Get.putAsync(() => AuthService().init());

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "VisionAid",
      getPages: AppPages.routes,
      home: const AuthChecker(), // ✅ Cek login atau tidak
    ),
  );
}


// void initDeepLinkListener() async {
//   try {
//     uriLinkStream.listen((Uri? uri) {
//       if (uri != null && uri.path == '/reset-password') {
//         final token = uri.queryParameters['token'];
//         if (token != null) {
//           Get.toNamed('/reset-password', arguments: token);
//         }
//       }
//     });
//   } on PlatformException {
//     print('Gagal inisialisasi deep link');
//   }
// }
