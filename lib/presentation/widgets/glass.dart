import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class Glass extends StatelessWidget {
  final Widget child;
  final BorderRadius radius;
  final EdgeInsetsGeometry padding;

  const Glass({
    super.key,
    required this.child,
    this.radius = const BorderRadius.all(Radius.circular(32)),
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: surface2.withOpacity(.62),
              borderRadius: radius,
              border: Border.all(color: Colors.white.withOpacity(.08)),
            ),
            child: child,
          ),
        ),
      );
}
