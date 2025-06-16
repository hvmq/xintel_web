import 'package:xintel/models/user.dart';

import '../presentation/features/chat_sidebar/chat_sidebar_controller.dart';
import 'base/graphql_service.dart';
import 'docs/search_user_schema.dart';
import 'docs/user_schema.dart';

class UserRepository {
  Future<List<User>> getUsersByIds(List<int> ids) async {
    final result = await graphQLService.query<Map<String, dynamic>>(
      document: getUsersByIdsQuery(ids),
      decoder: (data) => data,
    );

    if (result == null) return [];

    return User.fromJsonList((result['backend_users'] as List<dynamic>));
  }

  Future<List<User>> searchUserByTypes(
    String query,
    SearchType searchType,
  ) async {
    final result = await graphQLService.query<Map<String, dynamic>>(
      document: searchUserByQueryWithOption(query, searchType),
      decoder: (data) => data,
    );

    if (result == null) return [];

    return User.fromJsonList((result['backend_users'] as List<dynamic>));
  }
}

final userRepository = UserRepository();
