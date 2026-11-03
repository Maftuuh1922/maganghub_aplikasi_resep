import 'dart:ui';

import 'package:flutter/material.dart';

const double kSearchBarHeight = 48;
const double kSearchBarBottomSpacing = 12;
const double kFloatingContentGap = 12;
const double kFloatingListBottomExtra = 16;
const double kSearchBarHorizontalMargin = 16;
const double kSearchIconSize = 20;
const double kSearchIconTextGap = 10;
const double kSearchTextSize = 15;
const Color kSearchHintColor = Color(0x8CFFFFFF);
const Color kSearchFillColor = Color(0xA616283A);
const Color kSearchBorderColor = Color(0x14FFFFFF);
const Color kSearchShadowColor = Color(0x59000000);

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
        // Keep the shadow outside ClipRRect so it is not clipped.
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(
              color: kSearchShadowColor,
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            // Blur the catalog behind the readable search surface.
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: kSearchFillColor,
                borderRadius: radius,
                border: Border.all(color: kSearchBorderColor, width: 1),
              ),
              child: child,
            ),
          ),
        ),
      );
}
