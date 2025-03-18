import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/user_log_service.dart';
import '../service/log_service.dart';
import '../service/streak_service.dart';
import '../models/log_entry.dart' as models;

// Provider for the ProfileLogsViewModel
final profileLogsViewModelProvider =
    ChangeNotifierProvider<ProfileLogsViewModel>((ref) {
  return ProfileLogsViewModel();
});

class ProfileLogsViewModel extends ChangeNotifier {
  final UserLogService _userLogService = UserLogService();
  final LogService _logService = LogService();
  final StreakService _streakService = StreakService();

  bool _isLoading = false;
  String? _errorMessage;
  List<models.LogEntry> _logs = [];
  models.StreakInfo? _streakInfo;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<models.LogEntry> get logs => _logs;
  models.StreakInfo? get streakInfo => _streakInfo;

  // Constructor
  ProfileLogsViewModel() {
    // Clear any existing logs first
    _logs = [];
    _errorMessage = null;
    _streakInfo = null;

    // Then load fresh data
    loadLogs();
    loadStreakInfo();
  }

  // Load streak information
  Future<void> loadStreakInfo() async {
    try {
      final streakData = await _streakService.getUserStreakInfo();
      _streakInfo = models.StreakInfo.fromJson(streakData);
      notifyListeners();
    } catch (e) {
      print("Error loading streak info: $e");
    }
  }

  // Load logs from the service
  Future<void> loadLogs() async {
    _isLoading = true;
    _errorMessage = null;

    // Clear existing logs before loading new ones
    _logs = [];

    notifyListeners();

    try {
      // Try to use the user log service
      final userLogsData = await _userLogService.getUserLogs();

      // Convert the logs format to our model
      final List<models.LogEntry> allLogs = [];

      // Process water intake logs
      if (userLogsData['logs'] != null &&
          userLogsData['logs']['water_intake'] != null &&
          userLogsData['logs']['water_intake']['values'] != null) {
        final values = userLogsData['logs']['water_intake']['values'];
        final lastUpdate = userLogsData['logs']['water_intake']['last_update'];

        for (var i = 0; i < values.length; i++) {
          allLogs.add(models.LogEntry(
            id: 'water_$i',
            type: 'water_intake',
            value: double.parse(values[i].toString()),
            unit: 'ml',
            date: lastUpdate != null
                ? DateTime.parse(lastUpdate)
                : DateTime.now(),
            userId: '',
          ));
        }
      }

      // Process weight logs
      if (userLogsData['logs'] != null &&
          userLogsData['logs']['weight'] != null &&
          userLogsData['logs']['weight']['values'] != null) {
        final values = userLogsData['logs']['weight']['values'];
        final lastUpdate = userLogsData['logs']['weight']['last_update'];

        for (var i = 0; i < values.length; i++) {
          allLogs.add(models.LogEntry(
            id: 'weight_$i',
            type: 'weight',
            value: double.parse(values[i].toString()),
            unit: 'kg',
            date: lastUpdate != null
                ? DateTime.parse(lastUpdate)
                : DateTime.now(),
            userId: '',
          ));
        }
      }

      // Process steps logs
      if (userLogsData['logs'] != null &&
          userLogsData['logs']['steps'] != null &&
          userLogsData['logs']['steps']['values'] != null) {
        final values = userLogsData['logs']['steps']['values'];
        final lastUpdate = userLogsData['logs']['steps']['last_update'];

        for (var i = 0; i < values.length; i++) {
          allLogs.add(models.LogEntry(
            id: 'steps_$i',
            type: 'steps',
            value: double.parse(values[i].toString()),
            unit: 'steps',
            date: lastUpdate != null
                ? DateTime.parse(lastUpdate)
                : DateTime.now(),
            userId: '',
          ));
        }
      }

      _logs = allLogs;
    } catch (e) {
      print('Error with user log service: $e');

      // Fallback to old log service
      try {
        final List<models.LogEntry> allLogs = [];

        // Get logs for each type
        final weightLogs = await _logService.getLogs('weight');
        final waterLogs = await _logService.getLogs('water_intake');
        final stepLogs = await _logService.getLogs('steps');

        // Convert LogEntry from service to our model
        for (var log in weightLogs) {
          allLogs.add(models.LogEntry(
            id: 'weight_${log.date.millisecondsSinceEpoch}',
            type: 'weight',
            value: log.value,
            unit: 'kg',
            date: log.date,
            userId: '',
          ));
        }

        for (var log in waterLogs) {
          allLogs.add(models.LogEntry(
            id: 'water_${log.date.millisecondsSinceEpoch}',
            type: 'water_intake',
            value: log.value,
            unit: 'ml',
            date: log.date,
            userId: '',
          ));
        }

        for (var log in stepLogs) {
          allLogs.add(models.LogEntry(
            id: 'steps_${log.date.millisecondsSinceEpoch}',
            type: 'steps',
            value: log.value,
            unit: 'steps',
            date: log.date,
            userId: '',
          ));
        }

        _logs = allLogs;
      } catch (fallbackError) {
        print('Error with fallback log service: $fallbackError');
        _errorMessage = 'Failed to load logs. Please try again later.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new log
  Future<String> addLog(String type, String value, String unit) async {
    if (value.isEmpty) {
      return 'Please enter a value';
    }

    final double? numericValue = double.tryParse(value);
    if (numericValue == null) {
      return 'Please enter a valid number';
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Try to use the user log service
      final result = await _userLogService.updateLog(type, numericValue);

      if (result['success'] == true) {
        await loadLogs();

        // If steps meet threshold, refresh streak info
        if (type == 'steps' &&
            _streakInfo != null &&
            numericValue >= _streakInfo!.minimumStepsThreshold) {
          await loadStreakInfo();
        }

        return 'success';
      } else {
        throw Exception(result['message'] ?? 'Failed to update log');
      }
    } catch (e) {
      print('Error with user log service: $e');

      // Fallback to old log service
      try {
        final result = await _logService.addLog(type, numericValue);

        if (result['success'] == true) {
          await loadLogs();

          // If steps meet threshold, refresh streak info
          if (type == 'steps' &&
              _streakInfo != null &&
              numericValue >= _streakInfo!.minimumStepsThreshold) {
            await loadStreakInfo();
          }

          return 'success';
        } else {
          throw Exception(result['message'] ?? 'Failed to add log');
        }
      } catch (fallbackError) {
        print('Error with fallback log service: $fallbackError');
        _errorMessage = 'Failed to add log. Please try again later.';
        _isLoading = false;
        notifyListeners();
        return 'Failed to add log. Please try again later.';
      }
    }
  }

  // Get logs filtered by type
  List<models.LogEntry> getLogsByType(String type) {
    return _logs.where((log) => log.type == type).toList();
  }

  // Format date for display
  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  // Clear all logs and data
  void clearLogs() {
    _logs = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
