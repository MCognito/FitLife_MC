import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout.dart';
import '../service/workout_service.dart';
import '../../../features/authentication/providers/user_provider.dart';

/// Provider that manages the user's workout data
/// This acts as the ViewModel in the MVVM architecture
final workoutProvider =
    StateNotifierProvider<WorkoutNotifier, List<WorkoutModel>>((ref) {
  final userId = ref.watch(userIdProvider);
  return WorkoutNotifier(userId, ref);
});

/// WorkoutNotifier manages the state and operations for workouts
/// It handles loading, adding, updating, and deleting workouts
class WorkoutNotifier extends StateNotifier<List<WorkoutModel>> {
  final String userId;
  final Ref ref;
  final WorkoutService _apiService = WorkoutService();

  WorkoutNotifier(this.userId, this.ref) : super([]) {
    // Initialize by loading the user's workouts
    loadWorkouts(userId);
  }

  // Loads all workouts for a specific user
  // Updates the state with the fetched workouts
  Future<void> loadWorkouts(String userId) async {
    try {
      print("Loading workouts");

      state = await _apiService.getWorkouts(userId);
      print("Loaded ${state.length} workouts");
    } catch (e) {
      print("Error fetching workouts: $e");
      state = []; // Reset state on error to prevent UI issues
    }
  }

  // Adds a new workout to the database and updates the local state
  // Returns the created workout with its server-generated ID
  Future<void> addWorkout(WorkoutModel workout) async {
    try {
      // Send the workout to the server and get the updated workout with ID
      final createdWorkout = await _apiService.addWorkout(workout);

      // Add the created workout to the state
      state = [...state, createdWorkout];

      print("Workout added successfully with ID: ${createdWorkout.id}");
    } catch (e) {
      print("Error adding workout: $e");
      // Consider showing an error message to the user here
    }
  }

  // Updates an existing workout in the database and local state
  Future<void> updateWorkout(WorkoutModel workout) async {
    try {
      await _apiService.updateWorkout(workout);

      // Update the workout in our local state
      state = state.map((w) => w.id == workout.id ? workout : w).toList();

    } catch (e) {
      print("Error updating workout: $e");
      // Consider showing an error message to the user here
    }
  }

  // Deletes a workout from the database and removes it from local state
  Future<void> deleteWorkout(String id) async {
    try {
      await _apiService.deleteWorkout(id);

      // Remove the workout from our local state
      state = state.where((w) => w.id != id).toList();

      print("Workout deleted successfully: $id");
    } catch (e) {
      print("Error deleting workout: $e");
      // Consider showing an error message to the user here
    }
  }

  // Refreshes the workout list from the server
  // Useful after navigation or when data might have changed
  Future<void> refreshWorkouts() async {
    await loadWorkouts(userId);
  }
}
