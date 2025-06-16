class MessageSystem {
  final MessageSystemType type;
  final List<String> memberIds;

  const MessageSystem({required this.type, this.memberIds = const []});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageSystem &&
        other.type == type &&
        other.memberIds.length == memberIds.length &&
        other.memberIds.every((id) => memberIds.contains(id));
  }

  @override
  int get hashCode => type.hashCode ^ memberIds.hashCode;

  factory MessageSystem.fromJson(Map<String, dynamic> json) {
    return MessageSystem(
      type: _parseType(json['type'] as String),
      memberIds:
          (json['members'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  static MessageSystemType _parseType(String json) {
    return MessageSystemType.values.firstWhere((e) => e.value == json);
  }
}

enum MessageSystemType {
  addMember('Ad'),
  removeMember('Rm');

  final String value;

  const MessageSystemType(this.value);
}
