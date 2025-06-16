import '../../presentation/features/chat_sidebar/chat_sidebar_controller.dart';
import 'user_schema.dart';

String searchUserByQuery(String query) => '''
      query MyQuery(\$query: String = "%$query%") {
        backend_users(
            where: {
              _and: [
                {is_search_global: {_eq: true}},
                {
                  _or: [
                    {first_name: {_ilike: \$query}},
                    {last_name: {_ilike: \$query}},
                    {nickname: {_ilike: \$query}},
                    {email: {_ilike: \$query}},
                    {phone: {_ilike: \$query}},
                    {web_user_id: {_ilike: \$query}},
                    {nft_number: {_ilike: \$query}}
                  ]
                }
              ]
            },
            limit: 8
      ) {
          $userSchema
        }
      }
      ''';

String searchUserByQueryWithOption(String query, SearchType searchType) {
  final cleanQuery = query.replaceAll('%', '');

  String conditions;
  if (searchType == SearchType.suggest) {
    conditions = '''
                {first_name: {_ilike: \$query}},
                {last_name: {_ilike: \$query}},
                {nickname: {_ilike: \$query}},
                {email: {_ilike: \$query}},
                {phone: {_ilike: \$query}},
                {web_user_id: {_ilike: \$query}},
                {nft_number: {_ilike: \$query}}''';
  } else {
    conditions = '{${getFieldName(searchType)}: {_ilike: \$query}}';
  }

  return '''
    query MyQuery(\$query: String = "%$cleanQuery%") {
      backend_users(
        where: {
          _and: [
            {is_search_global: {_eq: true}},
            {
              _or: [
                $conditions
              ]
            }
          ]
        },
        order_by: [
          {first_name: asc},
          {last_name: asc}
        ],
        limit: 20
      ) {
        $userSchema
      }
    }
    ''';
}

String getFieldName(SearchType type) {
  switch (type) {
    case SearchType.firstname:
      return 'first_name';
    case SearchType.lastname:
      return 'last_name';
    case SearchType.username:
      return 'nickname';
    case SearchType.email:
      return 'email';
    case SearchType.phone:
      return 'phone';
    case SearchType.nft:
      return 'nft_number';
    case SearchType.suggest:
      return 'all';
  }
}
