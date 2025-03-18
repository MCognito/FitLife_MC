import 'package:flutter/material.dart';

/// A responsive text widget that adapts to screen size
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final double minFontSize;
  final double maxFontSize;
  final TextOverflow overflow;
  final bool softWrap;

  const ResponsiveText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.minFontSize = 8.0,
    this.maxFontSize = 16.0,
    this.overflow = TextOverflow.ellipsis,
    this.softWrap = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate font size based on screen width
    // For smaller screens, use smaller font size
    double fontSize = style?.fontSize ?? 14.0;

    if (screenWidth < 360) {
      // Very small screens (like curved edges)
      fontSize = minFontSize;
    } else if (screenWidth < 480) {
      // Small screens
      fontSize = minFontSize + 2.0;
    } else if (screenWidth < 600) {
      // Medium screens
      fontSize = (minFontSize + maxFontSize) / 2;
    } else {
      // Large screens
      fontSize = maxFontSize;
    }

    // Create a new style with the calculated font size
    final responsiveStyle =
        style?.copyWith(fontSize: fontSize) ?? TextStyle(fontSize: fontSize);

    return Text(
      text,
      style: responsiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}
