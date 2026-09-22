import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Highly optimized, cached image widget for the entire Velvors app.
///
/// Benefits over standard [Image.network]:
/// 1. Disk & Memory Caching via [CachedNetworkImage].
/// 2. Automatic memory downsampling ([memCacheWidth], [memCacheHeight]) to prevent OOM and lag.
/// 3. Elegant shimmer placeholder during loading.
/// 4. Graceful fallback icon on error or empty URL.
/// 5. Smooth cross-fade animation when image loads.
class AppCachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? color;
  final BlendMode? colorBlendMode;
  final int? memCacheWidth;
  final int? memCacheHeight;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.placeholder,
    this.errorWidget,
    this.color,
    this.colorBlendMode,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  /// Factory helper for circular avatar images
  factory AppCachedImage.circle({
    Key? key,
    required String? imageUrl,
    required double radius,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return AppCachedImage(
      key: key,
      imageUrl: imageUrl,
      width: radius * 2,
      height: radius * 2,
      borderRadius: radius,
      fit: BoxFit.cover,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }

  /// Convenience helper to obtain a [CachedNetworkImageProvider] for use in
  /// [CircleAvatar.backgroundImage] or [DecorationImage.image].
  static ImageProvider provider(
    String? url, {
    int? maxHeight,
    int? maxWidth,
    String fallbackAsset = 'assets/placeholder.png',
  }) {
    if (url == null || url.trim().isEmpty || !url.startsWith('http')) {
      return const AssetImage('assets/placeholder.png');
    }
    return CachedNetworkImageProvider(
      url.trim(),
      maxHeight: maxHeight,
      maxWidth: maxWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cleanUrl = imageUrl?.trim() ?? '';

    Widget imageContent;

    if (cleanUrl.isEmpty || !cleanUrl.startsWith('http')) {
      imageContent = errorWidget ?? _defaultErrorWidget();
    } else {
      // Calculate sensible memory cache limits to avoid RAM spikes
      final effectiveMemWidth = memCacheWidth ??
          (width != null && width!.isFinite ? (width! * 2.5).round() : 1000);
      final effectiveMemHeight = memCacheHeight ??
          (height != null && height!.isFinite ? (height! * 2.5).round() : 1000);

      imageContent = CachedNetworkImage(
        imageUrl: cleanUrl,
        width: width,
        height: height,
        fit: fit,
        color: color,
        colorBlendMode: colorBlendMode,
        memCacheWidth: effectiveMemWidth > 0 ? effectiveMemWidth : null,
        memCacheHeight: effectiveMemHeight > 0 ? effectiveMemHeight : null,
        fadeInDuration: const Duration(milliseconds: 250),
        fadeOutDuration: const Duration(milliseconds: 150),
        placeholder: (context, url) => placeholder ?? _defaultPlaceholder(),
        errorWidget: (context, url, error) =>
            errorWidget ?? _defaultErrorWidget(),
      );
    }

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageContent,
      );
    }

    return imageContent;
  }

  Widget _defaultPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        color: Colors.grey.shade300,
      ),
    );
  }

  Widget _defaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey.shade500,
        size: (width != null && height != null)
            ? (width! < height! ? width! * 0.4 : height! * 0.4).clamp(16.0, 48.0)
            : 24.0,
      ),
    );
  }
}
