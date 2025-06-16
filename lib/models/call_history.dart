import 'call.dart';

class CallHistory {
  final Call? call;
  final int userId;
  final String status;
  final int duration;
  final DateTime? joinedAt;
  final DateTime? leftAt;
  final String? role;

  CallHistory({
    required this.userId,
    required this.status,
    required this.duration,
    this.call,
    this.joinedAt,
    this.leftAt,
    this.role,
  });

  factory CallHistory.fromJson(Map<String, dynamic> json) {
    return CallHistory(
      userId: json['user_id'] as int,
      status: json['status'] as String,
      duration: json['duration'] as int,
      call:
          json['call'] != null
              ? Call.fromJson(json['call'] as Map<String, dynamic>)
              : null,
      joinedAt:
          json['joined_at'] != null
              ? DateTime.parse(json['joined_at'] as String)
              : null,
      leftAt:
          json['left_at'] != null
              ? DateTime.parse(json['left_at'] as String)
              : null,
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'status': status,
      'duration': duration,
      'call': call?.toJson(),
      'joinedAt': joinedAt?.toIso8601String(),
      'leftAt': leftAt?.toIso8601String(),
      'role': role,
    };
  }

  static List<CallHistory> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => CallHistory.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
