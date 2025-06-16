import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:xintel/core/extensions/date_time_extensions.dart';
import 'package:xintel/core/extensions/widget_extensions.dart';

import '../../../../../core/utils/image_save_service.dart';
import '../../../../../core/utils/intent_util.dart';
import '../../../../../core/utils/toast_util.dart';
import '../../../../../models/enums/reaction_message_type_enum.dart'
    show ReactionMessageEnum;
import '../../../../../models/message.dart';
import '../../../../../models/message_system.dart';
import '../../../../../models/user.dart';
import '../../../../../resources/styles/app_colors.dart';
import '../../../../../resources/styles/gaps.dart';
import '../../../../../resources/styles/text_styles.dart';
import '../../../../widgets/circle_avatar.dart';
import '../../../../widgets/reaction_chat_widget/model/menu_item.dart';
import '../../../../widgets/web_context_menu.dart';
import '../../chat_sidebar_controller.dart';
import '_call_message_body.dart';
import '_media_message_body.dart';
import 'hyper_text_message_widget.dart';
import 'reply_message_widget.dart';
import 'text_message_widget.dart';

class MessageItem extends StatefulWidget {
  final Message message;
  final Message? previousMessage;
  final Message? nextMessage;
  final bool isMine;
  final int currentUserId;
  final Function()? onTap;
  final VoidCallback onPressedUserAvatar;
  final bool isAdmin;
  final List<User> members;
  final bool isGroup;
  final Function(String? mention, Map<String, int> mentionUserIdMap)
  onMentionPressed;
  final Function(Message message) onSelectMessage;
  final bool isSelect;
  final bool isSelectMode;

  const MessageItem({
    required this.message,
    required this.currentUserId,
    required this.onPressedUserAvatar,
    required this.onMentionPressed,
    required this.onSelectMessage,
    required this.isSelect,
    required this.isSelectMode,
    super.key,
    this.isMine = false,
    this.previousMessage,
    this.nextMessage,
    this.onTap,
    this.isAdmin = false,
    this.members = const [],
    this.isGroup = false,
  });

