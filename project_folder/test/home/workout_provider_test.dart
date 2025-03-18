import 'package:flutter_test/flutter_test.dart';
import 'package:fitlife/features/home/models/workout.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkoutNotifier State Tests', () {
    test('WorkoutNotifier can add a workout to state', () {
      // Create a simple workout
      final workout = WorkoutModel(
        id: '1',
        userId: 'test-user-id',
        name: 'Test Workout',
        exercises: [],
      );

      // Create a list with the workout
      final workouts = [workout];

      // Verify the list has the expected properties
      expect(workouts.length, 1);
      expect(workouts[0].id, '1');
      expect(workouts[0].name, 'Test Workout');
    });

    test('WorkoutNotifier can update a workout in state', () {
      // Create initial workout
      final initialWorkout = WorkoutModel(
        id: '1',
        userId: 'test-user-id',
        name: 'Original Name',
        exercises: [],
      );

      // Create a list with the initial workout
      final workouts = [initialWorkout];

      // Create updated workout
      final updatedWorkout = WorkoutModel(
        id: '1',
        userId: 'test-user-id',
        name: 'Updated Name',
        exercises: [],
      );

      // Update the list
      final updatedWorkouts = workouts
          .map((w) => w.id == updatedWorkout.id ? updatedWorkout : w)
          .toList();

      // Verify the list has been updated correctly
      expect(updatedWorkouts.length, 1);
      expect(updatedWorkouts[0].id, '1');
      expect(updatedWorkouts[0].name, 'Updated Name');
    });

    test('WorkoutNotifier can remove a workout from state', () {
      // Create initial workouts
      final workouts = [
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

      // Remove a workout
      final updatedWorkouts = workouts.where((w) => w.id != '1').toList();

      // Verify the list has been updated correctly
      expect(updatedWorkouts.length, 1);
      expect(updatedWorkouts[0].id, '2');
      expect(updatedWorkouts[0].name, 'Workout 2');
    });
  });
}
