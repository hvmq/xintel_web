part of '../chat_resource_view.dart';

class _ImageTabView extends StatelessWidget {
  const _ImageTabView({required this.controller});

  final ChatSidebarController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.images.isEmpty) {
        return Center(child: Text('No images', style: AppTextStyles.s16w500));
      }

      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: controller.images.length,
        itemBuilder: (context, index) {
          final imageUrl = controller.images[index];

          return AppNetworkImage(
            imageUrl,
            fit: BoxFit.cover,
            clickToSeeFullImage: true,
            imageBuilder:
                (context, imageProvider) => Image(
                  image: ResizeImage(
                    imageProvider,
                    height: 100.toInt().cacheSize(context),
                  ),
                  fit: BoxFit.cover,
                ),
            errorWidget: Container(
              color: AppColors.greyBorder,
              child: const Icon(Icons.error_outline),
            ),
            placeholder: Container(
              color: AppColors.greyBorder,
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        },
      );
    });
  }

  void _onImageTap(BuildContext context, int index, List<String> images) {
    // TODO: Implement image preview
  }
}

// class _ImagesCarouselDialog extends StatelessWidget {
//   const _ImagesCarouselDialog({
//     required this.images,
//     required this.initialIndex,
//   });

//   final List<String> images;
//   final int initialIndex;

//   @override
//   Widget build(BuildContext context) {
//     return DisabledDialogWrapper(
//       dismissibleKey: Key(images[initialIndex]),
//       child: CarouselSlider.builder(
//         itemCount: images.length,
//         disableGesture: true,
//         options: CarouselOptions(
//           height: 1.sh,
//           initialPage: initialIndex,
//           enableInfiniteScroll: false,
//           viewportFraction: 1.0,
//           onPageChanged: (index, _) {},
//         ),
//         itemBuilder: (context, index, _) {
//           final imageUrl = images[index];

//           return AppNetworkImage(
//             imageUrl,
//             fit: BoxFit.contain,
//             imageBuilder: (context, imageProvider) {
//               return Image(
//                 image: ResizeImage(
//                   imageProvider,
//                   width: 1.sw.toInt().cacheSize(context),
//                 ),
//                 fit: BoxFit.contain,
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
