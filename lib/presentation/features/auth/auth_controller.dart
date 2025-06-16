import 'dart:async';

import 'package:get/get.dart';

import '../../../data/preferences/app_preferences.dart';
import '../../../models/user.dart';
import '../../../repositories/auth_repository.dart';
import '../../../services/chat_socket_service.dart';

class AuthController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var currentUser = Rxn<User>();
  var errorMessage = ''.obs;
  final AppPreferences _appPreferences = Get.find<AppPreferences>();

  @override
  Future<void> onInit() async {
    super.onInit();
    await checkLogin();

    // Connect socket if user is already logged in
    if (isLoggedIn.value) {
      unawaited(_connectSocket());
    }
  }

  Future<void> checkLogin() async {
    isLoggedIn.value = await _appPreferences.getLoggedIn() ?? false;
    if (isLoggedIn.value) {
      currentUser.value = await _appPreferences.getUser();
    }
  }

  // Login function
  Future<bool> login({
    required String password,
    String? email,
    String? phone,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Validate input
      if (password.isEmpty) {
        errorMessage.value = 'Vui lòng nhập mật khẩu';
        return false;
      }

      if ((email == null || email.isEmpty) &&
          (phone == null || phone.isEmpty)) {
        errorMessage.value = 'Vui lòng nhập email hoặc số điện thoại';
        return false;
      }

      final response = await authRepository.login(
        password: password,
        email: email?.isNotEmpty == true ? email : null,
        phone: phone?.isNotEmpty == true ? phone : null,
      );

      // Update state
      isLoggedIn.value = true;
      currentUser.value = response.user;
      await _appPreferences.saveAccessToken(response.token);
      await _appPreferences.saveUser(response.user);
      await _appPreferences.saveLoggedIn(true);

      // Connect socket after successful login
      await _connectSocket();

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    // Disconnect socket before logout
    await _disconnectSocket();

    isLoggedIn.value = false;
    unawaited(authRepository.logout());
    currentUser.value = null;
    await _appPreferences.deleteAllTokens();

    Get.offAllNamed('/login');
  }

  /// Connect socket after successful authentication
  Future<void> _connectSocket() async {
    try {
      print('🔌 Connecting socket after authentication...');
      final socketService = Get.find<ChatSocketService>();
      await socketService.connectSocket();
      print('✅ Socket connected successfully');
    } catch (e) {
      print('❌ Failed to connect socket: $e');
      // Don't throw error here - socket connection failure shouldn't break login
    }
  }

  /// Disconnect socket before logout
  Future<void> _disconnectSocket() async {
    try {
      print('🔌 Disconnecting socket before logout...');
      final socketService = Get.find<ChatSocketService>();
      socketService.disconnectSocket();
      print('✅ Socket disconnected successfully');
    } catch (e) {
      print('❌ Failed to disconnect socket: $e');
      // Continue with logout even if socket disconnect fails
    }
  }
}
