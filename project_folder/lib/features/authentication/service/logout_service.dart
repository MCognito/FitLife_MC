import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'token_manager.dart';
import '../providers/user_provider.dart';

/// A service class to handle logout functionality
/// This ensures all user data is properly cleared when a user logs out
class LogoutService {
  /// Performs a complete logout, clearing all user data
  /// This method should be called when a user logs out
  static Future<void> performLogout(BuildContext context, WidgetRef ref) async {
    try {
      // Clear authentication data
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

      // Reset user provider if available
      if (ref != null) {
        try {
          ref.read(userProvider.notifier).state = null;
        } catch (e) {
          print("Error resetting user provider: $e");
        }
      }

      print("All user data cleared during logout");

      // Navigate to login screen and remove all previous routes
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);

      // Show confirmation to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully logged out'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Error during logout: $e");
      // Still try to navigate to login screen even if there was an error
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }
}
