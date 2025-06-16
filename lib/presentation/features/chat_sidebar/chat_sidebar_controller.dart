import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constans/app_constants.dart';
import '../../../core/helpers/media_helper.dart';
import '../../../core/utils/log_util.dart';
import '../../../core/utils/toast_util.dart';
import '../../../data/preferences/app_preferences.dart';
import '../../../models/conversation.dart';
import '../../../models/message.dart';
import '../../../models/user.dart';
import '../../../repositories/chat_repository.dart';
import '../../../repositories/storage_repo.dart';
import '../../../repositories/user_repository.dart';
import '../../../services/chat_socket_service.dart';
import '../auth/auth_controller.dart';

enum SearchType { suggest, nft, phone, email, username, lastname, firstname }

class ChatSidebarController extends GetxController {
  // ============================================================================
  // OBSERVABLE PROPERTIES
  // ============================================================================
  final StorageRepository _storageRepository = Get.find<StorageRepository>();
  final ChatRepository chatRepository = Get.find<ChatRepository>();
  final ChatSocketService _socketService = Get.find<ChatSocketService>();
  final EventBus _eventBus = Get.find<EventBus>();

  // Debounce timer for search
  Timer? _searchDebounceTimer;

  // Request tracking to prevent race conditions
  int _currentSearchRequestId = 0;

  // Conversation Lists
  final RxList<Conversation> _conversations = <Conversation>[].obs;
  final RxList<Conversation> _archivedConversations = <Conversation>[].obs;
  final RxList<Conversation> _pinConversations = <Conversation>[].obs;
  final RxList<Conversation> filterAllConversations = <Conversation>[].obs;

  final RxList<Message> _messages = <Message>[].obs;
  RxInt currentConversationIndex = (-1).obs;
  final RxBool isLoadingMessages = false.obs;
  final RxBool hasMoreMessages = true.obs;
  final RxInt currentMessagePage = 1.obs;
  final Rxn<Message> _replyFromMessage = Rxn<Message>();
  String pathLocal = '';

  // UI State
  final RxBool isLoadingInit = true.obs;
  final RxBool isLazyLoading = false.obs;
  final RxBool hasMoreConversations = true.obs;
  final RxBool showGroupConversations = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isMuatruoc = false.obs;
  final RxBool isShowChatProfile = false.obs;

  // Profile width for resizable profile panel
  final RxDouble profileWidth = 350.0.obs;
  final RxBool isShowChatResource = false.obs;
  final RxBool isShowChatMember = false.obs;

  final RxBool isSearch = false.obs;

  final RxBool isCreateGroup = false.obs;
  final RxList<User> selectedUsersCreateGroup = <User>[].obs;
  final TextEditingController groupNameController = TextEditingController();

  // Search properties
  final RxBool isLoadingSearch = false.obs;
  final RxList<User> searchUsers = <User>[].obs;
  final RxList<Conversation> searchConversations = <Conversation>[].obs;
  final Rx<SearchType> selectedSearchType = SearchType.suggest.obs;
  final RxInt currentTabIndex = 0.obs;
  final RxBool isInitChat = true.obs;

  // Unread Messages
  final _unReadMessageCount = 0.obs;

  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final FocusNode searchFocusNode = FocusNode();
  final RxString textFieldMessage = ''.obs;

  /// Search controller for forward dialog
  final TextEditingController forwardSearchController = TextEditingController();
  final RxString forwardSearchQuery = ''.obs;

  // User Stories
  // final RxList<UserStory> userStorys = <UserStory>[].obs;

  // ============================================================================
  // GETTERS
  // ============================================================================

  /// Get active conversations (excluding archived ones)
  List<Conversation> get conversations =>
      _conversations.where((c) => !_archivedConversations.contains(c)).toList();

  /// Get archived conversations
  List<Conversation> get archivedConversations =>
      _archivedConversations.toList();

  /// Get pinned conversations
  List<Conversation> get pinConversations => _pinConversations.toList();

  /// Get all conversations (including archived)
  List<Conversation> get allConversations => _conversations.toList();

  /// Get user stories list
  // List<UserStory> get listUserStorys => userStorys.toList();

  /// Get unread message count stream
  Stream<int> get unReadMessageCountStream =>
      _unReadMessageCount.stream.asBroadcastStream();

  /// Get current unread message count
  int get unReadMessageCount => _unReadMessageCount.value;

  /// Get archived conversation subtitles for display
  String get archivedConversationSubTitles {
    final conversations = archivedConversations.take(5).toList();
    return conversations.map((conversation) => conversation.title()).join(', ');
  }

  /// Get messages by conversation id
  List<Message> get messages => _messages.toList();

  Message? get replyFromMessage => _replyFromMessage.value;

  final RxList<String> _images = <String>[].obs;
  List<String> get images => _images.reversed.toList();

  final RxList<Message> _pinnedMessages = <Message>[].obs;
  List<Message> get pinnedMessages => _pinnedMessages;

  LinkedHashMap<String, Message> _pinnedMessagesMap = LinkedHashMap();

  RxInt currentReplyIndex = (-1).obs;

  final RxList<String> _videos = <String>[].obs;
  List<String> get videos => _videos.reversed.toList();

  final RxList<String> _audios = <String>[].obs;
  List<String> get audios => _audios.reversed.toList();

  final RxList<String> _links = <String>[].obs;
  List<String> get links => _links.reversed.toList();

  final RxList<String> _groups = <String>[].obs;
  List<String> get groups => _groups.reversed.toList();

  final RxList<PickedMedia> _toSendImages = <PickedMedia>[].obs;

  List<PickedMedia> get toSendImages => _toSendImages.toList();

  // ============================================================================
  // CONTROLLERS & SUBSCRIPTIONS
  // ============================================================================

  final ScrollController conversationScrollController = ScrollController();
  final TextEditingController conversationNameController =
      TextEditingController();
  final TextEditingController messageTextController = TextEditingController();

  late StreamSubscription _newMessageSubscription;
  late StreamSubscription _conversationDeletedSubscription;
  late StreamSubscription _unreadMessageSubscription;
  late StreamSubscription _messageDeletedSubscription;
  late StreamSubscription _addOrRemoveUserBySocketSubscription;
  late StreamSubscription _messageSeenSubscription;
  late StreamSubscription _messageReactionSubscription;
  late StreamSubscription _messageUnreactionSubscription;
  late StreamSubscription _activeUsersSubscription;
  late StreamSubscription _eventBusSubscription;

  Worker? worker;
  int _currentConversationPage = 1;

  // ============================================================================
  // LIFECYCLE METHODS
  // ============================================================================

  @override
  Future<void> onInit() async {
    super.onInit();
    await initializeController();
    _setupSocketListeners();
  }

