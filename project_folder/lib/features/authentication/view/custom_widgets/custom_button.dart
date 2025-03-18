// Implementation of a custom button widget that can be used in the authentication view.
// Used for abstracting the button design and functionality.
// This widget is used in the login and register screens.

import 'package:flutter/material.dart';
import '../../../../resources/theme/color_style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';

// CustomButton class is used to create a custom button widget.
class CustomButton extends ConsumerWidget {
  final String text;
  final VoidCallback onPressed;

  // Constructor for CustomButton (atributtes must be required)
  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  // Build the custom button widget
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current theme mode
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    // Set colors based on theme
    final buttonColor =
        isDarkMode ? ColorStyle.purpleButton : ColorStyle.purpleButtonLight;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
