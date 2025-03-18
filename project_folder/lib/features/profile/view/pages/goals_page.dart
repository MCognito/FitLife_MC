import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../service/goal_service.dart';
import '../widgets/goal_card.dart';
import '../widgets/create_goal_dialog.dart';
import '../../../authentication/service/token_manager.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({Key? key}) : super(key: key);

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Goal created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create goal: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createGoal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadGoals,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _goals.isEmpty
                  ? Center(
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
                  : RefreshIndicator(
                      onRefresh: _loadGoals,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _goals.length,
                        itemBuilder: (context, index) {
                          final goal = _goals[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: GoalCard(
                              goal: goal,
                              onProgressUpdate: (value) async {
                                try {
                                  await _goalService.updateGoalProgress(
                                    goal.id!,
                                    value,
                                  );
                                  await _loadGoals();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Goal progress updated successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Failed to update progress: $e'),
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Goal deleted successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Failed to delete goal: $e'),
                                      ),
                                    );
                                  }
                                }
                              },
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Failed to abandon goal: $e'),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
