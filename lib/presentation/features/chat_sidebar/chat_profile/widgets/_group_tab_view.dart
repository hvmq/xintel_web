part of '../chat_resource_view.dart';

class _GroupTabView extends StatelessWidget {
  const _GroupTabView({required this.controller});

  final ChatSidebarController controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: AppSpacing.edgeInsetsH20,
      itemCount: controller.groups.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Row(
              children: [
                const AppCircleAvatar(url: '', size: Sizes.s48),
                AppSpacing.gapW16,
                Text(
                  'Group Name',
                  style: AppTextStyles.s16w700.copyWith(color: AppColors.text2),
                ),
              ],
            ),
            if (index < controller.groups.length - 1)
              Divider(
                color: AppColors.greyBorder,
                height: 1,
              ).paddingOnly(top: Sizes.s12, bottom: Sizes.s12),
          ],
        );
      },
    );
  }
}
