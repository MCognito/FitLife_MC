import 'package:flutter/material.dart';
import '../../models/goal.dart';

class CreateGoalDialog extends StatefulWidget {
  final Goal? initialGoal;

  const CreateGoalDialog({Key? key, this.initialGoal}) : super(key: key);

  @override
  State<CreateGoalDialog> createState() => _CreateGoalDialogState();
}

class _CreateGoalDialogState extends State<CreateGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late String _unit;
  final _startValueController = TextEditingController();
  final _targetValueController = TextEditingController();
  final _quoteController = TextEditingController();
  late DateTime _targetDate;

  final List<String> _goalTypes = [
    'Weight Loss',
    'Weight Gain',
    'Steps',
    'Water Intake',
    'Exercise Minutes',
    'Sleep Hours',
  ];

  Map<String, String> _unitMap = {
    'Weight Loss': 'kg',
    'Weight Gain': 'kg',
    'Steps': 'steps',
    'Water Intake': 'ml',
    'Exercise Minutes': 'min',
    'Sleep Hours': 'hours',
  };

  @override
  void initState() {
    super.initState();

    // Initialize with default values
    _type = 'Weight Loss';
    _unit = 'kg';
    _targetDate = DateTime.now().add(const Duration(days: 30));

    // If initialGoal is provided, populate fields with its values
    if (widget.initialGoal != null) {
      _type = widget.initialGoal!.type;
      _unit = widget.initialGoal!.unit;
      _startValueController.text = widget.initialGoal!.startValue.toString();
      _targetValueController.text = widget.initialGoal!.targetValue.toString();
      _quoteController.text = widget.initialGoal!.motivation.quote;
      _targetDate = widget.initialGoal!.targetDate;
    }
  }

  @override
  void dispose() {
    _startValueController.dispose();
    _targetValueController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  void _updateUnit(String type) {
    setState(() {
      _type = type;
      _unit = _unitMap[type] ?? 'units';
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialGoal == null ? 'Create New Goal' : 'Edit Goal'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Goal Type',
                ),
                items: _goalTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _updateUnit(newValue);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startValueController,
                decoration: InputDecoration(
                  labelText: 'Starting Value',
                  suffixText: _unit,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a starting value';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetValueController,
                decoration: InputDecoration(
                  labelText: 'Target Value',
                  suffixText: _unit,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a target value';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Target Date'),
                subtitle: Text(
                  '${_targetDate.year}-${_targetDate.month}-${_targetDate.day}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quoteController,
                decoration: const InputDecoration(
                  labelText: 'Motivational Quote (Optional)',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final startValue = double.parse(_startValueController.text);
              final targetValue = double.parse(_targetValueController.text);

              final goal = Goal(
                userId: widget.initialGoal?.userId ??
                    '', // Keep original userId if editing
                type: _type,
                startDate: widget.initialGoal?.startDate ?? DateTime.now(),
                targetDate: _targetDate,
                startValue: startValue,
                currentValue: widget.initialGoal?.currentValue ?? startValue,
                targetValue: targetValue,
                unit: _unit,
                milestones: _generateMilestones(startValue, targetValue),
                notes: widget.initialGoal?.notes ?? [],
                weeklyProgress: widget.initialGoal?.weeklyProgress ?? [],
                motivation: Motivation(
                  quote: _quoteController.text,
                  reminder:
                      widget.initialGoal?.motivation.reminder ?? Reminder(),
                ),
              );

              Navigator.pop(context, goal);
            }
          },
          child: Text(widget.initialGoal == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }

  List<Milestone> _generateMilestones(double start, double target) {
    final difference = (target - start).abs();
    final milestoneCount = 4;
    final step = difference / milestoneCount;
    final milestones = <Milestone>[];

    for (var i = 1; i <= milestoneCount; i++) {
      final value = start + (step * i);
      milestones.add(
        Milestone(
          value: value,
          reward: 'Keep going! You\'re ${(i * 25)}% there!',
        ),
      );
    }

    return milestones;
  }
}
