import 'dart:async';

import 'package:get/get.dart';

import '../../routing/routers/app_pages.dart';
import '../auth/auth_controller.dart';

class SplashController extends GetxController {
  @override
  Future<void> onInit() async {
    super.onInit();

    // Wait for auth check to complete
    final authController = Get.find<AuthController>();
    await authController.checkLogin();
    // Navigate based on login status
    if (authController.isLoggedIn.value) {
      unawaited(Get.offAllNamed(Routes.home));
    } else {
      unawaited(Get.offAllNamed(Routes.login));
    }
  }
}
