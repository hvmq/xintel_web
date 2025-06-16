import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../core/configs/env_config.dart';
import '../../core/mixins/log_mixin.dart';
import '../../data/preferences/app_preferences.dart';

enum METHOD { get, post, put, delete, patch }

enum APIURL { baseUrl, chatUrl }

class ApiService with LogMixin {
  Future<dynamic> callApi({
    required METHOD method,
    required APIURL envUrl,
    required String url,
    Map<String, dynamic>? params,
    Object? data,
    bool authen = false,
    bool enableLogHeader = true,
    bool enableLogRequestBody = true,
    bool enableLogResponseData = true,
    bool enableLogSuccessResponse = true,
    bool enableLogErrorResponse = true,
  }) async {
    // Prepare request URI outside try block for error logging
    final baseUrl = _getUrl(envUrl) + url;
    final uri =
        method == METHOD.get
            ? Uri.parse(baseUrl).replace(queryParameters: params)
            : Uri.parse(baseUrl);

    try {
      // Prepare headers
      final headers = <String, String>{'Content-Type': 'application/json'};

      // Add Authorization if needed
      if (authen) {
        final accessToken =
            await Get.find<AppPreferences>().getAccessToken() ?? '';
        headers['Authorization'] = 'Bearer $accessToken';

        // For chat API, try additional headers that might be required
        if (envUrl == APIURL.chatUrl) {
          headers['Accept'] = 'application/json';
          headers['X-Requested-With'] = 'XMLHttpRequest';
          // Try alternative authorization header formats
          logDebug('🔄 Using chat-specific headers for authentication');
        }

        // Debug log to check token
        logDebug(
          '🔑 Retrieved token from storage: ${accessToken.isNotEmpty ? '${accessToken.substring(0, 20)}...' : 'EMPTY'}',
        );
      }

      // Log request
      final log = <String>[];
      log.add('************ Request ************');
      log.add('🌐 Request: ${_getMethodString(method)} ${uri.toString()}');
      if (enableLogHeader) {
        log.add('🌐 Request Headers: $headers');
      }
      if (method == METHOD.get && params != null && params.isNotEmpty) {
        log.add('🌐 Query Parameters: $params');
      }
      if (enableLogRequestBody && data != null) {
        log.add('🌐 Request Body:\n${_formatJson(data)}');
      }
      logDebug(log.join('\n'));

      // Make request
      http.Response response;
      switch (method) {
        case METHOD.get:
          response = await http.get(uri, headers: headers);
          break;
        case METHOD.post:
          response = await http.post(
            uri,
            headers: headers,
            body: data != null ? jsonEncode(data) : null,
          );
          break;
        case METHOD.put:
          response = await http.put(
            uri,
            headers: headers,
            body: data != null ? jsonEncode(data) : null,
          );
          break;
        case METHOD.patch:
          response = await http.patch(
            uri,
            headers: headers,
            body: data != null ? jsonEncode(data) : null,
          );
          break;
        case METHOD.delete:
          response = await http.delete(
            uri,
            headers: headers,
            body: data != null ? jsonEncode(data) : null,
          );
          break;
      }

      // Log response when successful
      final successLog = <String>[];
      successLog.add('************ Request Response ************');
      successLog.add('🎉 ${_getMethodString(method)} ${uri.toString()}');
      successLog.add('🎉 Success Code: ${response.statusCode}');
      if (enableLogResponseData && response.body.isNotEmpty) {
        successLog.add(
          '🎉 Response Data:\n${_formatJson(jsonDecode(response.body))}',
        );
      }
      logDebug(successLog.join('\n'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'error': true,
          'statusCode': response.statusCode,
          'data': response.body.isNotEmpty ? jsonDecode(response.body) : null,
        };
      }
    } catch (error) {
      // Log error when it occurs
      final errorLog = <String>[];
      errorLog.add('************ Request Error ************');
      errorLog.add('⛔️ ${_getMethodString(method)} ${uri.toString()}');
      errorLog.add('⛔️ Error: $error');
      logError(errorLog.join('\n'));
      rethrow;
    }
  }

  String _formatJson(dynamic json) {
    if (json is Map) {
      return const JsonEncoder.withIndent('  ').convert(json);
    } else if (json is List) {
      return const JsonEncoder.withIndent('  ').convert(json);
    } else {
      return json.toString();
    }
  }

  // Get accessToken from AppPreferences
  // Future<String> _getAccessToken() async {
  //   return await Get.find<AppPreferences>().getAccessToken() ?? '';
  // }

  // Convert method enum to string
  String _getMethodString(METHOD method) {
    switch (method) {
      case METHOD.get:
        return 'GET';
      case METHOD.post:
        return 'POST';
      case METHOD.put:
        return 'PUT';
      case METHOD.delete:
        return 'DELETE';
      default:
        return 'GET';
    }
  }

  String _getUrl(APIURL url) {
    final envConfig = Get.find<EnvConfig>();
    switch (url) {
      case APIURL.baseUrl:
        return envConfig.apiUrl;
      case APIURL.chatUrl:
        return envConfig.apiChatUrl;
    }
  }
}
