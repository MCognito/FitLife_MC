// The login and sign up actions are handled by the AuthHandlers class
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import '../viewmodel/auth_view_model.dart';
import '../view/pages/login_page.dart';
import '../view/pages/verification_page.dart';
import '../../home/view/pages/workout_tracker.dart';
import '../../navigation/main_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../view/pages/password_reset_verification_page.dart';
import '../view/pages/reset_password_page.dart';

// Handles the login and sign up actions
class AuthHandlers {
  static Future<void> handleLogin(
    BuildContext context, {
    // Required parameters
    required GlobalKey<FormState> formKey,
    required TextEditingController emailController,
    required TextEditingController passwordController,
  }) async {
    // Validate the form
    if (!formKey.currentState!.validate()) return;

    // Get the email and password from the text controllers
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      // Get the AuthViewModel instance
      final authViewModel =
          provider.Provider.of<AuthViewModel>(context, listen: false);
      print("Attempting login with email: $email");
      final success = await authViewModel.login(email, password);

      // Close loading indicator
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (!context.mounted) return;

      // Show a snackbar based on the result
      if (success) {
        // Navigate to the main screen
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Login failed. Please check your credentials and try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading indicator if still showing
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Login failed. Please check your credentials and try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Handles the sign up action
  static Future<void> handleSignUp(
    BuildContext context, {
    // Required parameters
    required GlobalKey<FormState> formKey,
    required TextEditingController emailController,
    required TextEditingController usernameController,
    required TextEditingController passwordController,
  }) async {
    // Validate the form
    if (!formKey.currentState!.validate()) return;

    // Get the email, username, and password from the text controllers
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      // Instead of registering directly, navigate to verification page
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading indicator

        // Navigate to verification page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationPage(
              email: email,
              username: username,
              password: password,
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading indicator if still showing
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      print("Exception during sign up: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sign up error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Handles the forgot password action
  static Future<void> handleForgotPassword(
    BuildContext context, {
    required GlobalKey<FormState> formKey,
    required TextEditingController emailController,
  }) async {
    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    final email = emailController.text.trim().toLowerCase();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Get the AuthViewModel instance
      final authViewModel =
          provider.Provider.of<AuthViewModel>(context, listen: false);

      // Call the forgotPassword method
      final success = await authViewModel.forgotPassword(email);

      // Close loading dialog
      Navigator.pop(context);

      if (success) {
        // Navigate to verification page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordResetVerificationPage(email: email),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authViewModel.error ?? 'Failed to send reset code'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Handles the verify reset code action
  static Future<void> handleVerifyResetCode(
    BuildContext context, {
    required GlobalKey<FormState> formKey,
    required String email,
    required TextEditingController codeController,
  }) async {
    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    final code = codeController.text.trim();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Get the AuthViewModel instance
      final authViewModel =
          provider.Provider.of<AuthViewModel>(context, listen: false);

      // Call the verifyPasswordResetCode method
      final success = await authViewModel.verifyPasswordResetCode(email, code);

      // Close loading dialog
      Navigator.pop(context);

      if (success) {
        // Navigate to reset password page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage(
              email: email,
              code: code,
            ),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authViewModel.error ?? 'Invalid verification code'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Handles the reset password action
  static Future<void> handleResetPassword(
    BuildContext context, {
    required GlobalKey<FormState> formKey,
    required String email,
    required String code,
    required TextEditingController passwordController,
    required TextEditingController confirmPasswordController,
  }) async {
    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    final newPassword = passwordController.text;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Get the AuthViewModel instance
      final authViewModel =
          provider.Provider.of<AuthViewModel>(context, listen: false);

      // Call the resetPassword method
      final success =
          await authViewModel.resetPassword(email, code, newPassword);

      // Close loading dialog
      Navigator.pop(context);

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Password reset successful! Please login with your new password.'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to login page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authViewModel.error ?? 'Failed to reset password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
