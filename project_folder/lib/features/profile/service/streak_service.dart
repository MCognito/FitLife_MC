import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../authentication/service/token_manager.dart';
import '../../../config/api_config.dart';

class StreakService {
  // Dynamic base URL method
  static Future<String> getBaseUrl() async {
    return '${ApiConfig.baseUrl}/api/streaks';
  }

  // Get auth headers with JWT token
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await TokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get user streak info
  Future<Map<String, dynamic>> getUserStreakInfo() async {
    try {
      // Fetch streak info
      final userId = await TokenManager.getUserId();
      if (userId == null) {
        print("[STREAK] User not logged in, cannot fetch streak info");
        return {"error": "User not logged in"};
      }

      print("[STREAK] Fetching streak info");

      final baseUrl = await getBaseUrl();
      final headers = await _getAuthHeaders();

      try {
        print("[STREAK] Sending request to streaks endpoint");

        final response = await http.get(
          Uri.parse("$baseUrl/$userId"),
          headers: headers,
        );

        print("[STREAK] Response status code: ${response.statusCode}");

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print("[STREAK] Received streak data");
          return data;
        } else if (response.statusCode == 401) {
          print("[STREAK] Authentication failed, returning empty streak info");
          return {
            'currentStreak': 0,
            'longestStreak': 0,
            'lastActivityDate': null,
            'inGracePeriod': false,
            'gracePeriodHours': 24,
            'minimumStepsThreshold': 3000
          };
        } else {
          print(
              "[STREAK] Failed to load streak info. Status code: ${response.statusCode}");
          return {
            'currentStreak': 0,
            'longestStreak': 0,
            'lastActivityDate': null,
            'inGracePeriod': false,
            'gracePeriodHours': 24,
            'minimumStepsThreshold': 3000
          };
        }
      } catch (e) {
        print("[STREAK] HTTP error in getUserStreakInfo: $e");
        return {
          'currentStreak': 0,
          'longestStreak': 0,
          'lastActivityDate': null,
          'inGracePeriod': false,
          'gracePeriodHours': 24,
          'minimumStepsThreshold': 3000
        };
      }
    } catch (e) {
      print("[STREAK] Error in getUserStreakInfo: $e");
      return {
        'currentStreak': 0,
        'longestStreak': 0,
        'lastActivityDate': null,
        'inGracePeriod': false,
        'gracePeriodHours': 24,
        'minimumStepsThreshold': 3000
      };
    }
  }

  // Format streak info for display
  String formatStreakMessage(Map<String, dynamic> streakInfo) {
    final currentStreak = streakInfo['currentStreak'] ?? 0;
    final inGracePeriod = streakInfo['inGracePeriod'] ?? false;
    final gracePeriodHours = streakInfo['gracePeriodHours'] ?? 24;
    final minimumStepsThreshold = streakInfo['minimumStepsThreshold'] ?? 3000;

    if (currentStreak == 0) {
      return "Start your streak today by logging a workout or at least $minimumStepsThreshold steps!";
    } else if (inGracePeriod) {
      return "You're on a $currentStreak day streak! Log activity within $gracePeriodHours hours to keep it going.";
    } else {
      return "You're on a $currentStreak day streak! Keep it up!";
    }
  }

  // This method was a duplicate of getUserStreakInfo, removing it
  /*
  Future<Map<String, dynamic>> getStreakInfo(String userId) async {
    // Implementation removed to eliminate duplicate
  }
  */
}
