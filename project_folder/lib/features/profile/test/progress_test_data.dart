// Test data for profile progress page
class ProgressTestData {
  static Map<String, dynamic> getTestData() {
    final now = DateTime.now();

    return {
      'logs': [
        // Weight logs (showing a weight loss journey)
        {
          'type': 'weight',
          'value': '75.5',
          'date': now.subtract(const Duration(days: 7)).toIso8601String()
        },
        {
          'type': 'weight',
          'value': '75.0',
          'date': now.subtract(const Duration(days: 6)).toIso8601String()
        },
        {
          'type': 'weight',
          'value': '74.8',
          'date': now.subtract(const Duration(days: 4)).toIso8601String()
        },
        {
          'type': 'weight',
          'value': '74.3',
          'date': now.subtract(const Duration(days: 2)).toIso8601String()
        },
        {'type': 'weight', 'value': '74.0', 'date': now.toIso8601String()},

        // Water intake logs (showing varying intake)
        {
          'type': 'water_intake',
          'value': '2000',
          'date': now.subtract(const Duration(days: 7)).toIso8601String()
        },
        {
          'type': 'water_intake',
          'value': '2500',
          'date': now.subtract(const Duration(days: 6)).toIso8601String()
        },
        {
          'type': 'water_intake',
          'value': '1800',
          'date': now.subtract(const Duration(days: 4)).toIso8601String()
        },
        {
          'type': 'water_intake',
          'value': '2200',
          'date': now.subtract(const Duration(days: 2)).toIso8601String()
        },
        {
          'type': 'water_intake',
          'value': '2400',
          'date': now.toIso8601String()
        },

        // Steps logs (showing daily activity)
        {
          'type': 'steps',
          'value': '8000',
          'date': now.subtract(const Duration(days: 7)).toIso8601String()
        },
        {
          'type': 'steps',
          'value': '10000',
          'date': now.subtract(const Duration(days: 6)).toIso8601String()
        },
        {
          'type': 'steps',
          'value': '7500',
          'date': now.subtract(const Duration(days: 4)).toIso8601String()
        },
        {
          'type': 'steps',
          'value': '12000',
          'date': now.subtract(const Duration(days: 2)).toIso8601String()
        },
        {'type': 'steps', 'value': '9500', 'date': now.toIso8601String()},
      ],
      'workouts': [
        {
          'name': 'Morning Workout',
          'date': now.subtract(const Duration(days: 7)).toIso8601String(),
          'duration': 45,
          'exercises': [
            {
              'name': 'Push-ups',
              'sets': [
                {'reps': 12, 'weight': 0},
                {'reps': 10, 'weight': 0},
                {'reps': 8, 'weight': 0},
              ],
            },
            {
              'name': 'Squats',
              'sets': [
                {'reps': 15, 'weight': 20},
                {'reps': 15, 'weight': 20},
              ],
            },
          ],
        },
        {
          'name': 'Evening Run',
          'date': now.subtract(const Duration(days: 4)).toIso8601String(),
          'duration': 30,
          'exercises': [
            {
              'name': 'Running',
              'sets': [
                {'reps': 1, 'weight': 0},
              ],
            },
          ],
        },
        {
          'name': 'Full Body Workout',
          'date': now.toIso8601String(),
          'duration': 60,
          'exercises': [
            {
              'name': 'Bench Press',
              'sets': [
                {'reps': 10, 'weight': 60},
                {'reps': 8, 'weight': 65},
                {'reps': 6, 'weight': 70},
              ],
            },
            {
              'name': 'Deadlift',
              'sets': [
                {'reps': 8, 'weight': 100},
                {'reps': 8, 'weight': 100},
              ],
            },
            {
              'name': 'Pull-ups',
              'sets': [
                {'reps': 8, 'weight': 0},
                {'reps': 6, 'weight': 0},
              ],
            },
          ],
        },
      ]
    };
  }
}
