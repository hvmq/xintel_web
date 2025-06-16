// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/date_time_util.dart';
import '../../../../models/conversation.dart';
import '../../../../models/message.dart';
import '../../../../resources/styles/app_colors.dart';
import '../../../../resources/styles/gaps.dart';
import '../../../../resources/styles/text_styles.dart';
import '../../../widgets/circle_avatar.dart';
import '../../auth/auth_controller.dart';
import '../chat_sidebar_controller.dart';

class ConversationItem extends StatefulWidget {
  final Conversation conversation;
  final bool showChildOnly;
  final EdgeInsets? contentPadding;
  final VoidCallback? beforeGoToChat;
  final ChatSidebarController controller;
  final VoidCallback? onUnarchive;
  final bool isArchived;
  final bool isPinned;
  final int index;
  const ConversationItem({
    required this.conversation,
    required this.controller,
    this.contentPadding,
    this.showChildOnly = false,
    this.onUnarchive,
    this.beforeGoToChat,
    this.isArchived = false,
    this.isPinned = false,
    this.index = 0,
    super.key,
  });

  @override
  State<ConversationItem> createState() => _ConversationItemState();
}

class _ConversationItemState extends State<ConversationItem> {
  bool isMute = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isMute = widget.conversation.isMuted ?? false;
  }

  void _onDeleteChat(BuildContext context) {
    // ViewUtil.showActionSheet(
    //   items: [
    //     ActionSheetItem(
    //       title: 'Clear history',
    //       textStyle: AppTextStyles.s18w500.copyWith(color: Colors.blue),
    //       onPressed: () {
    //         // Get.find<ChatDashboardController>().deleteConversation(widget.conversation);
    //       },
    //     ),
    //     ActionSheetItem(
    //       title: context.l10n.delete_chat__confirm_title,
    //       textStyle: AppTextStyles.s18w500.copyWith(color: Colors.red),
    //       onPressed: () {
    //         Get.find<ChatDashboardController>()
    //             .deleteConversation(widget.conversation);
    //       },
    //     ),
    //   ],
    // );
  }

  Future<void> _onMuteChat(BuildContext context) async {
    // final ChatRepository chatRepository = Get.find();
    // if (widget.conversation.isMuted!) {
    //   await chatRepository.unMuteConversation(widget.conversation.id);
    // } else {
    //   await chatRepository.muteConversation(
    //     conversationId: widget.conversation.id,
    //     muteOption: MuteConversationOption.forever,
    //   );
    //   // // update current conversation ui
    //   // conversation.value = conversation.copyWith(isMuted: true);
    //   // // update chat hub view
    //   // updateMuteInChatHubView(true);

    //   ViewUtil.showToast(
    //     title: Get.context!.l10n.notification__title,
    //     message: MuteConversationOption.forever.labelName(context.l10n),
    //   );
    // }
    // setState(() {
    //   isMute = !isMute;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return _buildChildWidget();
  }

  Widget _buildChildWidget() {
    // If animation value is close to 0, show the normal list tile
    // If animation value is higher, show the preview
    // Increased threshold from 0.1 to 0.6 to keep original item longer
    final controller = Get.find<ChatSidebarController>();
    return _WebContextMenuWrapper(
      onContextMenu: (position) {
        _showContextMenu(context, position);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            widget.controller.selectConversation(widget.conversation);
          },
          child: Obx(() {
            return Container(
              color:
                  controller.currentConversationIndex.value == widget.index
                      ? AppColors.yellow1
                      : Colors.transparent,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitle(),
                        _buildSubtitle(context) ?? const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  _buildTrailing(context) ?? const SizedBox.shrink(),
                ],
              ).paddingOnly(top: 8, right: 12, left: 12, bottom: 8),
            );
          }),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Rect.fromLTWH(0, 0, overlay.size.width, overlay.size.height),
      ),
      items: _buildPopupMenuItems(context),
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ).then((value) {
      if (value != null) {
        _handleMenuAction(context, value);
      }
    });
  }

  void _handleMenuAction(BuildContext context, String action) {
    final controller = Get.find<ChatSidebarController>();
    switch (action) {
      case 'mark_read':
        // TODO: Implement mark as read/unread
        // const isMarkedAsRead = false;
        // if (isMarkedAsRead) {
        //   widget.controller.unmarkReadConversation(widget.conversation);
        // } else {
        //   widget.controller.markReadConversation(widget.conversation);
        // }
        break;
      case 'pin':
        // TODO: Implement pin/unpin conversation
        if (widget.conversation.isPinned) {
          widget.controller.unpinConversation(widget.conversation);
        } else {
          widget.controller.pinConversation(widget.conversation);
        }
        break;
      case 'mute':
        _onMuteChat(context);
        break;
      case 'block':
        if (widget.conversation.isBlocked) {
          if (widget.conversation.blockedByMe) {
            controller.unblockUser(widget.conversation);
          }
        } else {
          final userName =
              widget.conversation.chatPartner()?.fullName ?? 'người dùng này';

          Get.dialog(
            Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 350,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.negative.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.block,
                        size: 32,
                        color: AppColors.negative,
                      ),
                    ),
                    AppSpacing.gapH16,

                    // Title
                    Text(
                      'Chặn người dùng',
                      style: AppTextStyles.s18w700.copyWith(
                        color: AppColors.text2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.gapH12,

                    // Content
                    Text(
                      'Bạn có chắc chắn muốn chặn $userName không?\n\nSau khi chặn, bạn sẽ không nhận được tin nhắn từ người này nữa.',
                      style: AppTextStyles.s14Base.copyWith(
                        color: AppColors.subText,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.gapH24,

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Get.back(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: AppColors.greyBorder),
                              ),
                            ),
                            child: Text(
                              'Hủy',
                              style: AppTextStyles.s14w600.copyWith(
                                color: AppColors.subText,
                              ),
                            ),
                          ),
                        ),
                        AppSpacing.gapW12,
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              controller.blockUser(widget.conversation);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.negative,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Chặn',
                              style: AppTextStyles.s14w600.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            barrierDismissible: false,
          );
        }
        break;
      case 'archive':
        // TODO: Implement archive/unarchive conversation
        // if (widget.isArchived) {
        //   widget.controller.unarchiveConversation(widget.conversation);
        // } else {
        //   widget.controller.archiveConversation(widget.conversation);
        // }
        break;
      case 'leave':
        final userName = widget.conversation.title();

        Get.dialog(
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.negative.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.exit_to_app,
                      size: 32,
                      color: AppColors.negative,
                    ),
                  ),
                  AppSpacing.gapH16,

                  // Title
                  Text(
                    'Rời nhóm',
                    style: AppTextStyles.s18w700.copyWith(
                      color: AppColors.text2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.gapH12,

                  // Content
                  Text(
                    'Bạn có chắc chắn muốn rời nhóm $userName không?\n\nSau khi rời nhóm, bạn sẽ không nhận được tin nhắn từ nhóm này nữa.',
                    style: AppTextStyles.s14Base.copyWith(
                      color: AppColors.subText,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.gapH24,

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Get.back(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: AppColors.greyBorder),
                            ),
                          ),
                          child: Text(
                            'Hủy',
                            style: AppTextStyles.s14w600.copyWith(
                              color: AppColors.subText,
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.gapW12,
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            controller.leaveGroupChat(widget.conversation);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.negative,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Rời',
                            style: AppTextStyles.s14w600.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
        break;
      case 'delete':
        Get.dialog(
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.negative.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete,
                      size: 32,
                      color: AppColors.negative,
                    ),
                  ),
                  AppSpacing.gapH16,

                  // Title
                  Text(
                    'Xóa đoạn hội thoại',
                    style: AppTextStyles.s18w700.copyWith(
                      color: AppColors.text2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.gapH12,

                  // Content
                  Text(
                    'Bạn có chắc chắn muốn xóa đoạn hội thoại này không?\n\nSau khi xóa, bạn sẽ không thể khôi phục lại đoạn hội thoại này.',
                    style: AppTextStyles.s14Base.copyWith(
                      color: AppColors.subText,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.gapH24,

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Get.back(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: AppColors.greyBorder),
                            ),
                          ),
                          child: Text(
                            'Hủy',
                            style: AppTextStyles.s14w600.copyWith(
                              color: AppColors.subText,
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.gapW12,
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            controller.deleteConversation(widget.conversation);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.negative,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Xóa',
                            style: AppTextStyles.s14w600.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
        break;
    }
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(BuildContext context) {
    final items = <PopupMenuEntry<String>>[];

    // Mark as read/unread
    const isMarkedAsRead = false;
    // items.add(
    //   PopupMenuItem<String>(
    //     value: 'mark_read',
    //     height: 36,
    //     padding: const EdgeInsets.symmetric(horizontal: 12),
    //     child: Row(
    //       children: [
    //         Icon(
    //           isMarkedAsRead ? Icons.mark_email_unread : Icons.mark_email_read,
    //           size: 18,
    //         ),
    //         const SizedBox(width: 8),
    //         Text(
    //           isMarkedAsRead ? 'Đánh dấu chưa đọc' : 'Đánh dấu đã đọc',
    //           style: AppTextStyles.s12w500,
    //         ),
    //       ],
    //     ),
    //   ),
    // );

    // Pin/Unpin conversation
    items.add(
      PopupMenuItem<String>(
        value: 'pin',
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(
              widget.conversation.isPinned
                  ? Icons.push_pin_outlined
                  : Icons.push_pin,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              widget.conversation.isPinned
                  ? 'Bỏ ghim cuộc trò chuyện'
                  : 'Ghim cuộc trò chuyện',
              style: AppTextStyles.s12w500,
            ),
          ],
        ),
      ),
    );

    // // Mute/Unmute
    // items.add(
    //   PopupMenuItem<String>(
    //     value: 'mute',
    //     height: 36,
    //     padding: const EdgeInsets.symmetric(horizontal: 12),
    //     child: Row(
    //       children: [
    //         Icon(
    //           isMute ? Icons.notifications : Icons.notifications_off,
    //           size: 18,
    //         ),
    //         const SizedBox(width: 8),
    //         Text(
    //           isMute ? 'Bật thông báo' : 'Tắt thông báo',
    //           style: AppTextStyles.s12w500,
    //         ),
    //       ],
    //     ),
    //   ),
    // );

    // Block/Unblock
    if (!widget.conversation.isGroup) {
      items.add(
        PopupMenuItem<String>(
          value: 'block',
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Icon(Icons.block, size: 18),
              const SizedBox(width: 8),
              Text(
                widget.conversation.isBlocked ? 'Bỏ chặn' : 'Chặn người dùng',
                style: AppTextStyles.s12w500,
              ),
            ],
          ),
        ),
      );
    }

    if (widget.conversation.isGroup) {
      items.add(
        PopupMenuItem<String>(
          value: 'leave',
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Icon(Icons.exit_to_app, size: 18),
              const SizedBox(width: 8),
              Text('Rời nhóm', style: AppTextStyles.s12w500),
            ],
          ),
        ),
      );
    }

    // Archive/Unarchive
    // items.add(
    //   PopupMenuItem<String>(
    //     value: 'archive',
    //     height: 36,
    //     padding: const EdgeInsets.symmetric(horizontal: 12),
    //     child: Row(
    //       children: [
    //         const Icon(Icons.archive, size: 18),
    //         const SizedBox(width: 8),
    //         Text(
    //           widget.isArchived ? 'Bỏ lưu trữ' : 'Lưu trữ',
    //           style: AppTextStyles.s12w500,
    //         ),
    //       ],
    //     ),
    //   ),
    // );

    // Separator
    items.add(const PopupMenuDivider(height: 1));

    // Delete
    items.add(
      PopupMenuItem<String>(
        value: 'delete',
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(Icons.delete, size: 18, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'Xóa cuộc trò chuyện',
              style: AppTextStyles.s12w500.copyWith(color: Colors.red),
            ),
          ],
        ),
      ),
    );

    return items;
  }

  Widget _buildAvatar() {
    final child = AppCircleAvatar(
      url: widget.conversation.avatarUrl() ?? '',
      size: 52,
    );

    if (widget.conversation.isBlocked) {
      return Stack(
        children: [
          child,
          Positioned(
            bottom: 0,
            right: 0,
            child: Icon(Icons.block, color: AppColors.negative, size: 20),
          ),
        ],
      );
    }

    return child;
  }

  Widget _buildTitle() {
    return Row(
      children: [
        if (widget.conversation.isGroup)
          const Icon(
            Icons.group,
            size: 18,
            color: Colors.black,
          ).paddingOnly(right: 4),

        Expanded(
          child: Text(
            widget.conversation.title(),
            style: AppTextStyles.s14w700,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget? _buildSubtitle(BuildContext context) {
    final lastMessage = widget.conversation.lastMessage;

    final sender = widget.conversation.members.firstWhereOrNull(
      (e) => e.id == lastMessage?.senderId,
    );

    final senderText =
        sender == null || lastMessage?.type == MessageType.system
            ? null
            : sender.id == Get.find<AuthController>().currentUser.value?.id
            ? 'bạn'
            : sender.contactName;

    String? content;

    if (widget.conversation.lastMessage != null) {
      final isMyMessage = widget.conversation.lastMessage!.isMine(
        myId: Get.find<AuthController>().currentUser.value?.id ?? 0,
      );

      // ignore: no-equal-then-else, prefer-conditional-expressions
      if (!isMyMessage) {
        content = switch (widget.conversation.lastMessage!.type) {
          MessageType.text => widget.conversation.lastMessage!.content,
          MessageType.hyperText => widget.conversation.lastMessage!.content,
          MessageType.image => 'đã gửi một hình ảnh',
          MessageType.video => 'đã gửi một video',
          MessageType.audio => 'đã gửi một âm thanh',
          MessageType.call => 'đã gửi một cuộc gọi',
          MessageType.file => 'đã gửi một tài liệu',
          MessageType.post => 'đã gửi một bài viết',
          MessageType.sticker => 'đã gửi một sticker',
          MessageType.system => 'đã gửi một tin nhắn',
        };
      } else {
        content = switch (widget.conversation.lastMessage!.type) {
          MessageType.text =>
            widget.conversation.lastMessage!.contentWithoutFormat,
          MessageType.hyperText =>
            widget.conversation.lastMessage!.contentWithoutFormat,
          MessageType.image => 'đã gửi một hình ảnh',
          MessageType.video => 'đã gửi một video',
          MessageType.audio => 'đã gửi một âm thanh',
          MessageType.call => 'đã gửi một cuộc gọi',
          MessageType.file => 'đã gửi một tài liệu',
          MessageType.post => 'đã gửi một bài viết',
          MessageType.sticker => 'đã gửi một sticker',
          MessageType.system => 'đã gửi một tin nhắn',
        };
      }
    }

    if (content == null &&
        widget.conversation.isGroup &&
        widget.conversation.creator != null) {
      content = 'đã tạo nhóm';
    }

    if (content?.startsWith('business_card;') ?? false) {
      content = 'đã gửi một số điện thoại';
    }

    if (content?.startsWith('bank_info;') ?? false) {
      content = 'đã gửi thông tin chuyển khoản';
    }

    return Text(
      senderText != null ? '$senderText: $content' : content ?? '',
      style:
          widget.conversation.unreadCount != null &&
                  widget.conversation.unreadCount! > 0
              ? AppTextStyles.s12w700.copyWith(color: AppColors.text2)
              : AppTextStyles.s12w500.copyWith(color: AppColors.subText2),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget? _buildTrailing(BuildContext context) {
    if (widget.conversation.lastMessage == null) {
      return null;
    }

    final lastMessage = widget.conversation.lastMessage;

    final partner = widget.conversation.chatPartner();

    bool isPartnerSeenLastMessage = false;

    try {
      // if (lastMessage != null &&
      //     partner != null &&
      //     widget.conversation.lastSeenUsers != null) {
      //   final isMyMessage = lastMessage.isMine(
      //     myId: Get.find<AppController>().currentUser.id,
      //   );

      //   // ignore: no-equal-then-else, prefer-conditional-expressions
      //   if (isMyMessage) {
      //     final messageCreateAt = lastMessage.createdAt;
      //     final partnerLastSeen = DateTime.fromMillisecondsSinceEpoch(
      //       widget.conversation.lastSeenUsers![partner.id.toString()]!,
      //     );
      //     isPartnerSeenLastMessage = messageCreateAt.isBefore(partnerLastSeen);
      //     if (isPartnerSeenLastMessage) {
      //       print(1);
      //     }
      //   }
      // }
    } catch (e) {
      // LogUtil.e(e);
    }

    const isMarkedAsRead = false;
    const isPin = false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          widget.conversation.lastMessage != null
              ? DateTimeUtil.timeAgo(
                context,
                widget.conversation.lastMessage!.createdAt,
              )
              : '',
          style: AppTextStyles.s14w400.copyWith(
            fontSize: 10,
            color: AppColors.subText2,
          ),
        ),
        AppSpacing.gapH4,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.conversation.unreadCount != null &&
                widget.conversation.unreadCount! > 0)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.conversation.unreadCount.toString(),
                  style: AppTextStyles.s14w500.copyWith(
                    color: AppColors.white,
                    fontSize: 11,
                  ),
                ),
              )
            else if (isPartnerSeenLastMessage)
              AppCircleAvatar(url: '', size: 16)
            // TODO: Add isMarkedAsRead check from API
            else if (widget
                .conversation
                .isMarkRead) // Replace with widget.conversation.isMarkedAsRead
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            // TODO: Add isPinned check from API
            else if (widget
                .conversation
                .isPinned) // Replace with widget.conversation.isPinned
              const Icon(Icons.push_pin, size: 20, color: AppColors.primary),
          ],
        ),
      ],
    );
  }

  int findIndexLastSeen({
    required Map<String, int> lastSeenUsers,
    required List<Message> messages,
    required Conversation conversation,
    required int currentUserId,
  }) {
    var res = -1;
    try {
      if (conversation.isGroup) {
        return res;
      }

      final partner = conversation.chatPartner();
      final partnerLastSeen = DateTime.fromMillisecondsSinceEpoch(
        lastSeenUsers[partner!.id.toString()]!,
      );

      for (int i = 0; i < messages.length; i++) {
        final message = messages[i];
        final messageCreateAt = message.createdAt;
        final isPartnerSeenLastMessage = messageCreateAt.isBefore(
          partnerLastSeen,
        );
        if (message.isMine(myId: currentUserId)) {
          if (isPartnerSeenLastMessage) {
            res = i;
            break;
          }
        } else {
          break;
        }
      }
    } catch (e) {}
    return res;
  }
}

class _WebContextMenuWrapper extends StatelessWidget {
  final Widget child;
  final Function(Offset) onContextMenu;

  const _WebContextMenuWrapper({
    required this.child,
    required this.onContextMenu,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        onContextMenu(details.globalPosition);
      },
      child: child,
    );
  }
}
