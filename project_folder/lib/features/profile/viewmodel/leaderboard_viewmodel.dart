import 'package:flutter/material.dart';
import '../service/profile_service.dart';

class LeaderboardViewModel extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _leaderboardData = [];
  String _selectedMetric = 'Level';
  final List<String> _metrics = ['Level', 'Streak'];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get leaderboardData => _leaderboardData;
  String get selectedMetric => _selectedMetric;
  List<String> get metrics => _metrics;

  // Load leaderboard data
  Future<void> loadLeaderboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('[LEADERBOARD] Loading leaderboard data...');
      final leaderboardData = await _profileService.getLeaderboard('global');
      print('[LEADERBOARD] Raw leaderboard data: $leaderboardData');

      // Log streak values specifically
      for (var user in leaderboardData) {
        print(
            '[LEADERBOARD] User ${user['name']} has streak: ${user['streak']}');
      }

      // Filter users to only include those with publicProfile set to true
      final filteredData = leaderboardData
          .where((user) => user['publicProfile'] == true)
          .toList();

      print(
          '[LEADERBOARD] Filtered data (public profiles only): $filteredData');
      _leaderboardData = filteredData;
      _isLoading = false;
      notifyListeners();
      print('[LEADERBOARD] Leaderboard data loaded successfully');
    } catch (e) {
      print('[LEADERBOARD] Error loading leaderboard data: $e');
      _errorMessage = 'Failed to load leaderboard: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Change selected metric
  void setSelectedMetric(String metric) {
    if (_metrics.contains(metric) && _selectedMetric != metric) {
      print('[LEADERBOARD] Changing metric from $_selectedMetric to $metric');
      _selectedMetric = metric;
      notifyListeners();
    }
  }

  // Get sorted leaderboard data based on selected metric
  List<Map<String, dynamic>> getSortedLeaderboardData() {
    final sortedUsers = List<Map<String, dynamic>>.from(_leaderboardData);

    print('[LEADERBOARD] Sorting leaderboard by $_selectedMetric');
    switch (_selectedMetric) {
      case 'Level':
        sortedUsers.sort((a, b) => b['level'].compareTo(a['level']));
        break;
      case 'Streak':
        // Log streak values before sorting
        for (var user in sortedUsers) {
          print(
              '[LEADERBOARD] Before sorting: User ${user['name']} has streak: ${user['streak']} (type: ${user['streak'].runtimeType})');
        }

        sortedUsers.sort((a, b) {
          // Ensure streak values are integers
          final aStreak = a['streak'] is int ? a['streak'] : 0;
          final bStreak = b['streak'] is int ? b['streak'] : 0;
          return bStreak.compareTo(aStreak);
        });

        // Log streak values after sorting
        for (var user in sortedUsers) {
          print(
              '[LEADERBOARD] After sorting: User ${user['name']} has streak: ${user['streak']}');
        }
        break;
    }

    // Update ranks after sorting
    for (int i = 0; i < sortedUsers.length; i++) {
      sortedUsers[i]['rank'] = i + 1;
    }

    print('[LEADERBOARD] Sorted leaderboard data: $sortedUsers');
    return sortedUsers;
  }
}
