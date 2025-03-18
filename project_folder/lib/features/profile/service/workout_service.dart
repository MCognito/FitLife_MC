import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import '../../authentication/service/token_manager.dart';
import 'streak_service.dart';

class WorkoutService {
  // Dynamic base URL method
  static Future<String> getBaseUrl() async {
    if (kIsWeb) {
      return "http://localhost:5000/api/workouts"; // Web (Chrome, Edge, etc.)
    } else if (Platform.isAndroid) {
      bool isEmulator = await _isAndroidEmulator();
      return isEmulator
          ? "http://10.0.2.2:5000/api/workouts" // Android Emulator
          : "http://192.168.1.38:5000/api/workouts"; // Default for other Android devices
    } else if (Platform.isIOS) {
      return "http://localhost:5000/api/workouts"; // iOS Simulator
    } else {
      return "http://192.168.1.38:5000/api/workouts"; // Default for other devices
    }
  }

  // Check if the app is running on an Android emulator
  static Future<bool> _isAndroidEmulator() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    // Check common emulator properties
    bool isEmulator = androidInfo.isPhysicalDevice == false ||
        androidInfo.hardware.contains("ranchu") ||
        androidInfo.hardware.contains("goldfish") ||
        androidInfo.fingerprint.contains("generic");

    return isEmulator;
  }

  // Get auth headers with JWT token
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await TokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get workouts for the current user
  Future<List<Map<String, dynamic>>> getWorkouts() async {
    try {
      final userId = await TokenManager.getUserId();
      if (userId == null) {
        print("User not logged in, returning empty workouts");
        return [];
      }

      final baseUrl = await getBaseUrl();
      final headers = await _getAuthHeaders();

      try {
        final response = await http.get(
          Uri.parse("$baseUrl/user/$userId"),
          headers: headers,
        );

        print(
            "Workout API response: ${response.statusCode} - ${response.body}");

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          return data.cast<Map<String, dynamic>>();
        } else if (response.statusCode == 401) {
          print("Authentication failed, returning empty workouts");
          return [];
        } else {
          print("Failed to load workouts. Status code: ${response.statusCode}");
          print("Response body: ${response.body}");
          return [];
        }
      } catch (e) {
        print("HTTP error in getWorkouts: $e");
        return [];
      }
    } catch (e) {
      print("Error in getWorkouts: $e");
      return [];
    }
  }

  // Add a new workout
  Future<Map<String, dynamic>> addWorkout(
      String name, List<Map<String, dynamic>> exercises) async {
    try {
      final userId = await TokenManager.getUserId();
      if (userId == null) {
        print("User not logged in, cannot add workout");
        return {'success': false, 'message': 'User not logged in'};
      }

      final baseUrl = await getBaseUrl();
      final headers = await _getAuthHeaders();

      try {
        final response = await http.post(
          Uri.parse("$baseUrl"),
          headers: headers,
          body: jsonEncode({
            'user_id': userId,
            'name': name,
            'exercises': exercises,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(response.body);

          // Refresh streak info after adding a workout
          try {
            final streakService = StreakService();
            await streakService.getUserStreakInfo();
            print("Refreshed streak info after adding workout");
          } catch (e) {
            print("Error refreshing streak info: $e");
          }

          return data;
        } else {
          print("Failed to add workout. Status code: ${response.statusCode}");
          print("Response body: ${response.body}");
          return {
            'success': false,
            'message':
                'Failed to add workout. Status code: ${response.statusCode}'
          };
        }
      } catch (e) {
        print("HTTP error in addWorkout: $e");
        return {'success': false, 'message': 'Network error'};
      }
    } catch (e) {
      print("Error in addWorkout: $e");
      return {'success': false, 'message': 'Error adding workout'};
    }
  }
}
