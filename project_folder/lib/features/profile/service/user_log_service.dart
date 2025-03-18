import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import '../../authentication/service/token_manager.dart';
import '../../../config/api_config.dart';
class UserLogService {
  // Dynamic base URL method
  static Future<String> getBaseUrl() async {
    return '${ApiConfig.baseUrl}/api/logs';
  }

  // Get auth headers with JWT token
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await TokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get logs for the current user
  Future<Map<String, dynamic>> getUserLogs() async {
    try {
      final userId = await TokenManager.getUserId();
      if (userId == null) {
        print("[USER_LOG] User not logged in, returning empty logs");
        return {
          'logs': {
            'water_intake': {'values': [], 'last_update': null},
            'weight': {'values': [], 'last_update': null},
            'steps': {'values': [], 'last_update': null},
          }
        };
      }

      print("[USER_LOG] Fetching user logs");

      final baseUrl = await getBaseUrl();
      final headers = await _getAuthHeaders();

      try {
        print("[USER_LOG] Sending request to logs endpoint");

        final response = await http.get(
          Uri.parse("$baseUrl/$userId"),
          headers: headers,
        );

        print("[USER_LOG] Response status code: ${response.statusCode}");

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          print("[USER_LOG] Response data received");

          // Convert the new API format to the old format for compatibility
          if (data['success'] == true && data['data'] != null) {
            // Sort logs by date (newest first) before mapping
            final waterLogs = data['data']['water_logs'] ?? [];
            final weightLogs = data['data']['weight_logs'] ?? [];
            final stepLogs = data['data']['step_logs'] ?? [];

            // Sort logs by date (newest first)
            waterLogs.sort((a, b) =>
                DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
            weightLogs.sort((a, b) =>
                DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
            stepLogs.sort((a, b) =>
                DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

            print(
                "[USER_LOG] Sorted logs - Water: ${waterLogs.length}, Weight: ${weightLogs.length}, Steps: ${stepLogs.length}");

            return {
              'logs': {
                'water_intake': {
                  'values': waterLogs.map((log) => log['value']).toList(),
                  'last_update':
                      waterLogs.isNotEmpty ? waterLogs[0]['date'] : null
                },
                'weight': {
                  'values': weightLogs.map((log) => log['value']).toList(),
                  'last_update':
                      weightLogs.isNotEmpty ? weightLogs[0]['date'] : null
                },
                'steps': {
                  'values': stepLogs.map((log) => log['value']).toList(),
                  'last_update':
                      stepLogs.isNotEmpty ? stepLogs[0]['date'] : null
                },
              }
            };
          }

          return data;
        } else if (response.statusCode == 401) {
          print("Authentication failed, returning empty logs");
          return {
            'logs': {
              'water_intake': {'values': [], 'last_update': null},
              'weight': {'values': [], 'last_update': null},
              'steps': {'values': [], 'last_update': null},
            }
          };
        } else {
          print("Failed to load logs. Status code: ${response.statusCode}");
          print("Response body: ${response.body}");
          return {
            'logs': {
              'water_intake': {'values': [], 'last_update': null},
              'weight': {'values': [], 'last_update': null},
              'steps': {'values': [], 'last_update': null},
            }
          };
        }
      } catch (e) {
        print("HTTP error in getUserLogs: $e");
        return {
          'logs': {
            'water_intake': {'values': [], 'last_update': null},
            'weight': {'values': [], 'last_update': null},
            'steps': {'values': [], 'last_update': null},
          }
        };
      }
    } catch (e) {
      print("Error in getUserLogs: $e");
      return {
        'logs': {
          'water_intake': {'values': [], 'last_update': null},
          'weight': {'values': [], 'last_update': null},
          'steps': {'values': [], 'last_update': null},
        }
      };
    }
  }

  // Update a log
  Future<Map<String, dynamic>> updateLog(String type, double value) async {
    try {
      final userId = await TokenManager.getUserId();
      if (userId == null) {
        print("[USER_LOG] User not logged in, cannot update log");
        return {'success': false, 'message': 'User not logged in'};
      }

      // Convert water_intake to water for backend compatibility
      String backendType = type;
      if (type == 'water_intake') {
        backendType = 'water';
      }

      print("[USER_LOG] Updating log: type=$backendType, value=$value");

      final baseUrl = await getBaseUrl();
      final headers = await _getAuthHeaders();

      try {
        print("[USER_LOG] Sending request to logs/add endpoint");
        final response = await http.post(
          Uri.parse("$baseUrl/add"),
          headers: headers,
          body: jsonEncode({
            'user_id': userId,
            'type': backendType,
            'value': value,
          }),
        );

        print("[USER_LOG] Response status code: ${response.statusCode}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(response.body);
          print("[USER_LOG] Log updated successfully: ${response.body}");
          return data;
        } else {
          print(
              "[USER_LOG] Failed to update log. Status code: ${response.statusCode}");
          print("[USER_LOG] Response body: ${response.body}");
          return {
            'success': false,
            'message':
                'Failed to update log. Status code: ${response.statusCode}'
          };
        }
      } catch (e) {
        print("[USER_LOG] HTTP error in updateLog: $e");
        return {'success': false, 'message': 'Network error'};
      }
    } catch (e) {
      print("[USER_LOG] Error in updateLog: $e");
      return {'success': false, 'message': 'Error updating log'};
    }
  }

  // Format logs for display
  List<Map<String, dynamic>> formatLogsForDisplay(
      Map<String, dynamic> userLogs) {
    final List<Map<String, dynamic>> formattedLogs = [];

    try {
      final logs = userLogs['logs'];

      // Process water intake logs
      if (logs['water_intake'] != null &&
          logs['water_intake']['values'] != null) {
        final values = logs['water_intake']['values'];
        final lastUpdate = logs['water_intake']['last_update'];

        if (values.isNotEmpty) {
          formattedLogs.add({
            'type': 'water_intake',
            'value': values.last,
            'unit': 'ml',
            'date': lastUpdate ?? DateTime.now().toIso8601String(),
          });
        }
      }

      // Process weight logs
      if (logs['weight'] != null && logs['weight']['values'] != null) {
        final values = logs['weight']['values'];
        final lastUpdate = logs['weight']['last_update'];

        if (values.isNotEmpty) {
          formattedLogs.add({
            'type': 'weight',
            'value': values.last,
            'unit': 'kg',
            'date': lastUpdate ?? DateTime.now().toIso8601String(),
          });
        }
      }

      // Process steps logs
      if (logs['steps'] != null && logs['steps']['values'] != null) {
        final values = logs['steps']['values'];
        final lastUpdate = logs['steps']['last_update'];

        if (values.isNotEmpty) {
          formattedLogs.add({
            'type': 'steps',
            'value': values.last,
            'unit': 'steps',
            'date': lastUpdate ?? DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      print("Error formatting logs: $e");
    }

    return formattedLogs;
  }
}
