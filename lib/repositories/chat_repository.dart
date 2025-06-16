import 'dart:async';
import 'dart:collection';

import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../core/configs/env_config.dart';
import '../core/mixins/log_mixin.dart';
import '../data/preferences/app_preferences.dart';
import '../models/add_or_remove_user_by_socket.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/new_message.dart';
import '../models/unread_message.dart';
import 'base/api_service.dart';

class ChatRepository with LogMixin {
  final ApiService apiService = ApiService();

  // Socket related properties
  io.Socket? _socket;
  late Completer _initSocketCompleter;

  // Socket event callbacks
  Function(NewMessage)? _onNewMessage;
  Function(int)? _onUserConnected;
  Function(int)? _onUserDisconnected;
  Function(String)? _onConversationDeleted;
  Function(UnreadMessage)? _onUnreadMessage;
  Function(String, String)? _onMessageDeleted;
  Function(String, String, String, int)? _onReactToMessage;
  Function(String, String, String, int)? _onUnReactToMessage;
  Function(AddOrRemoveUserBySocket)? _onAddOrRemoveUserToGroup;
  Function(String, int, DateTime)? _onUserSeen;

  Future<List<Conversation>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    final queryParameters = {
      'skip': ((page - 1) * limit).toString(),
      'limit': limit.toString(),
    };

    final response = await apiService.callApi(
      method: METHOD.get,
      envUrl: APIURL.chatUrl,
      url: '/room',
      params: queryParameters,
      authen: true,
    );

    // Handle error response
    if (response is Map<String, dynamic> && response['error'] == true) {
      final statusCode = response['statusCode'] as int?;
      final errorData = response['data'] as Map<String, dynamic>?;

      if (statusCode == 401) {
        throw Exception(
          'Authentication failed: ${errorData?['message'] ?? 'Please authenticate'}',
        );
      }

      throw Exception('API Error: ${errorData?['message'] ?? 'Unknown error'}');
    }

