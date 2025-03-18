import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fitlife/features/home/service/workout_service.dart';
import 'package:fitlife/features/home/models/workout.dart';
import 'package:fitlife/features/authentication/service/token_manager.dart';

// Create mock classes manually
class MockClient extends Mock implements http.Client {}

class MockTokenManager extends Mock implements TokenManager {
  @override
  Future<String> getToken() async => 'test-token';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkoutService Tests', () {
    late MockClient mockClient;
    late MockTokenManager mockTokenManager;
    late WorkoutService workoutService;
    final baseUrl =
        "http://localhost:5000/api/workouts"; // Use a fixed URL for testing

    setUp(() {
      mockClient = MockClient();
      mockTokenManager = MockTokenManager();
      workoutService = WorkoutService();

      // No need to set up mock responses for getToken since we've overridden the method
    });

    test('getWorkouts returns list of workouts when successful', () async {
      // Arrange
      final userId = 'user123';
      final testToken = 'test-token';

      when(mockClient.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $testToken',
        },
      )).thenAnswer((_) async => http.Response(
            jsonEncode([
              {
                '_id': '123',
                'user_id': userId,
                'name': 'Chest Day',
                'exercises': [
                  {
                    'name': 'Bench Press',
                    'sets': [
                      {'reps': 10, 'weight': 135.0},
                    ],
                  },
                ],
              },
            ]),
            200,
          ));

      // Act
      final workouts = await workoutService.getWorkouts(userId);

      // Assert
      expect(workouts.length, 1);
      expect(workouts[0].id, '123');
      expect(workouts[0].name, 'Chest Day');
      expect(workouts[0].exercises.length, 1);
      expect(workouts[0].exercises[0].name, 'Bench Press');
      expect(workouts[0].exercises[0].sets.length, 1);
      expect(workouts[0].exercises[0].sets[0].reps, 10);
      expect(workouts[0].exercises[0].sets[0].weight, 135.0);
    });

    test('addWorkout returns created workout when successful', () async {
      // Arrange
      final testToken = 'test-token';
      final workout = WorkoutModel(
        id: '',
        userId: 'user123',
        name: 'New Workout',
        exercises: [
          ExerciseModel(
            name: 'Push-ups',
            sets: [SetModel(reps: 15, weight: 0)],
          ),
        ],
      );

      when(mockClient.post(
        Uri.parse('$baseUrl'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $testToken',
        },
        body: jsonEncode(workout.toJson()),
      )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'workout': {
                '_id': 'new123',
                'user_id': 'user123',
                'name': 'New Workout',
                'exercises': [
                  {
                    'name': 'Push-ups',
                    'sets': [
                      {'reps': 15, 'weight': 0},
                    ],
                  },
                ],
              }
            }),
            201,
          ));

      // Act
      final createdWorkout = await workoutService.addWorkout(workout);

      // Assert
      expect(createdWorkout.id, 'new123');
      expect(createdWorkout.name, 'New Workout');
      expect(createdWorkout.exercises.length, 1);
      expect(createdWorkout.exercises[0].name, 'Push-ups');
    });

    test('updateWorkout completes successfully when API call succeeds',
        () async {
      // Arrange
      final testToken = 'test-token';
      final workout = WorkoutModel(
        id: 'workout123',
        userId: 'user123',
        name: 'Updated Workout',
        exercises: [],
      );

      when(mockClient.put(
        Uri.parse('$baseUrl/${workout.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $testToken',
        },
        body: jsonEncode(workout.toJson()),
      )).thenAnswer((_) async => http.Response(
            jsonEncode({'success': true}),
            200,
          ));

      // Act & Assert
      expect(() async => await workoutService.updateWorkout(workout),
          returnsNormally);
    });

    test('deleteWorkout completes successfully when API call succeeds',
        () async {
      // Arrange
      final testToken = 'test-token';
      final workoutId = 'workout123';

      when(mockClient.delete(
        Uri.parse('$baseUrl/$workoutId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $testToken',
        },
      )).thenAnswer((_) async => http.Response(
            jsonEncode({'success': true}),
            200,
          ));

      // Act & Assert
      expect(() async => await workoutService.deleteWorkout(workoutId),
          returnsNormally);
    });

    test('getWorkouts throws exception when API call fails', () async {
      // Arrange
      final userId = 'user123';
      final testToken = 'test-token';

      when(mockClient.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $testToken',
        },
      )).thenAnswer((_) async => http.Response('Server error', 500));

      // Act & Assert
      expect(() async => await workoutService.getWorkouts(userId),
          throwsException);
    });

    test('addWorkout throws exception when API call fails', () async {
      // Arrange
      final testToken = 'test-token';
      final workout = WorkoutModel(
        id: '',
        userId: 'user123',
        name: 'New Workout',
        exercises: [],
      );

      when(mockClient.post(
        Uri.parse('$baseUrl'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $testToken',
        },
        body: jsonEncode(workout.toJson()),
      )).thenAnswer((_) async => http.Response('Bad request', 400));

      // Act & Assert
      expect(() async => await workoutService.addWorkout(workout),
          throwsException);
    });

    test('updateWorkout throws exception when API call fails', () async {
      // Arrange
      final testToken = 'test-token';
      final workout = WorkoutModel(
        id: 'workout123',
        userId: 'user123',
        name: 'Updated Workout',
        exercises: [],
      );

      when(mockClient.put(
        Uri.parse('$baseUrl/${workout.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $testToken',
        },
        body: jsonEncode(workout.toJson()),
      )).thenAnswer((_) async => http.Response('Not found', 404));

      // Act & Assert
      expect(() async => await workoutService.updateWorkout(workout),
          throwsException);
    });

    test('deleteWorkout throws exception when API call fails', () async {
      // Arrange
      final testToken = 'test-token';
      final workoutId = 'workout123';

      when(mockClient.delete(
        Uri.parse('$baseUrl/$workoutId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $testToken',
        },
      )).thenAnswer((_) async => http.Response('Not found', 404));

      // Act & Assert
      expect(() async => await workoutService.deleteWorkout(workoutId),
          throwsException);
    });
  });
}
