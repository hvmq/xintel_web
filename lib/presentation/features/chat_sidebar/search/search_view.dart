import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:xintel/core/extensions/widget_extensions.dart';
import 'package:xintel/presentation/widgets/circle_avatar.dart';

import '../../../../models/user.dart';
import '../../../../resources/styles/app_colors.dart';
import '../../../../resources/styles/gaps.dart';
import '../../../../resources/styles/text_styles.dart';
import '../../../widgets/app_check_box.dart';
import '../chat_sidebar_controller.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final controller = Get.find<ChatSidebarController>();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 7, vsync: this);
    tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (tabController.indexIsChanging) {
      controller.handleTabChange(tabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [_buildSearchOptions(), _buildSearchResult()]);
  }

  Widget _buildSearchResult() {
    return Obx(() {
      if (controller.isLoadingSearch.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ).paddingOnly(top: 0.2.sh);
      }
      if (controller.searchConversations.isEmpty &&
          controller.searchUsers.isEmpty) {
        return _buildEmptyResult();
      }

      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildConversationsList(), _buildUsersList()],
        ),
      );
    });
  }

  Widget _buildEmptyResult() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 0.2.sh),
        Icon(Icons.search, size: 48, color: AppColors.grey8),
        Text(
          'No results found',
          style: AppTextStyles.s18w500.copyWith(color: AppColors.grey8),
        ),
      ],
    );
  }

  Widget _buildConversationsList() {
    return Obx(() {
      if (controller.searchConversations.isEmpty ||
          controller.isCreateGroup.value) {
        return const SizedBox.shrink();
      }

      return SizedBox(
        height: 64,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.searchConversations.length,
          itemBuilder: (context, index) {
            final conversation = controller.searchConversations[index];

            return SizedBox(
              width: 87,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppCircleAvatar(
                    url: conversation.avatarUrl() ?? '',
                    size: 48,
                  ),
                  Text(
                    conversation.title(),
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
              controller.selectConversation(conversation);
            });
          },
        ),
      ).paddingOnly(top: 12, bottom: 12);
    });
  }

  Widget _buildUsersList() {
    return Obx(() {
      if (controller.searchUsers.isEmpty) {
        return const SizedBox.shrink();
      }

      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.gapH16,
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: controller.searchUsers.length,
                separatorBuilder: (context, index) => AppSpacing.gapH16,
                itemBuilder: (context, index) {
                  final user = controller.searchUsers[index];

                  return Row(
                    children: [
                      AppSpacing.gapW12,
                      Obx(() {
                        return controller.isCreateGroup.value
                            ? AppCheckBox(
                              value: controller.selectedUsersCreateGroup
                                  .contains(user),
                              onChanged: (value) {
                                controller.selectedUsersCreateGroup.add(user);
                              },
                            ).paddingOnly(right: 8)
                            : const SizedBox.shrink();
                      }),

                      Expanded(
                        child: UserItem(
                          key: ValueKey(user.id),
                          user: user,
                          onTap: () => _onUserTapped(user),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            AppSpacing.gapH20,
          ],
        ),
      );
    });
  }

  void _onUserTapped(User user) {
    if (controller.isCreateGroup.value) {
      if (controller.selectedUsersCreateGroup.contains(user)) {
        controller.selectedUsersCreateGroup.remove(user);
      } else {
        controller.selectedUsersCreateGroup.add(user);
      }
    } else {
      controller.selectUser(user);
    }
  }

  Widget _buildSearchOptions() {
    return TabBar(
      isScrollable: true,
      indicatorWeight: 1,
      padding: EdgeInsets.zero,
      tabAlignment: TabAlignment.start,
      labelStyle: AppTextStyles.s12w600.copyWith(color: AppColors.primary),
      dividerColor: AppColors.grey7,
      dividerHeight: 1,
      controller: tabController,
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
      unselectedLabelColor: AppColors.grey5,
      tabs: const [
        Tab(text: 'Global'),
        Tab(text: 'NFT'),
        Tab(text: 'Phone number'),
        Tab(text: 'Email'),
        Tab(text: 'Username'),
        Tab(text: 'Last name'),
        Tab(text: 'First name'),
      ],
    );
  }
}

// Placeholder UserItem widget
class UserItem extends StatelessWidget {
  final User user;
  final VoidCallback onTap;

  const UserItem({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppCircleAvatar(url: user.avatarPath ?? '', size: 48),
        AppSpacing.gapW8,
        Text(user.fullName, style: AppTextStyles.s14w500),
      ],
    ).clickable(onTap);
  }
}
