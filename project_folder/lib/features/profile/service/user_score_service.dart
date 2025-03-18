import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../authentication/service/token_manager.dart';
import '../models/user_score.dart';
import '../../../config/api_config.dart';

class UserScoreService {
  // Dynamic base URL method
  static Future<String> getBaseUrl() async {
    return '${ApiConfig.baseUrl}/api/user-scores';
  }

  // Get auth headers with JWT token
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await TokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get user score and level
  Future<UserScore> getUserScore() async {
    try {
      final userId = await TokenManager.getUserId();
      if (userId == null) {
        print("[USER_SCORE] User not logged in, returning empty score");
        return UserScore(
          totalScore: 0,
          level: 1,
          dailyPoints: 0,
          scoreHistory: [],
        );
      }

      print("[USER_SCORE] Fetching user score data");
      final baseUrl = await getBaseUrl();
      final headers = await _getAuthHeaders();

      try {
        print("[USER_SCORE] Sending request to user score endpoint");
        final response = await http.get(
          Uri.parse("$baseUrl/$userId"),
          headers: headers,
        );

        print(
            "[USER_SCORE] Score API response: ${response.statusCode} - ${response.body}");

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return UserScore.fromJson(data);
        } else if (response.statusCode == 401) {
          print("[USER_SCORE] Authentication failed, returning empty score");
          return UserScore(
            totalScore: 0,
            level: 1,
            dailyPoints: 0,
            scoreHistory: [],
          );
        } else {
          print(
              "[USER_SCORE] Failed to load score. Status code: ${response.statusCode}");
          print("[USER_SCORE] Response body: ${response.body}");
          return UserScore(
            totalScore: 0,
            level: 1,
            dailyPoints: 0,
            scoreHistory: [],
          );
        }
      } catch (e) {
        print("[USER_SCORE] HTTP error in getUserScore: $e");
        return UserScore(
          totalScore: 0,
          level: 1,
          dailyPoints: 0,
          scoreHistory: [],
        );
      }
    } catch (e) {
      print("[USER_SCORE] Error in getUserScore: $e");
      return UserScore(
        totalScore: 0,
        level: 1,
        dailyPoints: 0,
        scoreHistory: [],
      );
    }
  }

  // Add points manually (for testing or special events)
  Future<Map<String, dynamic>> addPoints(String action, int points) async {
    try {
      final userId = await TokenManager.getUserId();
      if (userId == null) {
        print("[USER_SCORE] User not logged in, cannot add points");
        return {'success': false, 'message': 'User not logged in'};
      }

      print(
          "[USER_SCORE] Adding points: action=$action, points=$points, userId=$userId");
      final baseUrl = await getBaseUrl();
      final headers = await _getAuthHeaders();

      try {
        // Log request details without exposing sensitive data
        print("[USER_SCORE] Sending request to add points");

        final response = await http.post(
          Uri.parse("$baseUrl/add"),
          headers: headers,
          body: jsonEncode({
            'user_id': userId,
            'action': action,
            'points': points,
          }),
        );

        print("[USER_SCORE] Response status: ${response.statusCode}");
        print("[USER_SCORE] Response body: ${response.body}");

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data;
        } else {
          print(
              "[USER_SCORE] Failed to add points. Status code: ${response.statusCode}");
          print("[USER_SCORE] Response body: ${response.body}");
          return {
            'success': false,
            'message':
                'Failed to add points. Status code: ${response.statusCode}'
          };
        }
      } catch (e) {
        print("[USER_SCORE] HTTP error in addPoints: $e");
        return {'success': false, 'message': 'Network error'};
      }
    } catch (e) {
      print("[USER_SCORE] Error in addPoints: $e");
      return {'success': false, 'message': 'Error adding points'};
    }
  }
}
