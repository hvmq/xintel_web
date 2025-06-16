part of '../chat_resource_view.dart';

class _VideoTabView extends StatelessWidget {
  const _VideoTabView({required this.controller});

  final ChatSidebarController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.videos.isEmpty) {
        return Center(child: Text('No videos', style: AppTextStyles.s16w500));
      }

      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: controller.videos.length,
        itemBuilder: (context, index) {
          final videoUrl = controller.videos[index];

          return Container(
            color: AppColors.greyBorder,
            child: const Center(
              child: Icon(Icons.play_circle_outline, size: 32),
            ),
          ).clickable(() => _onVideoTap(context, index, controller.videos));
        },
      );
    });
  }

  void _onVideoTap(BuildContext context, int index, List<String> videos) {
    // TODO: Implement video preview
  }
}

// class _VideosCarouselDialog extends StatelessWidget {
//   const _VideosCarouselDialog({
//     required this.videos,
//     required this.initialIndex,
//   });

//   final List<String> videos;
//   final int initialIndex;

//   @override
//   Widget build(BuildContext context) {
//     return DisabledDialogWrapper(
//       child: CarouselSlider.builder(
//         itemCount: videos.length,
//         disableGesture: true,
//         options: CarouselOptions(
//           height: 1.sh,
//           initialPage: initialIndex,
//           enableInfiniteScroll: false,
//           viewportFraction: 1,
//         ),
//         itemBuilder: (context, index, _) {
//           final videoUrl = videos[index];

//           return AppVideoPlayer(
//             videoUrl,
//             fit: BoxFit.fitWidth,
//           );
//         },
//       ),
//     );
//   }
// }
