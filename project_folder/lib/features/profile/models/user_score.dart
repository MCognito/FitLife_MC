class UserScore {
  final int totalScore;
  final int level;
  final int dailyPoints;
  final List<ScoreHistory> scoreHistory;

  UserScore({
    required this.totalScore,
    required this.level,
    required this.dailyPoints,
    required this.scoreHistory,
  });

  factory UserScore.fromJson(Map<String, dynamic> json) {
    List<ScoreHistory> history = [];
    if (json['score_history'] != null) {
      history = (json['score_history'] as List)
          .map((item) => ScoreHistory.fromJson(item))
          .toList();
    }

    return UserScore(
      totalScore: json['total_score'] ?? 0,
      level: json['level'] ?? 1,
      dailyPoints: json['daily_points'] ?? 0,
      scoreHistory: history,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_score': totalScore,
      'level': level,
      'daily_points': dailyPoints,
      'score_history': scoreHistory.map((item) => item.toJson()).toList(),
    };
  }

  // Calculate the score needed for a specific level
  static int scoreForLevel(int level) {
    return (level - 1) * (level - 1) * 100;
  }

  // Calculate the score needed for the next level
  int scoreForNextLevel() {
    return scoreForLevel(level + 1);
  }

  // Calculate the progress towards the next level (0.0 to 1.0)
  double levelProgress() {
    final currentLevelScore = scoreForLevel(level);
    final nextLevelScore = scoreForLevel(level + 1);
    final scoreNeeded = nextLevelScore - currentLevelScore;
    final scoreProgress = totalScore - currentLevelScore;

    return scoreProgress / scoreNeeded;
  }

  // Calculate points needed for the next level
  int pointsToNextLevel() {
    return scoreForNextLevel() - totalScore;
  }
}

class ScoreHistory {
  final DateTime date;
  final String action;
  final int points;

  ScoreHistory({
    required this.date,
    required this.action,
    required this.points,
  });

  factory ScoreHistory.fromJson(Map<String, dynamic> json) {
    return ScoreHistory(
      date: DateTime.parse(json['date']),
      action: json['action'] ?? '',
      points: json['points'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'action': action,
      'points': points,
    };
  }
}
