import 'package:flutter/material.dart';

/// A responsive container widget that adapts to screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final double minWidth;
  final double maxWidth;
  final Alignment? alignment;
  final BoxConstraints? constraints;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.width,
    this.height,
    this.minWidth = 0.0,
    this.maxWidth = double.infinity,
    this.alignment,
    this.constraints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive padding based on screen width
    EdgeInsetsGeometry responsivePadding =
        padding ?? const EdgeInsets.all(16.0);

    if (screenWidth < 360) {
      // Very small screens (like curved edges)
      // Reduce padding to prevent overflow
      responsivePadding = const EdgeInsets.all(8.0);
    } else if (screenWidth < 480) {
      // Small screens
      responsivePadding = const EdgeInsets.all(12.0);
    }

    // Calculate responsive width based on screen width
    double? responsiveWidth = width;
    if (width != null) {
      if (screenWidth < 360) {
        // Very small screens (like curved edges)
        responsiveWidth = (width! * 0.8).clamp(minWidth, maxWidth);
      } else if (screenWidth < 480) {
        // Small screens
        responsiveWidth = (width! * 0.9).clamp(minWidth, maxWidth);
      }
    }

    // Create responsive constraints
    BoxConstraints? responsiveConstraints = constraints;
    if (constraints == null) {
      if (screenWidth < 360) {
        // Very small screens (like curved edges)
        responsiveConstraints = BoxConstraints(
          maxWidth: screenWidth * 0.9,
        );
      }
    }

    return Container(
      padding: responsivePadding,
      margin: margin,
      color: color,
      decoration: decoration,
      width: responsiveWidth,
      height: height,
      alignment: alignment,
      constraints: responsiveConstraints,
      child: child,
    );
  }
}
