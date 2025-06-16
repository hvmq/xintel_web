import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../resources/styles/app_colors.dart';
import '../chat_sidebar_controller.dart';
import '_conversation_item.dart';

class ChatListWidget extends StatefulWidget {
  const ChatListWidget({super.key});

  @override
  State<ChatListWidget> createState() => _ChatListWidgetState();
}

class _ChatListWidgetState extends State<ChatListWidget> {
  final chatListController = ScrollController();
  final ChatSidebarController controller = Get.find<ChatSidebarController>();

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {});
  }

  @override
  void dispose() {
    chatListController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    chatListController.addListener(() {
      // Only trigger lazy loading if we have conversations and user scrolled near bottom
      if (controller.conversations.isNotEmpty &&
          chatListController.position.pixels >=
              chatListController.position.maxScrollExtent * 0.8) {
        _loadMoreConversations();
      }
    });
  }

  void _loadMoreConversations() {
    if (!controller.isLazyLoading.value &&
        controller.hasMoreConversations.value) {
      controller
          .loadMoreConversations(); // Call the new method for lazy loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 12),
              // if (unreadCount > 0)
              //   custom_badge.Badge(
              //     caption: unreadCount.toString(),
              //     color: primaryParticipantColor,
              //     fontSize: 10,
              //   )
              // else
              //   Container(
              //     width: 10,
              //     height: 10,
              //     color: primaryParticipantColor,
              //   ),
            ],
          ),
        ),
        Expanded(child: _buildConversationsList()),
      ],
    );
  }

  Widget _buildConversationsList() {
    return Obx(() {
      final conversations = controller.conversations;
      final isLoading = controller.isLazyLoading.value;
      final hasMore = controller.hasMoreConversations.value;

      return ListView.builder(
        cacheExtent: 5000,
        controller: chatListController,
        itemCount: conversations.length + (isLoading || hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loading indicator at the bottom
          if (index == conversations.length) {
            return _buildLoadingIndicator();
          }

          final hasArchived = false;

          return _ConversationListItem(
            index: index,
            conversations: conversations,
            hasArchived: hasArchived,
            controller: controller,
          );
        },
      );
    });
  }

  Widget _buildLoadingIndicator() {
    return Obx(() {
      if (controller.isLazyLoading.value) {
        return Padding(
          padding: EdgeInsets.only(top: 0.2.sh),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      } else if (!controller.hasMoreConversations.value) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'Không còn cuộc trò chuyện nào',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }
}

class _ConversationListItem extends StatelessWidget {
  const _ConversationListItem({
    required this.index,
    required this.conversations,
    required this.hasArchived,
    required this.controller,
  });

  final int index;
  final List conversations;
  final bool hasArchived;

  final ChatSidebarController controller;

  @override
  Widget build(BuildContext context) {
    //   // Handle archived conversations
    // if (hasArchived && index == 0) {
    //   final subtitle = controller.archivedConversationSubTitles;
    //   return RepaintBoundary(
    //     child: ArchivedItem(
    //       subTitle: subtitle,
    //     ),
    //   );
    // }

    // if (index < controller.pinConversations.length) {
    //   final pinConversationIndex = hasArchived ? index - 1 : index;
    //   final pinConversation = controller.pinConversations[pinConversationIndex];

    //   return ConversationItem(
    //     key: ValueKey(pinConversation.id),
    //     conversation: pinConversation,
    //     controller: controller,
    //     isPinned: true,
    //   );
    // }

    //   // Calculate conversation index
    final conversationIndex =
        hasArchived ? index - 1 : index - controller.pinConversations.length;

    final conversation = conversations[conversationIndex];

    return ConversationItem(
      key: ValueKey(conversation.id),
      conversation: conversation,
      controller: controller,
      index: conversationIndex,
    );
  }
}
