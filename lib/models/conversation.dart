import 'package:get/get.dart';

import '../presentation/features/auth/auth_controller.dart';
import 'message.dart';
import 'user.dart';

class Conversation {
  final String id;
  final String name;
  final int creatorId;
  final List<int> memberIds;
  final bool isGroup;
  final List<Message> messages;
  final String? avatar;
  final bool isLocked;
  final List<User> members;
  final List<int> adminIds;
  final List<User> admins;
  final int? lastSeen;
  final int? unreadCount;
  final bool isBlocked;
  final bool blockedByMe;
  final bool? isMuted;
  final int? mutedUntil;
  final List<String>? pins;
  final bool isMarkRead;
  final bool isPinned;
  final List<User> memberActionSystem;
  final Map<String, int>? lastSeenUsers;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.memberIds,
    required this.isGroup,
    required this.members,
    required this.messages,
    required this.adminIds,
    this.isLocked = false,
    this.avatar,
    this.admins = const [],
    this.lastSeen,
    this.unreadCount,
    this.isBlocked = false,
    this.blockedByMe = false,
    this.isMuted,
    this.mutedUntil,
    this.pins,
    this.memberActionSystem = const [],
    this.lastSeenUsers,
    this.isMarkRead = false,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
  });

  Message? get lastMessage {
    if (messages.isEmpty) {
      return null;
    }
    return messages.first;
  }

  String? avatarUrl() {
    final currentUserId = Get.find<AuthController>().currentUser.value?.id;

    if (avatar != null) {
      return avatar;
    }

    if (!isGroup && members.isNotEmpty) {
      // For private chats, use the other person's avatar
      if (currentUserId != null) {
        final otherMember = members.firstWhere(
          (member) => member.id != currentUserId,
          orElse: () => members.first,
        );
        return otherMember.avatarPath ?? '';
      }
      // If no currentUserId provided, use the first member
      final otherMember = members.isNotEmpty ? members.first : null;
      return otherMember?.avatarPath ?? '';
    }

    return '';
  }

  String title() {
    final partner = chatPartner();
    return partner?.fullName ?? name;
  }

  User? chatPartner() {
    final currentUserId = Get.find<AuthController>().currentUser.value?.id;

    if (!isGroup && members.isNotEmpty) {
      if (currentUserId != null) {
        // Filter out the current user and return the other member
        return members.firstWhere(
          (member) => member.id != currentUserId,
          orElse: () => members.first,
        );
      }
      // Return the first member for now if no currentUserId provided
      // In a real app, this would filter out the current user
      return members.first;
    }
    return null;
  }

  User? get creator {
    for (final member in members) {
      if (member.id == creatorId) {
        return member;
      }
    }
    return null;
  }

  bool isAdmin(int userId) => adminIds.contains(userId);

  bool isCreator(int userId) => creatorId == userId;

  bool isCreatorOrAdmin(int userId) => isCreator(userId) || isAdmin(userId);

  Conversation copyWith({
    String? id,
    String? name,
    int? creatorId,
    List<int>? memberIds,
    bool? isGroup,
    List<User>? members,
    List<Message>? messages,
    String? avatar,
    List<int>? adminIds,
    List<User>? admins,
    int? lastSeen,
    int? unreadCount,
    bool? isBlocked,
    bool? blockedByMe,
    bool? isMuted,
    int? mutedUntil,
    List<String>? pins,
    List<User>? memberActionSystem,
    Map<String, int>? lastSeenUsers,
    bool? isMarkRead,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
  }) {
    return Conversation(
      id: id ?? this.id,
      name: name ?? this.name,
      creatorId: creatorId ?? this.creatorId,
      memberIds: memberIds ?? this.memberIds,
      isGroup: isGroup ?? this.isGroup,
      members: members ?? this.members,
      messages: messages ?? this.messages,
      avatar: avatar ?? this.avatar,
      isLocked: isLocked,
      adminIds: adminIds ?? this.adminIds,
      admins: admins ?? this.admins,
      lastSeen: lastSeen ?? this.lastSeen,
      unreadCount: unreadCount ?? this.unreadCount,
      isBlocked: isBlocked ?? this.isBlocked,
      blockedByMe: blockedByMe ?? this.blockedByMe,
      isMuted: isMuted ?? this.isMuted,
      mutedUntil: mutedUntil ?? this.mutedUntil,
      pins: pins ?? this.pins,
      memberActionSystem: memberActionSystem ?? this.memberActionSystem,
      lastSeenUsers: lastSeenUsers ?? this.lastSeenUsers,
      isMarkRead: isMarkRead ?? this.isMarkRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      name: _parseName(
        json['name'] as String? ?? '',
        isGroup: json['isGroup'] as bool? ?? false,
      ),
      creatorId: _parseIntFromString(json['creator']),
      memberIds: _parseIntList(json['members']),
      isGroup: json['isGroup'] ?? false,
      messages:
          json['messages'] != null
              ? (json['messages'] as List)
                  .map((e) => Message.fromJson(e as Map<String, dynamic>))
                  .toList()
              : [],
      members:
          json['membersUserModel'] != null
              ? (json['mmembersUserModel'] as List)
                  .map((e) => User.fromJson(e as Map<String, dynamic>))
                  .toList()
              : [],
      avatar: json['avatar'],
      isLocked: json['isLocked'] ?? false,
      adminIds: _parseIntList(json['admins']),
      admins:
          json['adminsUserModel'] != null && json['adminsUserModel'].isNotEmpty
              ? (json['adminsUserModel'] as List)
                  .map((e) => User.fromJson(e as Map<String, dynamic>))
                  .toList()
              : [],
      unreadCount: json['unreadCount'],
      lastSeen: _parseLastSeen(json['lastSeen']),
      isBlocked: json['isBlocked'] ?? false,
      blockedByMe: json['blockedByYou'] ?? false,
      isMuted: json['isMuted'],
      mutedUntil: json['mutedUntil'],
      pins:
          json['pins'] != null
              ? (json['pins'] as List).map((e) => e.toString()).toList()
              : null,
      lastSeenUsers: (json['lastSeenUsers'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value as int),
      ),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'creator': creatorId.toString(),
      'members': memberIds.map((e) => e.toString()).toList(),
      'membersUserModel': members.map((e) => e.toJson()).toList(),
      'isGroup': isGroup,
      'messages': messages.map((e) => e.toJson()).toList(),
      'avatar': avatar,
      'isLocked': isLocked,
      'admins': adminIds.map((e) => e.toString()).toList(),
      'adminsUserModel': admins.map((e) => e.toJson()).toList(),
      'unreadCount': unreadCount,
      'lastSeen': lastSeen,
      'isBlocked': isBlocked,
      'blockedByYou': blockedByMe,
      'isMuted': isMuted,
      'mutedUntil': mutedUntil,
      'pins': pins,
      'lastSeenUsers': lastSeenUsers,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper methods for parsing
  static int _parseIntFromString(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static List<int> _parseIntList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) {
        if (e is int) return e;
        if (e is String) return int.tryParse(e) ?? 0;
        return 0;
      }).toList();
    }
    return [];
  }

  static int? _parseLastSeen(dynamic lastSeen) {
    if (lastSeen == null) return null;
    if (lastSeen is int) return lastSeen;
    if (lastSeen is String) return int.tryParse(lastSeen);
    return null;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static List<Conversation> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String _parseName(String name, {bool? isGroup}) {
    if (isGroup ?? false) {
      return name;
    }

    // For private chats, the name might contain user IDs
    // This is a simplified version without the current user context
    if (name.contains('_')) {
      final parts = name.split('_');
      return parts.length > 1 ? parts[1] : name;
    }

    return name;
  }
}
