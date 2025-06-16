import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xintel/core/extensions/widget_extensions.dart';
import 'package:xintel/presentation/features/auth/auth_controller.dart';

import '../../../../../models/message.dart';
import '../../../../../resources/styles/app_colors.dart';
import '../../../../../resources/styles/gaps.dart';
import '../../../../../resources/styles/text_styles.dart';
import '../../chat_sidebar_controller.dart';
import '_message_item.dart';

class PinMessagesWidget extends StatefulWidget {
  const PinMessagesWidget({super.key});

  @override
  State<PinMessagesWidget> createState() => _PinMessagesWidgetState();
}

class _PinMessagesWidgetState extends State<PinMessagesWidget> {
  final scrollController = ScrollController();
  final controller = Get.find<ChatSidebarController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.text1,
      appBar: AppBar(
        backgroundColor: AppColors.text1,
        foregroundColor: AppColors.text1,
        surfaceTintColor: AppColors.text1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.text2),
          onPressed: () {
            Get.back();
          },
        ),
        title: Obx(
          () => Text(
            '${controller.pinnedMessages.length} Pinned message',
            style: AppTextStyles.s16w600.copyWith(color: AppColors.text2),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          AppSpacing.gapH4,
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: AppSpacing.edgeInsetsH20,
              itemCount: controller.pinnedMessages.length,
              itemBuilder: (context, index) {
                final previousMessage =
                    index + 1 < controller.pinnedMessages.length
                        ? controller.pinnedMessages[index + 1]
                        : null;
                final message = controller.pinnedMessages[index];
                return MessageItem(
                  key: ValueKey(message.id),
                  isMine: message.isMine(
                    myId: Get.find<AuthController>().currentUser.value!.id,
                  ),
                  message: message,
                  previousMessage: previousMessage,
                  currentUserId:
                      Get.find<AuthController>().currentUser.value!.id,
                  onTap: () {
                    if (Get.isBottomSheetOpen == true) {
                      Get.back();
                    }
                    // Get.find<ChatHubController>().jumpToMessage(message);
                  },
                  onPressedUserAvatar: () {
                    if (Get.isBottomSheetOpen == true) {
                      Get.back();
                    }
                    // Get.find<ChatHubController>().onUserAvatarTap(message);
                  },
                  onMentionPressed: (mention, mentionUserIdMap) {
                    if (Get.isBottomSheetOpen == true) {
                      Get.back();
                    }
                    // Get.find<ChatHubController>().onMentionPressed(
                    //   mention,
                    //   mentionUserIdMap,
                    // );
                  },
                  onSelectMessage: (Message message) {},
                  isSelectMode: false,
                  isSelect: false,
                );
              },
            ),
          ),
          Padding(
            padding: AppSpacing.edgeInsetsH20,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              width: 200,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Text(
                  'Unpin all message',
                  style: AppTextStyles.s14w500.copyWith(color: AppColors.text1),
                ),
              ),
            ),
          ).clickable(() {
            controller.unPinAllMessage();
          }),
          AppSpacing.bottomPaddingSizedBox(context),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future unPinAllMessage() async {
    await Get.find<ChatSidebarController>().unPinAllMessage();
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
  }
}
