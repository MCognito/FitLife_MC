// Custom text form field widget which is used to create a text form field with custom styling.
// It takes in the label, controller, isPassword and validator as parameters.
// The label is the text that is displayed on the text form field.

import 'package:flutter/material.dart';
import '../../../../resources/theme/color_style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';

class CustomTextFormField extends ConsumerWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  // Constructor for the custom text form field
  const CustomTextFormField({
    Key? key,
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.validator,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    // Set colors based on theme
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final fillColor = isDarkMode ? ColorStyle.darkBackground : Colors.white;
    final borderColor = isDarkMode ? Colors.white70 : Colors.black54;
    final labelTextColor = isDarkMode ? Colors.lightBlue[100] : Colors.black87;

    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: labelTextColor,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: borderColor, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.red),
        ),
        suffixIcon: suffixIcon,
      ),
      style: TextStyle(
        color: isDarkMode ? Colors.lightBlue[100] : Colors.black,
        fontWeight: FontWeight.w500,
      ),
      validator: validator,
    );
  }
}
