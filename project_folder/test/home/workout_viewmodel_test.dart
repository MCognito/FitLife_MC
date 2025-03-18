import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fitlife/features/home/viewmodel/workout_viewmodel.dart';
import 'package:fitlife/features/home/service/workout_service.dart';
import 'package:fitlife/features/home/models/workout.dart';

class MockWorkoutService extends Mock implements WorkoutService {}

// Create a testable version of WorkoutViewModel that allows injecting the service
class TestableWorkoutViewModel extends WorkoutViewModel {
  final WorkoutService workoutService;

  TestableWorkoutViewModel(this.workoutService);

  @override
  WorkoutService get _workoutService => workoutService;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkoutViewModel Tests', () {
    late MockWorkoutService mockService;
    late TestableWorkoutViewModel viewModel;
    late List<WorkoutModel> testWorkouts;

    setUp(() {
      mockService = MockWorkoutService();
      viewModel = TestableWorkoutViewModel(mockService);

      // Create test data
      testWorkouts = [
        WorkoutModel(
          id: '1',
          userId: 'test-user-id',
          name: 'Chest Day',
          exercises: [
            ExerciseModel(
              name: 'Bench Press',
              sets: [
                SetModel(reps: 10, weight: 135),
              ],
            ),
          ],
        ),
        WorkoutModel(
          id: '2',
          userId: 'test-user-id',
          name: 'Leg Day',
          exercises: [
            ExerciseModel(
              name: 'Squats',
              sets: [
                SetModel(reps: 10, weight: 185),
              ],
            ),
          ],
        ),
      ];
    });

    test('loadWorkouts updates workouts when successful', () async {
      // Arrange
      when(mockService.getWorkouts('test-user-id'))
          .thenAnswer((_) async => testWorkouts);

      // Act
      await viewModel.loadWorkouts('test-user-id');

      // Assert
      expect(viewModel.workouts.length, 2);
      expect(viewModel.workouts[0].id, '1');
      expect(viewModel.workouts[0].name, 'Chest Day');
      expect(viewModel.workouts[1].id, '2');
      expect(viewModel.workouts[1].name, 'Leg Day');
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
    });

    test('loadWorkouts sets error when API call fails', () async {
      // Arrange
      when(mockService.getWorkouts('test-user-id'))
          .thenThrow(Exception('Network error'));

      // Act
      await viewModel.loadWorkouts('test-user-id');

      // Assert
      expect(viewModel.workouts, isEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, isNotNull);
    });

    test('addWorkout adds workout when successful', () async {
      // Arrange
      final newWorkout = WorkoutModel(
        id: '',
        userId: 'test-user-id',
        name: 'New Workout',
        exercises: [],
      );

      final createdWorkout = WorkoutModel(
        id: '3',
        userId: 'test-user-id',
        name: 'New Workout',
        exercises: [],
      );

      when(mockService.addWorkout(newWorkout))
          .thenAnswer((_) async => createdWorkout);

      // Act
      final result = await viewModel.addWorkout(newWorkout);

      // Assert
      expect(result, true);
      expect(viewModel.workouts.length, 1);
      expect(viewModel.workouts[0].id, '3');
      expect(viewModel.workouts[0].name, 'New Workout');
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
    });

    test('updateWorkout updates workout when successful', () async {
      // Arrange
      // First, set up initial state with a workout
      final initialWorkout = WorkoutModel(
        id: '1',
        userId: 'test-user-id',
        name: 'Initial Workout',
        exercises: [],
      );

      // Set up the initial state
      when(mockService.getWorkouts('test-user-id'))
          .thenAnswer((_) async => [initialWorkout]);
      await viewModel.loadWorkouts('test-user-id');

      // Now set up the update
      final updatedWorkout = WorkoutModel(
        id: '1',
        userId: 'test-user-id',
        name: 'Updated Workout',
        exercises: [
          ExerciseModel(
            name: 'New Exercise',
            sets: [SetModel(reps: 10, weight: 100)],
          ),
        ],
      );

      when(mockService.updateWorkout(updatedWorkout))
          .thenAnswer((_) async => true);

      // Act
      final result = await viewModel.updateWorkout(updatedWorkout);

      // Assert
      expect(result, true);
      expect(viewModel.workouts.length, 1);
      expect(viewModel.workouts[0].id, '1');
      expect(viewModel.workouts[0].name, 'Updated Workout');
      expect(viewModel.workouts[0].exercises.length, 1);
      expect(viewModel.workouts[0].exercises[0].name, 'New Exercise');
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
    });

    test('deleteWorkout removes workout when successful', () async {
      // Arrange
      // First, set up initial state with workouts
      final initialWorkouts = [
        WorkoutModel(
          id: '1',
          userId: 'test-user-id',
          name: 'Workout 1',
          exercises: [],
        ),
        WorkoutModel(
          id: '2',
          userId: 'test-user-id',
          name: 'Workout 2',
          exercises: [],
        ),
      ];

      // Set up the initial state
      when(mockService.getWorkouts('test-user-id'))
          .thenAnswer((_) async => initialWorkouts);
      await viewModel.loadWorkouts('test-user-id');

      // Now set up the delete
      when(mockService.deleteWorkout('1')).thenAnswer((_) async => true);

      // Act
      final result = await viewModel.deleteWorkout('1');

      // Assert
      expect(result, true);
      expect(viewModel.workouts.length, 1);
      expect(viewModel.workouts[0].id, '2');
      expect(viewModel.workouts[0].name, 'Workout 2');
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
    });

    test('clearError clears the error message', () async {
      // Arrange - set an error first
      when(mockService.getWorkouts('test-user-id'))
          .thenThrow(Exception('Network error'));

      // Trigger an error
      await viewModel.loadWorkouts('test-user-id');
      expect(viewModel.errorMessage, isNotNull); // Verify error is set

      // Act
      viewModel.clearError();

      // Assert
      expect(viewModel.errorMessage, null);
    });
  });
}
