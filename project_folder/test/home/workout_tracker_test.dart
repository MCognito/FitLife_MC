import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlife/features/home/models/workout.dart';
import 'package:fitlife/features/home/providers/workout_provider.dart';
import 'package:fitlife/features/home/view/pages/workout_tracker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Test data
  final testWorkouts = [
    WorkoutModel(
      id: '1',
      userId: 'test-user',
      name: 'Chest Day',
      exercises: [
        ExerciseModel(
          name: 'Bench Press',
          sets: [SetModel(reps: 10, weight: 135)],
        ),
      ],
    ),
    WorkoutModel(
      id: '2',
      userId: 'test-user',
      name: 'Leg Day',
      exercises: [
        ExerciseModel(
          name: 'Squats',
          sets: [SetModel(reps: 10, weight: 185)],
        ),
      ],
    ),
  ];

  group('WorkoutTracker Widget Tests', () {
    testWidgets('displays workouts when available',
        (WidgetTester tester) async {
      // Build our widget with ProviderScope
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutProvider.overrideWith(
                (_) => WorkoutNotifier('test-user', _)..state = testWorkouts),
          ],
          child: MaterialApp(
            home: WorkoutTracker(),
          ),
        ),
      );

      // Verify that the workouts are displayed
      expect(find.text('Chest Day'), findsOneWidget);
      expect(find.text('Leg Day'), findsOneWidget);
    });

    testWidgets('displays empty state when no workouts',
        (WidgetTester tester) async {
      // Build our widget with ProviderScope
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutProvider.overrideWith(
                (_) => WorkoutNotifier('test-user', _)..state = []),
          ],
          child: MaterialApp(
            home: WorkoutTracker(),
          ),
        ),
      );

      // Verify that the empty state message is displayed
      expect(find.text('No workouts found'), findsOneWidget);
    });

    testWidgets('has a FloatingActionButton', (WidgetTester tester) async {
      // Build our widget with ProviderScope
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutProvider
                .overrideWith((_) => WorkoutNotifier('test-user', _)),
          ],
          child: MaterialApp(
            home: WorkoutTracker(),
          ),
        ),
      );

      // Verify that the FloatingActionButton is present
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
