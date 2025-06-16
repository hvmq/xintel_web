import 'package:flutter/material.dart';

import '../../../../../../models/message.dart';
import '../../../../../../models/user.dart';
import '../../../../../resources/styles/app_colors.dart';
import '../../../../../resources/styles/gaps.dart';
import '../../../../../resources/styles/text_styles.dart';
import 'hyper_text_message_widget.dart';
import 'text_message_widget.dart';

class ReplyMessagePreviewWidget extends StatefulWidget {
  final Message message;
  final Function() onCloseMessage;
  final bool isMine;
  final List<User> members;
  final Function(String? mention, Map<String, int> mentionUserIdMap)
  onMentionPressed;

  const ReplyMessagePreviewWidget({
    required this.message,
    required this.onCloseMessage,
    required this.isMine,
    required this.members,
    required this.onMentionPressed,
    super.key,
  });

  @override
  State<ReplyMessagePreviewWidget> createState() =>
      _ReplyMessagePreviewWidgetState();
}

class _ReplyMessagePreviewWidgetState extends State<ReplyMessagePreviewWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Slide animation from bottom to top
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0), // Start from bottom
      end: const Offset(0.0, 0.0), // End at normal position
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Fade animation for smooth appearance
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Start the animation when widget is initialized
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.only(
            top: Sizes.s8,
            left: Sizes.s20,
            right: Sizes.s20,
            bottom: Sizes.s16,
          ),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 1,
                color: AppColors.grey8.withOpacity(0.5),
                offset: const Offset(0, 1),
              ),
            ],
            color: AppColors.text1,
            border: const Border(
              top: BorderSide(color: AppColors.grey8, width: 0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.message.sender != null)
                      Text(
                        widget.message.sender!.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.s14w700.copyWith(
                          color: AppColors.text2,
                        ),
                      ),
                    contentMessage(context, widget.message),
                  ],
                ),
              ),
              InkWell(
                onTap: () async {
                  // Animate out before closing
                  await _animationController.reverse();
                  widget.onCloseMessage();
                },
                child: Icon(Icons.close, color: AppColors.text2, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget contentMessage(BuildContext context, Message message) {
    return switch (message.type) {
      MessageType.text => TextMessageWidget(
        isMine: widget.isMine,
        message: message,
        members: widget.members,
        onMentionPressed: widget.onMentionPressed,
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        isTextEllipsis: true,
        maxLines: 2,
        isPreviewReply: true,
      ),
      MessageType.hyperText => HyperTextMessageWidget(
        isMine: widget.isMine,
        message: message,
        members: widget.members,
        onMentionPressed: widget.onMentionPressed,
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        isTextEllipsis: true,
        isShowLinkPreview: false,
        maxLines: 2,
        isPreviewReply: true,
      ),
      MessageType.image => textWidget('Image'),
      MessageType.video => textWidget('Video'),
      MessageType.audio => textWidget('Audio'),
      MessageType.call => textWidget('Call'),
      MessageType.file => textWidget('File'),
      MessageType.post => textWidget('Post'),
      MessageType.sticker => textWidget('Sticker'),
      MessageType.system => textWidget('System'),
    };
  }

  Widget textWidget(String text) {
    return Text(
      text,
      style: AppTextStyles.s14w600.copyWith(color: AppColors.grey8),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
