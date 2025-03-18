class UserProfile {
  final String userId;
  final String username;
  final String email;
  final String? avatarUrl;
  final UserPersonalInfo personalInfo;
  final UserFitnessStats fitnessStats;
  final UserPreferences preferences;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.userId,
    required this.username,
    required this.email,
    this.avatarUrl,
    required this.personalInfo,
    required this.fitnessStats,
    required this.preferences,
    this.createdAt,
    this.updatedAt,
  });

  // Create from JSON (for API responses)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['_id'] ?? json['userId'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'],
      personalInfo: UserPersonalInfo.fromJson(json['personalInfo'] ?? {}),
      fitnessStats: UserFitnessStats.fromJson(json['fitnessStats'] ?? {}),
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Convert to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'personalInfo': personalInfo.toJson(),
      'fitnessStats': fitnessStats.toJson(),
      'preferences': preferences.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  UserProfile copyWith({
    String? userId,
    String? username,
    String? email,
    String? avatarUrl,
    UserPersonalInfo? personalInfo,
    UserFitnessStats? fitnessStats,
    UserPreferences? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      personalInfo: personalInfo ?? this.personalInfo,
      fitnessStats: fitnessStats ?? this.fitnessStats,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserPersonalInfo {
  final int? age;
  final double? height; // in cm
  final String? gender;
  final DateTime? dateOfBirth;

  UserPersonalInfo({
    this.age,
    this.height,
    this.gender,
    this.dateOfBirth,
  });

  factory UserPersonalInfo.fromJson(Map<String, dynamic> json) {
    return UserPersonalInfo(
      age: json['age'],
      height: json['height']?.toDouble(),
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'height': height,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
    };
  }

  UserPersonalInfo copyWith({
    int? age,
    double? height,
    String? gender,
    DateTime? dateOfBirth,
  }) {
    return UserPersonalInfo(
      age: age ?? this.age,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}

class UserFitnessStats {
  final int level;
  final int experiencePoints;

  UserFitnessStats({
    this.level = 1,
    this.experiencePoints = 0,
  });

  factory UserFitnessStats.fromJson(Map<String, dynamic> json) {
    return UserFitnessStats(
      level: json['level'] ?? 1,
      experiencePoints: json['experiencePoints'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'experiencePoints': experiencePoints,
    };
  }

  UserFitnessStats copyWith({
    int? level,
    int? experiencePoints,
  }) {
    return UserFitnessStats(
      level: level ?? this.level,
      experiencePoints: experiencePoints ?? this.experiencePoints,
    );
  }
}

class UserPreferences {
  final bool darkMode;
  final bool? notifications;
  final bool? soundEffects;
  final String language;
  final String unitSystem; // 'metric' or 'imperial'
  final bool publicProfile; // Whether the profile is public for leaderboards

  UserPreferences({
    this.darkMode = false,
    this.notifications,
    this.soundEffects,
    this.language = 'English',
    this.unitSystem = 'Metric',
    this.publicProfile = false, // Default to private
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      darkMode: json['darkMode'] ?? false,
      notifications: json['notifications'],
      soundEffects: json['soundEffects'],
      language: json['language'] ?? 'English',
      unitSystem: json['unitSystem'] ?? 'Metric',
      publicProfile: json['publicProfile'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'darkMode': darkMode,
      'language': language,
      'unitSystem': unitSystem,
      'publicProfile': publicProfile,
    };

    if (notifications != null) {
      data['notifications'] = notifications;
    }
    if (soundEffects != null) {
      data['soundEffects'] = soundEffects;
    }

    return data;
  }

  // Create a copy with updated fields
  UserPreferences copyWith({
    bool? darkMode,
    bool? notifications,
    bool? soundEffects,
    String? language,
    String? unitSystem,
    bool? publicProfile,
  }) {
    return UserPreferences(
      darkMode: darkMode ?? this.darkMode,
      notifications: notifications ?? this.notifications,
      soundEffects: soundEffects ?? this.soundEffects,
      language: language ?? this.language,
      unitSystem: unitSystem ?? this.unitSystem,
      publicProfile: publicProfile ?? this.publicProfile,
    );
  }
}
