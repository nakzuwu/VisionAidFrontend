import 'package:get/get.dart';
import 'package:vision_aid_app/app/modules/calendar/controllers/calendar_controller.dart';
import 'package:vision_aid_app/app/modules/home/controllers/home_controller.dart';
import 'package:vision_aid_app/app/modules/note_detail/controllers/note_detail_controller.dart';

import '../modules/app_settings/bindings/app_settings_binding.dart';
import '../modules/app_settings/views/app_settings_view.dart';
import '../modules/auth/forgot_password/bindings/auth_forgot_password_binding.dart';
import '../modules/auth/forgot_password/views/auth_forgot_password_view.dart';
import '../modules/auth/login/bindings/auth_login_binding.dart';
import '../modules/auth/login/views/auth_login_view.dart';
import '../modules/auth/otp/bindings/auth_otp_binding.dart';
import '../modules/auth/otp/views/auth_otp_view.dart';
import '../modules/auth/register/bindings/auth_register_binding.dart';
import '../modules/auth/register/views/auth_register_view.dart';
import '../modules/auth/reset_password/bindings/auth_reset_password_binding.dart';
import '../modules/auth/reset_password/views/auth_reset_password_view.dart';
import '../modules/calendar/bindings/calendar_binding.dart';
import '../modules/calendar/views/calendar_view.dart';
import '../modules/folder/bindings/folder_binding.dart';
import '../modules/folder/views/folder_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login_history/bindings/login_history_binding.dart';
import '../modules/login_history/views/login_history_view.dart';
import '../modules/media/bindings/media_binding.dart';
import '../modules/media/views/media_view.dart';
import '../modules/note_detail/bindings/note_detail_binding.dart';
import '../modules/note_detail/views/note_detail_view.dart';
import '../modules/setting/bindings/setting_binding.dart';
import '../modules/setting/views/setting_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/user_profile/bindings/user_profile_binding.dart';
import '../modules/user_profile/views/user_profile_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.AUTH_LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<NoteDetailController>(
          () => NoteDetailController(),
          fenix: true,
        );
        Get.lazyPut<CalendarController>(
          () => CalendarController(),
          fenix: true,
        );
        Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
      }),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.AUTH_LOGIN,
      page: () => LoginView(),
      binding: AuthLoginBinding(),
    ),
    GetPage(
      name: _Paths.AUTH_REGISTER,
      page: () => RegisterView(),
      binding: AuthRegisterBinding(),
    ),
    GetPage(
      name: _Paths.CALENDAR,
      page: () => CalendarView(),
      binding: CalendarBinding(),
    ),
    GetPage(
      name: _Paths.FOLDER,
      page: () => FolderView(),
      binding: FolderBinding(),
    ),
    GetPage(
      name: _Paths.SETTING,
      page: () => const SettingView(),
      binding: SettingBinding(),
    ),
    GetPage(
      name: _Paths.NOTE_DETAIL,
      page: () => NoteDetailView(),
      binding: BindingsBuilder(() {
        Get.create<NoteDetailController>(() => NoteDetailController());
      }),
    ),
    GetPage(
      name: _Paths.USER_PROFILE,
      page: () => const UserProfileView(),
      binding: UserProfileBinding(),
    ),
    GetPage(
      name: _Paths.APP_SETTINGS,
      page: () => const AppSettingsView(),
      binding: AppSettingsBinding(),
    ),
    GetPage(
      name: _Paths.AUTH_OTP,
      page: () => OtpView(),
      binding: AuthOtpBinding(),
    ),
    GetPage(
      name: _Paths.MEDIA,
      page: () => MediaView(),
      binding: MediaBinding(),
    ),
    GetPage(
      name: _Paths.AUTH_FORGOT_PASSWORD,
      page: () => AuthForgotPasswordView(),
      binding: AuthForgotPasswordBinding(),
    ),
    GetPage(
      name: _Paths.AUTH_RESET_PASSWORD,
      page: () => AuthResetPasswordView(),
      binding: AuthResetPasswordBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN_HISTORY,
      page: () => const LoginHistoryView(),
      binding: LoginHistoryBinding(),
    ),
  ];
}
