import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../authentication/service/token_manager.dart';
import 'streak_service.dart';
import '../../../config/api_config.dart';
class LogEntry {
  final double value;
  final DateTime date;

  LogEntry({required this.value, required this.date});

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      value: json['value'].toDouble(),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() => {
        'value': value,
        'date': date.toIso8601String(),
      };
}

class LogService {
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
  Future<List<LogEntry>> getLogs(String type) async {
    try {
      final userId = await TokenManager.getUserId();
      if (userId == null) {
        print("[LOG_SERVICE] User not logged in, returning empty logs");
        return [];
      }

      final baseUrl = await getBaseUrl();
      final headers = await _getAuthHeaders();
      print("[LOG_SERVICE] Fetching logs for type: $type, userId: $userId");

      final response = await http.get(
        Uri.parse("$baseUrl/$userId"),
        headers: headers,
      );

      print("[LOG_SERVICE] Response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(
            "[LOG_SERVICE] Log API response for user $userId: ${response.body}");

        if (data['success'] == true) {
          if (data['data'] == null) {
            print("[LOG_SERVICE] Data is null in response for user $userId");
            return [];
          }

          // Map the type to the correct field name in the API response
          String fieldName;
          switch (type) {
            case 'water_intake':
              fieldName = 'water_logs';
              break;
            case 'weight':
              fieldName = 'weight_logs';
              break;
            case 'steps':
              fieldName = 'step_logs';
              break;
            default:
              fieldName = '${type}_logs';
          }

          if (data['data'][fieldName] == null) {
            print(
                "[LOG_SERVICE] $fieldName is null in response for user $userId");
            return [];
          }

          final logs = data['data'][fieldName] as List;
          print(
              "[LOG_SERVICE] Received ${logs.length} $fieldName for user $userId");

          final entries = logs.map((log) => LogEntry.fromJson(log)).toList();
          print(
              "[LOG_SERVICE] Converted to ${entries.length} LogEntry objects for user $userId");

          // Sort entries by date (newest first)
          entries.sort((a, b) => b.date.compareTo(a.date));

          return entries;
        } else {
          print("API returned success: false - ${data['message']}");
        }
      }
      print("Failed to get logs: Status code ${response.statusCode}");
      return [];
    } catch (e) {
      print("Error getting logs: $e");
      return [];
    }
  }

  // Get logs for a specific time range
  Future<List<LogEntry>> getLogsForRange(
      String type, DateTime start, DateTime end) async {
    try {
      final logs = await getLogs(type);
      if (logs.isEmpty) return [];

      final logData = logs.first;
      List<LogEntry> entries = [];

      switch (type) {
        case 'water_intake':
          entries = (logs as List<LogEntry>)
              .where((entry) =>
                  entry.date.isAfter(start) && entry.date.isBefore(end))
              .toList();
          break;
        case 'weight':
          entries = (logs as List<LogEntry>)
              .where((entry) =>
                  entry.date.isAfter(start) && entry.date.isBefore(end))
              .toList();
          break;
        case 'steps':
          entries = (logs as List<LogEntry>)
              .where((entry) =>
                  entry.date.isAfter(start) && entry.date.isBefore(end))
              .toList();
          break;
      }

      // Sort entries by date
      entries.sort((a, b) => a.date.compareTo(b.date));
      return entries;
    } catch (e) {
      print('Error getting logs for range: $e');
      return [];
    }
  }

  // Create default logs if none exist
  Future<void> _createDefaultLogs() async {
    try {
      final userId = await TokenManager.getUserId();
      if (userId == null) {
        print("User not logged in, cannot create default logs");
        return;
      }

      print("Creating default logs for user: $userId");

      // Try to create default logs, but don't throw if it fails
      try {
        await addLog('weight', 0);
        print("Created default weight log");
      } catch (e) {
        print("Error creating default weight log: $e");
      }

      try {
        await addLog('water_intake', 0);
        print("Created default water intake log");
      } catch (e) {
        print("Error creating default water intake log: $e");
      }

      try {
        await addLog('steps', 0);
        print("Created default steps log");
      } catch (e) {
        print("Error creating default steps log: $e");
      }

      print("Finished creating default logs");
    } catch (e) {
      print("Error in _createDefaultLogs: $e");
    }
  }

  // Add a new log entry
  Future<Map<String, dynamic>> addLog(String type, double value) async {
    try {
      final userId = await TokenManager.getUserId();
      if (userId == null) {
        print("User not logged in");
        return {'success': false, 'message': 'User not logged in'};
      }

      // Convert water_intake to water for backend compatibility
      String backendType = type;
      if (type == 'water_intake') {
        backendType = 'water';
      }

      final baseUrl = await getBaseUrl();
      final headers = await _getAuthHeaders();

      print(
          "[USER_LOG] Updating log: type=$backendType, value=$value for user=$userId");

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
          'message': 'Failed to update log. Status code: ${response.statusCode}'
        };
      }
    } catch (e) {
      print("[USER_LOG] Error updating log: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<List<LogEntry>> getLogsByDateRange(
      String type, DateTime start, DateTime end) async {
    try {
      final userId = await TokenManager.getUserId();
      if (userId == null) {
        print("User not logged in");
        return [];
      }

      final baseUrl = await getBaseUrl();
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse(
            "$baseUrl/range/$userId?type=$type&start_date=${start.toIso8601String()}&end_date=${end.toIso8601String()}"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final logs = data['data'] as List;
          return logs.map((log) => LogEntry.fromJson(log)).toList();
        }
      }
      print(
          "Failed to get logs by date range: ${response.statusCode} - ${response.body}");
      return [];
    } catch (e) {
      print("Error getting logs by date range: $e");
      return [];
    }
  }
}
