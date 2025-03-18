class LogEntry {
  final String id;
  final String type;
  final double value;
  final String unit;
  final DateTime date;
  final String userId;

  LogEntry({
    required this.id,
    required this.type,
    required this.value,
    required this.unit,
    required this.date,
    required this.userId,
  });

  // Create a LogEntry from a JSON map
  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['_id'] ?? json['id'] ?? '',
      type: json['type'] ?? '',
      value: double.tryParse(json['value'].toString()) ?? 0.0,
      unit: json['unit'] ?? '',
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      userId: json['user_id'] ?? '',
    );
  }

  // Convert LogEntry to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'value': value,
      'unit': unit,
      'date': date.toIso8601String(),
      'user_id': userId,
    };
  }

  // Create a copy of LogEntry with some fields changed
  LogEntry copyWith({
    String? id,
    String? type,
    double? value,
    String? unit,
    DateTime? date,
    String? userId,
  }) {
    return LogEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      date: date ?? this.date,
      userId: userId ?? this.userId,
    );
  }
}

// Model for streak information
class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final bool inGracePeriod;
  final int gracePeriodHours;
  final int minimumStepsThreshold;

  StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
    required this.inGracePeriod,
    required this.gracePeriodHours,
    required this.minimumStepsThreshold,
  });

  // Create a StreakInfo from a JSON map
  factory StreakInfo.fromJson(Map<String, dynamic> json) {
    return StreakInfo(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastActivityDate: json['lastActivityDate'] != null
          ? DateTime.parse(json['lastActivityDate'])
          : null,
      inGracePeriod: json['inGracePeriod'] ?? false,
      gracePeriodHours: json['gracePeriodHours'] ?? 24,
      minimumStepsThreshold: json['minimumStepsThreshold'] ?? 3000,
    );
  }

  // Convert StreakInfo to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivityDate': lastActivityDate?.toIso8601String(),
      'inGracePeriod': inGracePeriod,
      'gracePeriodHours': gracePeriodHours,
      'minimumStepsThreshold': minimumStepsThreshold,
    };
  }
}
