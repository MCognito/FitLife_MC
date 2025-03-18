import 'package:flutter/material.dart';
import '../../models/workout.dart';

class WorkoutListItem extends StatelessWidget {
  final WorkoutModel workout;

  const WorkoutListItem({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(workout.name),
        onTap: () {
          // Handle workout selection
        },
      ),
    );
  }
}
