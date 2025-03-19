import 'package:flutter/material.dart';
import '../../models/goal.dart';

class UpdateGoalValueDialog extends StatefulWidget {
  final Goal goal;

  const UpdateGoalValueDialog({Key? key, required this.goal}) : super(key: key);

  @override
  State<UpdateGoalValueDialog> createState() => _UpdateGoalValueDialogState();
}

class _UpdateGoalValueDialogState extends State<UpdateGoalValueDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentValueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentValueController.text = widget.goal.currentValue.toString();
  }

  @override
  void dispose() {
    _currentValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Current Value'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goal Type: ${widget.goal.type}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Start: ${widget.goal.startValue} ${widget.goal.unit}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Target: ${widget.goal.targetValue} ${widget.goal.unit}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _currentValueController,
              decoration: InputDecoration(
                labelText: 'Current Value',
                suffixText: widget.goal.unit,
                hintText:
                    'Enter your current ${widget.goal.type.toLowerCase()} value',
                helperText: widget.goal.type == 'Weight Loss'
                    ? 'Enter a value less than or equal to your starting weight (${widget.goal.startValue})'
                    : widget.goal.type == 'Weight Gain'
                        ? 'Enter a value greater than or equal to your starting weight (${widget.goal.startValue})'
                        : 'Enter your current progress value',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a value';
                }

                final currentValue = double.tryParse(value);
                if (currentValue == null) {
                  return 'Please enter a valid number';
                }

                // Ensure value is positive
                if (currentValue < 0) {
                  return 'Value cannot be negative';
                }

                // Validation based on goal type
                if (widget.goal.type == 'Weight Loss') {
                  // For weight loss, current value should be between target (lowest) and start (highest)
                  if (currentValue > widget.goal.startValue) {
                    return 'Value should be less than or equal to your starting weight (${widget.goal.startValue})';
                  }

                  if (currentValue < widget.goal.targetValue) {
                    // If below target, it's already achieved!
                    return 'Congratulations! You\'ve already reached your target.';
                  }
                } else if (widget.goal.type == 'Weight Gain') {
                  // For weight gain, current value should be between start (lowest) and target (highest)
                  if (currentValue < widget.goal.startValue) {
                    return 'Value should be greater than or equal to your starting weight (${widget.goal.startValue})';
                  }

                  if (currentValue > widget.goal.targetValue) {
                    // If above target, it's already achieved!
                    return 'Congratulations! You\'ve already reached your target.';
                  }
                } else {
                  // For steps, water intake, exercise minutes, sleep hours, etc.
                  if (currentValue < 0) {
                    return 'Value cannot be negative';
                  }
                }

                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              getHelpText(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
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
              final updatedGoal = widget.goal.copyWith(
                currentValue: double.parse(_currentValueController.text),
              );
              Navigator.pop(context, updatedGoal);
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }

  String getHelpText() {
    if (widget.goal.type == 'Weight Loss') {
      return 'Enter your current weight. This should be less than or equal to your starting weight (${widget.goal.startValue} ${widget.goal.unit}) as you progress toward your target of ${widget.goal.targetValue} ${widget.goal.unit}.';
    } else if (widget.goal.type == 'Weight Gain') {
      return 'Enter your current weight. This should be greater than or equal to your starting weight (${widget.goal.startValue} ${widget.goal.unit}) as you progress toward your target of ${widget.goal.targetValue} ${widget.goal.unit}.';
    } else {
      return 'Enter your current progress. Your target is ${widget.goal.targetValue} ${widget.goal.unit}.';
    }
  }
}
