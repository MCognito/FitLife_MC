// This file contains the AuthService class which handles all the authentication requests to the server.

import 'dart:io' show SocketException;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'token_manager.dart'; // Import the token manager
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitlife/config/api_config.dart';
// AuthService class is used to handle all the authentication requests to the server.
// It has three methods: getBaseUrl, login, register, and forgotPassword.
// The getBaseUrl method is used to get the base URL of the server based on the platform.

class AuthService {
  static Future<String> getBaseUrl() async {
    return '${ApiConfig.baseUrl}/api/auth';
  }

  // Handle the request and return the response as a Map
  Future<Map<String, dynamic>> _handleRequest(
      Future<http.Response> Function() request) async {
    try {
      final response = await request();
      print("Response status code: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // If this is a login response, include the user data and save the token
        if (data.containsKey('user')) {
          // Save JWT token if it exists in the response
          if (data.containsKey('token')) {
            await TokenManager.saveToken(data['token']);

            // Save user ID if it exists in the user object
            if (data['user'].containsKey('_id')) {
              await TokenManager.saveUserId(data['user']['_id']);
            }
          }

          return {
            'success': true,
            'user': data['user'],
            'message': data['message']
          };
        }

        return {'success': true, 'data': data};
      }

      // Handle specific error status codes
      // Contains the error message based on the status code
      switch (response.statusCode) {
        case 404:
          return {
            'success': false,
            'error': 'Server not found. Check your network connection.'
          };
        case 403:
          return {'success': false, 'error': 'Access denied'};
        case 500:
          return {'success': false, 'error': 'Server error'};
        default:
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'] ?? 'Unknown error';
          return {'success': false, 'error': 'Request failed: $errorMessage'};
      }
    } on SocketException catch (e) {
      // Handle network errors
      if (e.toString().contains('Connection refused')) {
        return {
          'success': false,
          'error': 'Could not connect to server. Make sure server is running.'
        };
      } else if (e.toString().contains('No route to host')) {
        return {
          'success': false,
          'error':
              'Cannot reach server. Check if your device and server are on the same network.'
        };
      }
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Login method to authenticate the user
  Future<Map<String, dynamic>> login(String email, String password) async {
    String baseUrl = await AuthService.getBaseUrl(); // Get the correct base URL

    // Clear any existing user data before attempting login
    // This ensures no data from previous users persists
    await logout();

    return _handleRequest(() async {
      // Convert email to lowercase
      final sanitizedEmail = email.toLowerCase().trim();

      print("Attempting login");
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": sanitizedEmail, "password": password}),
      );

      // Return the response object, not the parsed data
      // The _handleRequest method will handle parsing the response
      return response;
    });
  }

  // Register method to create a new user account
  Future<Map<String, dynamic>> register(
      String username, String email, String password,
      {String? code}) async {
    String baseUrl =
        await AuthService.getBaseUrl(); // Gets the correct base URL
    return _handleRequest(() async {
      // Convert email to lowercase
      final sanitizedEmail = email.toLowerCase().trim();

      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": sanitizedEmail,
          "password": password,
          "code": code
        }),
      );
      return response;
    });
  }

  // Send verification code to the user's email
  Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    String baseUrl = await AuthService.getBaseUrl();
    return _handleRequest(() async {
      // Convert email to lowercase
      final sanitizedEmail = email.toLowerCase().trim();

      final response = await http.post(
        Uri.parse("$baseUrl/send-verification-code"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": sanitizedEmail}),
      );
      return response;
    });
  }

  // Verify the code entered by the user
  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    String baseUrl = await AuthService.getBaseUrl();
    return _handleRequest(() async {
      // Convert email to lowercase
      final sanitizedEmail = email.toLowerCase().trim();

      print("Sending verification request");

      final response = await http.post(
        Uri.parse("$baseUrl/verify-code"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": sanitizedEmail, "code": code}),
      );
      return response;
    });
  }

  // Forgot password method to send a password reset link to the user's email
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    String baseUrl = await AuthService.getBaseUrl(); // Get the correct base URL

    return _handleRequest(() async {
      // Convert email to lowercase
      final sanitizedEmail = email.toLowerCase().trim();

      final response = await http.post(
        Uri.parse("$baseUrl/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": sanitizedEmail}),
      );
      return response;
    });
  }

  // Verify password reset code
  Future<Map<String, dynamic>> verifyPasswordResetCode(
      String email, String code) async {
    String baseUrl = await AuthService.getBaseUrl();
    return _handleRequest(() async {
      // Convert email to lowercase
      final sanitizedEmail = email.toLowerCase().trim();

      final response = await http.post(
        Uri.parse("$baseUrl/verify-reset-code"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": sanitizedEmail, "code": code}),
      );
      return response;
    });
  }

  // Reset password with verified code
  Future<Map<String, dynamic>> resetPassword(
      String email, String code, String newPassword) async {
    String baseUrl = await AuthService.getBaseUrl();
    return _handleRequest(() async {
      // Convert email to lowercase
      final sanitizedEmail = email.toLowerCase().trim();

      final response = await http.post(
        Uri.parse("$baseUrl/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": sanitizedEmail,
          "code": code,
          "newPassword": newPassword
        }),
      );
      return response;
    });
  }

  // Logout method to clear the token and user data
  Future<void> logout() async {
    await TokenManager.clearAuthData();

    // Clear user info from SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Clear all user-related data
    await prefs.remove('user_info');

    // Clear any cached data that might contain user information
    await prefs.remove('darkMode');
    await prefs.remove('workout_data');
    await prefs.remove('user_logs');
    await prefs.remove('user_profile');

    // Clear any other user-specific data that might be stored
    final keys = prefs
        .getKeys()
        .where((key) =>
            key.startsWith('user_') ||
            key.startsWith('workout_') ||
            key.startsWith('log_') ||
            key.startsWith('profile_'))
        .toList();

    for (var key in keys) {
      await prefs.remove(key);
    }

    print("All user data cleared from SharedPreferences");
  }

  // Delete account method to delete the user's account
  Future<Map<String, dynamic>> deleteAccount() async {
    String baseUrl = await AuthService.getBaseUrl(); // Get the correct base URL
    final token = await TokenManager.getToken();

    if (token == null) {
      return {'success': false, 'error': 'Not logged in'};
    }

    return _handleRequest(() async {
      final response = await http.delete(
        Uri.parse("$baseUrl/delete-account"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );
      return response;
    }).then((result) async {
      if (result['success']) {
        // Clear auth data on successful deletion
        await TokenManager.clearAuthData();
      }
      return result;
    });
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return TokenManager.isLoggedIn();
  }

  // Get the current user ID
  Future<String?> getCurrentUserId() async {
    return TokenManager.getUserId();
  }

  // Change password
  Future<Map<String, dynamic>> changePassword(
      String currentPassword, String newPassword) async {
    try {
      // Check if user is logged in
      final token = await TokenManager.getToken();
      if (token == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      final baseUrl = await getBaseUrl();

      // Make API request to change password
      final response = await http.post(
        Uri.parse('$baseUrl/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      // Log status code but not response body
      print('Change password response status code: ${response.statusCode}');

      // Parse response
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': responseData['message']};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to change password'
        };
      }
    } catch (e) {
      print('Error changing password: $e');
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }
}
