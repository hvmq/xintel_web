import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/extensions/widget_extensions.dart';
import '../../resources/styles/app_colors.dart';
import '../../resources/styles/gaps.dart';

const int _kDefaultImageCacheWidth = 200;
const int _kDefaultImageCacheHeight = 250;

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage(
    this.url, {
    super.key,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.imageBuilder,
    this.width,
    this.height,
    this.fadeOutDuration,
    this.fadeOutCurve = Curves.easeOut,
    this.useOldImageOnUrlChange = false,
    this.loadingBackgroundColor,
    this.radius,
    this.clickToSeeFullImage = false,
    this.colorLoading,
    this.sizeLoading,
    this.onFullImageLongPress,
    this.images,
    this.multiImage = false,
    this.initIndex,
  });

  final String? url;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Widget Function(BuildContext context, ImageProvider imageProvider)?
  imageBuilder;
  final double? width;
  final double? height;
  final Duration? fadeOutDuration;
  final Curve fadeOutCurve;
  final bool useOldImageOnUrlChange;
  final Color? loadingBackgroundColor;
  final double? radius;
  final bool clickToSeeFullImage;
  final Color? colorLoading;
  final double? sizeLoading;
  final VoidCallback? onFullImageLongPress;
  final List<String>? images;
  final bool multiImage;
  final int? initIndex;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _buildErrorWidget();
    }

    // Pre-calculate cache sizes để tránh tính toán lại trong build
    final cacheWidth =
        width != null ? width!.cacheSize(context) : _kDefaultImageCacheWidth;
    final cacheHeight =
        height != null ? height!.cacheSize(context) : _kDefaultImageCacheHeight;

    Widget image = RepaintBoundary(
      child: CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => placeholder ?? _buildDefaultLoadingWidget(),
        errorWidget: (_, __, dynamic error) => _buildErrorWidget(),
        imageBuilder: imageBuilder,
        fadeOutDuration: fadeOutDuration,
        fadeInDuration: Duration.zero,
        fadeOutCurve: fadeOutCurve,
        useOldImageOnUrlChange: useOldImageOnUrlChange,
        memCacheWidth: cacheWidth,
        memCacheHeight: cacheHeight,
        // Tối ưu cache settings cho ListView
        maxWidthDiskCache: cacheWidth,
        maxHeightDiskCache: cacheHeight,
      ),
    );

    if (radius != null) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(radius!),
        child: image,
      );
    }

    if (clickToSeeFullImage && url != null) {
      image = image.clickable(() => _showFullImageDialog(context));
    }

    return image;
  }

  void _showFullImageDialog(BuildContext context) {
    if (multiImage && images != null && images!.isNotEmpty) {
      // Show carousel for multiple images
      _showSingleImageDialog(context, images![initIndex ?? 0]);
    } else {
      // Show single image
      _showSingleImageDialog(context, url!);
    }
  }

  void _showSingleImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder:
          (context) => _FullImageDialog(
            imageUrl: imageUrl,
            onLongPress: onFullImageLongPress,
          ),
    );
  }

  void _showImageCarousel(
    BuildContext context,
    List<String> imageUrls,
    int initialIndex,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder:
          (context) => _ImageCarouselDialog(
            images: imageUrls,
            initialIndex: initialIndex,
            onLongPress: onFullImageLongPress,
          ),
    );
  }

  Widget _buildErrorWidget() {
    return errorWidget ?? AppSpacing.emptyBox;
  }

  Widget _buildDefaultLoadingWidget() {
    return Container(
      decoration: BoxDecoration(
        color: loadingBackgroundColor ?? AppColors.grey7,
        borderRadius: BorderRadius.circular(radius ?? 0),
      ),
      width: width,
      height: height,
      // child: AppDefaultLoading(
      //   color: widget.colorLoading,
      // ),
    );
  }
}

class AppCachedNetworkImageProvider extends CachedNetworkImageProvider {
  const AppCachedNetworkImageProvider(super.url);
}

extension ImageExtension on num {
  int cacheSize(BuildContext context) {
    return (this * MediaQuery.of(context).devicePixelRatio).round();
  }
}

class _FullImageDialog extends StatelessWidget {
  const _FullImageDialog({required this.imageUrl, this.onLongPress});

  final String imageUrl;
  final VoidCallback? onLongPress;

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
          // Image
          Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: GestureDetector(
                onLongPress: onLongPress,
                onTap: () {}, // Prevent tap from bubbling to background
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    placeholder:
                        (_, __) => const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                    errorWidget:
                        (_, __, ___) => const Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 64,
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ),
          // Close button with higher z-index
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

class _ImageCarouselDialog extends StatefulWidget {
  const _ImageCarouselDialog({
    required this.images,
    required this.initialIndex,
    this.onLongPress,
  });

  final List<String> images;
  final int initialIndex;
  final VoidCallback? onLongPress;

  @override
  State<_ImageCarouselDialog> createState() => _ImageCarouselDialogState();
}

class _ImageCarouselDialogState extends State<_ImageCarouselDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
          // Image carousel
          Center(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return Container(
                  constraints: BoxConstraints(maxWidth: 400, maxHeight: 400),
                  child: GestureDetector(
                    onLongPress: widget.onLongPress,
                    onTap: () {}, // Prevent tap from bubbling to background
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: CachedNetworkImage(
                        imageUrl: widget.images[index],
                        fit: BoxFit.contain,
                        width: 400,
                        height: 400,
                        placeholder:
                            (_, __) => const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                        errorWidget:
                            (_, __, ___) => const Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Colors.white,
                                size: 64,
                              ),
                            ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Close button with higher z-index
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
          // Image counter
          if (widget.images.length > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${widget.images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
