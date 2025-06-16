import 'package:flutter/material.dart';

import '../../resources/styles/app_colors.dart';

class AppCheckBox extends StatefulWidget {
  final bool value;
  final Function(bool?)? onChanged;
  const AppCheckBox({required this.value, super.key, this.onChanged});

  @override
  State<AppCheckBox> createState() => _AppCheckBoxState();
}

class _AppCheckBoxState extends State<AppCheckBox> {
  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: widget.value,
      onChanged: (value) {
        widget.onChanged!(value);
      },
      side: const BorderSide(color: AppColors.subText3),
      checkColor: AppColors.text1,
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }

        return Colors.transparent;
      }),
    );
  }
}
