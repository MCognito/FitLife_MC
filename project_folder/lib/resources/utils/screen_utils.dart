import 'package:flutter/material.dart';

/// A utility class for screen size detection and responsive design
class ScreenUtils {
  /// Returns true if the screen is considered small (width < 360)
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  /// Returns true if the screen is considered medium (width between 360 and 600)
  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 360 && width < 600;
  }

  /// Returns true if the screen is considered large (width >= 600)
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  /// Returns the appropriate padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isSmallScreen(context)) {
      return const EdgeInsets.all(8.0);
    } else if (isMediumScreen(context)) {
      return const EdgeInsets.all(12.0);
    } else {
      return const EdgeInsets.all(16.0);
    }
  }

  /// Returns the appropriate font size based on screen size
  static double getResponsiveFontSize(
    BuildContext context, {
    double small = 12.0,
    double medium = 14.0,
    double large = 16.0,
  }) {
    if (isSmallScreen(context)) {
      return small;
    } else if (isMediumScreen(context)) {
      return medium;
    } else {
      return large;
    }
  }

  /// Returns a responsive width based on screen size and percentage
  static double getResponsiveWidth(
    BuildContext context, {
    double percentage = 1.0,
  }) {
    return MediaQuery.of(context).size.width * percentage;
  }

  /// Returns a responsive height based on screen size and percentage
  static double getResponsiveHeight(
    BuildContext context, {
    double percentage = 1.0,
  }) {
    return MediaQuery.of(context).size.height * percentage;
  }

  /// Returns the safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }
}
