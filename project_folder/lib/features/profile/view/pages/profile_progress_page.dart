import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../service/profile_service.dart';
import '../../service/log_service.dart';
import '../../service/user_log_service.dart';
import '../../service/workout_service.dart';
import '../../models/user_profile.dart';
import '../../test/progress_test_data.dart'; // Import test data

class ProfileProgressPage extends StatefulWidget {
  const ProfileProgressPage({super.key});

  @override
  State<ProfileProgressPage> createState() => _ProfileProgressPageState();
}

class _ProfileProgressPageState extends State<ProfileProgressPage> {
  final ProfileService _profileService = ProfileService();
  final LogService _logService = LogService();
  final UserLogService _userLogService = UserLogService();
  final WorkoutService _workoutService = WorkoutService();

  bool _isLoading = true;
  String? _errorMessage;
  UserProfile? _userProfile;
  List<Map<String, dynamic>> _logs = [];
  List<Map<String, dynamic>> _workouts = [];
  String _selectedTimeRange = '1W'; // Default to 1 week

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load user profile
      final profile = await _profileService.getUserProfile();

      // Load logs for each type
      print('Loading weight logs...');
      final weightLogs = await _logService.getLogs('weight');
      print('Weight logs: ${weightLogs.length}');

      print('Loading water logs...');
      final waterLogs = await _logService.getLogs('water_intake');
      print('Water logs: ${waterLogs.length}');

      print('Loading step logs...');
      final stepLogs = await _logService.getLogs('steps');
      print('Step logs: ${stepLogs.length}');

      // Combine logs
      final logs = [
        {
          'weight_log': weightLogs,
          'water_log': waterLogs,
          'step_log': stepLogs,
        }
      ];

      // Load actual workouts from service
      print('Loading workouts...');
      final workouts = await _workoutService.getWorkouts();
      print('Workouts response: $workouts');

      if (!mounted) return;

