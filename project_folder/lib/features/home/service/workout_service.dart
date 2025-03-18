import 'dart:convert';
import 'dart:io' show Platform, SocketException;
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart'; // For device info
import 'package:flutter/foundation.dart'; // For kIsWeb
import '../models/workout.dart';
import '../../authentication/service/token_manager.dart'; // Import the token manager

class WorkoutService {
  // Dynamic base URL method similar to AuthService
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

  Future<List<WorkoutModel>> getWorkouts(String userId) async {
    try {
      final baseUrl = await getBaseUrl();
      final headers = await _getAuthHeaders();

      final response = await http.get(
        Uri.parse("$baseUrl/user/$userId"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => WorkoutModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        throw Exception("Authentication failed. Please login again.");
      } else {
        print("Failed to load workouts. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception("Failed to load workouts");
      }
    } catch (e) {
      print("Error in getWorkouts: $e");
      throw Exception("Failed to load workouts: $e");
    }
  }

  Future<WorkoutModel> addWorkout(WorkoutModel workout) async {
    try {
      final baseUrl = await getBaseUrl();
      final headers = await _getAuthHeaders();

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(workout.toJson()),
      );

      if (response.statusCode == 201) {
        // Parse the response which contains {success, workout, pointsAdded}
        final responseData = jsonDecode(response.body);
        print("Add workout response: $responseData");

        // Extract the workout object from the response
        if (responseData.containsKey('workout')) {
          return WorkoutModel.fromJson(responseData['workout']);
        } else {
          print("Response doesn't contain workout field: $responseData");
          throw Exception("Invalid response format");
        }
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        throw Exception("Authentication failed. Please login again.");
      } else {
        print("Failed to add workout. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception("Failed to add workout");
      }
    } catch (e) {
      print("Error in addWorkout: $e");
      throw Exception("Failed to add workout: $e");
    }
  }

  Future<void> updateWorkout(WorkoutModel workout) async {
    try {
      final baseUrl = await getBaseUrl();
      final headers = await _getAuthHeaders();
      print("Updating workout with ID: ${workout.id}");

      final response = await http.put(
        Uri.parse("$baseUrl/${workout.id}"),
        headers: headers,
        body: jsonEncode(workout.toJson()),
      );

      if (response.statusCode == 200) {
        // Parse the response to check for points awarded
        final responseData = jsonDecode(response.body);
        print("Update workout response: $responseData");

        // Log points awarded information if available
        if (responseData.containsKey('pointsAwarded')) {
          print("Points awarded: ${responseData['pointsAwarded']}");
        }
        // Success
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        throw Exception("Authentication failed. Please login again.");
      } else {
        print("Failed to update workout. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception("Failed to update workout");
      }
    } catch (e) {
      print("Error in updateWorkout: $e");
      throw Exception("Failed to update workout: $e");
    }
  }

  Future<void> deleteWorkout(String id) async {
    try {
      final baseUrl = await getBaseUrl();
      final headers = await _getAuthHeaders();

      final response = await http.delete(
        Uri.parse("$baseUrl/$id"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Success
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        throw Exception("Authentication failed. Please login again.");
      } else {
        print("Failed to delete workout. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception("Failed to delete workout");
      }
    } catch (e) {
      print("Error in deleteWorkout: $e");
      throw Exception("Failed to delete workout: $e");
    }
  }

  // Get current user's workouts
  Future<List<WorkoutModel>> getCurrentUserWorkouts() async {
    final userId = await TokenManager.getUserId();
    if (userId == null) {
      throw Exception("User not logged in");
    }
    return getWorkouts(userId);
  }
}
