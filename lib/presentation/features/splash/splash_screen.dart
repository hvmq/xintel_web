import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/app_logo.dart';
import 'splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: AppLogo()),
    );
  }
}