      setState(() {
        _userProfile = profile;
        _logs = logs;
        _workouts = workouts;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error loading data: $e');
      print('Stack trace: $stackTrace');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  String _getUnit(String type) {
    switch (type) {
      case 'weight':
        return 'kg';
      case 'water_intake':
        return 'ml';
      case 'steps':
        return 'steps';
      default:
        return '';
    }
  }

  List<FlSpot> _getDataPoints(String type, int days) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    if (_logs.isEmpty) {
      print('No logs available for $type');
      return [];
    }

    final logData = _logs.first;

    // Map the type to the correct field name in the logs data
    String fieldName;
    switch (type) {
      case 'water_intake':
        fieldName = 'water_log';
        break;
      case 'weight':
        fieldName = 'weight_log';
        break;
      case 'steps':
        fieldName = 'step_log';
        break;
      default:
        fieldName = '${type}_log';
    }

    print('Log data for $fieldName: ${logData[fieldName]}');

    if (logData[fieldName] == null) {
      print('$fieldName is null');
      return [];
    }

    if ((logData[fieldName] as List).isEmpty) {
      print('$fieldName is empty');
      return [];
    }

    List<LogEntry> entries = [];
    try {
      entries = (logData[fieldName] as List<LogEntry>)
          .where((entry) => entry.date.isAfter(startDate))
          .toList();
    } catch (e) {
      print('Error filtering entries for $type: $e');
      return [];
    }

    print('Filtered entries for $type: ${entries.length}');

    // Sort entries by date
    entries.sort((a, b) => a.date.compareTo(b.date));

    // Create a map to store unique dates and their corresponding values
    final Map<String, double> uniqueDatesMap = {};

    // Process entries to ensure one value per day (using the latest value for each day)
    for (var entry in entries) {
      // Format date to YYYY-MM-DD to use as a key (removing time component)
      String dateKey = DateFormat('yyyy-MM-dd').format(entry.date);
      // Store the value for this date (will overwrite previous value if exists)
      uniqueDatesMap[dateKey] = entry.value;
    }

    // Convert the map to a list of date-value pairs
    final List<MapEntry<DateTime, double>> uniqueDateEntries =
        uniqueDatesMap.entries.map((entry) {
      return MapEntry(
          DateFormat('yyyy-MM-dd')
              .parse(entry.key), // Convert string date back to DateTime
          entry.value);
    }).toList();

    // Sort by date
    uniqueDateEntries.sort((a, b) => a.key.compareTo(b.key));

    // Convert to FlSpot points with proper x-axis spacing
    final spots = <FlSpot>[];

    // Calculate the total range in days
    final totalDays = days.toDouble();

    for (int i = 0; i < uniqueDateEntries.length; i++) {
      final entry = uniqueDateEntries[i];
      // Calculate x position based on days from start date
      final daysDifference = entry.key.difference(startDate).inDays.toDouble();
      // Ensure x value is within the chart range
      final xValue = daysDifference.clamp(0.0, totalDays);
      spots.add(FlSpot(xValue, entry.value));

      // Debug output to verify x-axis values
      print(
          'Date: ${DateFormat('yyyy-MM-dd').format(entry.key)}, X: $xValue, Y: ${entry.value}');
    }

    print('Generated ${spots.length} data points for $type');
    return spots;
  }

  // Format large numbers with appropriate suffixes
  String _formatNumber(double value) {
    if (value >= 10000) {
      return NumberFormat.compact().format(value);
    } else if (value >= 1000) {
      return NumberFormat('#,##0').format(value);
    } else if (value >= 100) {
      return value.toStringAsFixed(0);
    } else if (value >= 10) {
      return value.toStringAsFixed(1);
    } else {
      return value.toStringAsFixed(1);
    }
  }

  Widget _buildChart(String type, String title, Color color) {
    final days = _selectedTimeRange == '1W'
        ? 7
        : _selectedTimeRange == '1M'
            ? 30
            : 365;
    final spots = _getDataPoints(type, days);
    final unit = _getUnit(type);

    // Calculate min and max values for better Y-axis scaling
    double? minY, maxY;
    if (spots.isNotEmpty) {
      minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
      maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
      // Add 10% padding to min/max
      final padding = (maxY - minY) * 0.1;
      // Ensure we have a non-zero interval even if min and max are the same
      if (padding == 0) {
        minY = minY! - 1;
        maxY = maxY! + 1;
      } else {
        minY -= padding;
        maxY += padding;
      }
    } else {
      // Default range if no data
      minY = 0;
      maxY = 100;
    }

    // Calculate appropriate intervals for the y-axis
    final yInterval = _calculateYAxisInterval(minY!, maxY!);

    // Calculate the dates for the x-axis
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    // Determine appropriate x-axis interval based on time range
    final xInterval = days <= 7 ? 1.0 : (days <= 30 ? 5.0 : 30.0);

    // Determine if we need to use compact number format based on the max value
    final useCompactFormat = maxY >= 1000;

    // Calculate the reserved size for y-axis labels based on the largest value
    final reservedSize = useCompactFormat ? 50.0 : (maxY >= 100 ? 60.0 : 50.0);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (spots.isNotEmpty) ...[
                  Flexible(
                    child: Text(
                      'Latest: ${_formatNumber(spots.last.y)} $unit',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            if (spots.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: [
                  Text(
                    'Min: ${_formatNumber(minY)} $unit',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '•',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Max: ${_formatNumber(maxY)} $unit',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            AspectRatio(
              aspectRatio: 1.5,
              child: spots.isEmpty
                  ? const Center(child: Text('No data available'))
                  : LineChart(
                      LineChartData(
                        minY: minY,
                        maxY: maxY,
                        minX: 0,
                        maxX: days.toDouble(),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: yInterval,
                          verticalInterval: xInterval,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300],
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300],
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: reservedSize,
                              interval: yInterval,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    _formatNumber(value),
                                    style: const TextStyle(fontSize: 9),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: xInterval,
                              getTitlesWidget: (value, meta) {
                                // Only show labels at grid line positions
                                if (value % xInterval != 0 && value != days) {
                                  return const SizedBox.shrink();
                                }

                                final date = startDate.add(
                                  Duration(days: value.toInt()),
                                );
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    DateFormat('MMM d').format(date),
                                    style: const TextStyle(fontSize: 9),
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved:
                                false, // Set to false to ensure accurate point positioning
                            color: color,
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: color,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: color.withOpacity(0.1),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                final date = startDate.add(
                                  Duration(days: spot.x.toInt()),
                                );
                                return LineTooltipItem(
                                  '${DateFormat('MMM d').format(date)}\n${_formatNumber(spot.y)} $unit',
                                  const TextStyle(color: Colors.white),
                                );
                              }).toList();
                            },
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to calculate appropriate y-axis interval
  double _calculateYAxisInterval(double min, double max) {
    final range = max - min;

    // Target 5-7 horizontal grid lines
    const targetGridLines = 5;

    // Calculate a nice interval
    final rawInterval = range / targetGridLines;

    // Round to a nice number
    if (rawInterval <= 0.1) return 0.1;
    if (rawInterval <= 0.2) return 0.2;
    if (rawInterval <= 0.5) return 0.5;
    if (rawInterval <= 1) return 1;
    if (rawInterval <= 2) return 2;
    if (rawInterval <= 5) return 5;
    if (rawInterval <= 10) return 10;
    if (rawInterval <= 20) return 20;
    if (rawInterval <= 50) return 50;
    if (rawInterval <= 100) return 100;
    if (rawInterval <= 200) return 200;
    if (rawInterval <= 500) return 500;
    if (rawInterval <= 1000) return 1000;

    // For larger values, round to nearest power of 10
    final power = (rawInterval / 1000).ceil();
    return power * 1000;
  }

  Widget _buildWorkoutSummary() {
    print('Building workout summary with ${_workouts.length} workouts');

    // Debug: Print the raw workout data
    if (_workouts.isNotEmpty) {
      print('First workout data structure:');
      _workouts.first.forEach((key, value) {
        print('  $key: $value');
      });
    } else {
      print('No workouts available');
    }

    // Group workouts by date
    final workoutsByDate = <String, List<Map<String, dynamic>>>{};

    try {
      for (final workout in _workouts) {
        // Check if workout has a date field
        if (workout['date'] == null) {
          print('Warning: Workout missing date: $workout');
          continue;
        }

        try {
          // MongoDB returns dates in a specific format, try to handle it
          String dateString;
          if (workout['date'] is String) {
            dateString = workout['date'];
          } else {
            // If it's not a string, it might be a MongoDB date object
            print(
                'Date is not a string: ${workout['date']} (${workout['date'].runtimeType})');
            // Try to convert it to a string
            dateString = workout['date'].toString();
          }

          final date =
              DateFormat('yyyy-MM-dd').format(DateTime.parse(dateString));
          print('Parsed date: $date for workout: ${workout['name']}');
          workoutsByDate[date] = [...(workoutsByDate[date] ?? []), workout];
        } catch (e) {
          print('Error parsing workout date: $e');
          continue;
        }
      }
      print('Grouped workouts by date: $workoutsByDate');
    } catch (e) {
      print('Error processing workouts: $e');
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Workouts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Total: ${_workouts.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _workouts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No workouts recorded yet\nStart logging your workouts to track progress!',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: workoutsByDate.length,
                    itemBuilder: (context, index) {
                      final date = workoutsByDate.keys.elementAt(index);
                      final workouts = workoutsByDate[date]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    DateFormat('EEEE, MMM d, yyyy')
                                        .format(DateTime.parse(date)),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                    '${workouts.length} workout${workouts.length == 1 ? '' : 's'}'),
                              ],
                            ),
                          ),
                          ...workouts.map((workout) {
                            final exercises =
                                workout['exercises'] as List<dynamic>? ?? [];
                            int totalSets = 0;
                            try {
                              for (final exercise in exercises) {
                                totalSets +=
                                    (exercise['sets'] as List<dynamic>? ?? [])
                                        .length;
                              }
                            } catch (e) {
                              print('Error calculating sets: $e');
                            }

                            return ListTile(
                              title: Text(workout['name'] ?? 'Unnamed Workout'),
                              subtitle: Text(
                                '${exercises.length} exercise${exercises.length == 1 ? '' : 's'} • $totalSets set${totalSets == 1 ? '' : 's'}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (workout['duration'] != null) ...[
                                    Text('${workout['duration']} min'),
                                    const SizedBox(width: 8),
                                  ],
                                  const Icon(Icons.fitness_center),
                                ],
                              ),
                            );
                          }),
                          if (index < workoutsByDate.length - 1)
                            const Divider(),
                        ],
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          // Time range selector
          DropdownButton<String>(
            value: _selectedTimeRange,
            items: const [
              DropdownMenuItem(value: '1W', child: Text('1 Week')),
              DropdownMenuItem(value: '1M', child: Text('1 Month')),
              DropdownMenuItem(value: '1Y', child: Text('1 Year')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedTimeRange = value;
                });
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChart('weight', 'Weight Progress', Colors.blue),
              const SizedBox(height: 16),
              _buildChart('water_intake', 'Water Intake Progress', Colors.cyan),
              const SizedBox(height: 16),
              _buildChart('steps', 'Steps Progress', Colors.green),
              const SizedBox(height: 16),
              _buildWorkoutSummary(),
            ],
          ),
        ),
      ),
    );
  }
}
