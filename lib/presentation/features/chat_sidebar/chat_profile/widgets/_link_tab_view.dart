part of '../chat_resource_view.dart';

class _LinkTabView extends StatelessWidget {
  const _LinkTabView({required this.controller});

  final ChatSidebarController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.links.isEmpty) {
        return Center(child: Text('No links', style: AppTextStyles.s16w500));
      }

      return ListView.builder(
        padding: AppSpacing.edgeInsetsH20,
        itemCount: controller.links.length,
        itemBuilder: (context, index) {
          final link = controller.links[index];

          return FutureBuilder(
            future: AnyLinkPreview.getMetadata(link: link),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || snapshot.data == null) {
                return Column(
                  children: [
                    Text(
                      link,
                      style: AppTextStyles.s14w400.copyWith(
                        color: AppColors.text2,
                      ),
                    ),
                    Divider(
                      color: AppColors.greyBorder,
                      height: 1,
                    ).paddingOnly(top: Sizes.s16, bottom: Sizes.s16),
                  ],
                );
              }

              final metadata = snapshot.data!;
              final hasError =
                  metadata.siteName == null &&
                  metadata.title == null &&
                  metadata.desc == null;

              return Column(
                children: [
                  AnyLinkPreview(
                    link: link,
                    displayDirection: UIDirection.uiDirectionHorizontal,
                    cache: const Duration(days: 5),
                    previewHeight: 100,
                    errorWidget: Text(
                      link,
                      style: AppTextStyles.s14w400.copyWith(
                        color: AppColors.text2,
                      ),
                    ),
                    placeholderWidget: const Center(
                      child: CircularProgressIndicator(),
                    ),
                    boxShadow: [],
                    borderRadius: 0,
                    removeElevation: true,
                    backgroundColor: Colors.white,
                    titleStyle: AppTextStyles.s16w600.copyWith(
                      color: AppColors.text2,
                    ),
                    bodyStyle: AppTextStyles.s12w400.copyWith(
                      color: AppColors.subText2,
                    ),
                  ),
                  if (!hasError)
                    Divider(
                      color: AppColors.greyBorder,
                      height: 1,
                    ).paddingOnly(top: Sizes.s16, bottom: Sizes.s16),
                ],
              );
            },
          );
        },
      );
    });
  }
}
