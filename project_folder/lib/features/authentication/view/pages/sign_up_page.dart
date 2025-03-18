// This file contains the sign up page which allows users to create an account
// The page contains text form fields for the user to enter their email, username, password and confirm password
// The user can click on the "Create Account" button to create an account
// If the user already has an account, they can click on the "Go to Login" button to navigate to the login page

import 'package:flutter/material.dart';
import '../../../../features/authentication/view/pages/login_page.dart';
import '../../../../resources/theme/color_style.dart';
import '../../../../features/authentication/view/custom_widgets/custom_input_fields.dart';
import '../../../../features/authentication/view/custom_widgets/custom_button.dart';
import '../../viewmodel/auth_validation_viewmodel.dart';
import '../../viewmodel/auth_handlers.dart';
import 'package:show_hide_password/show_hide_password.dart';
import 'package:provider/provider.dart' as provider;
import '../pages/terms_and_conditions.dart';
import '../../viewmodel/terms_and_conditions_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final ImageProvider image =
      const AssetImage('assets/images/fitlifeLogo.jpeg');
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final subjectController =
      TextEditingController(); // Optional: if you need a subject field
  final formKey = GlobalKey<FormState>();
  final _validationViewModel = AuthValidationViewModel();

  // Add password validation rules
  final _passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  // Boolean for checkbox state
  bool termsAccepted = false;

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    subjectController.dispose();
    super.dispose();
  }

  // Building the SignUp Page
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
        title: const Text('Sign Up Screen'),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0, bottom: 15.0),
                    child: Image(
                      image: image,
                      height: 250,
                      width: 250,
                    ),
                  ),
                  // Email field
                  TextFormField(
                    controller: emailController,
                    onChanged: (value) {
                      // Convert email to lowercase as user types
                      final newValue = value.toLowerCase();
                      if (value != newValue) {
                        emailController.value = emailController.value.copyWith(
                          text: newValue,
                          selection:
                              TextSelection.collapsed(offset: newValue.length),
                        );
                      }
                    },
                    decoration: InputDecoration(
                      labelText: "Enter Email:",
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
                  // Username field
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: "Enter Username:",
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
                    validator: (val) {
                      if (val!.trim().isEmpty) {
                        return "Please enter a username";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  // Password field
                  ShowHidePassword(
                    passwordField: (hidePassword) {
                      return TextFormField(
                        controller: passwordController,
                        obscureText: hidePassword,
                        decoration: InputDecoration(
                          labelText: "Enter Password:",
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
                          labelText: "Re-Enter Password:",
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
                          if (val!.trim().isEmpty) {
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
                  // Terms and Conditions checkbox with clickable link
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.black26
                          : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Checkbox(
                          value: termsAccepted,
                          onChanged: (bool? value) {
                            setState(() {
                              termsAccepted = value ?? false;
                            });
                          },
                          checkColor: Colors.white,
                          fillColor: MaterialStateProperty.resolveWith<Color>(
                              (states) {
                            if (states.contains(MaterialState.selected)) {
                              return isDarkMode
                                  ? ColorStyle.purpleButton
                                  : ColorStyle.purpleButtonLight;
                            }
                            return isDarkMode
                                ? Colors.grey
                                : Colors.grey.shade400;
                          }),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Open the Terms and Conditions dialog wrapped with ChangeNotifierProvider
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    provider.ChangeNotifierProvider(
                                  create: (_) => TermsConditionsViewModel(),
                                  child: const TermsConditionsView(),
                                ),
                              );
                            },
                            child: Text(
                              "I agree to the Terms and Conditions",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: "Create Account!",
                    onPressed: () {
                      if (!termsAccepted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Please accept the Terms and Conditions to proceed."),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      AuthHandlers.handleSignUp(
                        context,
                        formKey: formKey,
                        emailController: emailController,
                        usernameController: usernameController,
                        passwordController: passwordController,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Divider(
                    color: isDarkMode ? Colors.white24 : Colors.white30,
                    thickness: 2,
                  ),
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
                    'If you already have an account, \nClick below to login',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textColor),
                  ),
                  const SizedBox(height: 15),
                  CustomButton(
                    text: "Go to Login",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
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
