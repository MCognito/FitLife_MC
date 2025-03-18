import 'package:flutter/material.dart';
import '../../models/goal.dart';
import 'package:intl/intl.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final Function(double) onProgressUpdate;
  final VoidCallback onDelete;
  final VoidCallback onAbandon;
  final VoidCallback? onResume;
  final VoidCallback? onEdit;

  const GoalCard({
    Key? key,
    required this.goal,
    required this.onProgressUpdate,
    required this.onDelete,
    required this.onAbandon,
    this.onResume,
    this.onEdit,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  String _getStatusColor(String status) {
    final upperStatus = status.toUpperCase();
    if (upperStatus == 'IN_PROGRESS' || status == 'In Progress') {
      return 'blue';
    } else if (upperStatus == 'COMPLETED' || status == 'Completed') {
      return 'green';
    } else if (upperStatus == 'ABANDONED' || status == 'Abandoned') {
      return 'grey';
    } else {
      return 'blue';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.type,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'delete':
                        onDelete();
                        break;
                      case 'abandon':
                        onAbandon();
                        break;
                      case 'resume':
                        onResume?.call();
                        break;
                      case 'edit':
                        onEdit?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null &&
                        (goal.status.toUpperCase() == 'IN_PROGRESS' ||
                            goal.status == 'In Progress'))
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Edit Goal'),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline, color: Colors.red),
                        title: Text('Delete'),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    if (goal.status.toUpperCase() == 'IN_PROGRESS' ||
                        goal.status == 'In Progress')
                      const PopupMenuItem(
                        value: 'abandon',
                        child: ListTile(
                          leading: Icon(Icons.cancel_outlined),
                          title: Text('Abandon'),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                    if ((goal.status.toUpperCase() == 'ABANDONED' ||
                            goal.status == 'Abandoned') &&
                        onResume != null)
                      const PopupMenuItem(
                        value: 'resume',
                        child: ListTile(
                          leading: Icon(Icons.refresh),
                          title: Text('Resume Goal'),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${goal.status}',
              style: TextStyle(
                color: _getStatusColor(goal.status) == 'blue'
                    ? colorScheme.primary
                    : _getStatusColor(goal.status) == 'green'
                        ? Colors.green
                        : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Target: ${goal.targetValue} ${goal.unit}',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Current: ${goal.currentValue} ${goal.unit}',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(width: 8),
                if (goal.status.toUpperCase() == 'IN_PROGRESS' ||
                    goal.status == 'In Progress')
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Update progress',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => _UpdateProgressDialog(
                          currentValue: goal.currentValue,
                          onUpdate: onProgressUpdate,
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '${_calculateProgressPercentage(goal).toStringAsFixed(1)}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getProgressColor(
                            _calculateProgressPercentage(goal),
                            goal.isOnTrack,
                            colorScheme),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _calculateProgressPercentage(goal) /
                        100, // Convert percentage to 0.0-1.0 range
                    backgroundColor: Colors.grey[200],
                    minHeight: 10,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(_calculateProgressPercentage(goal),
                          goal.isOnTrack, colorScheme),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Started: ${_formatDate(goal.startDate)}',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  'Target: ${_formatDate(goal.targetDate)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            if (goal.motivation.quote.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '"${goal.motivation.quote}"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if ((goal.status.toUpperCase() == 'ABANDONED' ||
                    goal.status == 'Abandoned') &&
                onResume != null) ...[
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: onResume,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Resume Goal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Calculate progress percentage manually to ensure accuracy
  double _calculateProgressPercentage(Goal goal) {
    // Handle case where start and target are the same
    if (goal.startValue == goal.targetValue) return 100.0;

    // Calculate total change needed
    final totalChange = (goal.targetValue - goal.startValue).abs();

    // Calculate current change based on goal direction
    double currentChange;
    if (goal.targetValue > goal.startValue) {
      // For increasing goals (weight gain, etc.)
      currentChange =
          (goal.currentValue - goal.startValue).clamp(0.0, totalChange);
    } else {
      // For decreasing goals (weight loss, etc.)
      currentChange =
          (goal.startValue - goal.currentValue).clamp(0.0, totalChange);
    }

    // Calculate percentage
    double percentage = (currentChange / totalChange) * 100;

    // Ensure percentage is between 0 and 100
    percentage = percentage.clamp(0.0, 100.0);

    return percentage;
  }

  // Helper method to get progress color based on completion percentage
  Color _getProgressColor(
      double progress, bool isOnTrack, ColorScheme colorScheme) {
    if (progress >= 100) {
      return Colors.green; // Completed
    } else if (progress >= 75) {
      return Colors.greenAccent; // Almost there
    } else if (progress >= 50) {
      return colorScheme.primary; // Halfway
    } else if (progress >= 25) {
      return Colors.orange; // Getting started
    } else if (!isOnTrack) {
      return Colors.redAccent; // Behind schedule
    } else {
      return Colors.amber; // Just started
    }
  }
}

class _UpdateProgressDialog extends StatefulWidget {
  final double currentValue;
  final Function(double) onUpdate;

  const _UpdateProgressDialog({
    required this.currentValue,
    required this.onUpdate,
  });

  @override
  State<_UpdateProgressDialog> createState() => _UpdateProgressDialogState();
}

class _UpdateProgressDialogState extends State<_UpdateProgressDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Progress'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Current Value',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final value = double.tryParse(_controller.text);
            if (value != null) {
              widget.onUpdate(value);
              Navigator.pop(context);
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
