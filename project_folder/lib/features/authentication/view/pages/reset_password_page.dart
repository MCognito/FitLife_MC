import 'package:flutter/material.dart';
import '../../../../resources/theme/color_style.dart';
import '../../viewmodel/auth_validation_viewmodel.dart';
import '../../viewmodel/auth_handlers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../../../../resources/utils/responsive_container.dart';
import '../../../../resources/utils/responsive_text.dart';
import 'package:show_hide_password/show_hide_password.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  final String email;
  final String code;

  const ResetPasswordPage({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final ImageProvider image =
      const AssetImage('assets/images/fitlifeLogo.jpeg');
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final _validationViewModel = AuthValidationViewModel();

  // Password validation regex
  final _passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the theme mode for changes
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    // Set colors based on theme
    final backgroundColor =
        isDarkMode ? ColorStyle.darkGray : ColorStyle.fitLifeBlue;
    final textColor = isDarkMode ? Colors.white : ColorStyle.lightTextOnBlue;
    final inputFillColor =
        isDarkMode ? ColorStyle.darkBackground : Colors.white.withOpacity(0.9);
    final inputBorderColor = isDarkMode ? Colors.white : Colors.black54;
    final labelTextColor = isDarkMode ? Colors.lightBlue[100] : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: backgroundColor,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 10),
                  // Logo
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0, bottom: 15.0),
                    child: Image(
                      image: image,
                      height: 200,
                      width: 200,
                    ),
                  ),
                  // Instructions
                  ResponsiveContainer(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.only(bottom: 20.0),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.black26
                          : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        ResponsiveText(
                          'Create New Password',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ResponsiveText(
                          'Please enter your new password below. Your password must contain at least 8 characters, including uppercase, lowercase, number, and special character.',
                          style: TextStyle(
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                  // Password field
                  ShowHidePassword(
                    passwordField: (hidePassword) {
                      return TextFormField(
                        controller: passwordController,
                        obscureText: hidePassword,
                        decoration: InputDecoration(
                          labelText: "New Password",
                          labelStyle: TextStyle(
                            color: labelTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                          filled: true,
                          fillColor: inputFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide:
                                BorderSide(color: inputBorderColor, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide:
                                BorderSide(color: inputBorderColor, width: 2.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          suffixIconColor: isDarkMode
                              ? Colors.lightBlue[100]
                              : Colors.black87,
                        ),
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.lightBlue[100] : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Please enter a password";
                          }
                          if (!_passwordRegex.hasMatch(val)) {
                            return "Password must contain at least 8 characters, including uppercase, lowercase, number, and special character";
                          }
                          return null;
                        },
                      );
                    },
                    iconSize: 20,
                    visibleOffIcon: Icons.visibility_off,
                    visibleOnIcon: Icons.visibility,
                  ),
                  const SizedBox(height: 15),
                  // Confirm password field
                  ShowHidePassword(
                    passwordField: (hidePassword) {
                      return TextFormField(
                        controller: confirmPasswordController,
                        obscureText: hidePassword,
                        decoration: InputDecoration(
                          labelText: "Confirm New Password",
                          labelStyle: TextStyle(
                            color: labelTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                          filled: true,
                          fillColor: inputFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide:
                                BorderSide(color: inputBorderColor, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide:
                                BorderSide(color: inputBorderColor, width: 2.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          suffixIconColor: isDarkMode
                              ? Colors.lightBlue[100]
                              : Colors.black87,
                        ),
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.lightBlue[100] : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Please confirm your password";
                          }
                          if (val != passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      );
                    },
                    iconSize: 20,
                    visibleOffIcon: Icons.visibility_off,
                    visibleOnIcon: Icons.visibility,
                  ),
                  const SizedBox(height: 20),
                  // Reset Password button
                  ElevatedButton(
                    onPressed: () => AuthHandlers.handleResetPassword(
                      context,
                      formKey: formKey,
                      email: widget.email,
                      code: widget.code,
                      passwordController: passwordController,
                      confirmPasswordController: confirmPasswordController,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? ColorStyle.purpleButton
                          : ColorStyle.purpleButtonLight,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Reset Password",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
