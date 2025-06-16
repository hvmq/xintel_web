import 'dart:convert';

import 'package:get/get.dart';
import 'package:graphql/client.dart';

import '../../core/configs/env_config.dart';
import '../../core/mixins/log_mixin.dart';
import '../../data/preferences/app_preferences.dart';

class GraphQLService with LogMixin {
  late final GraphQLClient _client;

  GraphQLService() {
    final envConfig = Get.find<EnvConfig>();
    final httpLink = HttpLink(envConfig.apiGraphqlUrl);

    final authLink = AuthLink(
      getToken: () async {
        final token = await Get.find<AppPreferences>().getAccessToken();
        return token != null ? 'Bearer $token' : null;
      },
    );

    final link = authLink.concat(httpLink);

    _client = GraphQLClient(link: link, cache: GraphQLCache());

    logDebug(
      '🚀 GraphQL Service initialized with endpoint: ${envConfig.apiGraphqlUrl}',
    );
  }

  Future<T?> query<T>({
    required String document,
    Map<String, dynamic>? variables,
    T Function(Map<String, dynamic>)? decoder,
    bool enableLogRequest = true,
    bool enableLogVariables = true,
    bool enableLogResponseData = true,
    bool enableLogSuccessResponse = true,
    bool enableLogErrorResponse = true,
  }) async {
    final startTime = DateTime.now();

    try {
      // Log request
      if (enableLogRequest) {
        final log = <String>[];
        log.add('************ GraphQL Query Request ************');
        log.add('🔍 GraphQL Query: ${document.replaceAll('\n', ' ').trim()}');
        if (enableLogVariables && variables != null && variables.isNotEmpty) {
          log.add('🔍 Query Variables:\n${_formatJson(variables)}');
        }
        logDebug(log.join('\n'));
      }

      final result = await _client.query(
        QueryOptions(
          document: gql(document),
          variables: variables ?? const {},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      final duration = DateTime.now().difference(startTime).inMilliseconds;

      if (result.hasException) {
        if (enableLogErrorResponse) {
          final errorLog = <String>[];
          errorLog.add('************ GraphQL Query Error ************');
          errorLog.add('⛔️ GraphQL Query Failed');
          errorLog.add('⛔️ Duration: ${duration}ms');
          errorLog.add('⛔️ Error: ${result.exception}');
          logError(errorLog.join('\n'));
        }
        throw result.exception!;
      }

      if (enableLogSuccessResponse) {
        final successLog = <String>[];
        successLog.add('************ GraphQL Query Response ************');
        successLog.add('🎉 GraphQL Query Success');
        successLog.add('🎉 Duration: ${duration}ms');
        if (enableLogResponseData && result.data != null) {
          successLog.add('🎉 Response Data:\n${_formatJson(result.data!)}');
        }
        logDebug(successLog.join('\n'));
      }

      if (decoder != null && result.data != null) {
        final decodedResult = decoder(result.data!);
        if (enableLogResponseData) {
          logDebug('🔄 Decoded Result Type: ${decodedResult.runtimeType}');
        }
        return decodedResult;
      }

      return result.data as T?;
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      if (enableLogErrorResponse) {
        final errorLog = <String>[];
        errorLog.add('************ GraphQL Query Exception ************');
        errorLog.add('⛔️ GraphQL Query Exception');
        errorLog.add('⛔️ Duration: ${duration}ms');
        errorLog.add('⛔️ Error: $e');
        logError(errorLog.join('\n'));
      }
      rethrow;
    }
  }

  Future<T?> mutate<T>({
    required String document,
    Map<String, dynamic>? variables,
    T Function(Map<String, dynamic>)? decoder,
    bool enableLogRequest = true,
    bool enableLogVariables = true,
    bool enableLogResponseData = true,
    bool enableLogSuccessResponse = true,
    bool enableLogErrorResponse = true,
  }) async {
    final startTime = DateTime.now();

    try {
      // Log request
      if (enableLogRequest) {
        final log = <String>[];
        log.add('************ GraphQL Mutation Request ************');
        log.add(
          '🔄 GraphQL Mutation: ${document.replaceAll('\n', ' ').trim()}',
        );
        if (enableLogVariables && variables != null && variables.isNotEmpty) {
          log.add('🔄 Mutation Variables:\n${_formatJson(variables)}');
        }
        logDebug(log.join('\n'));
      }

      final result = await _client.mutate(
        MutationOptions(
          document: gql(document),
          variables: variables ?? const {},
        ),
      );

      final duration = DateTime.now().difference(startTime).inMilliseconds;

      if (result.hasException) {
        if (enableLogErrorResponse) {
          final errorLog = <String>[];
          errorLog.add('************ GraphQL Mutation Error ************');
          errorLog.add('⛔️ GraphQL Mutation Failed');
          errorLog.add('⛔️ Duration: ${duration}ms');
          errorLog.add('⛔️ Error: ${result.exception}');
          logError(errorLog.join('\n'));
        }
        throw result.exception!;
      }

      if (enableLogSuccessResponse) {
        final successLog = <String>[];
        successLog.add('************ GraphQL Mutation Response ************');
        successLog.add('🎉 GraphQL Mutation Success');
        successLog.add('🎉 Duration: ${duration}ms');
        if (enableLogResponseData && result.data != null) {
          successLog.add('🎉 Response Data:\n${_formatJson(result.data!)}');
        }
        logDebug(successLog.join('\n'));
      }

      if (decoder != null && result.data != null) {
        final decodedResult = decoder(result.data!);
        if (enableLogResponseData) {
          logDebug('🔄 Decoded Result Type: ${decodedResult.runtimeType}');
        }
        return decodedResult;
      }

      return result.data as T?;
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      if (enableLogErrorResponse) {
        final errorLog = <String>[];
        errorLog.add('************ GraphQL Mutation Exception ************');
        errorLog.add('⛔️ GraphQL Mutation Exception');
        errorLog.add('⛔️ Duration: ${duration}ms');
        errorLog.add('⛔️ Error: $e');
        logError(errorLog.join('\n'));
      }
      rethrow;
    }
  }

  /// Subscribe to GraphQL subscriptions (if needed)
  Stream<T?> subscribe<T>({
    required String document,
    Map<String, dynamic>? variables,
    T Function(Map<String, dynamic>)? decoder,
    bool enableLogRequest = true,
    bool enableLogVariables = true,
    bool enableLogResponseData = true,
  }) {
    if (enableLogRequest) {
      final log = <String>[];
      log.add('************ GraphQL Subscription Request ************');
      log.add(
        '📡 GraphQL Subscription: ${document.replaceAll('\n', ' ').trim()}',
      );
      if (enableLogVariables && variables != null && variables.isNotEmpty) {
        log.add('📡 Subscription Variables:\n${_formatJson(variables)}');
      }
      logDebug(log.join('\n'));
    }

    return _client
        .subscribe(
          SubscriptionOptions(
            document: gql(document),
            variables: variables ?? const {},
          ),
        )
        .map((result) {
          if (result.hasException) {
            final errorLog = <String>[];
            errorLog.add(
              '************ GraphQL Subscription Error ************',
            );
            errorLog.add('⛔️ GraphQL Subscription Error: ${result.exception}');
            logError(errorLog.join('\n'));
            throw result.exception!;
          }

          if (enableLogResponseData) {
            logDebug(
              '📨 Subscription Data Received:\n${_formatJson(result.data)}',
            );
          }

          if (decoder != null && result.data != null) {
            final decodedResult = decoder(result.data!);
            if (enableLogResponseData) {
              logDebug(
                '🔄 Decoded Subscription Result Type: ${decodedResult.runtimeType}',
              );
            }
            return decodedResult;
          }

          return result.data as T?;
        })
        .handleError((error) {
          final errorLog = <String>[];
          errorLog.add(
            '************ GraphQL Subscription Exception ************',
          );
          errorLog.add('⛔️ GraphQL Subscription Exception: $error');
          logError(errorLog.join('\n'));
        });
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
}

final graphQLService = GraphQLService();
