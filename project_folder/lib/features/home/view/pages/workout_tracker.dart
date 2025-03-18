import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/workout.dart';
import 'workout_details.dart';
import 'add_new_workout.dart';
import '../../providers/workout_provider.dart';
import '../../../../features/authentication/providers/user_provider.dart';

class WorkoutTracker extends ConsumerStatefulWidget {
  const WorkoutTracker({super.key});

  @override
  ConsumerState<WorkoutTracker> createState() => _WorkoutTrackerState();
}

class _WorkoutTrackerState extends ConsumerState<WorkoutTracker> {
  @override
  void initState() {
    super.initState();
    // Workouts are now loaded automatically by the provider
  }

  // Navigate to add workout page and refresh on return
  Future<void> _navigateToAddWorkout() async {
    final userId = ref.read(userIdProvider);
    final workouts = ref.read(workoutProvider);

    if (workouts.length >= 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You cannot create more than 7 workouts.')),
      );
      return;
    }

    // Navigate to add workout page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNewWorkoutPage(
          onAddWorkout: _addWorkout,
          currentWorkoutCount: workouts.length,
          userId: userId,
        ),
      ),
    );

    // Refresh workouts when returning from add workout page
    if (result == true) {
      await ref.read(workoutProvider.notifier).refreshWorkouts();
    }
  }

  // Add a new workout
  Future<void> _addWorkout(WorkoutModel workout) async {
    await ref.read(workoutProvider.notifier).addWorkout(workout);
  }

  // Delete a workout with confirmation
  Future<void> _deleteWorkout(String workoutId, String workoutName) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: Text('Are you sure you want to delete "$workoutName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // If user confirmed, delete the workout
    if (confirmed == true) {
      await ref.read(workoutProvider.notifier).deleteWorkout(workoutId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Workout deleted successfully'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // This would require implementing an undo feature
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Undo feature coming soon')),
                );
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the workouts to rebuild when they change
    final workouts = ref.watch(workoutProvider);
    final userId = ref.watch(userIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Tracker'),
        centerTitle: true,
        actions: [
          // Add refresh button
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              ref.read(workoutProvider.notifier).refreshWorkouts();
            },
            tooltip: 'Refresh workouts',
          ),
        ],
      ),
      body: workouts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No workouts found',
                    style: TextStyle(fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _navigateToAddWorkout,
                    child: Text('Add your first workout'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: workouts.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final workout = workouts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Dismissible(
                    key: Key(workout.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      color: Colors.red,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Workout'),
                          content: Text(
                              'Are you sure you want to delete "${workout.name}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      _deleteWorkout(workout.id, workout.name);
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Navigate to workout details and refresh on return
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WorkoutDetailPage(workout: workout),
                            ),
                          );
                          // Refresh workouts when returning from details page
                          ref.read(workoutProvider.notifier).refreshWorkouts();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.centerLeft,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        child: Text(
                          workout.name,
                          style: const TextStyle(fontSize: 22),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddWorkout,
        child: const Icon(Icons.add),
      ),
    );
  }
}
