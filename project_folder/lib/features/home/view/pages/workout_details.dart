//
// Summary: Page to display the details of a workout.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/workout.dart';
import '../../providers/workout_provider.dart';

class WorkoutDetailPage extends ConsumerStatefulWidget {
  final WorkoutModel workout;
  const WorkoutDetailPage({super.key, required this.workout});

  @override
  ConsumerState<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends ConsumerState<WorkoutDetailPage> {
  late WorkoutModel workout;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Create a deep copy of the workout to avoid modifying the original
    workout = _createDeepCopy(widget.workout);
  }

  // Create a deep copy of the workout model
  WorkoutModel _createDeepCopy(WorkoutModel original) {
    return WorkoutModel(
      id: original.id,
      userId: original.userId,
      name: original.name,
      exercises: original.exercises.map((exercise) {
        return ExerciseModel(
          name: exercise.name,
          sets: exercise.sets.map((set) {
            return SetModel(
              reps: set.reps,
              weight: set.weight,
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  // Save changes to the database
  void _saveChanges() async {
    try {
      await ref.read(workoutProvider.notifier).updateWorkout(workout);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Workout updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _hasChanges = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update workout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
        centerTitle: true,
        actions: [
          if (_hasChanges)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveChanges,
              tooltip: 'Save changes',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: workout.exercises.asMap().entries.map((exerciseEntry) {
            int exerciseIndex = exerciseEntry.key;
            ExerciseModel exercise = exerciseEntry.value;
            return Card(
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise name row
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(8),
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Text(
                        exercise.name,
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    // Headers row
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(
                            'Set',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          )),
                          Expanded(
                              child: Text(
                            'Reps',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          )),
                          Expanded(
                              child: Text(
                            'Weight (kg)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          )),
                        ],
                      ),
                    ),
                    // Sets rows
                    ...exercise.sets.asMap().entries.map((entry) {
                      int setIndex = entry.key;
                      SetModel set = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            // Set number
                            Expanded(
                              child: Text(
                                'Set ${setIndex + 1}',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Reps input
                            Expanded(
                              child: TextField(
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: set.reps.toString(),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 8),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    setState(() {
                                      workout
                                          .exercises[exerciseIndex]
                                          .sets[setIndex]
                                          .reps = int.parse(value);
                                      _hasChanges = true;
                                    });
                                  }
                                },
                              ),
                            ),
                            // Weight input
                            Expanded(
                              child: TextField(
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                decoration: InputDecoration(
                                  hintText: set.weight.toString(),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 8),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d*')),
                                ],
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    setState(() {
                                      workout
                                          .exercises[exerciseIndex]
                                          .sets[setIndex]
                                          .weight = double.parse(value);
                                      _hasChanges = true;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: _hasChanges
          ? FloatingActionButton(
              onPressed: _saveChanges,
              child: Icon(Icons.save),
              tooltip: 'Save changes',
            )
          : null,
    );
  }
}
