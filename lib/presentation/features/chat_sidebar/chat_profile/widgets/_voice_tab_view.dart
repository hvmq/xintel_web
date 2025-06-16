part of '../chat_resource_view.dart';

class _VoiceTabView extends StatelessWidget {
  const _VoiceTabView({required this.controller});

  final ChatSidebarController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.audios.isEmpty) {
        return Center(child: Text('No voice', style: AppTextStyles.s16w500));
      }

      return ListView.separated(
        padding: AppSpacing.edgeInsetsH20,
        itemCount: controller.audios.length,
        separatorBuilder:
            (context, index) => Divider(
              color: AppColors.greyBorder,
              height: 1,
            ).paddingOnly(top: Sizes.s12, bottom: Sizes.s12),
        itemBuilder: (context, index) {
          final audioUrl = controller.audios[index];

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(Icons.mic, color: AppColors.primary),
                AppSpacing.gapW12,
                Expanded(
                  child: Text(
                    'Voice message ${index + 1}',
                    style: AppTextStyles.s14w400.copyWith(
                      color: AppColors.text2,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {
                    // TODO: Implement audio playback
                  },
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
