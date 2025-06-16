import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:xintel/core/extensions/widget_extensions.dart';

import '../../resources/styles/gaps.dart';

class AppVideoPlayer extends StatefulWidget {
  const AppVideoPlayer(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
    this.isFile = false,
    this.autoPlay = false,
    this.loadingColor,
    this.onTap,
    this.onPlayingStateCallback,
    this.fit,
    this.isThumbnailMode = false,
    this.isClickToShowFullScreen = false,
    this.onFullScreenLongPress,
    this.playButtonSize = Sizes.s32,
    this.isView = false,
  });

  final String url;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final bool isFile;
  final bool autoPlay;
  final Color? loadingColor;
  final VoidCallback? onTap;
  final void Function(bool isPlaying)? onPlayingStateCallback;
  final BoxFit? fit;
  final bool isThumbnailMode;
  final bool isClickToShowFullScreen;
  final VoidCallback? onFullScreenLongPress;
  final double playButtonSize;
  final bool isView;

  @override
  State<AppVideoPlayer> createState() => AppVideoPlayerState();
}

class AppVideoPlayerState extends State<AppVideoPlayer>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _videoPlayerController;

  final ValueNotifier<bool> _isPlayingNotifier = ValueNotifier(false);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    _videoPlayerController =
        widget.isFile
            ? VideoPlayerController.file(File(widget.url))
            : VideoPlayerController.networkUrl(Uri.parse(widget.url));

    await _videoPlayerController!.initialize();

    await _videoPlayerController!.pause();

    _videoPlayerController!.addListener(() {
      if (_videoPlayerController!.value.isPlaying != _isPlayingNotifier.value) {
        _isPlayingNotifier.value = _videoPlayerController!.value.isPlaying;
        widget.onPlayingStateCallback?.call(
          _videoPlayerController!.value.isPlaying,
        );
      }
    });

    if (widget.autoPlay) {
      play();
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    pause();

    _videoPlayerController?.dispose();
    _isPlayingNotifier.dispose();
    super.dispose();
  }

  void play() {
    _videoPlayerController?.play();
  }

  void pause() {
    _videoPlayerController?.pause();
  }

  void _onTap() {
    if (widget.isThumbnailMode) {
      if (!widget.isClickToShowFullScreen) {
        return;
      }

      return _showVideoDialog(
        context,
        widget.url,
        isFile: widget.isFile,
        onLongPress: widget.onFullScreenLongPress,
      );
    } else if (_videoPlayerController!.value.isPlaying) {
      pause();
    }

    widget.onTap?.call();
  }

  void _onPlayButtonPressed() {
    if (_videoPlayerController!.value.isInitialized &&
        _videoPlayerController!.value.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void _showVideoDialog(
    BuildContext context,
    String videoUrl, {
    bool isFile = false,
    VoidCallback? onLongPress,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder:
          (context) => _FullVideoDialog(
            videoUrl: videoUrl,
            isFile: isFile,
            onLongPress: onLongPress,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final child =
        _videoPlayerController!.value.isInitialized
            ? _buildBody()
            : _buildLoading();

    // Wrap the entire widget with clickable for tap functionality
    Widget videoWidget = GestureDetector(
      onTap: () {
        if (widget.isView) {
          _onTap();
        } else {
          _onPlayButtonPressed();
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          child,
          if (_videoPlayerController!.value.isInitialized) _buildPlayButton(),
        ],
      ),
    );

    // Make the entire widget clickable if needed
    // if (widget.isThumbnailMode && widget.isClickToShowFullScreen) {
    //   videoWidget = videoWidget.clickable(_onTap);
    // }

    // if (widget.isView) {
    //   return videoWidget;
    // }

    return videoWidget;
  }

  SizedBox _buildLoading() {
    return SizedBox(width: widget.width, height: widget.height);
  }

  Widget _buildBody() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: widget.borderRadius,
      ),
      child: FittedBox(
        fit: widget.fit ?? BoxFit.cover,
        child: SizedBox(
          width: _videoPlayerController!.value.size.width,
          height: _videoPlayerController!.value.size.height,
          child: VideoPlayer(_videoPlayerController!),
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isPlayingNotifier,
      builder: (_, isPlaying, __) {
        final child = AnimatedOpacity(
          opacity: isPlaying ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          child: Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: widget.playButtonSize,
          ),
        );

        if (widget.isThumbnailMode) {
          return child;
        }

        return child.clickable(_onPlayButtonPressed);
      },
    );
  }
}

class _FullVideoDialog extends StatefulWidget {
  const _FullVideoDialog({
    required this.videoUrl,
    this.isFile = false,
    this.onLongPress,
  });

  final String videoUrl;
  final bool isFile;
  final VoidCallback? onLongPress;

  @override
  State<_FullVideoDialog> createState() => _FullVideoDialogState();
}

class _FullVideoDialogState extends State<_FullVideoDialog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.01),
      body: Stack(
        children: [
          // Tap to close background
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
          // Video Player
          Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: GestureDetector(
                onLongPress: widget.onLongPress,
                onTap: () {}, // Prevent tap from bubbling to background
                child: AppVideoPlayer(
                  widget.videoUrl,
                  isFile: widget.isFile,
                  autoPlay: true,
                  fit: BoxFit.contain,
                  height: MediaQuery.of(context).size.height * 0.7,
                ),
              ),
            ),
          ),
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Material(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
