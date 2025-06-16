import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:xintel/core/utils/intent_util.dart';

import '../../../../core/utils/toast_util.dart';
import '../../../../data/preferences/app_preferences.dart';
import '../../../../resources/styles/app_colors.dart';
import '../../../routing/routers/app_pages.dart';
import '../../../widgets/app_logo.dart';
import '../auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final _emailPhoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  final bool _isEmailMode = true; // true for email, false for phone

  @override
  void dispose() {
    _emailPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await authController.login(
        password: _passwordController.text.trim(),
        email: _isEmailMode ? _emailPhoneController.text.trim() : null,
        phone: !_isEmailMode ? _emailPhoneController.text.trim() : null,
      );

      if (success) {
        // Show success toast
        ToastUtil.showSuccess(
          'Đăng nhập thành công! Chào mừng bạn trở lại.',
          title: 'Thành công',
        );

        // Finish autofill context to help browsers save credentials
        TextInput.finishAutofillContext();

        await authController.checkLogin();
        // Add delay to ensure token is properly saved and synced
        await Future.delayed(const Duration(milliseconds: 200));

        // Verify token is actually saved before proceeding
        final savedToken = await Get.find<AppPreferences>().getAccessToken();
        if (savedToken?.isNotEmpty == true) {
          print(
            '✅ Token verified before navigation: ${savedToken!.substring(0, 20)}...',
          );
          Get.offAllNamed(Routes.home);
        } else {
          print('❌ Token not found after save, retrying...');
          await Future.delayed(const Duration(milliseconds: 100));
          Get.offAllNamed(Routes.home);
        }
      } else {
        // Show error toast
        ToastUtil.showError(
          authController.errorMessage.value.isNotEmpty
              ? authController.errorMessage.value
              : 'Đăng nhập thất bại. Vui lòng thử lại.',
          title: 'Lỗi đăng nhập',
        );
      }
    } else {
      // Show validation error toast
      ToastUtil.showWarning(
        'Vui lòng kiểm tra lại thông tin đăng nhập.',
        title: 'Thông tin không hợp lệ',
      );
    }
  }

  String? _validateEmailPhone(String? value) {
    if (value == null || value.isEmpty) {
      return _isEmailMode
          ? 'Vui lòng nhập email'
          : 'Vui lòng nhập số điện thoại';
    }

    if (_isEmailMode) {
      // Email validation
      if (!GetUtils.isEmail(value)) {
        return 'Email không hợp lệ';
      }
    } else {
      // Phone validation
      if (!GetUtils.isPhoneNumber(value)) {
        return 'Số điện thoại không hợp lệ';
      }
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // Logo and Title
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        AppLogo(size: 40),
                        const SizedBox(height: 8),
                        Text(
                          'Đăng nhập để tiếp tục',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Email/Phone Input
                  SizedBox(
                    width: 400,
                    child: TextFormField(
                      controller: _emailPhoneController,
                      keyboardType:
                          _isEmailMode
                              ? TextInputType.emailAddress
                              : TextInputType.phone,
                      validator: _validateEmailPhone,
                      style: const TextStyle(color: Colors.black),
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.next,
                      autofillHints:
                          _isEmailMode
                              ? [AutofillHints.email, AutofillHints.username]
                              : [
                                AutofillHints.telephoneNumber,
                                AutofillHints.username,
                              ],
                      decoration: InputDecoration(
                        labelText: _isEmailMode ? 'Email' : 'Số điện thoại',
                        labelStyle: TextStyle(color: Colors.grey.shade400),
                        hintText:
                            _isEmailMode ? 'example@email.com' : '+84123456789',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        prefixIcon: Icon(
                          _isEmailMode
                              ? Icons.email_outlined
                              : Icons.phone_outlined,
                          color: AppColors.primary,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade600),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade600),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Password Input
                  SizedBox(
                    width: 400,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      validator: _validatePassword,
                      style: const TextStyle(color: Colors.black),
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(),
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        labelStyle: TextStyle(color: Colors.grey.shade400),
                        hintText: 'Nhập mật khẩu của bạn',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: AppColors.primary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey.shade400,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade600),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade600),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Login Button
                  Obx(
                    () => SizedBox(
                      width: 400,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            authController.isLoading.value
                                ? null
                                : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child:
                            authController.isLoading.value
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Forgot Password
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Navigate to forgot password screen
                        IntentUtils.openBrowserURL(
                          url: 'https://dapp.xintel.co/',
                        );
                      },
                      child: Text(
                        'Quên mật khẩu?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Register Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Chưa có tài khoản? ',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to register screen
                            IntentUtils.openBrowserURL(
                              url: 'https://dapp.xintel.co/',
                            );
                          },
                          child: Text(
                            'Đăng ký ngay',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
