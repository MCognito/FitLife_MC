// Login Page for the application
// This page is the first page that the user sees when they open the application
// The user can login to their account using their email and password
// If the user does not have an account, they can click on the "Create Account" button to navigate to the SignUpPage

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_view_model.dart';
import '../../viewmodel/auth_handlers.dart';
import 'sign_up_page.dart';
import '../../../../resources/theme/color_style.dart';
import '../../../../main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:show_hide_password/show_hide_password.dart';
import 'forgot_password_page.dart';
import '../../../../features/authentication/view/custom_widgets/custom_input_fields.dart';
import '../../../../features/authentication/view/custom_widgets/custom_button.dart';
import '../../viewmodel/auth_validation_viewmodel.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final ImageProvider image = AssetImage('assets/images/fitlifeLogo.jpeg');
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final _validationViewModel = AuthValidationViewModel();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Building the Login Page
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
        title: const Text('Login Screen'),
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
                  // Keeping the Logo directly inside the LoginPage
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0, bottom: 15.0),
                    child: Image(
                      image: image,
                      height: 250,
                      width: 250,
                    ),
                  ),
                  // Custom text form field with theme-aware styling
                  TextFormField(
                    controller: emailController,
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
                    validator: _validationViewModel.validateEmail,
                  ),
                  const SizedBox(height: 15),
                  // Using ShowHidePassword widget for password field
                  ShowHidePassword(
                    passwordField: (hidePassword) {
                      return TextFormField(
                        controller: passwordController,
                        obscureText: hidePassword,
                        decoration: InputDecoration(
                          labelText: "Password",
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
                          // Use the simplified validation for login page
                          return _validationViewModel
                              .validateLoginPassword(val);
                        },
                      );
                    },
                    iconSize: 20,
                    visibleOffIcon: Icons.visibility_off,
                    visibleOnIcon: Icons.visibility,
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: "Login",
                    onPressed: () => AuthHandlers.handleLogin(
                      context,
                      formKey: formKey,
                      emailController: emailController,
                      passwordController: passwordController,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Forgot Password Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
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
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(
                      thickness: 2,
                      color: isDarkMode ? Colors.white24 : Colors.white30),
                  const SizedBox(height: 10),
                  Text(
                    'OR...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'If you do not have an account, \nClick below to register',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textColor),
                  ),
                  const SizedBox(height: 15),
                  CustomButton(
                    text: "Create Account",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
