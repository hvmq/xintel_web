String userSchema = '''
    id
    email
    first_name
    last_name
    phone
    avatar_path
    nickname
    is_activated
    web_user_id
    gender
    location
    birthday
    is_search_global
    is_show_email
    is_show_phone
    is_show_gender
    is_show_location
    is_show_birthday
    is_show_nft
    nft_number
    talk_language
    is_phone_verified
    authen_key
''';

String getUsersByIdsQuery(List<int> ids) => '''
  query MyQuery {
    backend_users(where: {id: {_in: $ids}}) {
      $userSchema
    }
  }
''';
