import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodel/leaderboard_viewmodel.dart';

// Provider for the LeaderboardViewModel
final leaderboardViewModelProvider =
    ChangeNotifierProvider((ref) => LeaderboardViewModel());

class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({
    super.key,
  });

  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage> {
  @override
  void initState() {
    super.initState();
    // Load leaderboard data when the page is initialized
    Future.microtask(
        () => ref.read(leaderboardViewModelProvider).loadLeaderboardData());
  }

  @override
  Widget build(BuildContext context) {
    // Watch the ViewModel for changes
    final viewModel = ref.watch(leaderboardViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.loadLeaderboardData(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Metric selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'Metric:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    value: viewModel.selectedMetric,
                    items: viewModel.metrics.map((String metric) {
                      return DropdownMenuItem<String>(
                        value: metric,
                        child: Text(metric),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        viewModel.setSelectedMetric(newValue);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Leaderboard content
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 60,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32.0),
                              child: Text(
                                viewModel.errorMessage!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => viewModel.loadLeaderboardData(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : viewModel.leaderboardData.isEmpty
                        ? const Center(
                            child: Text('No users found on the leaderboard.'),
                          )
                        : _buildLeaderboardList(
                            viewModel.getSortedLeaderboardData()),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(List<Map<String, dynamic>> users) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isCurrentUser = user['isCurrentUser'] == true;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          color: isCurrentUser
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          child: ListTile(
            leading: _buildRankBadge(context, user['rank']),
            title: Text(
              user['name'],
              style: TextStyle(
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: _buildMetricValue(context, user),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          ),
        );
      },
    );
  }

  Widget _buildRankBadge(BuildContext context, int rank) {
    Color badgeColor;

    // Determine badge color based on rank
    switch (rank) {
      case 1:
        badgeColor = Colors.amber; // Gold
        break;
      case 2:
        badgeColor = Colors.grey.shade300; // Silver
        break;
      case 3:
        badgeColor = Colors.brown.shade300; // Bronze
        break;
      default:
        badgeColor = Colors.grey.shade100;
    }

    return CircleAvatar(
      backgroundColor: badgeColor,
      child: Text(
        rank.toString(),
        style: TextStyle(
          color: rank <= 3 ? Colors.black : Colors.grey.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMetricValue(BuildContext context, Map<String, dynamic> user) {
    final viewModel = ref.read(leaderboardViewModelProvider);
    String value;
    IconData icon;

    // Format value based on selected metric
    switch (viewModel.selectedMetric) {
      case 'Level':
        value = 'Lvl ${user['level']}';
        icon = Icons.star;
        break;
      case 'Streak':
        print(
            '[LEADERBOARD_PAGE] Displaying streak for user ${user['name']}: ${user['streak']} (type: ${user['streak'].runtimeType})');
        value = '${user['streak']} days';
        icon = Icons.local_fire_department;
        break;
      default:
        value = '';
        icon = Icons.star;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
