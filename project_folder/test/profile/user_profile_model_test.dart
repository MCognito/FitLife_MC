import 'package:flutter_test/flutter_test.dart';
import 'package:fitlife/features/profile/models/user_profile.dart';

void main() {
  group('UserProfile Tests', () {
    test('UserProfile.fromJson correctly parses JSON data', () {
      // Arrange
      final json = {
        '_id': '123456',
        'username': 'testuser',
        'email': 'test@example.com',
        'avatarUrl': 'https://example.com/avatar.jpg',
        'personalInfo': {
          'age': 30,
          'height': 175.5,
          'gender': 'Male',
          'dateOfBirth': '1993-05-15T00:00:00.000Z',
        },
        'fitnessStats': {
          'level': 5,
          'experiencePoints': 1250,
        },
        'preferences': {
          'darkMode': true,
        },
        'createdAt': '2023-01-01T10:00:00.000Z',
        'updatedAt': '2023-03-15T15:30:00.000Z',
      };

      // Act
      final userProfile = UserProfile.fromJson(json);

      // Assert
      expect(userProfile.userId, '123456');
      expect(userProfile.username, 'testuser');
      expect(userProfile.email, 'test@example.com');
      expect(userProfile.avatarUrl, 'https://example.com/avatar.jpg');

      // Personal Info
      expect(userProfile.personalInfo.age, 30);
      expect(userProfile.personalInfo.height, 175.5);
      expect(userProfile.personalInfo.gender, 'Male');
      expect(userProfile.personalInfo.dateOfBirth,
          DateTime.parse('1993-05-15T00:00:00.000Z'));

      // Fitness Stats
      expect(userProfile.fitnessStats.level, 5);
      expect(userProfile.fitnessStats.experiencePoints, 1250);

      // Preferences
      expect(userProfile.preferences.darkMode, true);

      // Dates
      expect(userProfile.createdAt, DateTime.parse('2023-01-01T10:00:00.000Z'));
      expect(userProfile.updatedAt, DateTime.parse('2023-03-15T15:30:00.000Z'));
    });

    test('UserProfile.toJson correctly converts to JSON', () {
      // Arrange
      final userProfile = UserProfile(
        userId: '123456',
        username: 'testuser',
        email: 'test@example.com',
        avatarUrl: 'https://example.com/avatar.jpg',
        personalInfo: UserPersonalInfo(
          age: 30,
          height: 175.5,
          gender: 'Male',
          dateOfBirth: DateTime.parse('1993-05-15T00:00:00.000Z'),
        ),
        fitnessStats: UserFitnessStats(
          level: 5,
          experiencePoints: 1250,
        ),
        preferences: UserPreferences(
          darkMode: true,
        ),
        createdAt: DateTime.parse('2023-01-01T10:00:00.000Z'),
        updatedAt: DateTime.parse('2023-03-15T15:30:00.000Z'),
      );

      // Act
      final json = userProfile.toJson();

      // Assert
      expect(json['userId'], '123456');
      expect(json['username'], 'testuser');
      expect(json['email'], 'test@example.com');
      expect(json['avatarUrl'], 'https://example.com/avatar.jpg');

      // Personal Info
      expect(json['personalInfo']['age'], 30);
      expect(json['personalInfo']['height'], 175.5);
      expect(json['personalInfo']['gender'], 'Male');
      expect(json['personalInfo']['dateOfBirth'], '1993-05-15T00:00:00.000Z');

      // Fitness Stats
      expect(json['fitnessStats']['level'], 5);
      expect(json['fitnessStats']['experiencePoints'], 1250);

      // Preferences
      expect(json['preferences']['darkMode'], true);

      // Dates
      expect(json['createdAt'], '2023-01-01T10:00:00.000Z');
      expect(json['updatedAt'], '2023-03-15T15:30:00.000Z');
    });

    test('UserProfile.copyWith correctly creates a copy with updated fields',
        () {
      // Arrange
      final original = UserProfile(
        userId: '123456',
        username: 'testuser',
        email: 'test@example.com',
        personalInfo: UserPersonalInfo(),
        fitnessStats: UserFitnessStats(),
        preferences: UserPreferences(),
      );

      // Act
      final updated = original.copyWith(
        username: 'newusername',
        email: 'new@example.com',
        personalInfo: UserPersonalInfo(age: 35),
      );

      // Assert
      expect(updated.userId, '123456'); // Unchanged
      expect(updated.username, 'newusername'); // Changed
      expect(updated.email, 'new@example.com'); // Changed
      expect(updated.personalInfo.age, 35); // Changed
      expect(updated.fitnessStats, original.fitnessStats); // Unchanged
      expect(updated.preferences, original.preferences); // Unchanged
    });

    test('UserProfile.fromJson handles missing fields', () {
      // Arrange
      final json = {
        '_id': '123456',
        'username': 'testuser',
        // Missing email and other fields
      };

      // Act
      final userProfile = UserProfile.fromJson(json);

      // Assert
      expect(userProfile.userId, '123456');
      expect(userProfile.username, 'testuser');
      expect(userProfile.email, '');
      expect(userProfile.avatarUrl, null);
      expect(userProfile.personalInfo.age, null);
      expect(userProfile.fitnessStats.level, 1); // Default value
      expect(userProfile.preferences.darkMode, false); // Default value
    });
  });

  group('UserPersonalInfo Tests', () {
    test('UserPersonalInfo.fromJson correctly parses JSON data', () {
      // Arrange
      final json = {
        'age': 30,
        'height': 175.5,
        'gender': 'Male',
        'dateOfBirth': '1993-05-15T00:00:00.000Z',
      };

      // Act
      final personalInfo = UserPersonalInfo.fromJson(json);

      // Assert
      expect(personalInfo.age, 30);
      expect(personalInfo.height, 175.5);
      expect(personalInfo.gender, 'Male');
      expect(
          personalInfo.dateOfBirth, DateTime.parse('1993-05-15T00:00:00.000Z'));
    });

    test('UserPersonalInfo.toJson correctly converts to JSON', () {
      // Arrange
      final personalInfo = UserPersonalInfo(
        age: 30,
        height: 175.5,
        gender: 'Male',
        dateOfBirth: DateTime.parse('1993-05-15T00:00:00.000Z'),
      );

      // Act
      final json = personalInfo.toJson();

      // Assert
      expect(json['age'], 30);
      expect(json['height'], 175.5);
      expect(json['gender'], 'Male');
      expect(json['dateOfBirth'], '1993-05-15T00:00:00.000Z');
    });

    test(
        'UserPersonalInfo.copyWith correctly creates a copy with updated fields',
        () {
      // Arrange
      final original = UserPersonalInfo(
        age: 30,
        height: 175.5,
        gender: 'Male',
      );

      // Act
      final updated = original.copyWith(
        age: 31,
        gender: 'Female',
      );

      // Assert
      expect(updated.age, 31); // Changed
      expect(updated.height, 175.5); // Unchanged
      expect(updated.gender, 'Female'); // Changed
    });
  });

  group('UserFitnessStats Tests', () {
    test('UserFitnessStats.fromJson correctly parses JSON data', () {
      // Arrange
      final json = {
        'level': 5,
        'experiencePoints': 1250,
      };

      // Act
      final fitnessStats = UserFitnessStats.fromJson(json);

      // Assert
      expect(fitnessStats.level, 5);
      expect(fitnessStats.experiencePoints, 1250);
    });

    test('UserFitnessStats.toJson correctly converts to JSON', () {
      // Arrange
      final fitnessStats = UserFitnessStats(
        level: 5,
        experiencePoints: 1250,
      );

      // Act
      final json = fitnessStats.toJson();

      // Assert
      expect(json['level'], 5);
      expect(json['experiencePoints'], 1250);
    });
  });

  group('UserPreferences Tests', () {
    test('UserPreferences.fromJson correctly parses JSON data', () {
      // Arrange
      final json = {
        'darkMode': true,
      };

      // Act
      final preferences = UserPreferences.fromJson(json);

      // Assert
      expect(preferences.darkMode, true);
    });

    test('UserPreferences.toJson correctly converts to JSON', () {
      // Arrange
      final preferences = UserPreferences(
        darkMode: true,
      );

      // Act
      final json = preferences.toJson();

      // Assert
      expect(json['darkMode'], true);
    });
  });
}
