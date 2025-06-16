import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../models/message.dart';
import '../../../../../resources/styles/app_colors.dart';
import '../../../../../resources/styles/gaps.dart';
import '../../../../../resources/styles/text_styles.dart';
import '../../chat_sidebar_controller.dart';
import 'pin_messages_widget.dart';

class PinMessageWidget extends StatefulWidget {
  const PinMessageWidget({super.key});

  @override
  State<PinMessageWidget> createState() => _PinMessageWidgetState();
}

class _PinMessageWidgetState extends State<PinMessageWidget> {
  final ScrollController scrollController = ScrollController();

  void nextReplyMessage(ChatSidebarController controller) {
    if (controller.currentReplyIndex.value - 1 >= 0) {
      controller.currentReplyIndex.value--;
    } else {
      controller.currentReplyIndex.value = controller.pinnedMessages.length - 1;
    }
    scrollToIndex(
      controller.currentReplyIndex.value,
      controller.pinnedMessages,
    );
  }

  void scrollToIndex(int index, List<Message> pinnedMessages) {
    double containerHeight;
    if (pinnedMessages.length == 1) {
      containerHeight = 50;
    } else if (pinnedMessages.length == 2) {
      containerHeight = 50 / 2; // Half height
    } else {
      containerHeight = 50 / 3;
    }

    final position =
        containerHeight *
        index; // Chiều cao của Container trong ListView.builder
    scrollController.animateTo(
      position,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if ChatSidebarController is available before using it
    if (!Get.isRegistered<ChatSidebarController>()) {
      return AppSpacing.emptyBox;
    }

    final controller = Get.find<ChatSidebarController>();
    String label = '';
    return Obx(() {
      if (controller.pinnedMessages.isEmpty) {
        return AppSpacing.emptyBox;
      } else {
        var lastMessage = controller.pinnedMessages.last;
        final currentIndex = controller.currentReplyIndex.value;
        try {
          if (currentIndex != -1) {
            lastMessage = controller.pinnedMessages[currentIndex];
            if (controller.pinnedMessages.length - 1 - currentIndex > 0) {
              label = '#${controller.pinnedMessages.length - 1 - currentIndex}';
            }
          }
        } catch (e) {}

        return Container(
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.grey6,
            boxShadow: [
              BoxShadow(
                color: AppColors.text2.withOpacity(0.25),
                blurRadius: 4,
                offset: const Offset(0, 3), // // changes position of shadow
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: Sizes.s8.h),
          child: GestureDetector(
            onTap: () => nextReplyMessage(controller),
            behavior: HitTestBehavior.translucent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 50,
                  width: 2,
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: controller.pinnedMessages.length,
                    itemBuilder: (context, index) {
                      // Calculate container height based on length conditions
                      double containerHeight;
                      if (controller.pinnedMessages.length == 1) {
                        containerHeight = 50; // Full height
                      } else if (controller.pinnedMessages.length == 2) {
                        containerHeight = 50 / 2; // Half height
                      } else {
                        containerHeight = 50 / 3;
                      }

                      return Container(
                        height: containerHeight,
                        width: 8,
                        decoration: BoxDecoration(
                          color:
                              currentIndex == index
                                  ? AppColors.green3
                                  : AppColors.green3.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ).marginOnly(bottom: 2);
                    },
                  ),
                ),

                // Container(
                //   color: AppColors.green3,
                //   width: 2,
                // ),
                AppSpacing.gapW8,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pinned message',
                        style: AppTextStyles.s14w500.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        message(context, lastMessage),
                        style: AppTextStyles.s12w600.copyWith(
                          color: AppColors.text2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapW24,
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: InkWell(
                    onTap: () => showListPinnedMessages(),
                    child: Icon(
                      Icons.arrow_drop_down_circle_outlined,
                      color: AppColors.grey10,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });
  }

  void showListPinnedMessages() {
    showDialog(
      context: Get.context!,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizedBox(
              width: 400,
              height: 500,
              child: const PinMessagesWidget(),
            ),
          ),
    );
  }

  String message(BuildContext context, Message message) {
    return switch (message.type) {
      MessageType.text => message.content,
      MessageType.hyperText => message.contentWithoutFormat,
      MessageType.image => 'Image',
      MessageType.video => 'Video',
      MessageType.audio => 'Audio',
      MessageType.call => 'Call',
      MessageType.file => 'File',
      MessageType.post => 'Post',
      MessageType.sticker => 'Sticker',
      MessageType.system => 'System',
    };
  }
}
