import 'package:flutter/material.dart';

import '../../../../../models/message.dart';
import '../../../../../models/user.dart';
import '../../../../../resources/styles/app_colors.dart';
import '../../../../../resources/styles/gaps.dart';
import '../../../../../resources/styles/text_styles.dart';
import 'hyper_text_message_widget.dart';
import 'text_message_widget.dart';

class ReplyMessageWidget extends StatelessWidget {
  final Message message;
  final bool isMine;
  final Function(Message) onClick;
  final List<User> members;
  final Function(String? mention, Map<String, int> mentionUserIdMap)
  onMentionPressed;

  const ReplyMessageWidget({
    required this.message,
    required this.isMine,
    required this.onClick,
    required this.members,
    required this.onMentionPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClick(message),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            left:
                isMine
                    ? BorderSide.none
                    : const BorderSide(
                      color: AppColors.primary,
                      width: Sizes.s4,
                    ),
            right:
                isMine
                    ? const BorderSide(
                      color: AppColors.primary,
                      width: Sizes.s4,
                    )
                    : BorderSide.none,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: Sizes.s4,
          horizontal: Sizes.s8,
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.sender != null)
              Text(
                message.sender!.fullName,
                style: AppTextStyles.s14w700.copyWith(color: AppColors.primary),
              ),
            contentMessage(context, message),
          ],
        ),
      ),
    );
  }

  Widget contentMessage(BuildContext context, Message message) {
    return switch (message.type) {
      MessageType.text => TextMessageWidget(
        isMine: isMine,
        message: message,
        members: members,
        onMentionPressed: onMentionPressed,
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        isTextEllipsis: true,
        isReply: true,
      ),
      MessageType.hyperText => HyperTextMessageWidget(
        isMine: isMine,
        message: message,
        members: members,
        onMentionPressed: onMentionPressed,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        isTextEllipsis: true,
        isShowLinkPreview: false,
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

  Widget textWidget(String message) {
    return Text(
      message,
      style: AppTextStyles.s14w600.copyWith(color: AppColors.text2),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