  @override
  void onClose() {
    // Cancel debounce timer
    _searchDebounceTimer?.cancel();

    // Cancel all socket subscriptions
    _newMessageSubscription.cancel();
    _conversationDeletedSubscription.cancel();
    _unreadMessageSubscription.cancel();
    _messageDeletedSubscription.cancel();
    _addOrRemoveUserBySocketSubscription.cancel();
    _messageSeenSubscription.cancel();
    _messageReactionSubscription.cancel();
    _messageUnreactionSubscription.cancel();
    _activeUsersSubscription.cancel();
    // _eventBusSubscription.cancel();

    // Leave current conversation room if any
    if (currentConversationIndex.value >= 0 &&
        currentConversationIndex.value < _conversations.length) {
      chatRepository.emitLeaveRoom(
        _conversations[currentConversationIndex.value].id,
      );
    }

    super.onClose();
  }

  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   if (state == AppLifecycleState.resumed) {
  //     // Handle app resume if needed
  //   }
  // }

  /// Reset controller state

  /// Initialize controller with all necessary setup
  Future<void> initializeController() async {
    // Add small delay to ensure storage is fully synced after login
    await Future.delayed(const Duration(milliseconds: 100));

    // Verify token is available before making API calls
    final token = await Get.find<AppPreferences>().getAccessToken();
    if (token?.isNotEmpty == true) {
      print(
        '✅ Token verified in ChatSidebarController: ${token!.substring(0, 20)}...',
      );
    } else {
      print('⚠️ No token found in ChatSidebarController, waiting...');
      await Future.delayed(const Duration(milliseconds: 200));
    }

    _getConversations();
  }

  /// Refresh conversations and reset pagination
  @override
  Future<void> refresh() async {
    _currentConversationPage = 1;
    hasMoreConversations.value = true;
    _conversations.clear();
    isSearching.value = false;
    await _getConversations();
  }

  /// Load more conversations for lazy loading
  Future<void> loadMoreConversations() async {
    await _getConversations();
  }

  /// Load conversations with pagination
  Future<void> _getConversations({int retryCount = 0}) async {
    try {
      log('isLazyLoading: ${isLazyLoading.value}');
      log('hasMoreConversations: ${hasMoreConversations.value}');
      if (isLazyLoading.value || !hasMoreConversations.value) return;

      isLazyLoading.value = true;
      final conversations = await chatRepository.getConversations(
        page: _currentConversationPage,
        limit: 30,
      );

      final filteredConversations =
          conversations
              .where((conversation) => conversation.messages.isNotEmpty)
              .toList();

      final updatedConversations = await _updateAllConversationMembersOptimized(
        filteredConversations,
      );

      if (_currentConversationPage == 1) {
        _conversations.clear();
      }

      _conversations.addAll(updatedConversations);
      // _conversations.value = conversations;
      if (conversations.length < 20) {
        hasMoreConversations.value = false;
      }

      isLoadingInit.value = false;
      _currentConversationPage++;
      isLazyLoading.value = false;
    } catch (e) {
      print('❌ Error loading conversations: $e');

      // Handle authentication errors specifically
      if (e.toString().contains('Authentication failed') ||
          e.toString().contains('Please authenticate')) {
        print('🔑 Authentication error detected');

        // Retry with exponential backoff (max 3 retries)
        if (retryCount < 3) {
          final delayMs = [1000, 2000, 5000][retryCount];
          print('🔄 Retrying in ${delayMs}ms... (attempt ${retryCount + 1}/3)');

          await Future.delayed(Duration(milliseconds: delayMs));
          return _getConversations(retryCount: retryCount + 1);
        } else {
          print('💡 Max retries reached. Try refreshing the page manually.');
        }

        // Temporarily disable auto-logout for testing
        // final authController = Get.find<AuthController>();
        // await authController.signOut();
        return;
      }

      isLoadingInit.value = false;
      isLazyLoading.value = false;
      hasMoreConversations.value = true;
    }
  }

  Future<void> getMessages() async {
    try {
      isLoadingMessages.value = true;
      final messages = await chatRepository
          .getPaginatedMessagesByConversationId(
            conversationId: _conversations[currentConversationIndex.value].id,
            page: currentMessagePage.value,
            pageSize: 20,
          );
      if (messages.isNotEmpty) {
        _messages.clear();
        _messages.addAll(messages);
        List<Message> messagesWithSenders = <Message>[];
        // Get senders for messages
        if (_conversations[currentConversationIndex.value].isGroup) {
          messagesWithSenders = await _addSendersToMessagesInGroup(messages);
        } else {
          messagesWithSenders = await _addSendersToMessagesInPrivate(messages);
        }

        _messages.clear();
        _messages.addAll(messagesWithSenders);

        hasMoreMessages.value = messages.length >= 20;
        currentMessagePage.value++;
      } else {
        hasMoreMessages.value = false;
      }

      isLoadingMessages.value = false;
    } catch (e) {
      isLoadingMessages.value = false;
    }
  }

  /// Load more messages for lazy loading
  Future<void> loadMoreMessages() async {
    if (isLazyLoading.value || !hasMoreMessages.value) return;

    try {
      isLazyLoading.value = true;

      final moreMessages = await chatRepository
          .getPaginatedMessagesByConversationId(
            conversationId: _conversations[currentConversationIndex.value].id,
            page: currentMessagePage.value,
            pageSize: 20,
          );

      if (moreMessages.isNotEmpty) {
        List<Message> messagesWithSenders = <Message>[];

        // Get senders for messages
        if (_conversations[currentConversationIndex.value].isGroup) {
          messagesWithSenders = await _addSendersToMessagesInGroup(
            moreMessages,
          );
        } else {
          messagesWithSenders = await _addSendersToMessagesInPrivate(
            moreMessages,
          );
        }

        // Add to existing messages (insert at the end since reverse: true)
        _messages.addAll(messagesWithSenders);

        hasMoreMessages.value = moreMessages.length >= 20;
        currentMessagePage.value++;

        debugPrint(
          'Loaded ${moreMessages.length} more messages. Total: ${_messages.length}',
        );
      } else {
        hasMoreMessages.value = false;
        debugPrint('No more messages to load');
      }

      isLazyLoading.value = false;
    } catch (e) {
      debugPrint('Error loading more messages: $e');
      isLazyLoading.value = false;
    }
  }

  Future<List<Message>> _addSendersToMessagesInPrivate(
    List<Message> messages,
  ) async {
    if (messages.isEmpty) return messages;

    final partner = _conversations[currentConversationIndex.value].members
        .firstWhereOrNull(
          (member) =>
              member.id != Get.find<AuthController>().currentUser.value!.id,
        );

    return messages
        .map(
          (message) => message.copyWith(
            sender:
                message.senderId ==
                        Get.find<AuthController>().currentUser.value!.id
                    ? Get.find<AuthController>().currentUser.value!
                    : partner,
            repliedFrom: message.repliedFrom?.copyWith(
              sender:
                  message.senderId ==
                          Get.find<AuthController>().currentUser.value!.id
                      ? Get.find<AuthController>().currentUser.value!
                      : partner,
            ),
          ),
        )
        .toList();
  }

  Future<List<Message>> _addSendersToMessagesInGroup(
    List<Message> messages,
  ) async {
    if (messages.isEmpty) return messages;

    // Collect unique senderIds
    final senderIds = messages.map((m) => m.senderId).toSet().toList();

    // Get all users info in one API call
    final users = await userRepository.getUsersByIds(senderIds);

    // Create a map for quick lookup
    final userMap = Map.fromEntries(
      users.map((user) => MapEntry(user.id, user)),
    );

    // Map messages with their senders
    return messages
        .map((message) => message.copyWith(sender: userMap[message.senderId]))
        .toList();
  }

  Future<void> loadConversationResources() async {
    final images = await _storageRepository.getAllConversationMediaByType(
      conversationId: _conversations[currentConversationIndex.value].id,
      messageType: MessageType.image,
    );
    _images.addAll(
      images..removeWhere(
        (image) => image.endsWith('.mp4') || image.endsWith('.mov'),
      ),
    );

    final videos = await _storageRepository.getAllConversationMediaByType(
      conversationId: _conversations[currentConversationIndex.value].id,
      messageType: MessageType.video,
    );
    _videos.addAll(videos);

    final audios = await _storageRepository.getAllConversationMediaByType(
      conversationId: _conversations[currentConversationIndex.value].id,
      messageType: MessageType.audio,
    );
    _audios.addAll(audios);
  }

  // /// Optimized method to update conversation members in batch
  Future<List<Conversation>> _updateAllConversationMembersOptimized(
    List<Conversation> conversations,
  ) async {
    return await _processConversationMembersInBackground(conversations);
  }

  /// Process conversation members in background to avoid UI blocking
  Future<List<Conversation>> _processConversationMembersInBackground(
    List<Conversation> conversations,
  ) async {
    try {
      LogUtil.d('updatedConversations: ${conversations.length}');
      // Step 1: Collect all unique member IDs
      final Set<int> allMemberIds = <int>{};
      final Map<String, List<int>> conversationMemberMap = {};

      for (final conversation in conversations) {
        // if (conversation.isGroup) continue;
        if (conversation.isGroup) {
          final List<int> memberIds =
              conversation.lastMessage != null
                  ? [conversation.lastMessage!.senderId]
                  : [];

          conversationMemberMap[conversation.id] = memberIds;
        } else {
          final memberIds = [...conversation.memberIds];
          if (!memberIds.contains(conversation.creatorId)) {
            memberIds.add(conversation.creatorId);
          }

          conversationMemberMap[conversation.id] = memberIds;
          allMemberIds.addAll(memberIds);
        }
      }

      LogUtil.i('Total unique members to fetch: ${allMemberIds.length}');

      // Step 2: Batch fetch all users in single API call
      if (allMemberIds.isEmpty) return [];

      final Map<int, User> allUsers = {};
      try {
        final users = await userRepository.getUsersByIds(allMemberIds.toList());
        for (final user in users) {
          allUsers[user.id] = user;
        }
        LogUtil.i('Batch fetched ${users.length} users in 1 API call');
      } catch (e) {
        LogUtil.e('Error batch fetching users: $e');
        return [];
      }

      // Step 3: Distribute users to conversations and prepare updates
      final List<Conversation> updatedConversations = [];

      for (final conversation in conversations) {
        if (conversation.isGroup) {
          updatedConversations.add(conversation);
        } else {
          final memberIds = conversationMemberMap[conversation.id]!;
          final List<User> membersToAdd = [];

          for (final memberId in memberIds) {
            final user = allUsers[memberId];
            if (user != null &&
                !conversation.members.any((member) => member.id == memberId)) {
              membersToAdd.add(user);
            }
          }

          if (membersToAdd.isNotEmpty) {
            final updatedMembers = [...conversation.members, ...membersToAdd];
            final updatedConversation = conversation.copyWith(
              members: updatedMembers,
              admins:
                  updatedMembers.where((member) {
                    return conversation.adminIds.contains(member.id);
                  }).toList(),
            );
            updatedConversations.add(updatedConversation);
          }
        }
      }

      return updatedConversations;
    } catch (e) {
      LogUtil.e('Error in _processConversationMembersInBackground: $e');
      return [];
    }
  }

  /// Search conversations by query
  void searchConservation(String query) {
    query = query.trim().toLowerCase();
    filterAllConversations.value =
        allConversations
            .where(
              (conversation) =>
                  conversation.title().toLowerCase().contains(query),
            )
            .take(6)
            .toList();
  }

  void sendMessage() {
    String text = textEditingController.text;
    textEditingController.clear();
    if (text.isNotEmpty) {
      sendTextMessage(text);
    }

    // if (toSendMedia != null) {
    //   _sendMediaMessage(toSendMedia!);
    // }

    if (toSendImages.isNotEmpty) {
      final medias = _toSendImages.value;
      final List<File> images = [];
      final List<PickedMedia> orther = [];

      for (var media in medias) {
        final type = media.type;
        if (type == MediaAttachmentType.image) {
          images.add(media.file);
        } else {
          orther.add(media);
        }
      }
      if (images.isNotEmpty) {
        sendImagesMessage(files: images);
      }
      if (orther.isNotEmpty) {
        for (var item in orther) {
          _sendMediaMessage(item);
        }
      }

      _toSendImages.value = [];
    }
  }

  void sendImagesMessage({required List<File> files}) async {
    String path = '';
    // setStateMessage(StateMessage.loading);
    for (var file in files) {
      path = file != files.last ? '$path${file.path} ' : path + file.path;
    }
    final currentUser = Get.find<AuthController>().currentUser;
    final localMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: _conversations[currentConversationIndex.value].id,
      content: path,
      type: MessageType.image,
      createdAt: DateTime.now(),
      senderId: currentUser.value!.id,
      sender: currentUser.value!,
      isLocal: true,
      repliedFrom: replyFromMessage,
    );

    _insertMessage(localMessage, markAsNew: true);
    // _scrollToBottom();
    // setStateMessage(StateMessage.sending);

    String url = '';
    for (var file in files) {
      // file = await MediaService().compressImage(file) ?? file;
      final urlNetwork = await _storageRepository.uploadConversationMedia(
        file: file,
        messageType: MessageType.image,
        conversationId: _conversations[currentConversationIndex.value].id,
      );

      url = file != files.last ? '$url$urlNetwork ' : url + urlNetwork;
    }
    if (url != '') {
      final toSendMessage = localMessage.copyWith(content: url);
      final replyMessageId = replyFromMessage?.id;
      _replyFromMessage.value = null;
      final newMessage = await chatRepository.sendMessage(
        toSendMessage,
        replyMessage: replyMessageId,
      );

      _replaceMessage(
        oldMessage: toSendMessage,
        newMessage:
            addSenderToMessage(
              newMessage.copyWith(
                repliedFrom: addSenderToMessage(newMessage.repliedFrom),
              ),
            )!,
      );
      // setStateMessage(StateMessage.sent);
    }
  }

