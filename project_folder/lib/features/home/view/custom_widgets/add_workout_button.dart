import 'package:flutter/material.dart';

class AddWorkoutButton extends StatelessWidget {
  const AddWorkoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // Navigate to add workout page
      },
      child: const Icon(Icons.add),
    );
  }
}
