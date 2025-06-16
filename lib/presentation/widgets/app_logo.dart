import 'package:flutter/material.dart';

import '../../resources/styles/styles.dart';

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 30});

  @override
  Widget build(BuildContext context) {
    return Text(
      'XIN STAR',
      style: AppTextStyles.s28w700.copyWith(
          color: AppColors.primary,
          fontSize: size,
          fontWeight: FontWeight.w800),
    );
  }
}
