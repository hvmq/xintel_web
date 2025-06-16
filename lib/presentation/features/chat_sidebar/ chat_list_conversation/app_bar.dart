import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xintel/core/extensions/widget_extensions.dart';

import '../../../../resources/styles/app_colors.dart';
import '../../../../resources/styles/gaps.dart';
import '../../../../resources/styles/text_styles.dart';
import '../../../widgets/custom_popup.dart';
import '../../auth/auth_controller.dart';
import '../chat_sidebar_controller.dart';

class HomeWidgetAppBar extends StatelessWidget {
  const HomeWidgetAppBar({super.key, required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final controller = Get.find<ChatSidebarController>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          CustomPopup(
            contentPadding: EdgeInsets.zero,
            barrierColor: Colors.transparent,
            contentRadius: 12,

            showArrow: false,
            customOffset: const Offset(0, 0),
            content: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 0.5, color: const Color(0xff567596)),
                borderRadius: BorderRadius.circular(12),
              ),
              width: 150,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      AppSpacing.gapW8,
                      Icon(Icons.logout, color: AppColors.negative2, size: 20),
                      AppSpacing.gapW8,
                      Text(
                        'Đăng xuất',
                        style: AppTextStyles.s14Base.copyWith(
                          color: AppColors.negative2,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ).paddingOnly(right: 12, top: 6, bottom: 5).clickable(() {
                    authController.signOut();
                  }),
                ],
              ),
            ),
            child: Obx(
              () => CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  authController.currentUser.value?.avatarPath ?? '',
                ),
                radius: 18,
              ),
            ),
          ),

          const SizedBox(width: 15),
          Obx(
            () => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authController.currentUser.value?.fullName ?? '',
                  style: AppTextStyles.s16w700,
                ),
                Text(
                  authController.currentUser.value?.email ?? '',
                  style: AppTextStyles.s12w500,
                ),
              ],
            ),
          ),
          const Spacer(),
          Obx(() {
            return controller.isCreateGroup.value
                ? Text(
                  'Tạo',
                  style: AppTextStyles.s14w700.copyWith(
                    color: AppColors.primary,
                  ),
                ).clickable(() {
                  controller.createGroup();
                })
                : CustomPopup(
                  contentPadding: EdgeInsets.zero,
                  barrierColor: Colors.transparent,
                  contentRadius: 12,
                  showArrow: false,
                  customOffset: const Offset(-100, 0),
                  content: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.5,
                        color: const Color(0xff567596),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    width: 130,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Private Chat Option
                        Row(
                          children: [
                            AppSpacing.gapW8,
                            Icon(
                              Icons.person_add,
                              color: AppColors.text2,
                              size: 18,
                            ),
                            AppSpacing.gapW8,
                            Text(
                              'Private Chat',
                              style: AppTextStyles.s12w600.copyWith(
                                color: AppColors.text2,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ).paddingOnly(right: 12, top: 6, bottom: 6).clickable(
                          () {
                            Get.back(); // Clos
                            controller.searchController.clear();
                            controller.isSearch.value = true;
                            controller.searchFocusNode.requestFocus();
                          },
                        ),

                        // Divider
                        Container(
                          height: 0.5,
                          color: const Color(0xff567596),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),

                        // Group Chat Option
                        Row(
                          children: [
                            AppSpacing.gapW8,
                            Icon(
                              Icons.group_add,
                              color: AppColors.text2,
                              size: 18,
                            ),
                            AppSpacing.gapW8,
                            Text(
                              'Group Chat',
                              style: AppTextStyles.s12w600.copyWith(
                                color: AppColors.text2,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ).paddingOnly(right: 12, top: 6, bottom: 6).clickable(
                          () {
                            Get.back(); // Close popup
                            controller.searchController.clear();
                            controller.isSearch.value = true;
                            controller.searchFocusNode.requestFocus();
                            controller.isCreateGroup.value = true;
                            controller.selectedUsersCreateGroup.clear();
                            controller.groupNameController.clear();
                          },
                        ),
                      ],
                    ),
                  ),
                  child: Icon(Icons.create, color: AppColors.text2),
                );
          }),
        ],
      ),
    );
  }
}
