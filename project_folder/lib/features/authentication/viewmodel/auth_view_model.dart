// This file contains the view model for the authentication feature.
// The view model is responsible for handling the business logic of the feature.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/user_model.dart';
import '../service/auth_service.dart';
import '../providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthViewModel extends ChangeNotifier {
  // AuthService instance
  final AuthService _authService = AuthService();
  bool isLoading = false;
  String? error;
  UserModel? currentUser;
  final ProviderRef? _ref;

  // Constructor that accepts a ProviderRef
  AuthViewModel([this._ref]);

  // Login user
  Future<bool> login(String email, String password) async {
    // Set isLoading to true and error to null
    isLoading = true;
    error = null;
    notifyListeners(); // Notify listeners to update the UI

    try {
      // If the response is successful, get user details and update currentUser
      final response = await _authService.login(email, password);
      print("Login response: $response");

      if (response['success']) {
        // Get user details from response
        final userData = response['user'];

        if (userData == null) {
          error = "User data not found in response";
          return false;
        }

        try {
          currentUser = UserModel(
            id: userData['_id'] ?? '',
            username: userData['username'] ?? '',
            email: userData['email'] ?? '',
          );

          // Update the user provider if ref is available
          if (_ref != null) {
            _ref!.read(userProvider.notifier).state = currentUser;
          }

          // Store user info in SharedPreferences for profile access
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'user_info',
              jsonEncode({
                'username': userData['username'] ?? '',
                'email': userData['email'] ?? '',
              }));

          return true;
        } catch (e) {
          error = "Error parsing user data: $e";
          print("Error parsing user data: $e");
          print("User data: $userData");
          return false;
        }
      }
      error = response['error'];
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Register user
  Future<bool> register(String username, String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // If the response is successful, get user details and update currentUser
      final response = await _authService.register(username, email, password);
      if (response['success']) {
        return true;
      }
      error = response['error'];
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  // Forgot password - send reset code
  Future<bool> forgotPassword(String email) async {
    isLoading = true;
    error = null;
    notifyListeners(); // Notify listeners to update the UI

    try {
      // If the response is successful, get user details and update currentUser
      final response = await _authService.forgotPassword(email);
      if (response['success']) {
        return true;
      }
      error = response['error'];
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  // Verify password reset code
  Future<bool> verifyPasswordResetCode(String email, String code) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _authService.verifyPasswordResetCode(email, code);
      if (response['success']) {
        return true;
      }
      error = response['error'];
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Reset password with verified code
  Future<bool> resetPassword(
      String email, String code, String newPassword) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response =
          await _authService.resetPassword(email, code, newPassword);
      if (response['success']) {
        return true;
      }
      error = response['error'];
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Change password
  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response =
          await _authService.changePassword(currentPassword, newPassword);

      isLoading = false;

      if (response['success']) {
        notifyListeners();
        return true;
      } else {
        error = response['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      isLoading = false;
      error = 'An error occurred: $e';
      notifyListeners();
      return false;
    }
  }
}