  Message? addSenderToMessage(Message? message) {
    if (message == null) {
      return null;
    }
    final sender = _conversations[currentConversationIndex.value].members
        .firstWhereOrNull((member) => member.id == message.senderId);

    return message.copyWith(sender: sender);
  }

  void _sendMediaMessage(PickedMedia media) {
    final messageType = switch (media.type) {
      MediaAttachmentType.image => MessageType.image,
      MediaAttachmentType.video => MessageType.video,
      MediaAttachmentType.audio => MessageType.audio,
      MediaAttachmentType.document => MessageType.file,
    };

    sendMediaMessage(file: media.file, type: messageType);
    // _toSendMedia.value = null;
  }

  void sendMediaMessage({required MessageType type, required File file}) async {
    assert(type != MessageType.text);
    final currentUser = Get.find<AuthController>().currentUser;
    final localMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: _conversations[currentConversationIndex.value].id,
      content: file.path,
      type: type,
      createdAt: DateTime.now(),
      senderId: currentUser.value!.id,
      sender: currentUser.value!,
      isLocal: true,
      repliedFrom: replyFromMessage,
    );

    _insertMessage(localMessage, markAsNew: true);
    // _scrollToBottom();

    String url = '';

    if (type == MessageType.video) {
      // file = await MediaService().compressVideo(file) ?? file;
      url = await _storageRepository.uploadConversationMedia(
        file: file,
        messageType: type,
        conversationId: _conversations[currentConversationIndex.value].id,
      );
    } else {
      url = await _storageRepository.uploadConversationMedia(
        file: file,
        messageType: type,
        conversationId: _conversations[currentConversationIndex.value].id,
      );
    }

