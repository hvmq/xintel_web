import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xintel/presentation/widgets/network_image.dart';

import '../../../../../core/configs/env_config.dart';
import '../../../../../models/message.dart';
import '../../../../../resources/styles/app_colors.dart';
import '../../../../../resources/styles/gaps.dart';
import '../../../../widgets/video_player.dart';
import '../../chat_sidebar_controller.dart';

const _kDefaultMediaWidthPercentage = 0.6;

class MediaMessageBody extends StatefulWidget {
  final Message message;
  final bool isMine;
  final bool isReaction;

  const MediaMessageBody({
    required this.isMine,
    required this.message,
    this.isReaction = false,
    super.key,
  });

  @override
  State<MediaMessageBody> createState() => _MediaMessageBodyState();
}

class _MediaMessageBodyState extends State<MediaMessageBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.message.type != MessageType.text;

  late Message _message;

  @override
  void initState() {
    _message = widget.message;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget child;

    switch (_message.type) {
      case MessageType.image:
        child = _buildImageMessage();
      // child = AppSpacing.emptyBox;
      case MessageType.video:
        child = _buildVideoMessage();
      // child = AppSpacing.emptyBox;
      case MessageType.audio:
        child = AppSpacing.emptyBox;
      // child = widget.isReaction
      //     ? Material(
      //         color: Colors.transparent,
      //         child: _buildAudioMessage(),
      //       )
      //     : _buildAudioMessage();
      default:
        child = AppSpacing.emptyBox;
    }

    return child;
  }

  Widget _buildImageMessage() {
    List<String> images = [];
    final minioUrl = Get.find<EnvConfig>().minIoUrl;
    images =
        _message.isLocal
            ? _message.content
                .split(Get.find<ChatSidebarController>().pathLocal)
                .where((element) => element.isNotEmpty)
                .map(
                  (element) =>
                      '${Get.find<ChatSidebarController>().pathLocal}${element.trim()}',
                )
                .toList()
            : _message.content
                .split('https://$minioUrl')
                .where((element) => element.isNotEmpty)
                .map((element) => 'https://$minioUrl${element.trim()}')
                .toList();

    Widget decorateImage(ImageProvider imageProvider) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child:
            widget.isReaction
                ? Image(
                  height: 100,
                  image: ResizeImage(
                    imageProvider,
                    height: 100.toInt().cacheSize(context),
                  ),
                  fit: BoxFit.cover,
                )
                : Image(
                  // width: _kDefaultMediaWidthPercentage.sw,
                  fit: BoxFit.cover,
                  image: ResizeImage(
                    imageProvider,
                    width: 100.toInt().cacheSize(context),
                  ),
                ),
      );
    }

    if (_message.isLocal) {
      return images.length == 1
          ? Opacity(
            opacity: 0.5,
            child: decorateImage(FileImage(File(_message.content))),
          )
          : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 3,
              mainAxisSpacing: 8,
            ),
            shrinkWrap: true,
            itemCount: images.length == 2 ? 3 : images.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder:
                (context, index) =>
                    images.length == 2
                        ? index == 0
                            ? const SizedBox()
                            : Opacity(
                              opacity: 0.5,
                              child: decorateImage(
                                FileImage(File(images[index - 1])),
                              ),
                            )
                        : Opacity(
                          opacity: 0.5,
                          child: decorateImage(FileImage(File(images[index]))),
                        ),
          );
    }

    return images.length == 1
        ? AppNetworkImage(
          _message.content,
          width: 200,
          imageBuilder:
              (context, imageProvider) => decorateImage(imageProvider),
          placeholder: _buildImagePlaceholder(),
          clickToSeeFullImage: true,
        )
        : GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 3,
            mainAxisSpacing: 8,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              widget.isMine
                  ? (images.length == 2 ? 3 : images.length)
                  : images.length,
          itemBuilder: (context, index) {
            if (widget.isMine && images.length == 2 && index == 0) {
              return const SizedBox();
            }

            final imageIndex =
                widget.isMine && images.length == 2 ? index - 1 : index;

            return AppNetworkImage(
              images[imageIndex],
              fit: BoxFit.cover,
              imageBuilder:
                  (context, imageProvider) => decorateImage(imageProvider),
              placeholder: _buildImagePlaceholder(),
              clickToSeeFullImage: true,
              multiImage: true,
              images: images,
              initIndex: imageIndex,
            );
          },
        );
  }

  Widget _buildVideoMessage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AppVideoPlayer(
        _message.content,
        key: ValueKey(_message.content),
        width: 200,
        height: 200,
        fit: BoxFit.cover,
        isFile: _message.isLocal,
        isThumbnailMode: true,
        isClickToShowFullScreen: true,
        isView: true,
      ),
    );
  }

  // Widget _buildAudioMessage() {
  //   return VoiceMessageView(
  //     backgroundColor: widget.isMine ? AppColors.blue8 : AppColors.grey7,
  //     activeSliderColor: widget.isMine ? AppColors.primary : AppColors.text2,
  //     circlesColor: widget.isMine ? AppColors.primary : AppColors.grey8,
  //     counterTextStyle: AppTextStyles.s12w400
  //         .copyWith(color: widget.isMine ? AppColors.primary : AppColors.text2),
  //     controller: VoiceController(
  //       width: 0.34.sw,
  //       audioSrc: _message.content,
  //       isFile: _message.isLocal,
  //       maxDuration: const Duration(seconds: 10),
  //       onComplete: () {},
  //       onPause: () {},
  //       onPlaying: () {},
  //       onError: (err) {},
  //     ),
  //   );
  // }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      width: 100,
      height: 100,
      // child: const AppDefaultLoading(),
    );
  }
}
