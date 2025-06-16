import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xintel/core/extensions/widget_extensions.dart';
import 'package:xintel/resources/styles/gaps.dart';

import '../../../../models/message.dart';
import '../../../../resources/styles/app_colors.dart';
import '../../../../resources/styles/text_styles.dart' show AppTextStyles;
import '../../auth/auth_controller.dart';
import '../chat_sidebar_controller.dart';
import 'widgets/_chat_input.dart';
import 'widgets/_message_item.dart';

class ChatHubView extends StatefulWidget {
  const ChatHubView({super.key});

  @override
  State<ChatHubView> createState() => _ChatHubViewState();
}

class _ChatHubViewState extends State<ChatHubView> {
  late ScrollController _scrollController;
  final controller = Get.find<ChatSidebarController>();

  // Debounce timer for scroll events
  Timer? _scrollDebounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollDebounceTimer?.cancel();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // Debounce scroll events to avoid too many calls
      _scrollDebounceTimer?.cancel();
      _scrollDebounceTimer = Timer(const Duration(milliseconds: 100), () {
        // When scrolled to the top (or near the top) in reversed ListView
        // Reduced threshold for earlier loading
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100) {
          _loadMoreMessages();
        }
      });
    });
  }

  void _loadMoreMessages() {
    if (!controller.isLazyLoading.value &&
        controller.hasMoreMessages.value &&
        controller.messages.isNotEmpty) {
      debugPrint('🔄 Loading more messages...');
      controller.loadMoreMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Get.find<AuthController>().currentUser;
    return Obx(() {
      return Column(
        children: [
          Expanded(
            child:
                controller.isInitChat.value
                    ? Center(
                      child: Text(
                        'Hãy chọn cuộc hội thoại để bắt đầu trò chuyện',
                        style: AppTextStyles.s14w400.copyWith(
                          color: AppColors.subText2,
                        ),
                      ),
                    )
                    : controller.messages.isEmpty
                    ? Center(
                      child: Text(
                        'Hãy gửi lời chào!',
                        style: AppTextStyles.s14w400.copyWith(
                          color: AppColors.subText2,
                        ),
                      ),
                    )
                    : Column(
                      children: [
                        // Loading indicator for lazy loading
                        Obx(() {
                          return controller.isLazyLoading.value
                              ? Container(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.primary,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Đang tải tin nhắn...',
                                      style: AppTextStyles.s12w400.copyWith(
                                        color: AppColors.subText2,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : const SizedBox.shrink();
                        }),

                        // Messages list
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            itemCount:
                                controller.messages.length +
                                1, // +1 for end indicator
                            itemBuilder: (context, index) {
                              // End of messages indicator
                              if (index == controller.messages.length) {
                                return Obx(() {
                                  if (!controller.hasMoreMessages.value &&
                                      controller.messages.isNotEmpty &&
                                      !controller.isLazyLoading.value) {
                                    return Container(
                                      padding: const EdgeInsets.all(20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [],
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                });
                              }

                              final message = controller.messages[index];
                              final previousMessage =
                                  index + 1 < controller.messages.length
                                      ? controller.messages[index + 1]
                                      : null;

                              final nextMessage =
                                  index - 1 >= 0
                                      ? controller.messages[index - 1]
                                      : null;

                              return MessageItem(
                                key: ValueKey(message.id),
                                isMine: message.isMine(
                                  myId: currentUser.value!.id,
                                ),
                                message: message,
                                previousMessage: previousMessage,
                                nextMessage: nextMessage,
                                isSelectMode: false,
                                isSelect: false,
                                currentUserId: currentUser.value!.id,
                                isAdmin: controller
                                    .conversations[controller
                                        .currentConversationIndex
                                        .value]
                                    .isAdmin(currentUser.value!.id),
                                onPressedUserAvatar: () => {},
                                members:
                                    controller
                                        .conversations[controller
                                            .currentConversationIndex
                                            .value]
                                        .members,
                                isGroup:
                                    controller
                                        .conversations[controller
                                            .currentConversationIndex
                                            .value]
                                        .isGroup,
                                onMentionPressed:
                                    (
                                      String? mention,
                                      Map<String, int> mentionMap,
                                    ) {},
                                onSelectMessage: (Message message) => {},
                              );
                            },
                          ),
                        ),
                      ],
                    ),
          ),
          Obx(() {
            return !controller.isInitChat.value
                ? controller
                        .conversations[controller
                            .currentConversationIndex
                            .value]
                        .isBlocked
                    ? Container(
                      height: 40,
                      width:
                          controller
                                  .conversations[controller
                                      .currentConversationIndex
                                      .value]
                                  .blockedByMe
                              ? 100
                              : 150,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.text2.withValues(alpha: 0.3),
                            blurRadius: 2,
                            offset: Offset(0, 0),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(
                        child: Text(
                          controller
                                  .conversations[controller
                                      .currentConversationIndex
                                      .value]
                                  .blockedByMe
                              ? 'Bỏ chặn'
                              : 'Bạn đã bị chặn',
                          style: AppTextStyles.s14w600.copyWith(
                            color: AppColors.text2,
                          ),
                        ),
                      ),
                    ).clickable(() {
                      if (controller
                          .conversations[controller
                              .currentConversationIndex
                              .value]
                          .blockedByMe) {
                        controller.unblockUser(
                          controller.conversations[controller
                              .currentConversationIndex
                              .value],
                        );
                      }
                    })
                    : ChatInput()
                : const SizedBox.shrink();
          }),
          AppSpacing.gapH12,
        ],
      );
    });
  }
}
