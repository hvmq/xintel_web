import 'package:get/get.dart';

import '../../features/auth/login/login_screen.dart';
import '../../features/home/home_binding.dart';
import '../../features/home/home_screen.dart';
import '../../features/splash/splash_binding.dart';
import '../../features/splash/splash_screen.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initialRoute = Routes.splash;
  static const afterAuthRoute = Routes.home;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(name: _Paths.login, page: () => const LoginScreen()),
    GetPage(
      name: _Paths.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
  ];
}
