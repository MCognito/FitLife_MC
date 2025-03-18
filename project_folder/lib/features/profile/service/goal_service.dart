import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import '../models/goal.dart';
import '../../authentication/service/token_manager.dart';

class GoalService {
  // Dynamic base URL method
  static Future<String> getBaseUrl() async {
    if (kIsWeb) {
      return "http://localhost:5000/api/goals"; // Web (Chrome, Edge, etc.)
    } else if (Platform.isAndroid) {
      bool isEmulator = await _isAndroidEmulator();
      return isEmulator
          ? "http://10.0.2.2:5000/api/goals" // Android Emulator
          : "http://192.168.1.38:5000/api/goals"; // Default for other Android devices
    } else if (Platform.isIOS) {
      return "http://localhost:5000/api/goals"; // iOS Simulator
    } else {
      return "http://192.168.1.38:5000/api/goals"; // Default for other devices
    }
  }

  // Check if running on Android emulator
  static Future<bool> _isAndroidEmulator() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return !androidInfo.isPhysicalDevice;
  }

  // Get authentication headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Goal> createGoal(String userId, Goal goal) async {
    try {
      final baseUrl = await getBaseUrl();
      final response = await http.post(
        Uri.parse('$baseUrl/$userId/create'),
        headers: await _getHeaders(),
        body: jsonEncode(goal.toJson()),
      );

      if (response.statusCode == 201) {
        return Goal.fromJson(jsonDecode(response.body));
      } else {
        print(
            'Failed to create goal. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to create goal: ${response.body}');
      }
    } catch (e) {
      print('Error creating goal: $e');
      throw Exception('Error creating goal: $e');
    }
  }

  Future<List<Goal>> getUserGoals(String userId) async {
    try {
      final baseUrl = await getBaseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/$userId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> goalsJson = jsonDecode(response.body);
        return goalsJson.map((json) => Goal.fromJson(json)).toList();
      } else {
        print(
            'Failed to fetch goals. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to fetch goals: ${response.body}');
      }
    } catch (e) {
      print('Error fetching goals: $e');
      throw Exception('Error fetching goals: $e');
    }
  }

  Future<Goal> updateGoalProgress(String goalId, double currentValue) async {
    try {
      final baseUrl = await getBaseUrl();
      final response = await http.put(
        Uri.parse('$baseUrl/$goalId/progress'),
        headers: await _getHeaders(),
        body: jsonEncode({'currentValue': currentValue}),
      );

      if (response.statusCode == 200) {
        return Goal.fromJson(jsonDecode(response.body));
      } else {
        print(
            'Failed to update goal progress. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to update goal progress: ${response.body}');
      }
    } catch (e) {
      print('Error updating goal progress: $e');
      throw Exception('Error updating goal progress: $e');
    }
  }

  // Update an entire goal
  Future<Goal> updateGoal(Goal goal) async {
    try {
      if (goal.id == null) {
        throw Exception("Goal ID cannot be null for update operation");
      }

      final baseUrl = await getBaseUrl();
      final response = await http.put(
        Uri.parse('$baseUrl/${goal.id}'),
        headers: await _getHeaders(),
        body: jsonEncode(goal.toJson()),
      );

      if (response.statusCode == 200) {
        return Goal.fromJson(jsonDecode(response.body));
      } else {
        print(
            'Failed to update goal. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to update goal: ${response.body}');
      }
    } catch (e) {
      print('Error updating goal: $e');
      throw Exception('Error updating goal: $e');
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      final baseUrl = await getBaseUrl();
      final response = await http.delete(
        Uri.parse('$baseUrl/$goalId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        print(
            'Failed to delete goal. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to delete goal: ${response.body}');
      }
    } catch (e) {
      print('Error deleting goal: $e');
      throw Exception('Error deleting goal: $e');
    }
  }

  Future<Goal> abandonGoal(String goalId) async {
    try {
      final baseUrl = await getBaseUrl();
      final response = await http.put(
        Uri.parse('$baseUrl/$goalId/abandon'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return Goal.fromJson(jsonDecode(response.body));
      } else {
        print(
            'Failed to abandon goal. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to abandon goal: ${response.body}');
      }
    } catch (e) {
      print('Error abandoning goal: $e');
      throw Exception('Error abandoning goal: $e');
    }
  }

  // Resume an abandoned goal by creating a new goal with updated parameters
  Future<Goal> resumeGoal(Goal abandonedGoal) async {
    try {
      // Create a new goal with the same properties but status set to IN_PROGRESS
      final resumedGoal = Goal(
        userId: abandonedGoal.userId,
        type: abandonedGoal.type,
        status: 'IN_PROGRESS',
        startDate: DateTime.now(),
        targetDate:
            DateTime.now().add(const Duration(days: 90)), // Default to 90 days
        startValue: abandonedGoal.currentValue, // Start from current value
        currentValue: abandonedGoal.currentValue,
        targetValue: abandonedGoal.targetValue,
        unit: abandonedGoal.unit,
        milestones: [], // Will be generated by backend
        notes: [],
        weeklyProgress: [],
        motivation: abandonedGoal.motivation,
      );

      // Create the new goal
      final newGoal = await createGoal(abandonedGoal.userId, resumedGoal);

      // Delete the abandoned goal
      if (abandonedGoal.id != null) {
        await deleteGoal(abandonedGoal.id!);
      }

      return newGoal;
    } catch (e) {
      print('Error resuming goal: $e');
      throw Exception('Error resuming goal: $e');
    }
  }
}
