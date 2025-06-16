import 'package:flutter/material.dart';

import 'app_colors.dart';

/// AppTextStyle format as follows:
/// s[fontSize][fontWeight][Color]
/// Example: s18w400Primary

class AppTextStyles {
  AppTextStyles._();

  static const _fontFamily = 'Nunito';
  static const _defaultColor = AppColors.text2;

  static const TextStyle s12Base = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    color: _defaultColor,
    height: 1.5,
  );

  static const TextStyle s14Base = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    color: _defaultColor,
    height: 1.5,
  );

  static const TextStyle s16Base = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    color: _defaultColor,
    height: 1.5,
  );

  static const TextStyle s18Base = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    color: _defaultColor,
    height: 1.5,
  );

  static const TextStyle s20Base = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    color: _defaultColor,
    height: 1.5,
  );

  static const TextStyle s22Base = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    color: _defaultColor,
    height: 1.5,
  );

  static const TextStyle s24Base = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    color: _defaultColor,
    height: 1.5,
  );

  static const TextStyle s26Base = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 26,
    color: _defaultColor,
    height: 1.5,
  );

  static const TextStyle s28Base = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    color: _defaultColor,
    height: 1.5,
  );

  static TextStyle s12w400 = s12Base.copyWith(fontWeight: FontWeight.w400);
  static TextStyle s12w500 = s12Base.copyWith(fontWeight: FontWeight.w500);
  static TextStyle s12w600 = s12Base.copyWith(fontWeight: FontWeight.w600);
  static TextStyle s12w700 = s12Base.copyWith(fontWeight: FontWeight.w700);

  static TextStyle s14w400 = s14Base.copyWith(fontWeight: FontWeight.w400);
  static TextStyle s14w500 = s14Base.copyWith(fontWeight: FontWeight.w500);
  static TextStyle s14w600 = s14Base.copyWith(fontWeight: FontWeight.w600);
  static TextStyle s14w700 = s14Base.copyWith(fontWeight: FontWeight.w700);

  static TextStyle s16w400 = s16Base.copyWith(fontWeight: FontWeight.w400);
  static TextStyle s16w500 = s16Base.copyWith(fontWeight: FontWeight.w500);
  static TextStyle s16w600 = s16Base.copyWith(fontWeight: FontWeight.w600);
  static TextStyle s16w700 = s16Base.copyWith(fontWeight: FontWeight.w700);

  static TextStyle s18w400 = s18Base.copyWith(fontWeight: FontWeight.w400);
  static TextStyle s18w500 = s18Base.copyWith(fontWeight: FontWeight.w500);
  static TextStyle s18w600 = s18Base.copyWith(fontWeight: FontWeight.w600);
  static TextStyle s18w700 = s18Base.copyWith(fontWeight: FontWeight.w700);

  static TextStyle s20w400 = s20Base.copyWith(fontWeight: FontWeight.w400);
  static TextStyle s20w500 = s20Base.copyWith(fontWeight: FontWeight.w500);
  static TextStyle s20w600 = s20Base.copyWith(fontWeight: FontWeight.w600);
  static TextStyle s20w700 = s20Base.copyWith(fontWeight: FontWeight.w700);

  static TextStyle s22w400 = s22Base.copyWith(fontWeight: FontWeight.w400);
  static TextStyle s22w500 = s22Base.copyWith(fontWeight: FontWeight.w500);
  static TextStyle s22w600 = s22Base.copyWith(fontWeight: FontWeight.w600);
  static TextStyle s22w700 = s22Base.copyWith(fontWeight: FontWeight.w700);

  static TextStyle s24w400 = s24Base.copyWith(fontWeight: FontWeight.w400);
  static TextStyle s24w500 = s24Base.copyWith(fontWeight: FontWeight.w500);
  static TextStyle s24w600 = s24Base.copyWith(fontWeight: FontWeight.w600);
  static TextStyle s24w700 = s24Base.copyWith(fontWeight: FontWeight.w700);

  static TextStyle s26w400 = s26Base.copyWith(fontWeight: FontWeight.w400);
  static TextStyle s26w500 = s26Base.copyWith(fontWeight: FontWeight.w500);
  static TextStyle s26w600 = s26Base.copyWith(fontWeight: FontWeight.w600);
  static TextStyle s26w700 = s26Base.copyWith(fontWeight: FontWeight.w700);

  static TextStyle s28w400 = s28Base.copyWith(fontWeight: FontWeight.w400);
  static TextStyle s28w500 = s28Base.copyWith(fontWeight: FontWeight.w500);
  static TextStyle s28w600 = s28Base.copyWith(fontWeight: FontWeight.w600);
  static TextStyle s28w700 = s28Base.copyWith(fontWeight: FontWeight.w700);
}
