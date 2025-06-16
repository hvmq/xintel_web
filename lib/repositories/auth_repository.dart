import 'package:xintel/repositories/base/api_service.dart';

import '../models/login_response_data.dart';

class AuthRepository {
  // Login API
  final ApiService apiService = ApiService();
  Future<LoginResponseData> login({
    required String password,
    String? email,
    String? phone,
  }) async {
    try {} catch (e) {}
    final Map<String, dynamic> requestBody = {
      'password': password,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      'device': 'web',
    };

    final response = await apiService.callApi(
      method: METHOD.post,
      envUrl: APIURL.baseUrl,
      url: '/auth/login',
      data: requestBody,
      authen: false,
    );

    final respData = response as Map<String, dynamic>;

    return LoginResponseData.fromJson(respData);
  }

  Future<void> logout() async {
    await apiService.callApi(
      method: METHOD.post,
      envUrl: APIURL.baseUrl,
      url: '/auth/logout',
      authen: true,
      data: {'device': 'web'},
    );
  }
}

final authRepository = AuthRepository();