  @override
  State<MessageItem> createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem>
    with TickerProviderStateMixin {
  /// variable for check if user is click see more first time
  final ValueNotifier<bool> _isClickedSeeMoreFirstTime = ValueNotifier(false);

  /// variable for store list of menu item
  // final ValueNotifier<List<MenuItem>> _menuItems = ValueNotifier([]);

  /// Animation controller for checkbox slide animation
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimationLeft; // Animation cho tin nhắn bên trái
  late Animation<Offset>
  _slideAnimationRight; // Animation cho tin nhắn bên phải

  /// Track if checkbox should be visible (during animation or when select mode is active)
  bool _shouldShowCheckbox = false;

  /// Track previous reactions to detect new reactions for animation
  Map<String, dynamic>? _previousReactions;

  /// Map để track animation controller cho từng reaction
  final Map<String, AnimationController> _reactionAnimationControllers = {};
  final Map<String, Animation<double>> _reactionAnimations = {};

  final chatSidebarController = Get.find<ChatSidebarController>();

  @override
  void initState() {
    super.initState();

    // Initialize previous reactions
    _previousReactions = Map<String, dynamic>.from(
      widget.message.reactions ?? {},
    );

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Create slide animation from left side (for other's messages)
    _slideAnimationLeft = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Start from left outside screen
      end: Offset.zero, // End at center
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Create slide animation from right side (for my messages)
    _slideAnimationRight = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Start from right outside screen
      end: Offset.zero, // End at center
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Listen to animation status changes
    _animationController.addStatusListener((status) {
      setState(() {
        // Show checkbox during forward animation, or when select mode is active, or during reverse animation
        _shouldShowCheckbox =
            widget.isSelectMode ||
            status == AnimationStatus.forward ||
            status == AnimationStatus.reverse;
      });
    });

    // Start animation if select mode is already active
    if (widget.isSelectMode) {
      _shouldShowCheckbox = true;
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(MessageItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle animation when select mode changes
    if (widget.isSelectMode != oldWidget.isSelectMode) {
      if (widget.isSelectMode) {
        setState(() {
          _shouldShowCheckbox = true;
        });
        _animationController.forward();
      } else {
        // Don't hide checkbox immediately, let animation reverse first
        _animationController.reverse();
      }
    }

    // Check for reaction changes to trigger animation
    final currentReactions = widget.message.reactions ?? {};
    final oldReactions = _previousReactions ?? {};

    // Check for new or updated reactions
    currentReactions.forEach((reactionType, userList) {
      final currentCount = (userList as List).length;
      final oldCount = (oldReactions[reactionType] as List?)?.length ?? 0;

      // Nếu có reaction mới hoặc tăng số lượng
      if (currentCount > oldCount) {
        _triggerReactionAnimation(reactionType);
      }
    });

    // Update previous reactions for next comparison
    _previousReactions = Map<String, dynamic>.from(currentReactions);
  }

  Future<void> _triggerReactionAnimation(String reactionType) async {
    // Dispose old controller nếu có
    _reactionAnimationControllers[reactionType]?.dispose();

    // Tạo animation controller mới
    final controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Tạo animation rơi từ trên cao với kích thước lớn
    final animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.bounceOut));

    _reactionAnimationControllers[reactionType] = controller;
    _reactionAnimations[reactionType] = animation;
    await Future.delayed(const Duration(milliseconds: 50));
    // Start animation
    controller.forward().then((_) {
      // Clean up sau khi animation xong
      Future.delayed(const Duration(milliseconds: 500), () {
        _reactionAnimationControllers.remove(reactionType);
        _reactionAnimations.remove(reactionType);
        controller.dispose();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _isClickedSeeMoreFirstTime.dispose();
    // _menuItems.dispose();

    // Dispose all reaction animation controllers
    for (final controller in _reactionAnimationControllers.values) {
      controller.dispose();
    }
    _reactionAnimationControllers.clear();
    _reactionAnimations.clear();

    super.dispose();
  }

  Widget _buildAnimatedCheckbox({required bool isLeft}) {
    // Choose animation based on message position
    final Animation<Offset> slideAnimation =
        isLeft ? _slideAnimationLeft : _slideAnimationRight;

    return SlideTransition(
      position: slideAnimation,
      child:
          widget.isSelect
              ? Icon(color: Colors.black, Icons.check_circle).paddingOnly(
                bottom: _shouldShowTime() ? 28 : 4,
                right: isLeft ? 8 : 0, // Tin nhắn bên trái thì padding right
                left: isLeft ? 0 : 8, // Tin nhắn bên phải thì padding left
              )
              : Icon(
                color: Colors.black,
                Icons.radio_button_unchecked,
              ).paddingOnly(
                bottom: _shouldShowTime() ? 28 : 4,
                right: isLeft ? 8 : 0, // Tin nhắn bên trái thì padding right
                left: isLeft ? 0 : 8, // Tin nhắn bên phải thì padding left
              ),
    );
  }

  bool _shouldShowTime() {
    if (widget.nextMessage != null) {
      if (widget.message.createdAt.isSameDay(widget.nextMessage!.createdAt) &&
          (widget.nextMessage!.type == MessageType.text ||
              widget.nextMessage!.type == MessageType.sticker ||
              widget.nextMessage!.type == MessageType.file ||
              widget.nextMessage!.type == MessageType.call ||
              widget.nextMessage!.type == MessageType.audio ||
              widget.nextMessage!.type == MessageType.hyperText ||
              widget.nextMessage!.type == MessageType.image ||
              widget.nextMessage!.type == MessageType.video ||
              widget.nextMessage!.type == MessageType.post) &&
          widget.message.forwardedFrom == null &&
          (widget.message.type == MessageType.text ||
              widget.message.type == MessageType.sticker ||
              widget.message.type == MessageType.file ||
              widget.message.type == MessageType.call ||
              widget.message.type == MessageType.audio ||
              widget.message.type == MessageType.hyperText ||
              widget.message.type == MessageType.image ||
              widget.message.type == MessageType.video ||
              widget.message.type == MessageType.post) &&
          widget.nextMessage!.senderId == widget.message.senderId) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    bool shouldPadding = true;
    if (widget.previousMessage != null) {
      // log('--------------------------');
      // log(widget.previousMessage!.type.toString());
      // log(widget.previousMessage!.content.toString());
      // log(widget.message.content);
      // log('--------------------------');
      if ((widget.previousMessage!.type == MessageType.text ||
              widget.message.type == MessageType.hyperText) &&
          widget.message.repliedFrom == null &&
          widget.message.forwardedFrom == null &&
          (widget.message.type == MessageType.text ||
              widget.message.type == MessageType.hyperText) &&
          widget.message.createdAt.isSameDay(
            widget.previousMessage!.createdAt,
          )) {
        shouldPadding = false;
      }
    }

    bool shouldShowTime = true;
    if (widget.nextMessage != null) {
      if (widget.message.createdAt.isSameDay(widget.nextMessage!.createdAt) &&
          (widget.nextMessage!.type == MessageType.text ||
              widget.nextMessage!.type == MessageType.sticker ||
              widget.nextMessage!.type == MessageType.file ||
              widget.nextMessage!.type == MessageType.call ||
              widget.nextMessage!.type == MessageType.audio ||
              widget.nextMessage!.type == MessageType.hyperText ||
              widget.nextMessage!.type == MessageType.image ||
              widget.nextMessage!.type == MessageType.video ||
              widget.nextMessage!.type == MessageType.post) &&
          widget.message.forwardedFrom == null &&
          (widget.message.type == MessageType.text ||
              widget.message.type == MessageType.sticker ||
              widget.message.type == MessageType.file ||
              widget.message.type == MessageType.call ||
              widget.message.type == MessageType.audio ||
              widget.message.type == MessageType.hyperText ||
              widget.message.type == MessageType.image ||
              widget.message.type == MessageType.video ||
              widget.message.type == MessageType.post) &&
          widget.nextMessage!.senderId == widget.message.senderId) {
        shouldShowTime = false;
      }
    }

    final child = Column(
      children: [
        shouldPadding ? AppSpacing.gapH16 : const SizedBox(height: 2),
        _buildDate(),
        if (widget.message.type == MessageType.system && widget.isGroup)
          _buildSystemMessage(context),
        if (widget.message.type != MessageType.system)
          Container(
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment:
                  widget.isMine
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                _buildSenderName(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment:
                      widget.isMine
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                  children: [
                    if (!widget.isMine && _shouldShowCheckbox)
                      _buildAnimatedCheckbox(isLeft: true),
                    if (!widget.isMine &&
                        chatSidebarController
                            .conversations[chatSidebarController
                                .currentConversationIndex
                                .value]
                            .isGroup)
                      _buildMessageAvatar(),
                    Flexible(child: _buildMessageBody(context)),
                    if (widget.isMine && _shouldShowCheckbox)
                      _buildAnimatedCheckbox(isLeft: false),
                  ],
                ),
              ],
            ),
          ),
      ],
    );

    return GestureDetector(onTap: widget.onTap, child: child);

    // return Container(
    //   height: 30,
    //   color: Colors.red,
    //   child: const Text('message'),
    // );
  }

  Widget _buildMessageAvatar() {
    // Check if next message is from the same user to avoid showing the avatar
    final bool shouldShowAvatar =
        widget.nextMessage == null ||
        widget.nextMessage!.senderId != widget.message.senderId ||
        widget.nextMessage!.type == MessageType.system;

    return shouldShowAvatar
        ? Padding(
          padding: const EdgeInsets.only(bottom: 26, right: 4),
          child: AppCircleAvatar(
            url: widget.message.sender?.avatarPath ?? '',
            size: Sizes.s36,
          ).clickable(widget.onPressedUserAvatar),
        )
        : AppSpacing.gapW40;
  }

  Widget _buildDate() {
    final bool shouldShowDate =
        widget.previousMessage == null ||
        !widget.message.createdAt.isSameDay(widget.previousMessage!.createdAt);

    return shouldShowDate
        ? IgnorePointer(
          child: Container(
            padding: AppSpacing.edgeInsetsAll16.copyWith(top: 0),
            alignment: Alignment.center,
            child: Text(
              widget.message.createdAt.toLocaleString(),
              style: AppTextStyles.s12w400.copyWith(color: AppColors.grey8),
            ),
          ),
        )
        : AppSpacing.emptyBox;
  }

  List<MenuItem> _getMenuItems() {
    final allItems = [
      MenuItem(
        label: 'Reply',
        icon: Icons.reply,
        onPressed: () {
          _onReplyMessagePressed();
        },
      ),
      MenuItem(
        label: 'Forward',
        icon: Icons.forward,
        onPressed: () {
          print('Forward pressed');
        },
      ),
    ];

    if ((widget.isAdmin || !widget.isGroup)) {
      // check if message is already pinned or not
      final isPinned = Get.find<ChatSidebarController>().isMessagePinned(
        widget.message.id,
      );
      allItems.add(
        MenuItem(
          label: isPinned ? 'Unpin' : 'Pin',
          icon: isPinned ? Icons.push_pin : Icons.push_pin_outlined,
          onPressed:
              isPinned
                  // if not pinned, then pin message, otherwise unpin message
                  ? () {}
                  : () {},
        ),
      );
    }

    if (widget.message.type == MessageType.text ||
        widget.message.type == MessageType.hyperText) {
      allItems.add(MenuItem(label: 'Copy', icon: Icons.copy, onPressed: () {}));
    }

    if (widget.message.type == MessageType.image) {
      allItems.add(MenuItem(label: 'Save', icon: Icons.save, onPressed: () {}));
    }

    // Add items that are only visible for own messages
    if (widget.isMine)
      allItems.addAll([
        MenuItem(
          label: 'Delete',
          icon: Icons.delete,
          onPressed: _showDeleteConfirmDialog,
          isDestuctive: true,
        ),
      ]);

    return allItems;
  }

  Widget _buildMessageBody(BuildContext context) {
    final Widget messageBody;

    switch (widget.message.type) {
      case MessageType.text:
        messageBody = TextMessageWidget(
          isMine: widget.isMine,
          message: widget.message,
          members: widget.members,
          onMentionPressed: widget.onMentionPressed,
        );
      // _buildTextMessage();
      case MessageType.hyperText:
        messageBody = HyperTextMessageWidget(
          isMine: widget.isMine,
          message: widget.message,
          members: widget.members,
          onMentionPressed: widget.onMentionPressed,
        );
      // messageBody = _buildHyperTextMessage();
      case MessageType.image:
      case MessageType.video:
      case MessageType.audio:
        messageBody = MediaMessageBody(
          key: ValueKey(widget.message.id),
          message: widget.message,
          isMine: widget.isMine,
        );
      case MessageType.call:
        messageBody = CallMessageBody(
          message: widget.message,
          isMine: widget.isMine,
          currentUserId: widget.currentUserId,
        );
      case MessageType.file:
        messageBody = _buildFileMessage();
      case MessageType.post:
        messageBody = _buildPostMessage(context);
      case MessageType.sticker:
        messageBody = _buildStickerMessage();
      case MessageType.system:
        messageBody = _buildSystemMessage(context);
    }

    bool shouldShowTime = true;
    if (widget.nextMessage != null) {
      if (widget.message.createdAt.isSameDay(widget.nextMessage!.createdAt) &&
          (widget.nextMessage!.type == MessageType.text ||
              widget.nextMessage!.type == MessageType.sticker ||
              widget.nextMessage!.type == MessageType.file ||
              widget.nextMessage!.type == MessageType.call ||
              widget.nextMessage!.type == MessageType.audio ||
              widget.nextMessage!.type == MessageType.hyperText ||
              widget.nextMessage!.type == MessageType.image ||
              widget.nextMessage!.type == MessageType.video ||
              widget.nextMessage!.type == MessageType.post) &&
          widget.message.forwardedFrom == null &&
          (widget.message.type == MessageType.text ||
              widget.message.type == MessageType.sticker ||
              widget.message.type == MessageType.file ||
              widget.message.type == MessageType.call ||
              widget.message.type == MessageType.audio ||
              widget.message.type == MessageType.hyperText ||
              widget.message.type == MessageType.image ||
              widget.message.type == MessageType.video ||
              widget.message.type == MessageType.post) &&
          widget.nextMessage!.senderId == widget.message.senderId) {
        shouldShowTime = false;
      }
    }

    return Column(
      crossAxisAlignment:
          widget.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (widget.message.repliedFrom != null)
          ReplyMessageWidget(
            message: widget.message.repliedFrom!,
            isMine: widget.isMine,
            onClick: _onJumpToRepliedMessage,
            members: widget.members,
            onMentionPressed: widget.onMentionPressed,
          ),
        if (widget.message.forwardedFrom != null)
          Text(
            'Forward message',
            style: AppTextStyles.s12w600.copyWith(color: AppColors.primary),
          ).paddingOnly(bottom: Sizes.s8),
        Row(
          mainAxisAlignment:
              widget.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (widget.isMine)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      widget.message.type == MessageType.text ||
                              widget.message.type == MessageType.hyperText ||
                              widget.message.type == MessageType.image
                          ? SizedBox(width: 100)
                          : AppSpacing.gapW8,
                      // _buildButtonReaction(),
                    ],
                  ),
                  AppSpacing.gapW8,
                ],
              ),

            Flexible(
              child: WebContextMenu(
                menuItems: _getMenuItems(),
                onReactionTap: (reaction) {
                  Get.find<ChatSidebarController>().reactToMessage(
                    widget.message,
                    reaction,
                  );
                },
                onMenuItemTap: (item) {
                  if (item.label == 'Reply') {
                    _onReplyMessagePressed();
                  } else if (item.label == 'Pin') {
                    Get.find<ChatSidebarController>().pinMessage(
                      widget.message,
                    );
                  } else if (item.label == 'Unpin') {
                    Get.find<ChatSidebarController>().unPinMessage(
                      widget.message,
                    );
                  } else if (item.label == 'Forward') {
                    _onForwardMessagePressed(widget.message);
                  } else if (item.label == 'Copy') {
                    Clipboard.setData(
                      ClipboardData(text: widget.message.content),
                    );
                    ToastUtil.showSuccess('Copied to clipboard');
                  } else if (item.label == 'Save') {
                    _onSaveMessagePressed();
                  } else if (item.label == 'Delete') {
                    _showDeleteConfirmDialog();
                  }
                },
                child: ClipRect(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        widget.isMine
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment:
                            widget.isMine
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          messageBody,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildShowReaction(widget.message.reactions),
                            ],
                          ),
                          if (shouldShowTime && widget.isMine)
                            Align(
                              alignment: Alignment.centerRight,
                              child: _buildMessageTime(),
                            ),
                        ],
                      ),
                      if (shouldShowTime && !widget.isMine) _buildMessageTime(),
                    ],
                  ),
                ),
              ),
            ),
            if (!widget.isMine)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSpacing.gapW8,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widget.message.type == MessageType.text ||
                              widget.message.type == MessageType.hyperText ||
                              widget.message.type == MessageType.image
                          ? SizedBox(width: 100)
                          : AppSpacing.gapW8,
                      // _buildButtonReaction(),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageTime() {
    return Padding(
      padding:
          widget.message.reactions != null
              ? EdgeInsets.zero
              : AppSpacing.edgeInsetsV4,
      child: Text(
        widget.message.createdAt.toStringTimeOnly(),
        style: AppTextStyles.s12w400.copyWith(
          color: AppColors.grey8,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildSenderName() {
    if (widget.isMine ||
        widget.message.sender == null ||
        (widget.previousMessage != null &&
            widget.previousMessage!.senderId == widget.message.senderId)) {
      return AppSpacing.emptyBox;
    }

    return Padding(
      padding: const EdgeInsets.only(left: Sizes.s48, bottom: Sizes.s8),
      child: Text(
        widget.message.sender!.fullName,
        style: AppTextStyles.s12w600.copyWith(color: AppColors.text2),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildFileMessage() {
    return Container(
      padding: AppSpacing.edgeInsetsAll16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.s12),
        color: widget.isMine ? AppColors.blue8 : AppColors.grey7,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insert_drive_file,
            color: widget.isMine ? AppColors.primary : AppColors.grey8,
          ),
          AppSpacing.gapW4,
          Flexible(
            child: Text(
              widget.message.content.split('/').last,
              style: AppTextStyles.s14w400.copyWith(
                color: widget.isMine ? AppColors.primary : AppColors.text2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ).clickable(() {
      IntentUtils.openBrowserURL(url: widget.message.content);
    });
  }

  Widget _buildPostMessage(BuildContext context) {
    return AppSpacing.emptyBox;
  }

  void _onReplyMessagePressed() {
    Get.find<ChatSidebarController>().replyMessage(widget.message);
    Get.find<ChatSidebarController>().focusNode.requestFocus();
  }

  void _onJumpToRepliedMessage(Message message) {
    // Get.find<ChatHubController>().jumpToMessage(message);
  }

  /// Handle saving message content (especially images) to device
  Future<void> _onSaveMessagePressed() async {
    try {
      // Check message type and handle accordingly
      switch (widget.message.type) {
        case MessageType.image:
          // Save image from URL
          final success = await ImageSaveService.saveImageFromUrl(
            widget.message.content,
            fileName: _generateImageFileName(),
            showSuccessMessage: true,
            showErrorMessage: false, // We'll handle errors ourselves
          );

          if (!success) {
            // Show custom error with helpful info
            ToastUtil.showError(
              'Có thể do vấn đề quyền truy cập. Tap để xem thông tin chi tiết.',
              title: 'Không thể lưu ảnh',
            );
          } else {
            debugPrint('Image saved successfully');
          }
          break;

        case MessageType.file:
          // For files, open in browser for download
          IntentUtils.openBrowserURL(url: widget.message.content);
          break;

        case MessageType.text:
        case MessageType.hyperText:
          // For text messages, copy to clipboard
          Clipboard.setData(ClipboardData(text: widget.message.content));
          ToastUtil.showSuccess('Text copied to clipboard');
          break;

        case MessageType.video:
        case MessageType.audio:
          // For media files, open in browser for download
          IntentUtils.openBrowserURL(url: widget.message.content);
          break;

        default:
          // For other types, show not supported message
          ToastUtil.showError('Không thể lưu tin nhắn', title: 'Không hỗ trợ');
      }
    } catch (e) {
      debugPrint('Error in _onSaveMessagePressed: $e');
      ToastUtil.showError('Không thể lưu tin nhắn', title: 'Không hỗ trợ');
    }
  }

  /// Generate a meaningful filename for saved images
  String _generateImageFileName() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final senderName = widget.message.sender?.firstName ?? 'unknown';
    final conversationId = widget.message.conversationId;

    return 'image_${senderName}_${conversationId}_$timestamp.jpg';
  }

  Widget _buildShowReaction(Map<String, dynamic>? reactions) {
    if (reactions == null || reactions.isEmpty) {
      return const SizedBox();
    }

    final List<String> like = [];
    final List<String> love = [];
    final List<String> haha = [];
    final List<String> wow = [];
    final List<String> angry = [];
    final List<String> sad = [];

    reactions.forEach((key, value) {
      if (key == ReactionMessageEnum.like.name) {
        for (var item in value) {
          like.add(item.toString());
        }
      }

      if (key == ReactionMessageEnum.love.name) {
        for (var item in value) {
          love.add(item.toString());
        }
      }

      if (key == ReactionMessageEnum.haha.name) {
        for (var item in value) {
          haha.add(item.toString());
        }
      }

      if (key == ReactionMessageEnum.wow.name) {
        for (var item in value) {
          wow.add(item.toString());
        }
      }

      if (key == ReactionMessageEnum.angry.name) {
        for (var item in value) {
          angry.add(item.toString());
        }
      }

      if (key == ReactionMessageEnum.sad.name) {
        for (var item in value) {
          sad.add(item.toString());
        }
      }
    });

    return Transform.translate(
      offset: const Offset(0, -Sizes.s8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.isMine) AppSpacing.gapW8,
          if (love.isNotEmpty)
            _buildItemReaction(
              icon: '❤️',
              reactListUser: love,
              reactionType: ReactionMessageEnum.love.name,
              onTap: () {
                _buildShowBottomSheetUserReaction(reactions);
              },
            ),
          if (haha.isNotEmpty)
            _buildItemReaction(
              icon: '😆',
              reactListUser: haha,
              reactionType: ReactionMessageEnum.haha.name,
              onTap: () {
                _buildShowBottomSheetUserReaction(reactions);
              },
            ),
          if (sad.isNotEmpty)
            _buildItemReaction(
              icon: '😢',
              reactListUser: sad,
              reactionType: ReactionMessageEnum.sad.name,
              onTap: () {
                _buildShowBottomSheetUserReaction(reactions);
              },
            ),
          if (like.isNotEmpty)
            _buildItemReaction(
              icon: '👍',
              reactListUser: like,
              reactionType: ReactionMessageEnum.like.name,
              onTap: () {
                _buildShowBottomSheetUserReaction(reactions);
              },
            ),
          if (angry.isNotEmpty)
            _buildItemReaction(
              icon: '😡',
              reactListUser: angry,
              reactionType: ReactionMessageEnum.angry.name,
              onTap: () {
                _buildShowBottomSheetUserReaction(reactions);
              },
            ),
          if (wow.isNotEmpty)
            _buildItemReaction(
              icon: '😮',
              reactListUser: wow,
              reactionType: ReactionMessageEnum.wow.name,
              onTap: () {
                _buildShowBottomSheetUserReaction(reactions);
              },
            ),
          if (widget.isMine) AppSpacing.gapW8,
        ],
      ),
    );
  }

  Widget _buildItemReaction({
    required String icon,
    List<String> reactListUser = const [],
    Function()? onTap,
    String reactionType = '',
  }) {
    final Widget reactionContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Text(
            icon,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
        if (reactListUser.length > 1)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSpacing.gapW2,
              Text(
                reactListUser.length.toString(),
                style: AppTextStyles.s12w400.copyWith(color: AppColors.primary),
              ),
            ],
          ),
      ],
    );

    // Kiểm tra nếu có animation cho reaction này
    final animation = _reactionAnimations[reactionType];
    if (animation != null) {
      return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final value = animation.value;

          // Tạo hiệu ứng rơi từ trên cao với kích thước lớn xuống vị trí mặc định
          // Scale: bắt đầu từ 3x và giảm xuống 1x
          final scale = 3.0 - (2.0 * value);

          // Translate: bắt đầu từ trên cao (-50px) và rơi xuống vị trí mặc định (0px)
          final translateY = -50.0 + (50.0 * value);

          return Transform.scale(
            scale: scale,
            child: Transform.translate(
              offset: Offset(0, translateY),
              child: child,
            ),
          );
        },
        child: reactionContent,
      );
    }

    return reactionContent;
  }

  Future _buildShowBottomSheetUserReaction(Map<String, dynamic> reactions) {
    final List<String> like = [];
    final List<String> love = [];
    final List<String> haha = [];
    final List<String> wow = [];
    final List<String> angry = [];
    final List<String> sad = [];

    widget.message.reactions?.forEach((key, value) {
      if (key == ReactionMessageEnum.like.name) {
        for (var item in value) {
          like.add(item.toString());
        }
      }

      if (key == ReactionMessageEnum.love.name) {
        for (var item in value) {
          love.add(item.toString());
        }
      }

      if (key == ReactionMessageEnum.haha.name) {
        for (var item in value) {
          haha.add(item.toString());
        }
      }

      if (key == ReactionMessageEnum.wow.name) {
        for (var item in value) {
          wow.add(item.toString());
        }
      }

      if (key == ReactionMessageEnum.angry.name) {
        for (var item in value) {
          angry.add(item.toString());
        }
      }

      if (key == ReactionMessageEnum.sad.name) {
        for (var item in value) {
          sad.add(item.toString());
        }
      }
    });

    final int tabLength =
        (like.isNotEmpty ? 1 : 0) +
        (love.isNotEmpty ? 1 : 0) +
        (haha.isNotEmpty ? 1 : 0) +
        (wow.isNotEmpty ? 1 : 0) +
        (angry.isNotEmpty ? 1 : 0) +
        (sad.isNotEmpty ? 1 : 0);

    return Get.bottomSheet(
      SizedBox(
        height: 100,
        child: Container(
          child: DefaultTabController(
            length: tabLength,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    if (love.isNotEmpty)
                      Tab(icon: Icon(Icons.favorite, size: 32)),
                    if (haha.isNotEmpty)
                      Tab(icon: Icon(Icons.sentiment_very_satisfied, size: 32)),
                    if (sad.isNotEmpty)
                      Tab(
                        icon: Icon(Icons.sentiment_very_dissatisfied, size: 32),
                      ),
                    if (like.isNotEmpty)
                      Tab(icon: Icon(Icons.thumb_up, size: 32)),
                    if (angry.isNotEmpty)
                      Tab(
                        icon: Icon(Icons.sentiment_very_dissatisfied, size: 32),
                      ),
                    if (wow.isNotEmpty)
                      Tab(icon: Icon(Icons.sentiment_very_satisfied, size: 32)),
                  ],
                ),
                AppSpacing.gapH12,
                Expanded(
                  child: TabBarView(
                    children: [
                      if (love.isNotEmpty) _buildItemBottomSheet(love),
                      if (haha.isNotEmpty) _buildItemBottomSheet(haha),
                      if (like.isNotEmpty) _buildItemBottomSheet(like),
                      if (sad.isNotEmpty) _buildItemBottomSheet(sad),
                      if (angry.isNotEmpty) _buildItemBottomSheet(angry),
                      if (wow.isNotEmpty) _buildItemBottomSheet(wow),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemBottomSheet(List<String> reactListUser) {
    return AppSpacing.emptyBox;
    // return GetBuilder<ChatHubController>(
    //   init: ChatHubController(),
    //   builder: (controller) {
    //     final members = controller.getUsersByIds(reactListUser);

    //     return FutureBuilder<List<User>>(
    //       future: members,
    //       builder: (context, snapshot) {
    //         final members = snapshot.data ?? [];

    //         return Center(
    //           child: ListView.separated(
    //             itemCount: reactListUser.length,
    //             itemBuilder: (context, index) {
    //               final user = members.firstWhereOrNull(
    //                 (element) => element.id.toString() == reactListUser[index],
    //               );

    //               return ListTile(
    //                 leading: AppCircleAvatar(
    //                   url: user?.avatarPath ?? '',
    //                   size: Sizes.s40,
    //                 ),
    //                 title: Text(
    //                   (user?.contact?.fullName ?? '').isNotEmpty
    //                       ? user?.contact?.fullName ?? ''
    //                       : user?.fullName ?? '',
    //                 ),
    //               );
    //             },
    //             separatorBuilder: (context, index) => const SizedBox(height: 8),
    //           ),
    //         );
    //       },
    //     );
    //   },
    // );
  }

  Widget _buildStickerMessage() {
    return AppSpacing.emptyBox;
  }

  Widget _buildSystemMessage(BuildContext context) {
    final Widget messageSystemWidget;

    try {
      final messageSystem = MessageSystem.fromJson(
        jsonDecode(widget.message.content),
      );

      switch (messageSystem.type) {
        case MessageSystemType.addMember:
          messageSystemWidget = _buildTextMessageSystemAddMember(
            context,
            memberIds: messageSystem.memberIds,
          );
        case MessageSystemType.removeMember:
          messageSystemWidget = _buildTextMessageSystemRemoveMember(
            context,
            memberIds: messageSystem.memberIds,
          );
      }

      return messageSystemWidget;
    } catch (e) {
      return AppSpacing.emptyBox;
    }
  }

  Widget _buildTextMessageSystemAddMember(
    BuildContext context, {
    List<String> memberIds = const [],
  }) {
    return AppSpacing.emptyBox;
    // return GetBuilder<ChatHubController>(
    //   init: ChatHubController(),
    //   builder: (controller) {
    //     final members = controller.getUsersByIds(memberIds);

    //     return FutureBuilder<List<User>>(
    //       future: members,
    //       builder: (context, snapshot) {
    //         final members = snapshot.data ?? [];

    //         final user = members.firstWhereOrNull(
    //           (element) => memberIds.contains(element.id.toString()),
    //         );

    //         final name = user?.contactName ?? user?.fullName ?? '';

    //         return Text(
    //           context.l10n.conversation_details__add_member(name),
    //           style: AppTextStyles.s14w400.toColor(
    //             AppColors.zambezi,
    //           ),
    //         );
    //       },
    //     );
    //   },
    // );
  }

  Widget _buildTextMessageSystemRemoveMember(
    BuildContext context, {
    List<String> memberIds = const [],
  }) {
    return AppSpacing.emptyBox;
    // return GetBuilder<ChatHubController>(
    //   init: ChatHubController(),
    //   builder: (controller) {
    //     final members = controller.getUsersByIds(memberIds);

    //     return FutureBuilder<List<User>>(
    //       future: members,
    //       builder: (context, snapshot) {
    //         final members = snapshot.data ?? [];

    //         final user = members.firstWhereOrNull(
    //           (element) => memberIds.contains(element.id.toString()),
    //         );

    //         final name = user?.contactName ?? user?.fullName ?? '';

    //         return Text(
    //           context.l10n.conversation_details__remove_member(name),
    //           style: AppTextStyles.s14w400.toColor(
    //             AppColors.zambezi,
    //           ),
    //         );
    //       },
    //     );
    //   },
    // );
  }

  void _onForwardMessagePressed(Message message) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 400,
          height: 500,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text('Forward Message', style: AppTextStyles.s16w700),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: AppColors.text2, size: 20),
                  ),
                ],
              ),

              // Conversations List
              Expanded(
                child: Builder(
                  builder: (context) {
                    return Obx(() {
                      return ListView.builder(
                        itemCount: chatSidebarController.conversations.length,
                        itemBuilder: (context, index) {
                          final conversation =
                              chatSidebarController.conversations[index];

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            leading: AppCircleAvatar(
                              url: conversation.avatarUrl() ?? '',
                              size: 48,
                            ),
                            title: Text(
                              conversation.title(),
                              style: AppTextStyles.s14w600,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            onTap: () {
                              chatSidebarController.forwardMessage(
                                message,
                                conversation,
                              );
                            },
                          );
                        },
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Xóa tin nhắn',
                style: AppTextStyles.s16w700.copyWith(color: AppColors.text2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),

              // Content
              Text(
                'Bạn có chắc chắn muốn xóa tin nhắn này không?',
                style: AppTextStyles.s12w400.copyWith(
                  color: AppColors.subText2,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.greyBorder,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.text2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Hủy',
                          style: AppTextStyles.s14w600.copyWith(
                            color: AppColors.text2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Delete button
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.negative,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.negative.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () {
                          Get.back();
                          Get.find<ChatSidebarController>().deleteMessage(
                            widget.message,
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Xóa',
                          style: AppTextStyles.s14w600.copyWith(
                            color: Colors.white,
                          ),
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
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 300),
      transitionCurve: Curves.easeInOut,
    );
  }
}
