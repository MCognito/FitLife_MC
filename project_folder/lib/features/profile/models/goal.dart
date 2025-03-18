class Goal {
  final String? id;
  final String userId;
  final String type;
  final String status;
  final DateTime startDate;
  final DateTime targetDate;
  final double startValue;
  final double currentValue;
  final double targetValue;
  final String unit;
  final List<Milestone> milestones;
  final List<Note> notes;
  final List<WeeklyProgress> weeklyProgress;
  final Motivation motivation;
  final double progress;
  final bool isOnTrack;

  Goal({
    this.id,
    required this.userId,
    required this.type,
    this.status = 'IN_PROGRESS',
    required this.startDate,
    required this.targetDate,
    required this.startValue,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    required this.milestones,
    required this.notes,
    required this.weeklyProgress,
    required this.motivation,
    this.progress = 0.0,
    this.isOnTrack = true,
  });

  // Create a copy of this Goal with optional modified properties
  Goal copyWith({
    String? id,
    String? userId,
    String? type,
    String? status,
    DateTime? startDate,
    DateTime? targetDate,
    double? startValue,
    double? currentValue,
    double? targetValue,
    String? unit,
    List<Milestone>? milestones,
    List<Note>? notes,
    List<WeeklyProgress>? weeklyProgress,
    Motivation? motivation,
    double? progress,
    bool? isOnTrack,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      startValue: startValue ?? this.startValue,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      milestones: milestones ?? this.milestones,
      notes: notes ?? this.notes,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
      motivation: motivation ?? this.motivation,
      progress: progress ?? this.progress,
      isOnTrack: isOnTrack ?? this.isOnTrack,
    );
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['_id'],
      userId: json['user_id'],
      type: json['type'],
      status: json['status'],
      startDate: DateTime.parse(json['startDate']),
      targetDate: DateTime.parse(json['targetDate']),
      startValue: json['startValue'].toDouble(),
      currentValue: json['currentValue'].toDouble(),
      targetValue: json['targetValue'].toDouble(),
      unit: json['unit'],
      milestones: (json['milestones'] as List)
          .map((m) => Milestone.fromJson(m))
          .toList(),
      notes: (json['notes'] as List).map((n) => Note.fromJson(n)).toList(),
      weeklyProgress: (json['weeklyProgress'] as List)
          .map((w) => WeeklyProgress.fromJson(w))
          .toList(),
      motivation: Motivation.fromJson(json['motivation']),
      progress: json['progress']?.toDouble() ?? 0.0,
      isOnTrack: json['isOnTrack'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'user_id': userId,
      'type': type,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'targetDate': targetDate.toIso8601String(),
      'startValue': startValue,
      'currentValue': currentValue,
      'targetValue': targetValue,
      'unit': unit,
      'milestones': milestones.map((m) => m.toJson()).toList(),
      'notes': notes.map((n) => n.toJson()).toList(),
      'weeklyProgress': weeklyProgress.map((w) => w.toJson()).toList(),
      'motivation': motivation.toJson(),
    };
  }
}

class Milestone {
  final double value;
  final bool achieved;
  final DateTime? achievedDate;
  final String reward;

  Milestone({
    required this.value,
    this.achieved = false,
    this.achievedDate,
    required this.reward,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      value: json['value'].toDouble(),
      achieved: json['achieved'] ?? false,
      achievedDate: json['achievedDate'] != null
          ? DateTime.parse(json['achievedDate'])
          : null,
      reward: json['reward'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'achieved': achieved,
      if (achievedDate != null) 'achievedDate': achievedDate!.toIso8601String(),
      'reward': reward,
    };
  }
}

class Note {
  final DateTime date;
  final String content;

  Note({
    required this.date,
    required this.content,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      date: DateTime.parse(json['date']),
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'content': content,
    };
  }
}

class WeeklyProgress {
  final int week;
  final double value;
  final DateTime date;

  WeeklyProgress({
    required this.week,
    required this.value,
    required this.date,
  });

  factory WeeklyProgress.fromJson(Map<String, dynamic> json) {
    return WeeklyProgress(
      week: json['week'],
      value: json['value'].toDouble(),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week': week,
      'value': value,
      'date': date.toIso8601String(),
    };
  }
}

class Motivation {
  final String quote;
  final Reminder reminder;

  Motivation({
    required this.quote,
    required this.reminder,
  });

  factory Motivation.fromJson(Map<String, dynamic> json) {
    return Motivation(
      quote: json['quote'],
      reminder: Reminder.fromJson(json['reminder']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quote': quote,
      'reminder': reminder.toJson(),
    };
  }
}

class Reminder {
  final bool enabled;
  final String frequency;
  final String time;

  Reminder({
    this.enabled = true,
    this.frequency = 'DAILY',
    this.time = '09:00',
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      enabled: json['enabled'] ?? true,
      frequency: json['frequency'] ?? 'DAILY',
      time: json['time'] ?? '09:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'frequency': frequency,
      'time': time,
    };
  }
}
