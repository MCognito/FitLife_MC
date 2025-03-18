import 'package:flutter_test/flutter_test.dart';
import 'package:fitlife/features/home/models/workout.dart';

void main() {
  group('WorkoutModel Tests', () {
    test('WorkoutModel.fromJson correctly parses JSON data', () {
      // Arrange
      final json = {
        '_id': '123456',
        'user_id': 'user123',
        'name': 'Chest Day',
        'exercises': [
          {
            'name': 'Bench Press',
            'sets': [
              {'reps': 10, 'weight': 135.0},
              {'reps': 8, 'weight': 155.0},
            ],
          },
          {
            'name': 'Incline Press',
            'sets': [
              {'reps': 10, 'weight': 115.0},
            ],
          },
        ],
      };

      // Act
      final workout = WorkoutModel.fromJson(json);

      // Assert
      expect(workout.id, '123456');
      expect(workout.userId, 'user123');
      expect(workout.name, 'Chest Day');
      expect(workout.exercises.length, 2);

      // Check first exercise
      expect(workout.exercises[0].name, 'Bench Press');
      expect(workout.exercises[0].sets.length, 2);
      expect(workout.exercises[0].sets[0].reps, 10);
      expect(workout.exercises[0].sets[0].weight, 135.0);
      expect(workout.exercises[0].sets[1].reps, 8);
      expect(workout.exercises[0].sets[1].weight, 155.0);

      // Check second exercise
      expect(workout.exercises[1].name, 'Incline Press');
      expect(workout.exercises[1].sets.length, 1);
      expect(workout.exercises[1].sets[0].reps, 10);
      expect(workout.exercises[1].sets[0].weight, 115.0);
    });

    test('WorkoutModel.fromJson handles MongoDB ObjectId format', () {
      // Arrange
      final json = {
        '_id': {'\$oid': '507f1f77bcf86cd799439011'},
        'user_id': {'\$oid': '507f1f77bcf86cd799439012'},
        'name': 'Leg Day',
        'exercises': [],
      };

      // Act
      final workout = WorkoutModel.fromJson(json);

      // Assert
      expect(workout.id, '507f1f77bcf86cd799439011');
      expect(workout.userId, '507f1f77bcf86cd799439012');
      expect(workout.name, 'Leg Day');
      expect(workout.exercises.length, 0);
    });

    test('WorkoutModel.toJson correctly converts to JSON', () {
      // Arrange
      final workout = WorkoutModel(
        id: '123456',
        userId: 'user123',
        name: 'Back Day',
        exercises: [
          ExerciseModel(
            name: 'Pull-ups',
            sets: [
              SetModel(reps: 12, weight: 0),
              SetModel(reps: 10, weight: 0),
            ],
          ),
        ],
      );

      // Act
      final json = workout.toJson();

      // Assert
      expect(json['_id'], '123456');
      expect(json['user_id'], 'user123');
      expect(json['name'], 'Back Day');
      expect(json['exercises'].length, 1);
      expect(json['exercises'][0]['name'], 'Pull-ups');
      expect(json['exercises'][0]['sets'].length, 2);
      expect(json['exercises'][0]['sets'][0]['reps'], 12);
      expect(json['exercises'][0]['sets'][0]['weight'], 0);
      expect(json['exercises'][0]['sets'][1]['reps'], 10);
      expect(json['exercises'][0]['sets'][1]['weight'], 0);
    });
  });

  group('ExerciseModel Tests', () {
    test('ExerciseModel.fromJson correctly parses JSON data', () {
      // Arrange
      final json = {
        '_id': '123',
        'name': 'Squats',
        'sets': [
          {'reps': 15, 'weight': 185.0},
          {'reps': 12, 'weight': 205.0},
        ],
      };

      // Act
      final exercise = ExerciseModel.fromJson(json);

      // Assert
      expect(exercise.id, '123');
      expect(exercise.name, 'Squats');
      expect(exercise.sets.length, 2);
      expect(exercise.sets[0].reps, 15);
      expect(exercise.sets[0].weight, 185.0);
      expect(exercise.sets[1].reps, 12);
      expect(exercise.sets[1].weight, 205.0);
    });

    test('ExerciseModel.toJson correctly converts to JSON', () {
      // Arrange
      final exercise = ExerciseModel(
        id: '123',
        name: 'Deadlift',
        sets: [
          SetModel(reps: 5, weight: 225.0),
          SetModel(reps: 5, weight: 245.0),
        ],
      );

      // Act
      final json = exercise.toJson();

      // Assert
      expect(json['_id'], '123');
      expect(json['name'], 'Deadlift');
      expect(json['sets'].length, 2);
      expect(json['sets'][0]['reps'], 5);
      expect(json['sets'][0]['weight'], 225.0);
      expect(json['sets'][1]['reps'], 5);
      expect(json['sets'][1]['weight'], 245.0);
    });
  });

  group('SetModel Tests', () {
    test('SetModel.fromJson correctly parses JSON data', () {
      // Arrange
      final json = {
        '_id': '123',
        'reps': 10,
        'weight': 135.0,
      };

      // Act
      final set = SetModel.fromJson(json);

      // Assert
      expect(set.id, '123');
      expect(set.reps, 10);
      expect(set.weight, 135.0);
    });

    test('SetModel.fromJson handles MongoDB NumberInt and NumberDouble formats',
        () {
      // Arrange
      final json = {
        'reps': {'\$numberInt': '12'},
        'weight': {'\$numberDouble': '145.5'},
      };

      // Act
      final set = SetModel.fromJson(json);

      // Assert
      expect(set.reps, 12);
      expect(set.weight, 145.5);
    });

    test('SetModel.toJson correctly converts to JSON', () {
      // Arrange
      final set = SetModel(
        id: '123',
        reps: 8,
        weight: 155.0,
      );

      // Act
      final json = set.toJson();

      // Assert
      expect(json['_id'], '123');
      expect(json['reps'], 8);
      expect(json['weight'], 155.0);
    });
  });
}
