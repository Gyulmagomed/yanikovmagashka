import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:telemost12_app/theme/app_theme.dart';

/// Показывает фото товара: из URL (Firebase) или assets.
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  final String imagePath;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  bool get _isNetworkUrl =>
      imagePath.startsWith('http://') || imagePath.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_isNetworkUrl) {
      child = CachedNetworkImage(
        imageUrl: imagePath,
        fit: fit,
        width: width,
        height: height,
        placeholder: (_, __) => _placeholder(context),
        errorWidget: (_, __, ___) => _placeholder(context),
      );
    } else {
      child = Image.asset(
        imagePath,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    }
    if (borderRadius != null) {
      child = ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }
    return child;
  }

  Widget _placeholder(BuildContext context) {
    final c = AppTheme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.image_outlined,
        size: (width != null && height != null)
            ? (width! < height! ? width! : height!) * 0.4
            : 48,
        color: c.textSecondary,
      ),
    );
  }
}
