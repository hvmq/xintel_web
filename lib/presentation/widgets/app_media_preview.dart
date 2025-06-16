import 'package:flutter/material.dart';
import 'package:xintel/core/extensions/widget_extensions.dart';

import '../../core/helpers/media_helper.dart';
import '../../resources/styles/app_colors.dart';
import '../../resources/styles/gaps.dart';
import '../../resources/styles/text_styles.dart';
import 'video_player.dart';

const double _kDefaultPreviewSize = 60;

class AppMediaPreview extends StatelessWidget {
  final PickedMedia media;
  final void Function() onRemove;
  final double width;
  final double height;

  const AppMediaPreview({
    required this.media,
    required this.onRemove,
    this.width = _kDefaultPreviewSize,
    this.height = _kDefaultPreviewSize,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (media.type == MediaAttachmentType.audio) {
      return AppSpacing.emptyBox;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.only(top: 4, right: 4),
          child: Container(
            color: AppColors.blue8,
            padding: EdgeInsets.zero,

            child: _buildPreview(context),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(100),
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(Icons.close, color: AppColors.text1),
        ).clickable(() {
          onRemove();
        }),
      ],
    );
  }

  Widget _buildPreview(BuildContext context) {
    switch (media.type) {
      case MediaAttachmentType.image:
        return _buildImagePreview();
      case MediaAttachmentType.video:
        return _buildVideoPreview();
      case MediaAttachmentType.document:
        return _buildDocumentPreview();
      case MediaAttachmentType.audio:
        return AppSpacing.emptyBox;
    }
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image(
        width: width,
        height: height,
        image: FileImage(media.file),
        fit: BoxFit.cover,
      ).clickable(() {}),
    );
  }

  Widget _buildVideoPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: AppVideoPlayer(
        media.file.path,
        width: width,
        height: height,
        fit: BoxFit.fitWidth,
        isFile: true,
        isThumbnailMode: true,
        playButtonSize: Sizes.s16,
        isClickToShowFullScreen: true,
        isView: true,
      ),
    );
  }

  Widget _buildDocumentPreview() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file, color: AppColors.primary),
          AppSpacing.gapW4,
          Flexible(
            child: Text(
              media.file.path.split('/').last,
              style: AppTextStyles.s14w400.copyWith(color: AppColors.primary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
