import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../service/goal_service.dart';
import '../widgets/goal_card.dart';
import '../widgets/create_goal_dialog.dart';
import '../../../authentication/service/token_manager.dart';

class ProfileGoalsPage extends StatefulWidget {
  const ProfileGoalsPage({super.key});

  @override
  State<ProfileGoalsPage> createState() => _ProfileGoalsPageState();
}

class _ProfileGoalsPageState extends State<ProfileGoalsPage> {
  final GoalService _goalService = GoalService();
  List<Goal> _goals = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = await TokenManager.getUserId();
      if (userId == null) {
        setState(() {
          _error = 'User not logged in';
          _isLoading = false;
        });
        return;
      }

      final goals = await _goalService.getUserGoals(userId);
      setState(() {
        _goals = goals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load goals: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createGoal() async {
    final result = await showDialog<Goal?>(
      context: context,
      builder: (context) => const CreateGoalDialog(),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        final userId = await TokenManager.getUserId();
        if (userId == null) {
          throw Exception('User not logged in');
        }
        await _goalService.createGoal(userId, result);
        await _loadGoals();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create goal: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // Function to edit an existing goal
  Future<void> _editGoal(Goal goal) async {
    // We need to use the original goal data (not formatted) for editing
    // The one in the card has formatted names so get the original from _goals
    final originalGoal =
        _goals.firstWhere((g) => g.id == goal.id, orElse: () => goal);

    final result = await showDialog<Goal?>(
      context: context,
      builder: (context) => CreateGoalDialog(initialGoal: originalGoal),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        // Create updated goal with same ID and userId
        final updatedGoal = result.copyWith(
          id: originalGoal.id,
          userId: originalGoal.userId,
        );

        await _goalService.updateGoal(updatedGoal);
        await _loadGoals();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error updating goal: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update goal: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadGoals,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadGoals,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Page title
                        Text(
                          'Your Goals',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Track your fitness goals and progress',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),

                        // Goals summary
                        _buildSummaryCard(context),

                        const SizedBox(height: 24),

                        // Goals list by sections
                        if (_goals.isEmpty)
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'No goals yet',
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _createGoal,
                                  child: const Text('Create Goal'),
                                ),
                              ],
                            ),
                          )
                        else
                          ..._buildGoalSections(context),

                        const SizedBox(height: 24),

                        // Add new goal button
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _createGoal,
                            icon: const Icon(Icons.add),
                            label: const Text('Add New Goal'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
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

  // Build collapsible sections for goals by status
  List<Widget> _buildGoalSections(BuildContext context) {
    // Group goals by status
    final inProgressGoals = _goals
        .where((g) =>
            g.status.toUpperCase() == 'IN_PROGRESS' ||
            g.status == 'In Progress')
        .toList();
    final completedGoals = _goals
        .where((g) =>
            g.status.toUpperCase() == 'COMPLETED' || g.status == 'Completed')
        .toList();
    final abandonedGoals = _goals
        .where((g) =>
            g.status.toUpperCase() == 'ABANDONED' || g.status == 'Abandoned')
        .toList();

    final sections = <Widget>[];

    // In Progress section (always expanded by default and always shown)
    sections.add(
      _buildGoalSection(
        context: context,
        title: 'In Progress',
        goals: inProgressGoals,
        icon: Icons.pending,
        color: Colors.orange,
        initiallyExpanded: true,
      ),
    );

    // Completed section (only shown if there are completed goals)
    if (completedGoals.isNotEmpty) {
      sections.add(
        const SizedBox(height: 16),
      );
      sections.add(
        _buildGoalSection(
          context: context,
          title: 'Completed',
          goals: completedGoals,
          icon: Icons.check_circle,
          color: Colors.green,
          initiallyExpanded: false,
        ),
      );
    }

    // Abandoned section (only shown if there are abandoned goals)
    if (abandonedGoals.isNotEmpty) {
      sections.add(
        const SizedBox(height: 16),
      );
      sections.add(
        _buildGoalSection(
          context: context,
          title: 'Abandoned',
          goals: abandonedGoals,
          icon: Icons.cancel,
          color: Colors.grey,
          initiallyExpanded: false,
        ),
      );
    }

    return sections;
  }

  // Build a collapsible section for goals
  Widget _buildGoalSection({
    required BuildContext context,
    required String title,
    required List<Goal> goals,
    required IconData icon,
    required Color color,
    required bool initiallyExpanded,
  }) {
    // Define subtle background colors for each section
    Color backgroundColor;
    Color collapsedBackgroundColor;

    switch (title) {
      case 'In Progress':
        backgroundColor = Colors.orange.withOpacity(0.05);
        collapsedBackgroundColor = Colors.orange.withOpacity(0.03);
        break;
      case 'Completed':
        backgroundColor = Colors.green.withOpacity(0.05);
        collapsedBackgroundColor = Colors.green.withOpacity(0.03);
        break;
      case 'Abandoned':
        backgroundColor = Colors.grey.withOpacity(0.05);
        collapsedBackgroundColor = Colors.grey.withOpacity(0.03);
        break;
      default:
        backgroundColor = Colors.grey.shade50;
        collapsedBackgroundColor = Colors.white;
    }

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                Text(
                  '${goals.length} ${goals.length == 1 ? 'goal' : 'goals'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                ),
              ],
            ),
          ],
        ),
        initiallyExpanded: initiallyExpanded,
        backgroundColor: backgroundColor,
        collapsedBackgroundColor: collapsedBackgroundColor,
        iconColor: color,
        collapsedIconColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
        children: [
          // Add a subtle divider
          Divider(
            height: 1,
            thickness: 1,
            color: color.withOpacity(0.1),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: goals.isEmpty
                ? _buildEmptyState(context, title)
                : Column(
                    children: goals
                        .map((goal) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GoalCard(
                                goal: goal.copyWith(
                                  type: _formatGoalName(goal.type),
                                  status: _formatGoalStatus(goal.status),
                                ),
                                onProgressUpdate: (value) async {
                                  try {
                                    await _goalService.updateGoalProgress(
                                      goal.id!,
                                      value,
                                    );
                                    await _loadGoals();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Failed to update progress: $e'),
                                      ),
                                    );
                                  }
                                },
                                onDelete: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Goal'),
                                      content: const Text(
                                        'Are you sure you want to delete this goal?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    try {
                                      await _goalService.deleteGoal(goal.id!);
                                      await _loadGoals();
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Failed to delete goal: $e'),
                                        ),
                                      );
                                    }
                                  }
                                },
                                onEdit: goal.status.toUpperCase() ==
                                            'IN_PROGRESS' ||
                                        goal.status == 'In Progress'
                                    ? () {
                                        _editGoal(goal);
                                      }
                                    : null,
                                onAbandon: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Abandon Goal'),
                                      content: const Text(
                                        'Are you sure you want to abandon this goal? '
                                        'You can always create a new one.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Abandon'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    try {
                                      await _goalService.abandonGoal(goal.id!);
                                      await _loadGoals();
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Failed to abandon goal: $e'),
                                        ),
                                      );
                                    }
                                  }
                                },
                                onResume: goal.status.toUpperCase() ==
                                        'ABANDONED'
                                    ? () async {
                                        try {
                                          await _goalService.resumeGoal(goal);
                                          await _loadGoals();

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Goal resumed successfully!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Failed to resume goal: $e'),
                                            ),
                                          );
                                        }
                                      }
                                    : null,
                              ),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  // Helper method to format goal name (replace underscores with spaces and capitalize each word)
  String _formatGoalName(String name) {
    if (name.isEmpty) return name;

    // Replace underscores with spaces
    String formatted = name.replaceAll('_', ' ');

    // Capitalize each word
    List<String> words = formatted.split(' ');
    words = words
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .toList();

    return words.join(' ');
  }

  // Helper method to format goal status (replace underscores with spaces and capitalize each word)
  String _formatGoalStatus(String status) {
    if (status.isEmpty) return status;

    // Replace underscores with spaces
    String formatted = status.replaceAll('_', ' ');

    // Capitalize each word
    List<String> words = formatted.split(' ');
    words = words
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .toList();

    return words.join(' ');
  }

  // Build empty state message for a section
  Widget _buildEmptyState(BuildContext context, String sectionTitle) {
    String message;
    IconData icon;

    switch (sectionTitle) {
      case 'In Progress':
        message = 'No goals in progress. Create a new goal to get started!';
        icon = Icons.add_circle_outline;
        break;
      case 'Completed':
        message = 'No completed goals yet. Keep working towards your goals!';
        icon = Icons.emoji_events_outlined;
        break;
      case 'Abandoned':
        message = 'No abandoned goals. Great job staying committed!';
        icon = Icons.thumb_up_outlined;
        break;
      default:
        message = 'No goals in this section.';
        icon = Icons.info_outline;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    // Calculate summary statistics
    final totalGoals = _goals.length;
    final completedGoals =
        _goals.where((goal) => goal.status.toUpperCase() == 'COMPLETED').length;
    final abandonedGoals =
        _goals.where((goal) => goal.status.toUpperCase() == 'ABANDONED').length;
    final inProgressGoals = totalGoals - completedGoals - abandonedGoals;
    final completionRate = totalGoals > 0 ? completedGoals / totalGoals : 0.0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goals Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'Total',
                    totalGoals.toString(),
                    Icons.flag,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'Completed',
                    completedGoals.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'In Progress',
                    inProgressGoals.toString(),
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Completion Rate',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: completionRate,
                minHeight: 10,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getCompletionColor(
                      completionRate, Theme.of(context).colorScheme),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(completionRate * 100).toStringAsFixed(0)}% Complete',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (inProgressGoals > 0)
                  Text(
                    '$inProgressGoals in progress',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.orange,
                        ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  // Helper method to get color based on completion rate
  Color _getCompletionColor(double rate, ColorScheme colorScheme) {
    if (rate >= 0.75) {
      return Colors.green;
    } else if (rate >= 0.5) {
      return colorScheme.primary;
    } else if (rate >= 0.25) {
      return Colors.orange;
    } else {
      return Colors.amber;
    }
  }
}
