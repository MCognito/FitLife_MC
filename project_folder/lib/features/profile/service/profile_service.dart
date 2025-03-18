import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../../authentication/service/token_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/api_config.dart';

class ProfileService {
  // Dynamic base URL method
  static Future<String> getBaseUrl() async {
    return '${ApiConfig.baseUrl}/api/users';
  }

  // Dynamic base URL method for auth
  static Future<String> getAuthBaseUrl() async {
    return '${ApiConfig.baseUrl}/api/auth';
  }

  // Get auth headers with JWT token
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await TokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get user profile
  Future<UserProfile> getUserProfile() async {
    try {
      final userId = await TokenManager.getUserId();
      if (userId == null) {
        throw Exception("User not logged in");
      }

      final baseUrl = await getBaseUrl();
      final headers = await _getAuthHeaders();

      final response = await http.get(
        Uri.parse("$baseUrl/$userId"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserProfile.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception("Authentication failed. Please login again.");
      } else {
        print("Failed to load profile. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception("Failed to load profile");
      }
    } catch (e) {
      print("Error in getUserProfile: $e");
      throw Exception("Failed to load profile: $e");
    }
  }

  // Update user profile
  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    try {
      final userId = await TokenManager.getUserId();
      if (userId == null) {
        throw Exception("User not logged in");
      }

      final baseUrl = await getBaseUrl();
      final headers = await _getAuthHeaders();

      final response = await http.put(
        Uri.parse("$baseUrl/$userId"),
        headers: headers,
        body: jsonEncode(profile.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserProfile.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception("Authentication failed. Please login again.");
      } else {
        print("Failed to update profile. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception("Failed to update profile");
      }
    } catch (e) {
      print("Error in updateUserProfile: $e");
      throw Exception("Failed to update profile: $e");
    }
  }

  // Get leaderboard data
  Future<List<Map<String, dynamic>>> getLeaderboard(String type) async {
    try {
      print('[LEADERBOARD_SERVICE] Getting leaderboard data for type: $type');
      final baseUrl = await getBaseUrl();
      final headers = await _getAuthHeaders();
      final userId = await TokenManager.getUserId();

      print(
          '[LEADERBOARD_SERVICE] Sending request to: $baseUrl/leaderboard/$type');
      final response = await http.get(
        Uri.parse("$baseUrl/leaderboard/$type"),
        headers: headers,
      );

      print(
          '[LEADERBOARD_SERVICE] Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print(
            '[LEADERBOARD_SERVICE] Received ${data.length} users in leaderboard');
        final List<Map<String, dynamic>> leaderboardData =
            data.cast<Map<String, dynamic>>();

        // Mark the current user
        if (userId != null) {
          for (var user in leaderboardData) {
            if (user['userId'] == userId) {
              user['isCurrentUser'] = true;
              print(
                  '[LEADERBOARD_SERVICE] Marked current user in leaderboard: ${user['name']}');
            }
          }
        }

        return leaderboardData;
      } else if (response.statusCode == 401) {
        print('[LEADERBOARD_SERVICE] Authentication failed');
        throw Exception("Authentication failed. Please login again.");
      } else {
        print(
            "[LEADERBOARD_SERVICE] Failed to load leaderboard. Status code: ${response.statusCode}");
        print("[LEADERBOARD_SERVICE] Response body: ${response.body}");
        throw Exception("Failed to load leaderboard");
      }
    } catch (e) {
      print("[LEADERBOARD_SERVICE] Error in getLeaderboard: $e");
      throw Exception("Failed to load leaderboard: $e");
    }
  }

  // Update user preferences
  Future<UserPreferences> updatePreferences(UserPreferences preferences) async {
    try {
      final userId = await TokenManager.getUserId();
      if (userId == null) {
        throw Exception("User not logged in");
      }

      final baseUrl = await getBaseUrl();
      final headers = await _getAuthHeaders();

      // Print the preferences being sent to the backend for debugging
      print("Updating preferences: ${preferences.toJson()}");
      print("Dark mode value being sent: ${preferences.darkMode}");

      final response = await http.put(
        Uri.parse("$baseUrl/$userId/preferences"),
        headers: headers,
        body: jsonEncode(preferences.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Preferences updated successfully: $data");

        // Save the updated darkMode preference to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('darkMode', preferences.darkMode);

        return UserPreferences.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception("Authentication failed. Please login again.");
      } else {
        print(
            "Failed to update preferences. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception("Failed to update preferences");
      }
    } catch (e) {
      print("Error in updatePreferences: $e");
      throw Exception("Failed to update preferences: $e");
    }
  }

  // Get user information from local storage
  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      // Try to get user info from SharedPreferences first
      final prefs = await SharedPreferences.getInstance();
      final userInfoString = prefs.getString('user_info');

      if (userInfoString != null && userInfoString.isNotEmpty) {
        return jsonDecode(userInfoString);
      }

      // If not available in SharedPreferences, fetch from API
      final userId = await TokenManager.getUserId();
      if (userId == null) {
        throw Exception("User not logged in");
      }

      final baseUrl = await getAuthBaseUrl();
      final headers = await _getAuthHeaders();

      final response = await http.get(
        Uri.parse("$baseUrl/user/$userId"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save to SharedPreferences for future use
        await prefs.setString('user_info', jsonEncode(data));

        return data;
      } else {
        throw Exception("Failed to get user information");
      }
    } catch (e) {
      print("Error getting user info: $e");

      // Return default values if there's an error
      return {
        'username': 'User',
        'email': 'user@example.com',
      };
    }
  }
}
