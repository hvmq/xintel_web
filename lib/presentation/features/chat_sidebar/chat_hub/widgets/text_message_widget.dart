import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:styled_text/styled_text.dart';
import 'package:xintel/core/constans/app_constants.dart';
import 'package:xintel/core/extensions/widget_extensions.dart';

import '../../../../../models/message.dart';
import '../../../../../models/user.dart';
import '../../../../../resources/styles/app_colors.dart';
import '../../../../../resources/styles/gaps.dart';
import '../../../../../resources/styles/text_styles.dart';
import 'business_card_widget.dart';

class TextMessageController extends GetxController {
  final isFlashing = false.obs;

  RxString tag = ''.obs;

  void triggerFlash(String id) {
    tag.value = id;
    isFlashing.value = true;
    Future.delayed(const Duration(milliseconds: 1000), () {
      isFlashing.value = false;
    });
  }
}

class TextMessageWidget extends StatelessWidget {
  final bool isMine;
  final Message message;
  final List<User> members;
  final Function(String? mention, Map<String, int> mentionUserIdMap)
  onMentionPressed;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final bool isTextEllipsis;
  final int? maxLines;
  final bool isReply;
  final bool isPreviewReply;
  final bool isReaction;

  const TextMessageWidget({
    required this.isMine,
    required this.message,
    required this.members,
    required this.onMentionPressed,
    super.key,
    this.padding,
    this.backgroundColor,
    this.isTextEllipsis = false,
    this.maxLines,
    this.isReply = false,
    this.isPreviewReply = false,
    this.isReaction = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TextMessageController>();
    if (_isBusinessCard(message.content)) {
      return _buildBusinessCard(false);
    }
    if (message.content.startsWith('bank_info;')) {
      return _buildBusinessCard(true);
    }
    return message.content.contains('https://maps.google.com/')
        ? Container(
          width: 200,
          decoration: BoxDecoration(
            color: AppColors.grey7,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Vị trí được chia sẻ',
                    style: AppTextStyles.s14w600.copyWith(
                      color: AppColors.text2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: 100,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Xem vị trí',
                        style: AppTextStyles.s12w500.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ).clickable(() {
                // Check for Google Maps links (with or without hyper tags)
                String cleanContent = message.content;
                String? mapsUrl;

                // Remove hyper tags and extract Google Maps URL
                if (message.content.contains('<hyper>') &&
                    message.content.contains('</hyper>')) {
                  final hyperRegex = RegExp(r'<hyper>(.*?)</hyper>');
                  final match = hyperRegex.firstMatch(message.content);
                  if (match != null) {
                    final extractedUrl = match.group(1);
                    if (extractedUrl != null &&
                        extractedUrl.contains('maps.google.com')) {
                      mapsUrl = extractedUrl;
                      cleanContent = message.content.replaceAll(hyperRegex, '');
                    }
                  }
                } else if (message.content.contains(
                  'https://maps.google.com/',
                )) {
                  mapsUrl = message.content;
                }
                // IntentUtils.openBrowserURL(url: mapsUrl!);
              }),
            ],
          ),
        )
        : Obx(
          () => AnimatedContainer(
            duration: const Duration(milliseconds: 1000),
            decoration: BoxDecoration(
              color:
                  controller.isFlashing.value &&
                          controller.tag.value == message.id
                      ? AppColors.blue7
                      : backgroundColor ??
                          (isMine ? AppColors.primary : AppColors.grey7),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(Sizes.s20),
                topRight: const Radius.circular(Sizes.s20),
                bottomLeft: Radius.circular(isMine ? Sizes.s20 : 0),
                bottomRight: Radius.circular(isMine ? 0 : Sizes.s20),
              ),
            ),
            padding:
                padding ??
                const EdgeInsets.symmetric(
                  horizontal: Sizes.s24,
                  vertical: Sizes.s8,
                ),
            child: Builder(
              builder: (context) {
                if (message.isMentionedMessage ||
                    message.type == MessageType.hyperText) {
                  String content = message.content;

                  final mentionedUserIds = message.mentionedUserIds;

                  final mentionUserIdMap = <String, int>{};

                  for (final userId in mentionedUserIds) {
                    final user = members.firstWhereOrNull(
                      (element) => element.id == userId,
                    );

                    final mentionKey = userIdMentionWrapper.replaceAll(
                      'userId',
                      userId.toString(),
                    );

                    String? userFullName =
                        user?.contact?.fullName ?? user?.fullName;

                    if (userFullName == null) {
                      final originMentionUserName = message.mentions?.keys
                          .toList()
                          .firstWhereOrNull(
                            (element) => element.contains(mentionKey),
                          );

                      userFullName = originMentionUserName;
                    }

                    if (userFullName != null) {
                      final toReplace =
                          '<${AppConstants.mentionTag}>@${userFullName.trim()}</${AppConstants.mentionTag}>';

                      mentionUserIdMap[toReplace] = userId;
                      content = content.replaceAll(mentionKey, toReplace);
                    }
                  }

                  return isReaction
                      ? LayoutBuilder(
                        builder: (context, constraints) {
                          return Container(
                            constraints: BoxConstraints(maxHeight: 0.4),
                            child: SingleChildScrollView(
                              child: contentHyperText(
                                context,
                                content,
                                mentionUserIdMap,
                              ),
                            ),
                          );
                        },
                      )
                      : contentHyperText(context, content, mentionUserIdMap);
                }

                return isReaction
                    ? LayoutBuilder(
                      builder: (context, constraints) {
                        final textStyle = AppTextStyles.s16w500.copyWith(
                          color:
                              isPreviewReply
                                  ? AppColors.text1
                                  : isMine
                                  ? AppColors.white
                                  : AppColors.text1,
                        );

                        final textPainter = TextPainter(
                          text: TextSpan(
                            text: message.getDisplayContent,
                            style: textStyle,
                          ),
                          textDirection: TextDirection.ltr,
                        )..layout(maxWidth: constraints.maxWidth);

                        final lineMetrics = textPainter.computeLineMetrics();
                        final isOverflowing =
                            textPainter.height > constraints.maxHeight;

                        // Calculate approximate line height
                        final lineHeight =
                            lineMetrics.isNotEmpty
                                ? textPainter.height / lineMetrics.length
                                : textStyle.fontSize ?? 16.0;

                        return Container(
                          constraints: BoxConstraints(maxHeight: 0.4),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Text(
                              message.getDisplayContent,
                              style: textStyle.copyWith(
                                decoration: TextDecoration.none,
                                color:
                                    isPreviewReply
                                        ? AppColors.grey8
                                        : isReply
                                        ? AppColors.text2
                                        : isMine
                                        ? AppColors.text1
                                        : AppColors.text2,
                              ),
                              maxLines:
                                  isOverflowing
                                      ? (constraints.maxHeight ~/ lineHeight)
                                          .clamp(1, 10)
                                      : null,
                              overflow:
                                  isOverflowing ? TextOverflow.ellipsis : null,
                            ),
                          ),
                        );
                      },
                    )
                    : Text(
                      message.content,
                      overflow:
                          isTextEllipsis
                              ? TextOverflow.ellipsis
                              : TextOverflow.clip,

                      // style: AppTextStyles.s14w400.toColor(
                      //   isPreviewReply
                      //       ? AppColors.grey8
                      //       : isReply
                      //           ? AppColors.text2
                      //           : isMine
                      //               ? AppColors.text1
                      //               : AppColors.text2,
                      // ),
                      style: AppTextStyles.s14w400.copyWith(
                        decoration: TextDecoration.none,
                        color:
                            isPreviewReply
                                ? AppColors.grey8
                                : isReply
                                ? AppColors.text2
                                : isMine
                                ? AppColors.text1
                                : AppColors.text2,
                      ),
                      maxLines: maxLines,
                    );
              },
            ),
          ),
        );
  }

  bool _isBusinessCard(String content) {
    return content.startsWith('business_card;');
  }

  Widget _buildBusinessCard(bool isBankInfo) {
    final parts = message.content.split(';');
    if (parts.length >= 5) {
      final phone = parts[1];
      final String name = parts[2];
      String avatarUrl = parts[3];
      final userId = parts[4];

      if (isBankInfo) {
        avatarUrl =
            phone == 'MBBANK'
                ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQaFNN2m4N6r9I6PrPTqxOdj2OVJZ_l1rqb1g&s'
                : phone == 'TPBANK'
                ? 'https://play-lh.googleusercontent.com/BPH-8BeU4Zx4OgW5OQHBx9-IoaGTPKX8yoLu2SjDZNvq20zuVnkfXQVOQbFGgA8qm2o'
                : 'https://play-lh.googleusercontent.com/rNSXUqGnK-ljK6qUdUmy7h_sDrMOzZ1nPwAUAwshsmPaQuwNGn0Xwj-psgFrBSJOHg';
      }
      return BusinessCardWidget(
        phone: phone,
        name: name,
        avatarUrl: avatarUrl,
        isMine: isMine,
        userId: userId,
        isBankInfo: isBankInfo,
      );
    }

    // Fallback to normal text if parsing fails
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.s24,
        vertical: Sizes.s8,
      ),
      decoration: BoxDecoration(
        color: isMine ? AppColors.primary : AppColors.grey7,
        borderRadius: BorderRadius.circular(Sizes.s20),
      ),
      child: Text(
        message.content,
        style: AppTextStyles.s14w400.copyWith(
          color: isMine ? AppColors.white : AppColors.text1,
        ),
      ),
    );
  }

  /// Widget use for rendering content of message with type is hypertext
  Widget contentHyperText(
    BuildContext context,
    String content,
    Map<String, int> mentionUserIdMap,
  ) {
    return StyledText(
      text: content,
      overflow: isTextEllipsis ? TextOverflow.ellipsis : TextOverflow.clip,
      style: AppTextStyles.s14w400.copyWith(
        color: isMine ? AppColors.text1 : AppColors.text2,
      ),
      maxLines: maxLines,
      tags: {
        AppConstants.mentionTag: StyledTextActionTag(
          (mention, _) => onMentionPressed(mention, mentionUserIdMap),
          style: AppTextStyles.s14w400.copyWith(
            color: isMine ? Colors.white : Colors.black,
            decoration: TextDecoration.underline,
            decorationColor: isMine ? Colors.white : Colors.black,
          ),
        ),
        AppConstants.hyperTextTag: StyledTextActionTag(
          (hyper, _) {
            if (hyper == null) {
              return;
            }
            // if (hyper.contains(Get.find<EnvConfig>().jitsiUrl)) {
            //   final List<String> parts = hyper.split('/');

            //   final String idMeeting = parts[3];

            //   Get.find<ChatHubController>()
            //       .createOrJoinCallJitsi(idMeeting, ' ');
            // } else {
            //   IntentUtils.openBrowserURL(url: hyper);
            // }
          },
          style: AppTextStyles.s14w400.copyWith(
            color:
                isPreviewReply
                    ? AppColors.grey8
                    : isMine
                    ? Colors.white
                    : AppColors.primary,
            decoration: TextDecoration.underline,
            decorationColor:
                isPreviewReply
                    ? AppColors.grey8
                    : isMine
                    ? Colors.white
                    : AppColors.primary,
          ),
        ),
      },
    );
  }
}