    final respData = response as Map<String, dynamic>;
    return Conversation.fromJsonList(respData['rooms']);
  }

  Future<List<Message>> getPaginatedMessagesByConversationId({
    required String conversationId,
    required int page,
    required int pageSize,
  }) async {
    final queryParameters = {
      'skip': ((page - 1) * pageSize).toString(),
      'limit': pageSize.toString(),
    };

    final response = await apiService.callApi(
      method: METHOD.get,
      envUrl: APIURL.chatUrl,
      url: '/message/$conversationId',
      params: queryParameters,
      authen: true,
    );

    final respData = response as Map<String, dynamic>;

    return Message.fromJsonList(respData['messages']);
  }

  Future<Message> sendMessage(
    Message toSendMessage, {
    String? replyMessage,
    Map<String, String>? mentionsData,
  }) async {
    final body = <String, dynamic>{
      'content': toSendMessage.content,
      'type': toSendMessage.type.value,
    };

    if (replyMessage != null) {
      body['repliedFrom'] = replyMessage;
    }
    // if (!toSendMessage.description.isBlank) {
    //   body['description'] = toSendMessage.description!;
    // }
    if (mentionsData != null) {
      body['mentions'] = mentionsData;
    }

    final response = await apiService.callApi(
      method: METHOD.post,
      envUrl: APIURL.chatUrl,
      url: '/message/${toSendMessage.conversationId}',
      data: body,
      authen: true,
    );

    final respData = response as Map<String, dynamic>;
    return Message.fromJson(respData['new_message']);
  }

  Future reactToMessage({
    required String conversationId,
    required String messageId,
    required String reactionType,
  }) async {
    final response = await apiService.callApi(
      method: METHOD.post,
      envUrl: APIURL.chatUrl,
      url: '/message/$conversationId/$messageId/react',
      data: {'reactionType': reactionType},
      authen: true,
    );
  }

  Future unReactToMessage({
    required String conversationId,
    required String messageId,
  }) async {
    final response = await apiService.callApi(
      method: METHOD.delete,
      envUrl: APIURL.chatUrl,
      url: '/message/$conversationId/$messageId/react',
      authen: true,
    );
  }

  Future<LinkedHashMap<String, Message>> getPinnedMessages(
    String conversationId,
  ) async {
    final response = await apiService.callApi(
      method: METHOD.get,
      envUrl: APIURL.chatUrl,
      url: '/room/$conversationId/pinned-messages',
      authen: true,
    );
    final respData = response as Map<String, dynamic>;
    final LinkedHashMap<String, Message> linkedHashMap =
        LinkedHashMap<String, Message>();
    for (var element in (respData['messages'] as List<dynamic>)) {
      linkedHashMap.putIfAbsent(
        element['id'],
        () => Message.fromJson(element as Map<String, dynamic>),
      );
    }

    return linkedHashMap;
  }

  Future updatePinMessage(String id, List<String> messageId) async {
    final response = await apiService.callApi(
      method: METHOD.patch,
      envUrl: APIURL.chatUrl,
      url: '/room/$id',
      data: {'pins': messageId},
      authen: true,
    );
  }

  Future<Conversation> createConversation(List<int> userIds) async {
    final response = await apiService.callApi(
      method: METHOD.post,
      envUrl: APIURL.chatUrl,
      url: '/room',
      data: {
        'members': userIds.map((userId) => userId.toString()).toList(),
        'isGroup': userIds.length > 1,
      },
      authen: true,
    );
    final respData = response as Map<String, dynamic>;
    return Conversation.fromJson(respData['chatRoom']);
  }

  Future<void> updateGroupChatInfo({
    required Conversation conversation,
    String? name,
    String? avatarUrl,
  }) async {
    if (!conversation.isGroup) {
      throw ArgumentError('Conversation must be a group chat');
    }

    final body = <String, dynamic>{};

    if (name != null) {
      body['name'] = name;
    }

    if (avatarUrl != null) {
      body['avatar'] = avatarUrl;
    }

    await apiService.callApi(
      method: METHOD.patch,
      envUrl: APIURL.chatUrl,
      url: '/room/${conversation.id}',
      data: body,
      authen: true,
    );
  }

  Future<void> forwardMessage({
    required Message toMessage,
    required String conversationId,
  }) async {
    final body = {
      'forwardedFrom': toMessage.id,
      'content': toMessage.content,
      'type': toMessage.type.value,
    };

    return apiService.callApi(
      method: METHOD.post,
      envUrl: APIURL.chatUrl,
      url: '/message/$conversationId',
      data: body,
      authen: true,
    );
  }

  Future<void> blockUser(int userId) {
    return apiService.callApi(
      method: METHOD.post,
      envUrl: APIURL.chatUrl,
      url: '/user/$userId/block',
      data: {'userId': userId},
      authen: true,
    );
  }

  Future<void> unblockUser(int userId) {
    return apiService.callApi(
      method: METHOD.delete,
      envUrl: APIURL.chatUrl,
      url: '/user/$userId/block',
      authen: true,
    );
  }

  Future<void> deleteConversation(Conversation conversation) {
    return apiService.callApi(
      method: METHOD.delete,
      envUrl: APIURL.chatUrl,
      url: '/room/${conversation.id}',
      authen: true,
    );
  }

  Future<void> deleteMessage(Conversation conversation, Message message) {
    return apiService.callApi(
      method: METHOD.delete,
      envUrl: APIURL.chatUrl,
      url: '/message/${conversation.id}/${message.id}',
      authen: true,
    );
  }

  Future<void> leaveGroupChat(String conversationId) {
    return apiService.callApi(
      method: METHOD.patch,
      envUrl: APIURL.chatUrl,
      url: '/room/$conversationId/leave',
      authen: true,
    );
  }

  Future<void> updateConversationLastSeen(String conversationId) async {
    try {
      final response = await apiService.callApi(
        method: METHOD.patch,
        envUrl: APIURL.chatUrl,
        url: '/room/$conversationId/seen',
        authen: true,
      );

      logInfo('Last seen updated for conversation $conversationId');
    } catch (e) {
      logError('Failed to update last seen', error: e);
      rethrow;
    }
  }

  // ============================================================================
  // SOCKET METHODS
  // ============================================================================

  /// Initialize socket connection
  Future<void> initSocket() async {
    try {
      logInfo('Initializing socket...');

      _socket = io.io(
        Get.find<EnvConfig>().chatSocketUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableForceNew()
            .setQuery({'token': await _getAccessToken()})
            .build(),
      );

      _setupSocketEvents();
      logInfo('Socket initialized successfully');
    } catch (e) {
      logError('Failed to initialize socket', error: e);
      rethrow;
    }
  }

  Future<void> connectSocket() async {
    try {
      if (_socket == null) {
        await initSocket();
      }

      if (_socket?.connected == true) {
        logInfo('Socket already connected');
        return;
      }

      // Update auth token before connecting
      final token = await _getAccessToken();
      _socket?.auth = {'token': token};

      _socket?.connect();

      // Wait for connection
      final completer = Completer<void>();

      _socket?.on('connect', (_) {
        logInfo('Socket connected successfully');
        if (!completer.isCompleted) {
          completer.complete();
        }
      });

      _socket?.on('connect_error', (error) {
        logError('Socket connection error: $error');
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      });

      // Timeout after 10 seconds
      Timer(const Duration(seconds: 10), () {
        if (!completer.isCompleted) {
          completer.completeError('Socket connection timeout');
        }
      });

      await completer.future;
    } catch (e) {
      logError('Failed to connect socket', error: e);
      rethrow;
    }
  }

  Future<void> disconnectSocket() async {
    if (!_initSocketCompleter.isCompleted) {
      await _initSocketCompleter.future;
    }
    _socket?.disconnect();
  }

  void _setupSocketEvents() {
    _socket?.on('connect', (_) {
      logInfo('Socket connected');
    });

    _socket?.on('disconnect', (_) {
      logInfo('Socket disconnected');
    });

    _socket?.on('connect_error', (error) {
      logError('Socket connection error: $error');
    });

    _socket?.on('error', (error) {
      logError('Socket error: $error');
    });

    // Chat events
    _socket?.on('new-message', (data) {
      try {
        final newMessage = NewMessage.fromJson(data as Map<String, dynamic>);
        _onNewMessage?.call(newMessage);
      } catch (e) {
        logError('Error parsing new message', error: e);
      }
    });

    _socket?.on('userConnected', (data) {
      try {
        final userId = data['userId'] as int;
        _onUserConnected?.call(userId);
      } catch (e) {
        logError('Error parsing user connected', error: e);
      }
    });

    _socket?.on('userDisconnected', (data) {
      try {
        final userId = data['userId'] as int;
        _onUserDisconnected?.call(userId);
      } catch (e) {
        logError('Error parsing user disconnected', error: e);
      }
    });

    _socket?.on('room-deleted', (data) {
      try {
        final conversationId = data['roomId'] as String;
        _onConversationDeleted?.call(conversationId);
      } catch (e) {
        logError('Error parsing conversation deleted', error: e);
      }
    });

    _socket?.on('unreadMessage', (data) {
      try {
        final unreadMessage = UnreadMessage.fromJson(
          data as Map<String, dynamic>,
        );
        _onUnreadMessage?.call(unreadMessage);
      } catch (e) {
        logError('Error parsing unread message', error: e);
      }
    });

    _socket?.on('delete-message', (data) {
      try {
        logInfo('👍 Message deleted: $data');
        final conversationId = data['roomId'] as String;
        final messageId = data['messageId'] as String;
        _onMessageDeleted?.call(conversationId, messageId);
      } catch (e) {
        logError('Error parsing message deleted', error: e);
      }
    });

    _socket?.on('message-reaction', (data) {
      try {
        final conversationId = data['roomId'] as String;
        final messageId = data['messageId'] as String;
        final reactionType = data['reactionType'] as String;
        final userId = data['userId'] as String;
        _onReactToMessage?.call(
          conversationId,
          messageId,
          reactionType,
          int.parse(userId),
        );
      } catch (e) {
        logError('Error parsing react to message', error: e);
      }
    });

    _socket?.on('message-remove-reaction', (data) {
      try {
        final conversationId = data['roomId'] as String;
        final messageId = data['messageId'] as String;
        final reactionType = data['removedType'] as String;
        final userId = data['userId'] as String;
        _onUnReactToMessage?.call(
          conversationId,
          messageId,
          reactionType,
          int.parse(userId),
        );
      } catch (e) {
        logError('Error parsing unreact to message', error: e);
      }
    });

    _socket?.on('room-updated', (data) {
      try {
        logInfo('👍 Room update: $data');
        final addOrRemoveUser = AddOrRemoveUserBySocket.fromJson(
          data as Map<String, dynamic>,
        );
        _onAddOrRemoveUserToGroup?.call(addOrRemoveUser);
      } catch (e) {
        logError('Error parsing add/remove user to group', error: e);
      }
    });

    _socket?.on('userSeen', (data) {
      try {
        final roomId = data['roomId'] as String;
        final userId = data['userId'] as int;
        final lastSeen = DateTime.parse(data['lastSeen'] as String);
        _onUserSeen?.call(roomId, userId, lastSeen);
      } catch (e) {
        logError('Error parsing user seen', error: e);
      }
    });
  }

  Future<String?> _getAccessToken() async {
    try {
      final appPreferences = AppPreferences();
      return await appPreferences.getAccessToken();
    } catch (e) {
      logError('Failed to get access token', error: e);
      return null;
    }
  }

  Future<List<int>> getActiveUsers() async {
    // TODO: Implement API call to get active users
    // For now, return empty list
    return [];
  }

  // Event listener setters
  void onNewMessage(Function(NewMessage) callback) {
    _onNewMessage = callback;
  }

  void onUserConnected(Function(int) callback) {
    _onUserConnected = callback;
  }

  void onUserDisconnected(Function(int) callback) {
    _onUserDisconnected = callback;
  }

  void onConversationDeleted(Function(String) callback) {
    _onConversationDeleted = callback;
  }

  void onUnreadMessage(Function(UnreadMessage) callback) {
    _onUnreadMessage = callback;
  }

  void onMessageDeleted(Function(String, String) callback) {
    _onMessageDeleted = callback;
  }

  void onReactToMessage(Function(String, String, String, int) callback) {
    _onReactToMessage = callback;
  }

  void onUnReactToMessage(Function(String, String, String, int) callback) {
    _onUnReactToMessage = callback;
  }

  void onAddOrRemoveUserToGroup(Function(AddOrRemoveUserBySocket) callback) {
    _onAddOrRemoveUserToGroup = callback;
  }

  void onUserSeen(Function(String, int, DateTime) callback) {
    _onUserSeen = callback;
  }

  // Emit socket events
  void emitJoinRoom(String roomId) {
    _socket?.emit('joinRoom', {'roomId': roomId});
  }

  void emitLeaveRoom(String roomId) {
    _socket?.emit('leaveRoom', {'roomId': roomId});
  }

  void emitTyping(String roomId, bool isTyping) {
    _socket?.emit('typing', {'roomId': roomId, 'isTyping': isTyping});
  }

  void emitSeenMessage(String roomId, String messageId) {
    _socket?.emit('seenMessage', {'roomId': roomId, 'messageId': messageId});
  }

  // Group management methods
  Future<void> updateConversationMembers({
    required String conversationId,
    required List<int> membersIds,
    required List<int> adminIds,
  }) {
    return apiService.callApi(
      method: METHOD.patch,
      envUrl: APIURL.chatUrl,
      url: '/room/$conversationId',
      data: {
        'members': membersIds.map((id) => id.toString()).toList(),
        'admins': adminIds.map((id) => id.toString()).toList(),
      },
      authen: true,
    );
  }

  Future<void> removeUserFromGroupChat(
    String conversationId,
    int userId,
  ) async {
    try {
      final response = await apiService.callApi(
        method: METHOD.delete,
        envUrl: APIURL.chatUrl,
        url: '/room/$conversationId/members/$userId',
        authen: true,
      );

      logInfo('User $userId removed from group $conversationId successfully');
    } catch (e) {
      logError('Failed to remove user from group', error: e);
      rethrow;
    }
  }
}
