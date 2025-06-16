import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xintel/core/extensions/widget_extensions.dart';

import ' chat_list_conversation/app_bar.dart';
import ' chat_list_conversation/chat_list_conversation_view.dart';
import '../../../resources/styles/app_colors.dart';
import '../../../resources/styles/gaps.dart';
import '../../../resources/styles/text_styles.dart';
import '../../widgets/circle_avatar.dart';
import '../../widgets/text_field.dart';
import 'chat_sidebar_controller.dart';
import 'search/search_view.dart';

class ChatSidebar extends StatefulWidget {
  const ChatSidebar({super.key});

  @override
  State<ChatSidebar> createState() => _ChatSidebarState();
}

class _ChatSidebarState extends State<ChatSidebar> {
  final controller = Get.find<ChatSidebarController>();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        HomeWidgetAppBar(size: size),

        Row(
          children: [
            Obx(() {
              return controller.isSearch.value
                  ? Icon(
                    Icons.arrow_back,
                    color: AppColors.subText2,
                  ).paddingOnly(left: 12).clickable(() {
                    controller.isSearch.value = false;
                    controller.searchController.clear();
                    controller.searchFocusNode.unfocus();
                    controller.isCreateGroup.value = false;
                    controller.selectedUsersCreateGroup.clear();
                    controller.groupNameController.clear();
                  })
                  : Container();
            }),
            Expanded(
              child: AppTextField(
                controller: controller.searchController,
                focusNode: controller.searchFocusNode,
                hintStyle: AppTextStyles.s16w400.copyWith(
                  color: AppColors.subText2,
                ),
                hintText: 'Tìm kiếm',
                onChanged: (value) {
                  controller.search(value);
                },
                onTap: () {
                  controller.isSearch.value = true;
                },
                prefixIcon: Icon(Icons.search, color: AppColors.subText2),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                fillColor: AppColors.grey6,
                borderRadius: 100,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(100),
                ),
              ).paddingSymmetric(horizontal: 12),
            ),
          ],
        ),
        Obx(() {
          return controller.isCreateGroup.value
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.gapH4,
                  AppTextField(
                    controller: controller.groupNameController,
                    hintStyle: AppTextStyles.s16w400.copyWith(
                      color: AppColors.subText2,
                    ),
                    hintText: 'Tên nhóm',

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    fillColor: Colors.transparent,
                    borderRadius: 100,
                    border: InputBorder.none,
                  ).paddingSymmetric(horizontal: 12),

                  Divider(
                    color: AppColors.greyBorder,
                    height: 0.5,
                    thickness: 0.5,
                  ),
                  AppSpacing.gapH8,
                  Obx(() {
                    return controller.selectedUsersCreateGroup.isNotEmpty
                        ? SizedBox(
                          height: 68,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount:
                                controller.selectedUsersCreateGroup.length,
                            itemBuilder: (context, index) {
                              final user =
                                  controller.selectedUsersCreateGroup[index];

                              return SizedBox(
                                width: 87,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 52,
                                      height: 52,
                                      child: Stack(
                                        children: [
                                          AppCircleAvatar(
                                            url: user.avatarPath ?? '',
                                            size: 48,
                                          ),
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                              width: 18,
                                              height: 18,
                                              decoration: BoxDecoration(
                                                color: AppColors.grey7,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.close,
                                                  color: AppColors.text2,
                                                  size: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      user.fullName,
                                      style: AppTextStyles.s14w500.copyWith(
                                        color: AppColors.text2,
                                        fontSize: 10,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ).clickable(() {
                                controller.selectedUsersCreateGroup.remove(
                                  user,
                                );
                              });
                            },
                          ),
                        )
                        : const SizedBox.shrink();
                  }),
                ],
              )
              : const SizedBox.shrink();
        }),

        AppSpacing.gapH8,
        Expanded(
          child: Obx(() {
            return controller.isSearch.value
                ? const SearchView()
                : ChatListWidget();
          }),
        ),
      ],
    );
  }
}
