import 'dart:convert';

import 'call_history.dart';
import 'callers.dart';
import 'conversation.dart';
import 'receivers.dart';

class Call {
  String id;
  String chatChannelId;
  bool? isGroup;
  bool? isVideo;
  bool? isTranslate;
  DateTime? createdAt;
  DateTime? startedAt;
  DateTime? canceledAt;
  DateTime? endedAt;
  int? duration;
  List<Callers> callers;
  List<Receivers> receivers;
  List<CallHistory>? callHistories;
  Conversation? conversation;

  Call({
    required this.id,
    required this.chatChannelId,
    this.isGroup,
    this.isVideo,
    this.isTranslate,
    this.createdAt,
    this.startedAt,
    this.canceledAt,
    this.endedAt,
    this.duration,
    this.callers = const [],
    this.receivers = const [],
    this.callHistories,
    this.conversation,
  });

  factory Call.fromJson(Map<String, dynamic> json) {
    return Call(
      id: json['id'] as String,
      chatChannelId: json['chat_channel_id'] as String,
      isGroup: json['is_group'] as bool?,
      isVideo: json['is_video'] as bool?,
      isTranslate: json['is_translate'] as bool?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      startedAt:
          json['started_at'] != null
              ? DateTime.parse(json['started_at'] as String)
              : null,
      canceledAt:
          json['canceled_at'] != null
              ? DateTime.parse(json['canceled_at'] as String)
              : null,
      endedAt:
          json['ended_at'] != null
              ? DateTime.parse(json['ended_at'] as String)
              : null,
      duration: json['duration'] as int?,
      callers:
          json['callers'] != null
              ? Callers.fromJsonList(json['callers'] as List<dynamic>)
              : [],
      receivers:
          json['receivers'] != null
              ? Receivers.fromJsonList(json['receivers'] as List<dynamic>)
              : [],
      callHistories:
          json['participants'] != null
              ? CallHistory.fromJsonList(json['participants'] as List<dynamic>)
              : null,
      conversation:
          json['conversation'] != null
              ? Conversation.fromJson(
                json['conversation'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatChannelId': chatChannelId,
      'isGroup': isGroup,
      'isVideo': isVideo,
      'isTranslate': isTranslate,
      'createdAt': createdAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'canceledAt': canceledAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'duration': duration,
      'callers': callers.map((e) => e.toJson()).toList(),
      'receivers': receivers.map((e) => e.toJson()).toList(),
      'participants': callHistories?.map((e) => e.toJson()).toList(),
      'conversation': conversation?.toJson(),
    };
  }

  static List<Call> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => Call.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Call? callFromStringJson(String? json) {
    if (json == null || json.isEmpty) {
      return null;
    }

    return Call.fromJson(jsonDecode(json));
  }

  Call copyWith({
    String? id,
    String? chatChannelId,
    bool? isGroup,
    bool? isVideo,
    bool? isTranslate,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? canceledAt,
    DateTime? endedAt,
    int? duration,
    List<Callers>? callers,
    List<Receivers>? receivers,
    List<CallHistory>? callHistories,
    Conversation? conversation,
  }) {
    return Call(
      id: id ?? this.id,
      chatChannelId: chatChannelId ?? this.chatChannelId,
      isGroup: isGroup ?? this.isGroup,
      isVideo: isVideo ?? this.isVideo,
      isTranslate: isTranslate ?? this.isTranslate,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      canceledAt: canceledAt ?? this.canceledAt,
      endedAt: endedAt ?? this.endedAt,
      duration: duration ?? this.duration,
      callers: callers ?? this.callers,
      receivers: receivers ?? this.receivers,
      callHistories: callHistories ?? this.callHistories,
      conversation: conversation ?? this.conversation,
    );
  }
}
