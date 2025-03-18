import 'package:flutter_test/flutter_test.dart';
import 'package:fitlife/features/home/models/workout.dart';
import 'package:fitlife/features/home/viewmodel/workout_viewmodel.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fitlife/features/home/service/workout_service.dart';

@GenerateMocks([WorkoutService])
import 'workout_test.mocks.dart';

// Create a testable version of WorkoutViewModel that allows injecting the service
class TestableWorkoutViewModel extends WorkoutViewModel {
  final WorkoutService workoutService;

  TestableWorkoutViewModel(this.workoutService);

  @override
  WorkoutService get _workoutService => workoutService;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Workout Functionality', () {
    late TestableWorkoutViewModel viewModel;
    late MockWorkoutService mockWorkoutService;

    setUp(() {
      mockWorkoutService = MockWorkoutService();
      viewModel = TestableWorkoutViewModel(mockWorkoutService);
    });

    test('Creating a new workout adds it to the list', () async {
      // Arrange
      final userId = 'user123';
      final newWorkout = WorkoutModel(
        id: '',
        userId: userId,
        name: 'New Workout',
        exercises: [],
      );

      final createdWorkout = WorkoutModel(
        id: 'workout1',
        userId: userId,
        name: 'New Workout',
        exercises: [],
      );

      when(mockWorkoutService.addWorkout(newWorkout))
          .thenAnswer((_) async => createdWorkout);

      // Act
      final result = await viewModel.addWorkout(newWorkout);

      // Assert
      expect(result, true);
      expect(viewModel.workouts.length, 1);
      expect(viewModel.workouts.first.id, 'workout1');
      expect(viewModel.workouts.first.name, 'New Workout');
    });

    test('Deleting a workout removes it from the list', () async {
      // Arrange
      final userId = 'user123';
      final workoutId = 'workout1';

      // Setup initial state with one workout
      final initialWorkouts = [
        WorkoutModel(
          id: workoutId,
          userId: userId,
          name: 'Test Workout',
          exercises: [],
        ),
      ];

      when(mockWorkoutService.getWorkouts(userId))
          .thenAnswer((_) async => initialWorkouts);

      await viewModel.loadWorkouts(userId);

      when(mockWorkoutService.deleteWorkout(workoutId))
          .thenAnswer((_) async => true);

      // Act
      final result = await viewModel.deleteWorkout(workoutId);

      // Assert
      expect(result, true);
      expect(viewModel.workouts.length, 0);
    });

    test('Updating a workout changes its properties', () async {
      // Arrange
      final userId = 'user123';
      final workoutId = 'workout1';

      // Setup initial state with one workout
      final initialWorkouts = [
        WorkoutModel(
          id: workoutId,
          userId: userId,
          name: 'Original Name',
          exercises: [],
        ),
      ];

      when(mockWorkoutService.getWorkouts(userId))
          .thenAnswer((_) async => initialWorkouts);

      await viewModel.loadWorkouts(userId);

      final updatedWorkout = WorkoutModel(
        id: workoutId,
        userId: userId,
        name: 'Updated Name',
        exercises: [
          ExerciseModel(
            name: 'New Exercise',
            sets: [SetModel(reps: 10, weight: 100)],
          ),
        ],
      );

      when(mockWorkoutService.updateWorkout(updatedWorkout))
          .thenAnswer((_) async => true);

      // Act
      final result = await viewModel.updateWorkout(updatedWorkout);

      // Assert
      expect(result, true);
      expect(viewModel.workouts.length, 1);
      expect(viewModel.workouts.first.name, 'Updated Name');
      expect(viewModel.workouts.first.exercises.length, 1);
      expect(viewModel.workouts.first.exercises.first.name, 'New Exercise');
    });

    test('Loading workouts populates the list', () async {
      // Arrange
      final userId = 'user123';
      final workouts = [
        WorkoutModel(
          id: 'workout1',
          userId: userId,
          name: 'Workout 1',
          exercises: [],
        ),
        WorkoutModel(
          id: 'workout2',
          userId: userId,
          name: 'Workout 2',
          exercises: [],
        ),
      ];

      when(mockWorkoutService.getWorkouts(userId))
          .thenAnswer((_) async => workouts);

      // Act
      await viewModel.loadWorkouts(userId);

      // Assert
      expect(viewModel.workouts.length, 2);
      expect(viewModel.workouts[0].id, 'workout1');
      expect(viewModel.workouts[1].id, 'workout2');
    });

    test('Error handling when loading workouts fails', () async {
      // Arrange
      final userId = 'user123';

      when(mockWorkoutService.getWorkouts(userId))
          .thenThrow(Exception('Network error'));

      // Act
      await viewModel.loadWorkouts(userId);

      // Assert
      expect(viewModel.workouts.length, 0);
      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.isLoading, false);
    });

    test('Workout limit prevents adding more than 7 workouts', () async {
      // Arrange
      final userId = 'user123';

      // Create 7 workouts (maximum allowed)
      final workouts = List.generate(
        7,
        (index) => WorkoutModel(
          id: 'workout$index',
          userId: userId,
          name: 'Workout $index',
          exercises: [],
        ),
      );

      when(mockWorkoutService.getWorkouts(userId))
          .thenAnswer((_) async => workouts);

      await viewModel.loadWorkouts(userId);

      final newWorkout = WorkoutModel(
        id: '',
        userId: userId,
        name: 'One Too Many',
        exercises: [],
      );

      // Act
      final result = await viewModel.addWorkout(newWorkout);

      // Assert
      expect(result, false);
      expect(viewModel.workouts.length, 7);
      expect(viewModel.errorMessage,
          contains('cannot create more than 7 workouts'));
    });
  });
}
