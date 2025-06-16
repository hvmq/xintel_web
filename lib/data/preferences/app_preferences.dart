// ignore_for_file: unused_element

import 'package:xintel/models/user.dart';

import '../../core/constans/storage_constants.dart';
import 'base_storage.dart';

class AppPreferences extends BaseStorage {
  @override
  String get boxName => StorageConstants.appPreferencesBox;

  Future<void> saveAccessToken(String value) async {
    return write(StorageConstants.accessTokenKey, value);
  }

  Future<String?> getAccessToken() async {
    return read(StorageConstants.accessTokenKey);
  }

  Future<void> saveRefreshToken(String value) async {
    return write(StorageConstants.refreshTokenKey, value);
  }

  Future<String?> getRefreshToken() async {
    return read(StorageConstants.refreshTokenKey);
  }

  Future<void> deleteAllTokens() async {
    await delete(StorageConstants.accessTokenKey);
    await delete(StorageConstants.refreshTokenKey);
    await delete(StorageConstants.userKey);
    await delete(StorageConstants.loggedInKey);
  }

  Future<void> saveUser(User value) async {
    return write(StorageConstants.userKey, value.toJson());
  }

  Future<User?> getUser() async {
    final json = await read(StorageConstants.userKey);
    if (json == null) return null;
    return User.fromJson(json as Map<String, dynamic>);
  }

  Future<void> saveLoggedIn(bool value) async {
    return write(StorageConstants.loggedInKey, value);
  }

  Future<bool?> getLoggedIn() async {
    return read(StorageConstants.loggedInKey);
  }

  // Save all login data and ensure it's flushed
  Future<void> saveLoginData({
    required String token,
    required User user,
  }) async {
    await saveAccessToken(token);
    await saveUser(user);
    await saveLoggedIn(true);

    // Ensure all data is flushed to storage
    await flush();

    // Add small delay to ensure storage is completely synced
    await Future.delayed(const Duration(milliseconds: 50));
  }
}
