import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = _fallback();
    if (imageUrl.trim().isEmpty) return _clip(fallback);

    return _clip(
      CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => _loading(),
        errorWidget: (_, __, ___) => fallback,
      ),
    );
  }

  Widget _clip(Widget child) {
    final radius = borderRadius;
    if (radius == null) return child;
    return ClipRRect(borderRadius: radius, child: child);
  }

  Widget _loading() => SizedBox(
        width: width,
        height: height,
        child: const ColoredBox(
          color: surface2,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: mint),
            ),
          ),
        ),
      );

  Widget _fallback() => SizedBox(
        width: width,
        height: height,
        child: const ColoredBox(
          color: surface2,
          child: Center(
            child: Icon(CupertinoIcons.photo, color: muted, size: 22),
          ),
        ),
      );
}
