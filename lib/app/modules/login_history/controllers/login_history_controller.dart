import 'package:get/get.dart';
import 'package:vision_aid_app/app/data/services/auth_service.dart';

class LoginHistoryController extends GetxController {
  final authService = AuthService();
  final loginHistory = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadLoginHistory();
  }

  Future<void> loadLoginHistory() async {
    final data = await authService.fetchLoginHistory();
    loginHistory.assignAll(data);
  }
}
