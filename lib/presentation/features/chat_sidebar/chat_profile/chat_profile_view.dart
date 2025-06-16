import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xintel/core/extensions/widget_extensions.dart';

import '../../../../resources/styles/styles.dart';
import '../../../widgets/circle_avatar.dart';
import '../chat_sidebar_controller.dart';
import 'chat_member_view.dart';
import 'chat_resource_view.dart';

class ChatProfileView extends StatefulWidget {
  const ChatProfileView({super.key});

  @override
  State<ChatProfileView> createState() => _ChatProfileViewState();
}

class _ChatProfileViewState extends State<ChatProfileView>
    with TickerProviderStateMixin {
  late TabController tabController;

  void _showDetail(String pageName) {
    final controller = Get.find<ChatSidebarController>();
    controller.loadConversationResources();
    controller.isShowChatResource.value = true;
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatSidebarController>();
    return Obx(
      () => Stack(
        alignment: Alignment.centerRight,
        children: [
          // Profile Container
          Container(
            width: controller.profileWidth.value,
            height: double.infinity,
            color: Colors.white,
            child: Obx(() {
              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: controller.profileWidth.value,
                    height: 56,
                    child: Row(
                      children: [
                        AppSpacing.gapW12,
                        Icon(Icons.close, color: AppColors.subText2).clickable(
                          () {
                            controller.isShowChatResource.value = false;
                            controller.isShowChatProfile.value = false;
                          },
                        ),
                        AppSpacing.gapW12,
                        Text(
                          'User Info',
                          style: AppTextStyles.s16w700.copyWith(
                            color: AppColors.text2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: AppColors.greyBorder,
                    height: 1,
                    thickness: 0.5,
                  ),
                  AppSpacing.gapH24,
                  _buildConversationInfo(context, controller),
                  AppSpacing.gapH24,
                  _buildPrivacyAndSupport(context, controller),
                ],
              );
            }),
          ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width:
                controller.isShowChatResource.value
                    ? controller.profileWidth.value
                    : 0,
            height: double.infinity,
            color: Colors.white,
            child:
                controller.isShowChatResource.value
                    ? ChatResourceView()
                    : const SizedBox.shrink(),
          ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width:
                controller.isShowChatMember.value
                    ? controller.profileWidth.value
                    : 0,
            height: double.infinity,
            color: Colors.white,
            child:
                controller.isShowChatMember.value
                    ? ChatMemberView()
                    : const SizedBox.shrink(),
          ),
          // Detail Page Container
        ],
      ),
    );
  }

  Widget _buildConversationInfo(
    BuildContext context,
    ChatSidebarController controller,
  ) {
    return Column(
      children: [
        AppCircleAvatar(
          url:
              controller
                  .conversations[controller.currentConversationIndex.value]
                  .avatarUrl() ??
              '',
          size: 100,
        ).clickable(() {
          // _buildShowDialogAvatarUrl(
          //   context: context,
          //   avatarPath: controller.conversation.avatarUrl ?? '',
          // );
        }),
        AppSpacing.gapH4,
        // Text(
        //   controller.conversation.title(),
        //   style: AppTextStyles.s26w600,
        // ),
        Text(
          controller.conversations[controller.currentConversationIndex.value]
              .title(),
          style: AppTextStyles.s22w700.copyWith(color: AppColors.text2),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        AppSpacing.gapH8,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ngoại tuyến',
              style: AppTextStyles.s14w400.copyWith(color: AppColors.subText2),
            ),

            // Container(
            //   margin: const EdgeInsets.only(left: 8),
            //   height: 8,
            //   width: 8,
            //   decoration: const BoxDecoration(
            //     shape: BoxShape.circle,
            //     color: Color(0xff52C91D),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Widget buildContainerGroupItem(Widget child) => Container(
    padding: AppSpacing.edgeInsetsAll16,
    width: 300,
    decoration: BoxDecoration(
      color: AppColors.grey11,
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );

  Widget builditemSetting(
    IconData icon,
    Color color,
    String title,
    Function() onTap,
  ) => Row(
    children: [
      Icon(icon, color: color, size: 20),
      AppSpacing.gapW12,
      Text(title, style: AppTextStyles.s14w600.copyWith(color: color)),
      const Spacer(),
      // if (icon != AppIcons.trashMessage)
      //   AppIcon(
      //     icon: AppIcons.arrowRight,
      //     color: AppColors.text2,
      //   )
    ],
  ).clickable(() {
    onTap();
  });

  Widget _buildDivider() =>
      const Divider(height: Sizes.s24, color: Color(0xffdbdbdb));

  Widget _buildPrivacyAndSupport(
    BuildContext context,
    ChatSidebarController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cài đặt',
          style: AppTextStyles.s16w700.copyWith(color: AppColors.text2),
        ),
        AppSpacing.gapH8,
        buildContainerGroupItem(
          Column(
            children: [
              controller
                      .conversations[controller.currentConversationIndex.value]
                      .isGroup
                  ? builditemSetting(
                    Icons.person,
                    AppColors.text2,
                    'Thành viên',
                    () {
                      final controller = Get.find<ChatSidebarController>();
                      controller.isShowChatMember.value = true;
                    },
                  )
                  : builditemSetting(
                    Icons.group,
                    AppColors.text2,
                    'Tạo nhóm chat với ${controller.conversations[controller.currentConversationIndex.value].chatPartner()?.lastName}',
                    () {
                      controller.isCreateGroup.value = true;
                      controller.isSearch.value = true;
                      controller.searchFocusNode.requestFocus();
                      controller.isShowChatProfile.value = false;
                      controller.isShowChatResource.value = false;
                      controller.selectedUsersCreateGroup.value = [
                        controller
                            .conversations[controller
                                .currentConversationIndex
                                .value]
                            .chatPartner()!,
                      ];
                    },
                  ),
              _buildDivider(),
              builditemSetting(
                Icons.library_books,
                AppColors.text2,
                'Tài nguyên chat',
                () => _showDetail('chat_resources'),
              ),
              _buildDivider(),
              controller
                      .conversations[controller.currentConversationIndex.value]
                      .isGroup
                  ? builditemSetting(
                    Icons.output_outlined,
                    AppColors.text2,
                    'Rời nhóm',
                    () {
                      final userName =
                          controller
                              .conversations[controller
                                  .currentConversationIndex
                                  .value]
                              .title();

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
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            side: BorderSide(
                                              color: AppColors.greyBorder,
                                            ),
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
                                          controller.leaveGroupChat(
                                            controller.conversations[controller
                                                .currentConversationIndex
                                                .value],
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.negative,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
                    },
                  )
                  : builditemSetting(
                    Icons.block,
                    AppColors.text2,
                    'Chặn người dùng',
                    () {
                      final userName =
                          controller
                              .conversations[controller
                                  .currentConversationIndex
                                  .value]
                              .chatPartner()
                              ?.fullName ??
                          'người dùng này';

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
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            side: BorderSide(
                                              color: AppColors.greyBorder,
                                            ),
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
                                          controller.blockUser(
                                            controller.conversations[controller
                                                .currentConversationIndex
                                                .value],
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.negative,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
                    },
                  ),
              _buildDivider(),
              // builditemSetting(
              //     Icons.archive, AppColors.text2, 'Lưu trữ tin nhắn', () => {}),
              // _buildDivider(),
              builditemSetting(
                Icons.delete,
                AppColors.negative,
                'Xóa đoạn hội thoại',
                () {
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
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                          color: AppColors.greyBorder,
                                        ),
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
                                      controller.deleteConversation(
                                        controller.conversations[controller
                                            .currentConversationIndex
                                            .value],
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.negative,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
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
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
