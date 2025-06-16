import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/mixins/log_mixin.dart';
import '../events/messages/show_unread_message_event.dart';
import '../models/add_or_remove_user_by_socket.dart';
import '../models/message.dart';
import '../models/new_message.dart';
import '../models/unread_message.dart';
import '../presentation/features/auth/auth_controller.dart';
import '../repositories/chat_repository.dart';

class ChatSocketService extends GetxService
    with LogMixin, WidgetsBindingObserver {
  final _chatRepository = Get.find<ChatRepository>();
  final _eventBus = Get.find<EventBus>();

  final GetStream<Message> _newMessageStream = GetStream<Message>();

  Stream<Message> get newMessageStream => _newMessageStream.stream.distinct();

  final List<int> _activeUsers = [];

  final GetStream<List<int>> _activeUsersStream = GetStream<List<int>>();

  GetStream<List<int>> get activeUsersStream => _activeUsersStream;

  final GetStream<String> _onConversationDeletedStream = GetStream<String>();

  GetStream<String> get onConversationDeletedStream =>
      _onConversationDeletedStream;

  final GetStream<UnreadMessage> _onUnreadMessageStream =
      GetStream<UnreadMessage>();

  GetStream<UnreadMessage> get onUnreadMessageStream => _onUnreadMessageStream;

  final GetStream<Map<String, dynamic>> _onMessageDeletedStream =
      GetStream<Map<String, dynamic>>();

  GetStream<Map<String, dynamic>> get onMessageDeletedStream =>
      _onMessageDeletedStream;

  final GetStream<Map<String, dynamic>> _onReactToMessageStream =
      GetStream<Map<String, dynamic>>();

  GetStream<Map<String, dynamic>> get onReactToMessageStream =>
      _onReactToMessageStream;

  final GetStream<Map<String, dynamic>> _onUnReactToMessageStream =
      GetStream<Map<String, dynamic>>();

  GetStream<Map<String, dynamic>> get onUnReactToMessageStream =>
      _onUnReactToMessageStream;

  final GetStream<AddOrRemoveUserBySocket> _onAddOrRemoveUserToGroupStream =
      GetStream<AddOrRemoveUserBySocket>();

  GetStream<AddOrRemoveUserBySocket> get onAddOrRemoveUserToGroupStream =>
      _onAddOrRemoveUserToGroupStream;

  final GetStream<Map<String, dynamic>> _onSeenToMessageStream =
      GetStream<Map<String, dynamic>>();

  GetStream<Map<String, dynamic>> get onSeenToMessageStream =>
      _onSeenToMessageStream;

  // Connection state
  final RxBool _isConnected = false.obs;
  bool get isConnected => _isConnected.value;

  @override
  Future<void> onInit() async {
    super.onInit();

    // Add lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    await _chatRepository.initSocket();
    // unawaited(_getActiveUsers());
    _setupSocketListeners();

    logInfo('ChatSocketService initialized');
  }

  @override
  void onClose() {
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    _chatRepository.disconnectSocket();
    _newMessageStream.close();
    _isConnected.value = false;
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    logInfo('App lifecycle state changed: $state');

    switch (state) {
      case AppLifecycleState.paused:
        logInfo('App paused - keeping socket connection');
        // Keep connection for background notifications
        break;
      case AppLifecycleState.resumed:
        logInfo('App resumed - checking socket connection');
        _handleAppResumed();
        break;
      case AppLifecycleState.detached:
        logInfo('App detached - disconnecting socket');
        disconnectSocket();
        break;
      default:
        break;
    }
  }

  void _handleAppResumed() {
    // Reconnect socket if user is logged in but socket is not connected
    final authController = Get.find<AuthController>();
    if (authController.isLoggedIn.value && !_isConnected.value) {
      unawaited(connectSocket());
    }
  }

  Future<void> _getActiveUsers() async {
    final authController = Get.find<AuthController>();
    if (!authController.isLoggedIn.value) {
      return;
    }

    final activeUsers = await _chatRepository.getActiveUsers();
    _activeUsers.addAll(activeUsers);
    _activeUsersStream.add(_activeUsers);
  }

  void _setupSocketListeners() {
    _chatRepository.onNewMessage((newMessage) {
      _handleNewMessage(newMessage);
    });

    _chatRepository.onUserConnected((userId) {
      _activeUsers.add(userId);
      _activeUsersStream.add(_activeUsers);
    });

    _chatRepository.onUserDisconnected((userId) {
      _activeUsers.remove(userId);
      _activeUsersStream.add(_activeUsers);
    });

    _chatRepository.onConversationDeleted((conversationId) {
      _onConversationDeletedStream.add(conversationId);
    });

    _chatRepository.onUnreadMessage((unreadMessage) {
      _onUnreadMessageStream.add(unreadMessage);

      // to show unread message badge in the message nav item
      _eventBus.fire(ShowUnreadMessageEvent());
    });

    _chatRepository.onMessageDeleted((conversationId, messageId) {
      _onMessageDeletedStream.add({
        'conversationId': conversationId,
        'messageId': messageId,
      });
    });

    _chatRepository.onReactToMessage((
      conversationId,
      messageId,
      reactionType,
      userId,
    ) {
      _onReactToMessageStream.add({
        'conversationId': conversationId,
        'messageId': messageId,
        'reactionType': reactionType,
        'userId': userId,
      });
    });

    _chatRepository.onUnReactToMessage((
      conversationId,
      messageId,
      reactionType,
      userId,
    ) {
      _onUnReactToMessageStream.add({
        'conversationId': conversationId,
        'messageId': messageId,
        'reactionType': reactionType,
        'userId': userId,
      });
    });

    _chatRepository.onAddOrRemoveUserToGroup((addOrRemoveUser) {
      _onAddOrRemoveUserToGroupStream.add(addOrRemoveUser);
    });

    _chatRepository.onUserSeen((roomId, userId, lastSeen) {
      _onSeenToMessageStream.add({
        'roomId': roomId,
        'userId': userId,
        'lastSeen': lastSeen,
      });
    });
  }

  Future<void> connectSocket() async {
    try {
      logInfo('Connecting to socket...');
      await _chatRepository.connectSocket();
      _isConnected.value = true;
      logInfo('Socket connected successfully');
    } catch (e) {
      logError('Failed to connect socket', error: e);
      _isConnected.value = false;
      rethrow;
    }
  }

  void disconnectSocket() {
    try {
      logInfo('Disconnecting socket...');
      _chatRepository.disconnectSocket();
      _isConnected.value = false;
      logInfo('Socket disconnected');
    } catch (e) {
      logError('Failed to disconnect socket', error: e);
    }
  }

  Future<void> _handleNewMessage(NewMessage newMessage) async {
    final message = newMessage.message;

    if (message == null) {
      return;
    }

    _newMessageStream.add(message);
  }
}
