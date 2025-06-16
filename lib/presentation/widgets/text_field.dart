import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xintel/core/extensions/widget_extensions.dart';

import '../../resources/styles/app_colors.dart';
import '../../resources/styles/gaps.dart';
import '../../resources/styles/text_styles.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.hintText,
    this.hintStyle,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    this.onEditingComplete,
    this.autofocus = false,
    this.autocorrect = false,
    this.enabled = true,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.border,
    this.textCapitalization = TextCapitalization.none,
    this.label,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.contentPadding = const EdgeInsets.fromLTRB(22, 16, 22, 16),
    this.autovalidateMode,
    this.onPrefixIconPressed,
    this.onSuffixIconPressed,
    this.borderRadius,
    this.fillColor,
    this.showCursor,
    this.textAlign = TextAlign.start,
    this.style,
    this.inputFormatters,
    this.addPrefixIconWidth,
    this.isSponsor = false,
    this.cursorColor,
    this.onTapOutside,
    this.contextMenuBuilder,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final String? hintText;
  final TextStyle? hintStyle;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final bool autofocus;
  final bool autocorrect;
  final bool enabled;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final InputBorder? border;
  final TextCapitalization textCapitalization;
  final String? label;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final EdgeInsets contentPadding;
  final AutovalidateMode? autovalidateMode;
  final VoidCallback? onPrefixIconPressed;
  final VoidCallback? onSuffixIconPressed;
  final TapRegionCallback? onTapOutside;
  final double? borderRadius;
  final Color? fillColor;
  final bool? showCursor;
  final TextAlign textAlign;
  final TextStyle? style;
  final List<TextInputFormatter>? inputFormatters;
  final double? addPrefixIconWidth;
  final bool isSponsor;
  final Color? cursorColor;
  final Widget Function(BuildContext, EditableTextState)? contextMenuBuilder;

  @override
  Widget build(BuildContext context) {
    final Widget child = TextFormField(
      cursorColor: cursorColor ?? AppColors.text2,
      inputFormatters: inputFormatters,
      autovalidateMode: autovalidateMode,
      controller: controller,
      focusNode: focusNode,
      initialValue: initialValue,
      readOnly: readOnly,
      contextMenuBuilder: contextMenuBuilder,
      decoration: InputDecoration(
        contentPadding: contentPadding,
        fillColor: fillColor ?? Colors.white,
        filled: true,
        isDense: true,
        hintText: hintText,
        hintStyle:
            hintStyle ??
            AppTextStyles.s16w400.copyWith(
              color: AppColors.subText2,
              fontStyle: FontStyle.italic,
            ),
        errorText: errorText,
        errorStyle: AppTextStyles.s14Base.copyWith(color: AppColors.negative),
        errorMaxLines: 2,
        prefixIcon:
            prefixIcon != null
                ? Padding(
                  padding: EdgeInsets.only(
                    left: contentPadding.left,
                    right: Sizes.s8,
                  ),
                  child: prefixIcon,
                ).clickable(() => onPrefixIconPressed?.call())
                : null,
        prefixIconConstraints: BoxConstraints(
          maxWidth: contentPadding.left + Sizes.s24 + Sizes.s8,
        ),
        suffixIcon:
            suffixIcon != null
                ? Padding(
                  padding: EdgeInsets.only(
                    right: contentPadding.right,
                    left: Sizes.s8,
                  ),
                  child: suffixIcon,
                ).clickable(() => onSuffixIconPressed?.call())
                : null,
        suffixIconConstraints: BoxConstraints(
          maxWidth:
              contentPadding.right +
              Sizes.s24 +
              Sizes.s8 +
              (addPrefixIconWidth ?? 0.0),
        ),
        border: border ?? _defaultBorder(context),
        enabledBorder: border ?? _defaultBorder(context),
        disabledBorder: border ?? _defaultBorder(context),
        focusedBorder: border ?? _defaultBorder(context, focused: true),
        errorBorder: border ?? _defaultBorder(context, error: true),
        counterStyle: AppTextStyles.s12Base.copyWith(color: AppColors.subText2),
      ),
      style: style ?? AppTextStyles.s16w400.copyWith(color: AppColors.text2),
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      autofocus: autofocus,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      onTap: onTap,
      showCursor: showCursor,
      textAlign: textAlign,
    );

    if (label == null) {
      return child;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Sizes.s8),
          child: SizedBox(
            height: 24,
            child: Text(
              label!,
              style: AppTextStyles.s16w500.copyWith(color: AppColors.text2),
            ),
          ),
        ),
        AppSpacing.gapH4,
        child,
      ],
    );
  }

  InputBorder? _defaultBorder(
    BuildContext context, {
    bool focused = false,
    bool error = false,
  }) {
    return OutlineInputBorder(
      borderSide:
          error
              ? BorderSide.none
              : const BorderSide(color: AppColors.greyBorder),
      borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 7)),
    );
  }
}