    final toSendMessage = localMessage.copyWith(content: url);
    final replyMessageId = replyFromMessage?.id;
    _replyFromMessage.value = null;
    final newMessage = await chatRepository.sendMessage(
      toSendMessage,
      replyMessage: replyMessageId,
    );

    _replaceMessage(
      oldMessage: toSendMessage,
      newMessage:
          addSenderToMessage(
            newMessage.copyWith(
              repliedFrom: addSenderToMessage(newMessage.repliedFrom),
            ),
          )!,
    );
  }

  Future<void> sendTextMessage(String content) async {
    if (content.trim().isEmpty) {
      return;
    }

    // Check if content is only numbers (phone number)
    // final trimmedContent = content.trim();
    // if (RegExp(r'^[0-9]+$').hasMatch(trimmedContent)) {
    //   await _handlePhoneNumberMessage(trimmedContent);
    //   return;
    // }

    // // Check if content contains bank info (bank name + numbers)
    // if (_isBankInfoMessage(trimmedContent)) {
    //   await _handleBankInfoMessage(trimmedContent);
    //   return;
    // }

    // detect if the message contains link and send it as hyperlink with <hyper> tag

    MessageType type = MessageType.text;

    if (content.contains(RegExp(r'http[s]?://'))) {
      type = MessageType.hyperText;

      final hyperLinks = content.split(RegExp(r'(?=http[s]?://)'));
      final hyperTexts =
          hyperLinks.map((link) {
            if (link.contains(RegExp(r'\s'))) {
              final linkParts = link.split(RegExp(r'\s'));

              return linkParts
                  .map((part) {
                    if (part.contains(RegExp(r'http[s]?://'))) {
                      return '<${AppConstants.hyperTextTag}>$part</${AppConstants.hyperTextTag}>';
                    }

                    return part;
                  })
                  .join(' ');
            }

            return '<${AppConstants.hyperTextTag}>$link</${AppConstants.hyperTextTag}>';
          }).join();

      content = hyperTexts;
    }

    final mentionedUsers = _extractMentionedUsers(content);
    final mentionsData = <String, String>{};

    if (mentionedUsers.isNotEmpty) {
      // eg: @'user full name' => @${id}
      for (final user in mentionedUsers) {
        final mentionText = userIdMentionWrapper.replaceAll(
          'userId',
          user.id.toString(),
        );
        mentionsData[mentionText] = user.fullName;
        content = content.replaceAll('@${user.fullName}', mentionText);
      }
    }
    final currentUser = Get.find<AuthController>().currentUser;
    final toSendMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversations[currentConversationIndex.value].id,
      content: content.trim(),
      type: type,
      createdAt: DateTime.now(),
      senderId: currentUser.value!.id,
      sender: currentUser.value!,
      repliedFrom: replyFromMessage,
      mentions: mentionsData,
    );

    // Use optimized insertion and scrolling
    _insertMessage(toSendMessage, markAsNew: true);

    // _scrollToBottomOptimized();
    // chatDashboardController.moveConversationToTop(conversation);

    final replyMessageId = replyFromMessage?.id;
    _replyFromMessage.value = null;
    final newMessage = await chatRepository.sendMessage(
      toSendMessage,
      replyMessage: replyMessageId,
      mentionsData: mentionsData,
    );

    // _replaceMessage(
    //   oldMessage: toSendMessage,
    //   newMessage:
    //       addSenderToMessage(
    //         newMessage.copyWith(
    //           repliedFrom: addSenderToMessage(newMessage.repliedFrom),
    //         ),
    //       )!,
    // );
  }

  void _insertMessage(Message message, {bool markAsNew = false}) {
    _messages.insert(0, message);

    // if (indexLastSeen.value != -1) {
    //   indexLastSeen.value++;
    // }

    // Only mark as new if explicitly requested and it's the current user's message
    // if (markAsNew && message.isMine(myId: currentUser.id)) {
    //   _newlyInsertedMessageIds.add(message.id);
    // }
  }

  void _replaceMessage({
    required Message oldMessage,
    required Message newMessage,
  }) {
    final index = messages.indexWhere((element) => element.id == oldMessage.id);
    log('index: $index');
    if (index != -1) {
      _messages[index] = newMessage;
    }
  }

  List<User> _extractMentionedUsers(String message) {
    // Currently, the format of mention is @full name (can include space)

    if (!message.contains('@')) {
      return [];
    }

    final mentionUsers = <User>[];

    final mentionPattern = RegExp(r'@([a-zA-Z0-9\s]+)');

    final matches = mentionPattern.allMatches(message);

    for (final match in matches) {
      final mentionedUserText = match.group(1);

      if (mentionedUserText == null) {
        continue;
      }

      final mentionUser = conversations[currentConversationIndex.value].members
          .firstWhereOrNull(
            (member) => mentionedUserText.startsWith(member.fullName),
          );

      if (mentionUser != null) {
        mentionUsers.add(mentionUser);
      }
    }

    return mentionUsers;
  }

  void removeItemInMedias(PickedMedia item) {
    final tempList = [..._toSendImages];
    _toSendImages.value =
        tempList.where((e) {
          return e != item;
        }).toList();
  }

  void attachImage(List<PickedMedia> medias) {
    _toSendImages.value = medias;
  }

  Future replyMessage(Message message) async {
    _replyFromMessage.value = message;
  }

  void removeReplyMessage() {
    _replyFromMessage.value = null;
  }

  void reactToMessage(
    Message message,
    String reactionType, {
    bool isCallToApi = true,
    String userId = '',
    bool isSocket = false,
    bool isRemoveReaction = false,
  }) {
    var reactions = message.reactions ?? {};

    // listen to reaction event from socket
    if (isSocket) {
      // check userId exist in reactions
      final userIdExistReaction = reactions.values
          .expand((element) => element)
          .toList()
          .contains(userId);

      // remove userId from reactions
      if (userIdExistReaction) {
        reactions = reactions.map((key, value) {
          final newValue = value.where((element) => element != userId);

          return MapEntry(key, newValue.toList());
        });
      }

      // update unReaction to message
      if (isRemoveReaction) {
        final newMessageWithReaction = message.copyWith(
          reactions: {...reactions},
        );

        _replaceMessage(
          oldMessage: message,
          newMessage: newMessageWithReaction,
        );

        return;
      }

      // update reaction to message from socket
      final newMessageWithReaction = message.copyWith(
        reactions: {
          ...reactions,
          reactionType: [...reactions[reactionType] ?? [], userId],
        },
      );

      _replaceMessage(oldMessage: message, newMessage: newMessageWithReaction);

      return;
    }

    // user react to message
    // check user has reacted according to the reactionType
    // if user has reacted according to the reactionType, remove reaction
    final valueWithReactionType = reactions[reactionType] ?? [];

    // if userId exist in valueWithReactionType, remove userId and unReact to message
    if (valueWithReactionType.contains(userId)) {
      reactions = reactions.map((key, value) {
        final newValue = value.where((element) => element != userId);

        return MapEntry(key, newValue.toList());
      });

      Message newMessageWithReaction;

      newMessageWithReaction = message.copyWith(reactions: {...reactions});

      _replaceMessage(oldMessage: message, newMessage: newMessageWithReaction);
      if (isCallToApi) {
        unawaited(
          chatRepository.unReactToMessage(
            conversationId: _conversations[currentConversationIndex.value].id,
            messageId: message.id,
          ),
        );
      }

      return;
    }

    // check userId exist in reactions
    final userIdExistReaction = reactions.values
        .expand((element) => element)
        .toList()
        .contains(userId);

    if (userIdExistReaction) {
      reactions = reactions.map((key, value) {
        final newValue = value.where((element) => element != userId);

        return MapEntry(key, newValue.toList());
      });
    }

    final newMessageWithReaction = message.copyWith(
      reactions: {
        ...reactions,
        reactionType: [...reactions[reactionType] ?? [], userId],
      },
    );

    _replaceMessage(oldMessage: message, newMessage: newMessageWithReaction);

    if (isCallToApi) {
      unawaited(
        chatRepository.reactToMessage(
          conversationId: _conversations[currentConversationIndex.value].id,
          messageId: message.id,
          reactionType: reactionType,
        ),
      );
    }

    return;
  }

  Future getPinMessages(String conversationId) async {
    _pinnedMessagesMap = await chatRepository.getPinnedMessages(conversationId);

    _pinnedMessages.value = _pinnedMessagesMap.values.toList();

    loadCurrentReply();
    // Future.delayed(const Duration(milliseconds: 1000), () {
    //   scrollToIndex(currentReplyIndex.value);
    // });
  }

  void loadCurrentReply() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_pinnedMessagesMap.values.toList().isNotEmpty) {
        currentReplyIndex.value = _pinnedMessagesMap.values.toList().length - 1;
      }
    });
  }

  bool isMessagePinned(String messageId) =>
      _pinnedMessagesMap.containsKey(messageId);

  Future pinMessage(Message message) async {
    if (isMessagePinned(message.id)) {
      return;
    }

    _pinnedMessagesMap[message.id] = message;
    _pinnedMessages.add(message);
    loadCurrentReply();
    await _updatePinMessage(message);
  }

  Future unPinMessage(Message message) async {
    if (!isMessagePinned(message.id)) {
      return;
    }
    _pinnedMessagesMap.remove(message.id);
    _pinnedMessages.remove(message);
    loadCurrentReply();
    await _updatePinMessage(message);
  }

  Future _updatePinMessage(Message message) async {
    await chatRepository.updatePinMessage(
      conversations[currentConversationIndex.value].id,
      _pinnedMessagesMap.keys.toList(),
    );
  }

  Future unPinAllMessage() async {
    _pinnedMessagesMap.clear();

    _pinnedMessages.clear();
    loadCurrentReply();
    await chatRepository.updatePinMessage(
      conversations[currentConversationIndex.value].id,
      _pinnedMessagesMap.keys.toList(),
    );
  }

  // ============================================================================
  // SEARCH METHODS
  // ============================================================================

  void handleTabChange(int index) {
    selectedSearchType.value = SearchType.values[index];
    currentTabIndex.value = index;

    // Trigger search with current query if needed
    search(searchController.text);
  }

  void filterConversations(String query) {
    searchConversations.clear();

    if (query.trim().isEmpty) {
      return;
    }

    searchConversations.addAll(
      _conversations.where((conversation) {
        return conversation.title().toLowerCase().contains(
          (query.trim()).toLowerCase(),
        );
      }),
    );
  }

  Future<void> search(String query) async {
    query = query.trim();

    // Always filter conversations immediately (no debounce for local filtering)
    filterConversations(query);

    if (query.trim().isEmpty) {
      searchUsers.clear();
      _searchDebounceTimer?.cancel();
      return;
    }

    // Cancel previous timer if exists
    _searchDebounceTimer?.cancel();

    // Increment request ID to track this search
    final currentRequestId = ++_currentSearchRequestId;

    // Set up debounce timer for API search (500ms delay)
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
      // Check if this is still the latest request
      if (currentRequestId != _currentSearchRequestId) {
        LogUtil.d('🚫 Ignoring outdated search request #$currentRequestId');
        return;
      }

      isLoadingSearch.value = true;

      try {
        await searchUsersAPI(query, currentRequestId);
      } catch (e) {
        LogUtil.e('Search error: $e');
      } finally {
        // Only update loading state if this is still the current request
        if (currentRequestId == _currentSearchRequestId) {
          isLoadingSearch.value = false;
        }
      }
    });
  }

  Future<void> searchUsersAPI(String query, int requestId) async {
    // Don't modify the query case - let GraphQL handle it with _ilike
    final originalQuery = query.trim();

    if (originalQuery.isEmpty) {
      return;
    }

    try {
      LogUtil.d(
        '🔍 Search request #$requestId - query: "$originalQuery" with type: ${selectedSearchType.value}',
      );

      final data = await userRepository.searchUserByTypes(
        originalQuery,
        selectedSearchType.value,
      );

      // Check if this request is still current before processing results
      if (requestId != _currentSearchRequestId) {
        LogUtil.d(
          '🚫 Ignoring outdated search response #$requestId (current: $_currentSearchRequestId)',
        );
        return;
      }

      LogUtil.d('📊 Search request #$requestId returned ${data.length} users');

      // Filter out current user and sort by relevance
      final currentUserId = Get.find<AuthController>().currentUser.value?.id;
      final filteredUsers =
          data.where((user) => user.id != currentUserId).toList();

      // Sort by relevance: exact matches first, then partial matches
      filteredUsers.sort((a, b) {
        final aScore = _calculateRelevanceScore(a, originalQuery);
        final bScore = _calculateRelevanceScore(b, originalQuery);
        return bScore.compareTo(aScore); // Higher score first
      });

      // Only update results if this is still the current request
      if (requestId == _currentSearchRequestId) {
        searchUsers.value = filteredUsers;
        LogUtil.d(
          '✅ Updated results for request #$requestId - ${filteredUsers.length} users (excluded current user)',
        );
      } else {
        LogUtil.d('🚫 Discarded results for outdated request #$requestId');
      }
    } catch (e) {
      LogUtil.e('❌ User search error for request #$requestId: $e');
      // Only clear results if this is the current request
      if (requestId == _currentSearchRequestId) {
        searchUsers.clear();
      }
    }
  }

  /// Calculate relevance score for search results
  int _calculateRelevanceScore(User user, String query) {
    final queryLower = query.toLowerCase();
    int score = 0;

    // Exact matches get highest score
    if (user.firstName.toLowerCase() == queryLower) score += 100;
    if (user.lastName.toLowerCase() == queryLower) score += 100;
    if (user.email?.toLowerCase() == queryLower) score += 100;
    if (user.nickname?.toLowerCase() == queryLower) score += 100;

    // Starts with matches get high score
    if (user.firstName.toLowerCase().startsWith(queryLower)) score += 50;
    if (user.lastName.toLowerCase().startsWith(queryLower)) score += 50;
    if (user.email?.toLowerCase().startsWith(queryLower) == true) score += 50;
    if (user.nickname?.toLowerCase().startsWith(queryLower) == true)
      score += 50;

    // Contains matches get medium score
    if (user.firstName.toLowerCase().contains(queryLower)) score += 25;
    if (user.lastName.toLowerCase().contains(queryLower)) score += 25;
    if (user.email?.toLowerCase().contains(queryLower) == true) score += 25;
    if (user.nickname?.toLowerCase().contains(queryLower) == true) score += 25;

    // Full name matches
    final fullName = user.fullName.toLowerCase();
    if (fullName == queryLower) score += 150;
    if (fullName.startsWith(queryLower)) score += 75;
    if (fullName.contains(queryLower)) score += 30;

    return score;
  }

  void clearSearch() {
    searchUsers.clear();
    searchConversations.clear();
    searchController.clear();
    isLoadingSearch.value = false;
    // Cancel any pending search requests
    _searchDebounceTimer?.cancel();
    _currentSearchRequestId++;
  }

  void selectConversation(Conversation conversation, {bool isNew = false}) {
    isInitChat.value = false;
    searchController.clear();
    if (isNew) {
      _conversations.insert(0, conversation);
      currentConversationIndex.value = 0;
      currentMessagePage.value = 1;
      hasMoreConversations.value = true;
      isShowChatMember.value = false;
      isShowChatResource.value = false;
      isSearch.value = false;
      _messages.clear();
      // getMessages();
      removeReplyMessage();
      _pinnedMessages.clear();
      // getPinMessages(conversation.id);
    } else {
      currentConversationIndex.value = _conversations.indexOf(conversation);
      currentMessagePage.value = 1;
      hasMoreConversations.value = true;
      isSearch.value = false;
      isShowChatMember.value = false;
      isShowChatResource.value = false;
      getMessages();
      removeReplyMessage();
      getPinMessages(conversation.id);
      _conversations[currentConversationIndex
          .value] = _conversations[currentConversationIndex.value].copyWith(
        unreadCount: 0,
      );
      updateLastSeen(conversation);
    }
  }

  Future<void> updateLastSeen(Conversation conversation) async {
    await chatRepository.updateConversationLastSeen(conversation.id);
  }

  Future<void> selectUser(User user) async {
    searchController.clear();
    final privateConversation = await getPrivateConversation(user);
    selectConversation(privateConversation, isNew: isNewConversation);
  }

  bool isNewConversation = false;
  Future<Conversation> getPrivateConversation(User user) async {
    Conversation? conversation = _conversations.firstWhereOrNull(
      (conversation) =>
          !conversation.isGroup && conversation.memberIds.contains(user.id),
    );

    if (conversation == null) {
      isNewConversation = true;
      conversation = await chatRepository.createConversation([user.id]);
      conversation = conversation.copyWith(members: [user]);
    }

    return conversation;
  }

  Future<void> createGroup() async {
    isCreateGroup.value = false;
    if (selectedUsersCreateGroup.isEmpty) {
      return;
    }

    var conversation = await chatRepository.createConversation(
      selectedUsersCreateGroup.map((e) => e.id).toList(),
    );
    var conversationName = 'New Group';
    if (groupNameController.text.trim().isNotEmpty) {
      conversationName = groupNameController.text.trim();
    }

    await chatRepository.updateGroupChatInfo(
      conversation: conversation,
      name: conversationName,
    );

    conversation = conversation.copyWith(
      members: [...selectedUsersCreateGroup],
      name: conversationName,
    );

    selectConversation(conversation, isNew: true);
  }

  /// Forward message to selected conversation
  Future<void> forwardMessage(
    Message message,
    Conversation targetConversation,
  ) async {
    Navigator.pop(Get.context!);
    // Create a new message with forwarded content
    final forwardedMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: targetConversation.id,
      content: message.content,
      type: message.type,
      createdAt: DateTime.now(),
      senderId: Get.find<AuthController>().currentUser.value!.id,
      forwardedFrom: message,
      isLocal: true,
    );
    if (targetConversation.id ==
        _conversations[currentConversationIndex.value].id) {
      _insertMessage(forwardedMessage);
    } else {
      final index = _conversations.indexOf(targetConversation);
      _conversations[index] = targetConversation.copyWith(
        messages: [forwardedMessage],
      );
    }

    // Send the forwarded message
    await chatRepository.forwardMessage(
      conversationId: targetConversation.id,
      toMessage: message,
    );

    ToastUtil.showSuccess('Message forwarded successfully');
  }

  Future<void> blockUser(Conversation conversation) async {
    ToastUtil.showSuccess('User blocked successfully');
    final index = _conversations.indexOf(conversation);
    _conversations[index] = conversation.copyWith(
      isBlocked: true,
      blockedByMe: true,
    );
    await chatRepository.blockUser(conversation.chatPartner()!.id);
  }

  Future<void> unblockUser(Conversation conversation) async {
    ToastUtil.showSuccess('User unblocked successfully');
    final index = _conversations.indexOf(conversation);
    _conversations[index] = conversation.copyWith(isBlocked: false);
    await chatRepository.unblockUser(conversation.chatPartner()!.id);
  }

  Future<void> deleteConversation(Conversation conversation) async {
    ToastUtil.showSuccess('Conversation deleted successfully');

    isShowChatProfile.value = false;
    isShowChatResource.value = false;
    isInitChat.value = true;
    _messages.clear();
    _pinnedMessages.clear();
    _images.clear();
    _videos.clear();
    _audios.clear();
    currentConversationIndex.value = -1;
    _conversations.remove(conversation);
    await chatRepository.deleteConversation(conversation);
  }

  Future<void> deleteMessage(Message message) async {
    ToastUtil.showSuccess('Message deleted successfully');
    _messages.remove(message);
    await chatRepository.deleteMessage(
      conversations[currentConversationIndex.value],
      message,
    );
  }

  Future<void> leaveGroupChat(Conversation conversation) async {
    ToastUtil.showSuccess('Group left successfully');

    isShowChatProfile.value = false;
    isShowChatResource.value = false;
    isInitChat.value = true;
    _messages.clear();
    _pinnedMessages.clear();
    _images.clear();
    _videos.clear();
    _audios.clear();
    currentConversationIndex.value = -1;
    _conversations.remove(conversation);
    await chatRepository.leaveGroupChat(conversation.id);
  }

  Future<void> pinConversation(Conversation conversation) async {
    ToastUtil.showSuccess('Conversation pinned successfully');
    final index = _conversations.indexOf(conversation);
    _conversations[index] = conversation.copyWith(isPinned: true);
    _conversations.sort(
      (a, b) => (b.isPinned ? 1 : 0).compareTo(a.isPinned ? 1 : 0),
    );
    // await chatRepository.pinConversation(conversation.id, conversation.isPinned);
  }

  Future<void> unpinConversation(Conversation conversation) async {
    ToastUtil.showSuccess('Conversation unpinned successfully');
    final index = _conversations.indexOf(conversation);
    _conversations[index] = conversation.copyWith(isPinned: false);
    _conversations.sort(
      (a, b) => (b.isPinned ? 1 : 0).compareTo(a.isPinned ? 1 : 0),
    );
    // await chatRepository.unpinConversation(conversation.id);
  }

  void _setupSocketListeners() {
    // Listen to new messages
    _newMessageSubscription = _socketService.newMessageStream.listen((message) {
      _handleNewMessage(message);
    });

    // Listen to conversation deleted events
    _conversationDeletedSubscription = _socketService
        .onConversationDeletedStream
        .stream
        .listen((conversationId) {
          _handleConversationDeleted(conversationId);
        });

    // Listen to unread message events
    _unreadMessageSubscription = _socketService.onUnreadMessageStream.stream
        .listen((unreadMessage) {
          _handleUnreadMessage(unreadMessage);
        });

    // Listen to message deleted events
    _messageDeletedSubscription = _socketService.onMessageDeletedStream.stream
        .listen((data) {
          _handleMessageDeleted(data);
        });

    // Listen to user add/remove events
    _addOrRemoveUserBySocketSubscription = _socketService
        .onAddOrRemoveUserToGroupStream
        .stream
        .listen((data) {
          _handleAddOrRemoveUser(data);
        });

    // Listen to message seen events
    _messageSeenSubscription = _socketService.onSeenToMessageStream.stream
        .listen((data) {
          _handleMessageSeen(data);
        });

    // Listen to message reaction events
    _messageReactionSubscription = _socketService.onReactToMessageStream.stream
        .listen((data) {
          _handleMessageReaction(data, isRemove: false);
        });

    // Listen to message unreaction events
    _messageUnreactionSubscription = _socketService
        .onUnReactToMessageStream
        .stream
        .listen((data) {
          _handleMessageReaction(data, isRemove: true);
        });

    // Listen to active users updates
    _activeUsersSubscription = _socketService.activeUsersStream.stream.listen((
      activeUsers,
    ) {
      _handleActiveUsersUpdate(activeUsers);
    });

    // Listen to event bus for unread message notifications
    // _eventBusSubscription = _eventBus.on<ShowUnreadMessageEvent>().listen((event) {
    //   _handleUnreadMessageEvent(event);
    // });

    LogUtil.i('Socket listeners setup completed');
  }

  // Socket Event Handlers

  void _handleNewMessage(Message message) {
    LogUtil.d('📩 New message received: ${message.content}');

    // Find the conversation for this message
    final conversationIndex = _conversations.indexWhere(
      (conv) => conv.id == message.conversationId,
    );

    if (conversationIndex != -1) {
      // Update conversation with new message
      final conversation = _conversations[conversationIndex];
      final updatedConversation = conversation.copyWith(
        messages: [message],
        unreadCount: (conversation.unreadCount ?? 0) + 1,
      );

      // // Move conversation to top
      _conversations.removeAt(conversationIndex);
      _conversations.insert(0, updatedConversation);

      // If this is the current conversation, add message to messages list
      if (currentConversationIndex.value == conversationIndex) {
        currentConversationIndex.value = 0;
        final messageWithSender = addSenderToMessage(message);
        if (messageWithSender != null) {
          _insertMessage(messageWithSender);
        }
      } else if (currentConversationIndex.value < conversationIndex) {
        // Adjust current index if conversation moved above it
        currentConversationIndex.value++;
      } else if (currentConversationIndex.value > conversationIndex) {}
    } else {
      // New conversation - might need to refresh conversations list
      LogUtil.d('New conversation detected, refreshing...');
      refresh();
    }
  }

  void _handleConversationDeleted(String conversationId) {
    LogUtil.d('🗑️ Conversation deleted: $conversationId');

    final conversationIndex = _conversations.indexWhere(
      (conv) => conv.id == conversationId,
    );

    if (conversationIndex != -1) {
      _conversations.removeAt(conversationIndex);

      // If current conversation was deleted
      if (currentConversationIndex.value == conversationIndex) {
        isInitChat.value = true;
        _messages.clear();
        _pinnedMessages.clear();
        currentConversationIndex.value = -1;
        isShowChatProfile.value = false;
        isShowChatResource.value = false;
      } else if (currentConversationIndex.value > conversationIndex) {
        // Adjust current index
        currentConversationIndex.value--;
      }
    }
  }

  void _handleUnreadMessage(unreadMessage) {
    LogUtil.d('🔴 Unread message update: ${unreadMessage.conversationId}');

    // Update unread count
    _unReadMessageCount.value = unreadMessage.unreadCount;

    // Find and update conversation
    final conversationIndex = _conversations.indexWhere(
      (conv) => conv.id == unreadMessage.conversationId,
    );

    if (conversationIndex != -1) {
      final conversation = _conversations[conversationIndex];
      final updatedConversation = conversation.copyWith(
        unreadCount: unreadMessage.unreadCount,
      );
      _conversations[conversationIndex] = updatedConversation;
    }
  }

  void _handleMessageDeleted(Map<String, dynamic> data) {
    final conversationId = data['conversationId'] as String?;
    final messageId = data['messageId'] as String?;

    if (conversationId == null || messageId == null) return;

    LogUtil.d('🗑️ Message deleted: $messageId in $conversationId');

    // If it's current conversation, remove from messages
    if (currentConversationIndex.value >= 0 &&
        _conversations[currentConversationIndex.value].id == conversationId) {
      _messages.removeWhere((msg) => msg.id == messageId);
    }
  }

  void _handleAddOrRemoveUser(addOrRemoveData) {
    LogUtil.d('👥 User add/remove event: ${addOrRemoveData.roomId}');

    final conversationIndex = _conversations.indexWhere(
      (conv) => conv.id == addOrRemoveData.roomId,
    );

    if (conversationIndex != -1 && addOrRemoveData.user != null) {
      final conversation = _conversations[conversationIndex];
      List<User> updatedMembers = List.from(conversation.members);

      if (addOrRemoveData.isAdd == true) {
        // Add user
        if (!updatedMembers.any(
          (member) => member.id == addOrRemoveData.user!.id,
        )) {
          updatedMembers.add(addOrRemoveData.user!);
        }
      } else {
        // Remove user
        updatedMembers.removeWhere(
          (member) => member.id == addOrRemoveData.user!.id,
        );
      }

      final updatedConversation = conversation.copyWith(
        members: updatedMembers,
      );
      _conversations[conversationIndex] = updatedConversation;
    }
  }

  void _handleMessageSeen(Map<String, dynamic> data) {
    final roomId = data['roomId'] as String?;
    final userId = data['userId'] as int?;
    final lastSeen = data['lastSeen'] as DateTime?;

    if (roomId == null || userId == null || lastSeen == null) return;

    LogUtil.d('👁️ Message seen by user $userId in $roomId');

    // Update message seen status if it's current conversation
    if (currentConversationIndex.value >= 0 &&
        _conversations[currentConversationIndex.value].id == roomId) {
      // Update seen status for messages
      for (int i = 0; i < _messages.length; i++) {
        final message = _messages[i];
        if (message.createdAt.isBefore(lastSeen) ||
            message.createdAt.isAtSameMomentAs(lastSeen)) {
          // Mark as seen by this user
          // You might want to update a seen status in your message model
          LogUtil.d('Message ${message.id} seen by user $userId');
        }
      }
    }
  }

  void _handleMessageReaction(
    Map<String, dynamic> data, {
    required bool isRemove,
  }) {
    final conversationId = data['conversationId'] as String?;
    final messageId = data['messageId'] as String?;
    final reactionType = data['reactionType'] as String?;
    final userId = data['userId'] as int?;

    if (conversationId == null ||
        messageId == null ||
        reactionType == null ||
        userId == null) {
      return;
    }

    LogUtil.d(
      '${isRemove ? '👎' : '👍'} Message ${isRemove ? 'unreaction' : 'reaction'}: $reactionType on $messageId by $userId',
    );

    // If it's current conversation, update message reaction
    if (currentConversationIndex.value >= 0 &&
        _conversations[currentConversationIndex.value].id == conversationId) {
      final messageIndex = _messages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex != -1) {
        final message = _messages[messageIndex];
        reactToMessage(
          message,
          reactionType,
          isCallToApi: false,
          userId: userId.toString(),
          isSocket: true,
          isRemoveReaction: isRemove,
        );
      }
    }
  }

  void _handleActiveUsersUpdate(List<int> activeUsers) {
    LogUtil.d('👥 Active users updated: ${activeUsers.length} users online');

    // Update online status for conversation members
    for (int i = 0; i < _conversations.length; i++) {
      final conversation = _conversations[i];
      if (!conversation.isGroup) {
        final partner = conversation.members.firstWhereOrNull(
          (member) =>
              member.id != Get.find<AuthController>().currentUser.value?.id,
        );

        if (partner != null) {
          final isOnline = activeUsers.contains(partner.id);
          // You might want to update online status in your user/conversation model
          LogUtil.d(
            'User ${partner.fullName} is ${isOnline ? 'online' : 'offline'}',
          );
        }
      }
    }
  }

  // void _handleUnreadMessageEvent(ShowUnreadMessageEvent event) {
  //   LogUtil.d('🔔 Unread message event received');

  //   // Update navigation badge or other UI elements
  //   if (event.unreadCount != null) {
  //     _unReadMessageCount.value = event.unreadCount!;
  //   }
  // }

  // Socket Actions

  void startTyping() {
    if (currentConversationIndex.value >= 0 &&
        currentConversationIndex.value < _conversations.length) {
      final conversationId = _conversations[currentConversationIndex.value].id;
      chatRepository.emitTyping(conversationId, true);
    }
  }

  void stopTyping() {
    if (currentConversationIndex.value >= 0 &&
        currentConversationIndex.value < _conversations.length) {
      final conversationId = _conversations[currentConversationIndex.value].id;
      chatRepository.emitTyping(conversationId, false);
    }
  }

  void markMessageAsSeenSocket(String messageId) {
    if (currentConversationIndex.value >= 0 &&
        currentConversationIndex.value < _conversations.length) {
      final conversationId = _conversations[currentConversationIndex.value].id;
      chatRepository.emitSeenMessage(conversationId, messageId);
    }
  }

  void markLastMessageAsSeen() {
    if (_messages.isNotEmpty) {
      final lastMessage = _messages.first;
      markMessageAsSeenSocket(lastMessage.id);
    }
  }
}
