class UnreadMessage {
  final String conversationId;
  final int unreadCount;
  final DateTime lastMessageTime;

  UnreadMessage({
    required this.conversationId,
    required this.unreadCount,
    required this.lastMessageTime,
  });

  factory UnreadMessage.fromJson(Map<String, dynamic> json) {
    return UnreadMessage(
      conversationId: json['conversationId'] as String,
      unreadCount: json['unreadCount'] as int,
      lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'unreadCount': unreadCount,
      'lastMessageTime': lastMessageTime.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'UnreadMessage(conversationId: $conversationId, unreadCount: $unreadCount, lastMessageTime: $lastMessageTime)';
  }
}
