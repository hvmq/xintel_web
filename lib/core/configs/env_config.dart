class EnvConfig {
  EnvConfig(this.environment);

  final Map<String, String> environment;

  String get apiUrl => 'https://travel.xintel.info/api';
  String get apiChatUrl => 'https://chat.xintel.info/api';
  String get apiGraphqlUrl => 'https://hasura.xintel.info/v1/graphql';
  String get minIoUrl => 'minio.xintel.info';
  String get minIoAccessKey => 'vcGqD17jZ1S4Zu6fZzIe';
  String get minIoSecretKey => '9KmOysfXq71nVKO3HvYr2bmOnxKFtgvj9KpGgiPl';
  String get chatSocketUrl => 'https://chat.xintel.info';

  // String get apiUrl => environment['BASE_URL']!;
  // String get apiChatUrl => environment['CHAT_URL']!;
  // String get apiGraphqlUrl => environment['HASURA_URL']!;
  // String get minIoUrl => environment['MINIO_URL']!;
  // String get minIoAccessKey => environment['MINIO_ACCESS_KEY']!;
  // String get minIoSecretKey => environment['MINIO_SECRET_KEY']!;
  // String get chatSocketUrl =>
  //     environment['CHAT_SOCKET_URL'] ?? environment['CHAT_URL']!;
}
