import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import '../../viewmodel/terms_and_conditions_viewmodel.dart';
import '../../../../resources/theme/color_style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';

class TermsConditionsView extends ConsumerWidget {
  const TermsConditionsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final termsVM =
        provider.Provider.of<TermsConditionsViewModel>(context, listen: false);
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    // Set colors based on theme
    final backgroundColor =
        isDarkMode ? ColorStyle.darkBackground : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final buttonColor =
        isDarkMode ? ColorStyle.purpleButton : ColorStyle.purpleButtonLight;

    return AlertDialog(
      backgroundColor: backgroundColor,
      title: Text(
        "Terms and Conditions",
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Text(
            termsVM.termsText,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: buttonColor,
          ),
          child: const Text("Close"),
        )
      ],
    );
  }
}
