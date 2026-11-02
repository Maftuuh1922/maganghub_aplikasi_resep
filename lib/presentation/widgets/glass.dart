import 'dart:ui';

import 'package:flutter/material.dart';

const double kFloatingBarHeight = 48;
const double kFloatingBarBottomSpacing = 12;
const double kFloatingContentGap = 12;
const double kFloatingListBottomExtra = 16;

class FloatingGlass extends StatelessWidget {
  final Widget child;
  final double height;
  final BorderRadius radius;

  const FloatingGlass({
    super.key,
    required this.child,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) => DecoratedBox(
        // Keep the shadow outside ClipRRect so it is not clipped away.
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(
              color: Color(0x59000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            // Blur the catalog behind the compact search surface.
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: const Color(0xA616283A),
                borderRadius: radius,
                border: Border.all(
                  color: const Color(0x14FFFFFF),
                  width: 1,
                ),
              ),
              child: child,
            ),
          ),
        ),
      );
}
