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
const double kSearchBlurSigma = 14;
const double kGlassShadowBlur = 24;
const Offset kGlassShadowOffset = Offset(0, 8);
const EdgeInsetsGeometry kNoGlassPadding = EdgeInsets.zero;

class FloatingGlass extends StatelessWidget {
  final Widget child;
  final double height;
  final BorderRadius radius;
  final EdgeInsetsGeometry padding;
  final Color fillColor;
  final Color borderColor;
  final Color shadowColor;
  final double blurSigma;
  final double shadowBlur;
  final Offset shadowOffset;
  final bool overlayBorder;
  final bool borderConsumesSpace;

  const FloatingGlass({
    super.key,
    required this.child,
    required this.height,
    required this.radius,
    this.padding = kNoGlassPadding,
    this.fillColor = kSearchFillColor,
    this.borderColor = kSearchBorderColor,
    this.shadowColor = kSearchShadowColor,
    this.blurSigma = kSearchBlurSigma,
    this.shadowBlur = kGlassShadowBlur,
    this.shadowOffset = kGlassShadowOffset,
    this.overlayBorder = true,
    this.borderConsumesSpace = true,
  });

  @override
  Widget build(BuildContext context) => DecoratedBox(
        // Outside the clip so the shadow is not cut off.
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: shadowBlur,
              offset: shadowOffset,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            // Blur the catalog behind the floating capsule.
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              height: height,
              padding: padding,
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: radius,
                border: overlayBorder && borderConsumesSpace
                    ? Border.all(color: borderColor, width: 1)
                    : null,
              ),
              child: child,
            ),
          ),
        ),
      );
}
