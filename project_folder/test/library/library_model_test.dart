import 'package:flutter_test/flutter_test.dart';
import 'package:fitlife/features/library/models/library_item.dart';

void main() {
  group('LibraryItem Tests', () {
    test('LibraryItem.fromJson correctly parses JSON data', () {
      // Arrange
      final json = {
        '_id': '123456',
        'title': 'Proper Squat Form',
        'content': 'This is a guide to proper squat form...',
        'category': 'Exercise Techniques',
        'created_at': '2023-01-15T10:30:00.000Z',
      };

      // Act
      final libraryItem = LibraryItem.fromJson(json);

      // Assert
      expect(libraryItem.id, '123456');
      expect(libraryItem.title, 'Proper Squat Form');
      expect(libraryItem.content, 'This is a guide to proper squat form...');
      expect(libraryItem.category, 'Exercise Techniques');
      expect(libraryItem.createdAt, DateTime.parse('2023-01-15T10:30:00.000Z'));
    });

    test('LibraryItem.fromJson handles MongoDB ObjectId format', () {
      // Arrange
      final json = {
        '_id': {'\$oid': '507f1f77bcf86cd799439011'},
        'title': 'Nutrition Basics',
        'content': 'Understanding macronutrients...',
        'category': 'Nutrition',
        'created_at': {'\$date': '2023-02-20T14:45:00.000Z'},
      };

      // Act
      final libraryItem = LibraryItem.fromJson(json);

      // Assert
      expect(libraryItem.id, '507f1f77bcf86cd799439011');
      expect(libraryItem.title, 'Nutrition Basics');
      expect(libraryItem.content, 'Understanding macronutrients...');
      expect(libraryItem.category, 'Nutrition');
      expect(libraryItem.createdAt, DateTime.parse('2023-02-20T14:45:00.000Z'));
    });

    test('LibraryItem.fromJson handles MongoDB NumberLong date format', () {
      // Arrange
      final json = {
        '_id': '123456',
        'title': 'Recovery Tips',
        'content': 'How to recover properly after workouts...',
        'category': 'Recovery',
        'created_at': {
          '\$date': {'\$numberLong': '1674309600000'}
        },
      };

      // Act
      final libraryItem = LibraryItem.fromJson(json);

      // Assert
      expect(libraryItem.id, '123456');
      expect(libraryItem.title, 'Recovery Tips');
      expect(libraryItem.content, 'How to recover properly after workouts...');
      expect(libraryItem.category, 'Recovery');
      // 1674309600000 milliseconds since epoch is 2023-01-21T12:00:00.000Z
      expect(libraryItem.createdAt.year, 2023);
      expect(libraryItem.createdAt.month, 1);
      expect(libraryItem.createdAt.day, 21);
    });

    test('LibraryItem.toJson correctly converts to JSON', () {
      // Arrange
      final createdAt = DateTime.parse('2023-03-10T09:15:00.000Z');
      final libraryItem = LibraryItem(
        id: '123456',
        title: 'Meal Planning Guide',
        content: 'How to plan your meals for the week...',
        category: 'Nutrition',
        createdAt: createdAt,
      );

      // Act
      final json = libraryItem.toJson();

      // Assert
      expect(json['_id'], '123456');
      expect(json['title'], 'Meal Planning Guide');
      expect(json['content'], 'How to plan your meals for the week...');
      expect(json['category'], 'Nutrition');
      expect(json['created_at'], createdAt.toIso8601String());
    });

    test('LibraryItem.fromJson handles missing fields', () {
      // Arrange
      final json = {
        '_id': '123456',
        // Missing title and content
        'category': 'Miscellaneous',
        // Missing created_at
      };

      // Act
      final libraryItem = LibraryItem.fromJson(json);

      // Assert
      expect(libraryItem.id, '123456');
      expect(libraryItem.title, '');
      expect(libraryItem.content, '');
      expect(libraryItem.category, 'Miscellaneous');
      // Should default to current date (approximately)
      expect(libraryItem.createdAt.year, DateTime.now().year);
      expect(libraryItem.createdAt.month, DateTime.now().month);
      expect(libraryItem.createdAt.day, DateTime.now().day);
    });
  });
}
