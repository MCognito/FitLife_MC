import 'package:flutter/material.dart';
import '../../../../resources/theme/color_style.dart';
import '../../viewmodel/auth_validation_viewmodel.dart';
import '../../viewmodel/auth_handlers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../../../../resources/utils/responsive_container.dart';
import '../../../../resources/utils/responsive_text.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final ImageProvider image =
      const AssetImage('assets/images/fitlifeLogo.jpeg');
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final _validationViewModel = AuthValidationViewModel();

  @override
  void dispose() {
    emailController.dispose();
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
        title: const Text('Forgot Password'),
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
                          'Reset Your Password',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ResponsiveText(
                          'Enter your email address below. We will send you a verification code to reset your password.',
                          style: TextStyle(
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  // Email field
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
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
                    ),
                    style: TextStyle(
                      color: isDarkMode ? Colors.lightBlue[100] : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    validator: (val) => _validationViewModel.validateEmail(val),
                  ),
                  const SizedBox(height: 20),
                  // Send Reset Code button
                  ElevatedButton(
                    onPressed: () => AuthHandlers.handleForgotPassword(
                      context,
                      formKey: formKey,
                      emailController: emailController,
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
                      "Send Reset Code",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Back to Login button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Back to Login",
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.lightBlue[100]
                            : Colors.blue[800],
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
