import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'package:flutter/foundation.dart'; 
import 'firebase_options.dart'; 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.web,
    );
  } else {
    await Firebase.initializeApp(); // untuk Android/iOS
  }

  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
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
