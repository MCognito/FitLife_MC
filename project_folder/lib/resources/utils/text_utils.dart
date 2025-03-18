import 'package:flutter/material.dart';

/// A utility class that provides text styles with proper overflow handling
class TextUtils {
  /// Creates a text widget with proper overflow handling for titles
  static Widget safeTitle(String text,
      {TextStyle? style, int maxLines = 1, TextAlign? textAlign}) {
    return Text(
      text,
      style: style,
      overflow: TextOverflow.ellipsis,
      maxLines: maxLines,
      textAlign: textAlign,
      softWrap: true,
    );
  }

  /// Creates a text widget with proper overflow handling for body text
  static Widget safeBody(String text,
      {TextStyle? style, int maxLines = 3, TextAlign? textAlign}) {
    return Text(
      text,
      style: style,
      overflow: TextOverflow.visible,
      maxLines: maxLines,
      textAlign: textAlign,
      softWrap: true,
    );
  }

  /// Creates a text widget with proper overflow handling for labels
  static Widget safeLabel(String text,
      {TextStyle? style, TextAlign? textAlign}) {
    return Text(
      text,
      style: style,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      textAlign: textAlign,
    );
  }

  /// Creates a text widget with proper overflow handling for multiline content
  static Widget safeMultiline(String text,
      {TextStyle? style, TextAlign? textAlign}) {
    return Text(
      text,
      style: style,
      overflow: TextOverflow.visible,
      softWrap: true,
      textAlign: textAlign,
    );
  }
}
