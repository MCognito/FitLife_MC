import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodel/profile_logs_viewmodel.dart';

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class ProfileLogsPage extends ConsumerStatefulWidget {
  const ProfileLogsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileLogsPage> createState() => _ProfileLogsPageState();
}

class _ProfileLogsPageState extends ConsumerState<ProfileLogsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Explicitly reload logs when the page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(profileLogsViewModelProvider);
      // Clear any existing logs first
      viewModel.clearLogs();
      // Then load fresh data
      viewModel.loadLogs();
      viewModel.loadStreakInfo();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  // Add a new log
  void _addLog(String type) async {
    final viewModel = ref.read(profileLogsViewModelProvider);

    // Determine unit based on type
    String unit = '';
    String displayType = type;

    switch (type) {
      case 'weight':
        unit = 'kg';
        displayType = 'Weight';
        break;
      case 'water_intake':
        unit = 'ml';
        displayType = 'Water';
        break;
      case 'steps':
        unit = 'steps';
        displayType = 'Steps';
        break;
    }

    final result = await viewModel.addLog(type, _valueController.text, unit);

    if (result == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$displayType Log added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _valueController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(profileLogsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              // Clear logs first
              viewModel.clearLogs();
              // Then reload
              await viewModel.loadLogs();
              await viewModel.loadStreakInfo();

              // Show confirmation to user
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logs refreshed successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Weight'),
            Tab(text: 'Water'),
            Tab(text: 'Steps'),
          ],
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.errorMessage != null
              ? Center(child: Text(viewModel.errorMessage!))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildWeightTab(viewModel),
                    _buildWaterIntakeTab(viewModel),
                    _buildStepsTab(viewModel),
                  ],
                ),
    );
  }

  Widget _buildWeightTab(ProfileLogsViewModel viewModel) {
    final weightLogs = viewModel.getLogsByType('weight');

    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.loadLogs();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.amber.shade200,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  'Track your weight progress over time',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16.0),
              _buildLogForm('weight'),
              const SizedBox(height: 24.0),
              const Text(
                'Weight History',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              weightLogs.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No weight logs yet',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: weightLogs.length,
                      itemBuilder: (context, index) {
                        final log = weightLogs[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            title: Text('${log.value} ${log.unit}'),
                            subtitle: Text(viewModel.formatDate(log.date)),
                            leading: const Icon(Icons.monitor_weight),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaterIntakeTab(ProfileLogsViewModel viewModel) {
    final waterLogs = viewModel.getLogsByType('water_intake');

    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.loadLogs();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade200,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  'Track your daily water intake',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16.0),
              _buildLogForm('water_intake'),
              const SizedBox(height: 24.0),
              const Text(
                'Water Intake History',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              waterLogs.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No water intake logs yet',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: waterLogs.length,
                      itemBuilder: (context, index) {
                        final log = waterLogs[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            title: Text('${log.value} ${log.unit}'),
                            subtitle: Text(viewModel.formatDate(log.date)),
                            leading: const Icon(Icons.water_drop),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepsTab(ProfileLogsViewModel viewModel) {
    final stepLogs = viewModel.getLogsByType('steps');
    final minimumStepsThreshold =
        viewModel.streakInfo?.minimumStepsThreshold ?? 3000;

    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.loadLogs();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.green.shade200,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_walk,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 8.0),
                    const Flexible(
                      child: Text(
                        'Track your daily steps',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              _buildLogForm('steps'),
              const SizedBox(height: 24.0),
              const Text(
                'Steps History',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              stepLogs.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No steps logs yet',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: stepLogs.length,
                      itemBuilder: (context, index) {
                        final log = stepLogs[index];
                        final isAboveThreshold =
                            log.value >= minimumStepsThreshold;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          color: isAboveThreshold ? Colors.green.shade50 : null,
                          child: ListTile(
                            title: Text(
                              '${log.value.toInt()} ${log.unit}',
                              style: TextStyle(
                                color: isAboveThreshold
                                    ? Colors.green.shade700
                                    : null,
                                fontWeight:
                                    isAboveThreshold ? FontWeight.bold : null,
                              ),
                            ),
                            subtitle: Text(viewModel.formatDate(log.date)),
                            leading: Icon(
                              Icons.directions_walk,
                              color: isAboveThreshold
                                  ? Colors.green.shade700
                                  : null,
                            ),
                            trailing: isAboveThreshold
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogForm(String type) {
    String hintText = '';
    String buttonText = '';
    IconData icon = Icons.add;

    switch (type) {
      case 'weight':
        hintText = 'Enter weight in kg';
        buttonText = 'Add Weight';
        icon = Icons.monitor_weight;
        break;
      case 'water_intake':
        hintText = 'Enter water intake in ml';
        buttonText = 'Add Water Intake';
        icon = Icons.water_drop;
        break;
      case 'steps':
        hintText = 'Enter steps count';
        buttonText = 'Add Steps';
        icon = Icons.directions_walk;
        break;
    }

    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: hintText,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: () => _addLog(type),
              icon: Icon(icon),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
