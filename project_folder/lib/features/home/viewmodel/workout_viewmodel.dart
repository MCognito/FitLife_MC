import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout.dart';
import '../service/workout_service.dart';

/// Provider for the WorkoutViewModel
final workoutViewModelProvider =
    ChangeNotifierProvider<WorkoutViewModel>((ref) {
  return WorkoutViewModel();
});

/// ViewModel for managing workout data and operations
///
/// This class follows the MVVM pattern by:
/// - Encapsulating business logic related to workouts
/// - Providing state management through ChangeNotifier
/// - Abstracting service calls from the UI layer
class WorkoutViewModel extends ChangeNotifier {
  final WorkoutService _workoutService = WorkoutService();

  List<WorkoutModel> _workouts = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<WorkoutModel> get workouts => _workouts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasWorkouts => _workouts.isNotEmpty;
  bool get canAddMoreWorkouts => _workouts.length < 7;

  /// Loads workouts for a specific user
  Future<void> loadWorkouts(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _workouts = await _workoutService.getWorkouts(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to load workouts. Please try again.";
      _isLoading = false;
      _workouts = [];
      notifyListeners();
      print("Error loading workouts: $e");
    }
  }

  /// Adds a new workout
  Future<bool> addWorkout(WorkoutModel workout) async {
    if (_workouts.length >= 7) {
      _errorMessage = "You cannot create more than 7 workouts.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final createdWorkout = await _workoutService.addWorkout(workout);
      _workouts = [..._workouts, createdWorkout];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Failed to add workout. Please try again.";
      _isLoading = false;
      notifyListeners();
      print("Error adding workout: $e");
      return false;
    }
  }

  /// Updates an existing workout
  Future<bool> updateWorkout(WorkoutModel workout) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _workoutService.updateWorkout(workout);
      _workouts =
          _workouts.map((w) => w.id == workout.id ? workout : w).toList();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Failed to update workout. Please try again.";
      _isLoading = false;
      notifyListeners();
      print("Error updating workout: $e");
      return false;
    }
  }

  /// Deletes a workout
  Future<bool> deleteWorkout(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _workoutService.deleteWorkout(id);
      _workouts = _workouts.where((w) => w.id != id).toList();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Failed to delete workout. Please try again.";
      _isLoading = false;
      notifyListeners();
      print("Error deleting workout: $e");
      return false;
    }
  }

  /// Clears any error messages
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
