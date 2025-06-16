import 'package:flutter/material.dart';

import '../../resources/styles/app_colors.dart';
import 'network_image.dart';

class AppCircleAvatar extends StatelessWidget {
  final String url;
  final double? size;
  final Color? backgroundColor;

  const AppCircleAvatar({
    required this.url,
    this.size,
    this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final finalSize = size ?? 50;
    final radius = finalSize / 2;
    final cacheSize = finalSize.toInt();

    // Wrap với RepaintBoundary để tránh repaint không cần thiết
    return RepaintBoundary(
      child: _OptimizedCircleAvatar(
        url: url,
        finalSize: finalSize,
        radius: radius,
        cacheSize: cacheSize,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

// Widget riêng biệt để tối ưu performance
class _OptimizedCircleAvatar extends StatelessWidget {
  final String url;
  final double finalSize;
  final double radius;
  final int cacheSize;
  final Color? backgroundColor;

  const _OptimizedCircleAvatar({
    required this.url,
    required this.finalSize,
    required this.radius,
    required this.cacheSize,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Nếu URL rỗng, return fallback ngay lập tức
    if (url.isEmpty) {
      return _buildFallbackWidget();
    }

    return AppNetworkImage(
      url,
      radius: radius,
      width: finalSize,
      height: finalSize,
      // Tối ưu imageBuilder với cache size đã tính sẵn
      imageBuilder:
          (context, imageProvider) => _CircleAvatarImage(
            imageProvider: imageProvider,
            radius: radius,
            cacheSize: cacheSize,
            backgroundColor: backgroundColor,
          ),
      errorWidget: _buildFallbackWidget(),
      // Thêm placeholder nhẹ hơn
      placeholder: _buildLoadingWidget(),
    );
  }

  Widget _buildFallbackWidget() {
    return _FallbackAvatar(
      radius: radius,
      finalSize: finalSize,
      backgroundColor: backgroundColor,
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: finalSize,
      height: finalSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? AppColors.grey7,
      ),
    );
  }
}

// Widget tối ưu cho CircleAvatar với image
class _CircleAvatarImage extends StatelessWidget {
  final ImageProvider imageProvider;
  final double radius;
  final int cacheSize;
  final Color? backgroundColor;

  const _CircleAvatarImage({
    required this.imageProvider,
    required this.radius,
    required this.cacheSize,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppColors.grey7,
      backgroundImage: ResizeImage(
        imageProvider,
        width: cacheSize,
        height: cacheSize, // Thêm height để tối ưu hơn
      ),
    );
  }
}

// Widget tối ưu cho fallback avatar
class _FallbackAvatar extends StatelessWidget {
  final double radius;
  final double finalSize;
  final Color? backgroundColor;

  const _FallbackAvatar({
    required this.radius,
    required this.finalSize,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: finalSize,
      height: finalSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? AppColors.grey6,
      ),
      child: Icon(
        Icons.person,
        color: AppColors.text2,
        size: radius, // Sử dụng Icon thay vì AppIcon để nhẹ hơn
      ),
    );
  }
}
