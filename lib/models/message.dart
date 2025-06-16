import 'package:html_unescape/html_unescape.dart';

import '../core/constans/app_constants.dart';
import 'user.dart';

const String userIdMentionWrapper = r'@${userId}';

enum MessageDisplayState { original, translated }

class Message {
  final String id;
  final String conversationId;
  final String content;
  final String? description;
  final MessageType type;
  final DateTime createdAt;
  final int senderId;
  final User? sender;
  final bool isLocal;
  final Message? forwardedFrom;
  final Message? repliedFrom;
  final Map<String, dynamic>? reactions;
  final Map<String, String>? mentions;
  final String? translatedMessage;
  final MessageDisplayState displayState;

  const Message({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.senderId,
    this.description,
    this.sender,
    this.isLocal = false,
    this.forwardedFrom,
    this.repliedFrom,
    this.reactions,
    this.mentions,
    this.translatedMessage,
    this.displayState = MessageDisplayState.original,
  });

  bool isMine({required int myId}) => senderId == myId;

  bool get isMentionedMessage =>
      content.contains('@') || mentions?.isNotEmpty == true;

  List<int> get mentionedUserIds {
    final mentionedIds = <int>[];

    if (mentions != null && mentions!.isNotEmpty) {
      mentions!.forEach((key, value) {
        // @${29} => 29
        final id = key.replaceAll(RegExp(r'@|\$|\{|\}'), '');
        mentionedIds.add(int.parse(id));
      });
    }

    return mentionedIds;
  }

  bool get isShowingTranslatedMessage =>
      displayState == MessageDisplayState.translated;

  String get getDisplayContent {
    if (isShowingTranslatedMessage) {
      return translatedMessage ?? content;
    }

    return content;
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? content,
    String? description,
    MessageType? type,
    DateTime? createdAt,
    int? senderId,
    User? sender,
    bool? isLocal,
    Message? forwardedFrom,
    Message? repliedFrom,
    Map<String, dynamic>? reactions,
    String? translatedMessage,
    MessageDisplayState? displayState,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      description: description ?? this.description,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      senderId: senderId ?? this.senderId,
      sender: sender ?? this.sender,
      isLocal: isLocal ?? this.isLocal,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      repliedFrom: repliedFrom ?? this.repliedFrom,
      reactions: reactions ?? this.reactions,
      mentions: mentions,
      translatedMessage: translatedMessage ?? this.translatedMessage,
      displayState: displayState ?? this.displayState,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['chatRoomId'],
      content: HtmlUnescape().convert(json['content']),
      description: json['description'],
      type: _parseType(json['type'] as String),
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      senderId: int.parse(json['sender'] as String),
      forwardedFrom:
          json['forwardedFrom'] != null
              ? Message.fromJson(json['forwardedFrom'] as Map<String, dynamic>)
              : null,
      repliedFrom:
          json['repliedFrom'] != null
              ? Message.fromJson(json['repliedFrom'] as Map<String, dynamic>)
              : null,
      reactions:
          json['reactions'] != null
              ? Map<String, dynamic>.from(json['reactions'] as Map)
              : null,
      mentions:
          json['mentions'] != null
              ? Map<String, String>.from(json['mentions'] as Map)
              : null,
      sender:
          json['senderUserModel'] != null
              ? User.fromJson(json['senderUserModel'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'chatRoomId': conversationId,
    'content': content,
    'description': description,
    'type': type.value,
    'createdAt': createdAt.toIso8601String(),
    'sender': senderId.toString(),
    'senderUserModel': sender?.toJson(),
    'forwardedFrom': forwardedFrom?.toJson(),
    'repliedFrom': repliedFrom?.toJson(),
    'reactions': reactions,
    'mentions': mentions,
  };

  static List<Message> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Message.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Message &&
        other.id == id &&
        other.conversationId == conversationId &&
        other.content == content &&
        other.description == description &&
        other.type == type &&
        other.createdAt == createdAt &&
        other.senderId == senderId &&
        other.sender == sender &&
        other.isLocal == isLocal &&
        other.forwardedFrom == forwardedFrom &&
        other.repliedFrom == repliedFrom &&
        other.reactions == reactions &&
        other.mentions == mentions &&
        other.translatedMessage == translatedMessage &&
        other.displayState == displayState;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        conversationId.hashCode ^
        content.hashCode ^
        description.hashCode ^
        type.hashCode ^
        createdAt.hashCode ^
        senderId.hashCode ^
        sender.hashCode ^
        isLocal.hashCode ^
        forwardedFrom.hashCode ^
        repliedFrom.hashCode ^
        reactions.hashCode ^
        mentions.hashCode ^
        translatedMessage.hashCode ^
        displayState.hashCode;
  }

  static MessageType _parseType(String json) {
    return MessageType.values.firstWhere((e) => e.value == json);
  }

  String get contentWithoutFormat {
    String result = content.replaceAllMapped(RegExp(r'<[^>]*>'), (match) => '');

    if (mentions != null && mentions!.isNotEmpty) {
      for (final mention in mentions!.entries) {
        final userId = mention.key.replaceAll(RegExp(r'@|\$|\{|\}'), '');

        result = result.replaceAll('@\${$userId}', '@${mention.value}');
      }
    }

    return result;
  }

  List<String> get linksInContent {
    final matches =
        RegExp(
          '<${AppConstants.hyperTextTag}>(.*?)</${AppConstants.hyperTextTag}>',
        ).allMatches(content).map((match) => match.group(1)).toList();

    return matches
        .where((link) => link != null && Uri.tryParse(link) != null)
        .map((link) => link!)
        .toList();
  }

  bool get isCallJitsi => description == 'jitsi';
}

enum MessageType {
  text('T'),
  hyperText('HT'),
  image('I'),
  video('V'),
  audio('A'),
  call('C'),
  file('F'),
  sticker('S'),
  post('P'),
  system('Sy');

  final String value;

  const MessageType(this.value);
}

extension MessageTypeX on MessageType {
  bool get isTranslatable =>
      this == MessageType.text || this == MessageType.hyperText;
}
