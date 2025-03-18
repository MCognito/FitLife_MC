import 'package:flutter/material.dart';
import '../../models/workout.dart';

class AddNewWorkoutPage extends StatefulWidget {
  final Function(WorkoutModel) onAddWorkout;
  final int currentWorkoutCount;
  final String userId;

  AddNewWorkoutPage({
    required this.onAddWorkout,
    required this.currentWorkoutCount,
    required this.userId,
  });

  @override
  _AddNewWorkoutPageState createState() => _AddNewWorkoutPageState();
}

class _AddNewWorkoutPageState extends State<AddNewWorkoutPage> {
  final _formKey = GlobalKey<FormState>();
  String _workoutName = '';
  int? _numberOfExercises;
  List<String> _exerciseNames = [];
  List<int> _numberOfSets = [];
  List<TextEditingController> _exerciseControllers = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    for (var controller in _exerciseControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Initialize or update controllers when number of exercises changes
  void _updateExerciseControllers() {
    // Dispose old controllers first
    for (var controller in _exerciseControllers) {
      controller.dispose();
    }
    
    // Create new controllers
    _exerciseControllers = List.generate(
      _numberOfExercises ?? 0,
      (index) => TextEditingController(text: _exerciseNames.length > index ? _exerciseNames[index] : ''),
    );
    
    // Ensure exercise names list is the right size
    if (_exerciseNames.length != _numberOfExercises) {
      // Preserve existing names if reducing the number
      if (_exerciseNames.length > (_numberOfExercises ?? 0)) {
        _exerciseNames = _exerciseNames.sublist(0, _numberOfExercises);
      } else {
        // Add empty strings for new exercises
        while (_exerciseNames.length < (_numberOfExercises ?? 0)) {
          _exerciseNames.add('');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Workout'),
      ),
      body: _isSubmitting
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Workout Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a workout name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _workoutName = value!;
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: DropdownButtonFormField<int>(
                        decoration:
                            InputDecoration(labelText: 'Number of Exercises'),
                        value: _numberOfExercises,
                        items: List.generate(5, (index) => index + 1)
                            .map((number) => DropdownMenuItem(
                                  value: number,
                                  child: Text(number.toString()),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _numberOfExercises = value!;
                            // Initialize or update sets
                            if (_numberOfSets.length != _numberOfExercises) {
                              if (_numberOfSets.length > _numberOfExercises!) {
                                _numberOfSets = _numberOfSets.sublist(0, _numberOfExercises);
                              } else {
                                while (_numberOfSets.length < _numberOfExercises!) {
                                  _numberOfSets.add(1);
                                }
                              }
                            }
                            // Update controllers and exercise names
                            _updateExerciseControllers();
                          });
                        },
                        validator: (value) {
                          if (value == null || value <= 0) {
                            return 'Please select the number of exercises';
                          }
                          return null;
                        },
                      ),
                    ),
                    Divider(
                      height: 5,
                      thickness: 3,
                    ),
                    Expanded(
                      child: ListView(
                        children:
                            List.generate(_numberOfExercises ?? 0, (index) {
                          return Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _exerciseControllers.length > index 
                                            ? _exerciseControllers[index] 
                                            : null,
                                        decoration: InputDecoration(
                                            labelText:
                                                'Exercise ${index + 1} Name'),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter the name of exercise ${index + 1}';
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          // Update the exercise name as it's typed
                                          if (index < _exerciseNames.length) {
                                            _exerciseNames[index] = value;
                                          }
                                        },
                                        onSaved: (value) {
                                          if (value != null && index < _exerciseNames.length) {
                                            _exerciseNames[index] = value;
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Container(
                                      width: 100,
                                      child: DropdownButtonFormField<int>(
                                        decoration:
                                            InputDecoration(labelText: 'Sets'),
                                        value: _numberOfSets[index],
                                        items: List.generate(
                                                10, (index) => index + 1)
                                            .map((number) => DropdownMenuItem(
                                                  value: number,
                                                  child:
                                                      Text(number.toString()),
                                                ))
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _numberOfSets[index] = value!;
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null || value <= 0) {
                                            return 'Please select the number of sets';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                height: 5,
                                thickness: 3,
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 200, // Adjust the width as needed
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: Text('Add Workout'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(0), // Rectangular shape
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _submitForm() async {
    if (widget.currentWorkoutCount >= 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You cannot create more than 7 workouts.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        _formKey.currentState!.save();

        // Create a new workout model
        WorkoutModel newWorkout = WorkoutModel(
          id: '', // This will be set by the backend
          userId: widget.userId, // Use the provided user ID
          name: _workoutName,
          exercises: List.generate(_numberOfExercises!, (index) {
            return ExerciseModel(
              name: _exerciseNames[index],
              sets: List.generate(_numberOfSets[index], (setIndex) {
                return SetModel(
                  reps: 0, // Default values
                  weight: 0, // Default values
                );
              }),
            );
          }),
        );

        // Pass the new workout back to the parent
        await widget.onAddWorkout(newWorkout);

        // Return true to indicate success
        Navigator.pop(context, true);
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add workout: $e')),
        );

        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
