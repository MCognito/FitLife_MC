import 'package:flutter/material.dart';
import '../pages/profile_ui_page.dart';
import '../pages/profile_progress_page.dart';
import '../pages/profile_goals_page.dart';
import '../pages/settings_page.dart';
import '../pages/faq_page.dart';
import '../pages/contact_page.dart';
import '../pages/profile_logs_page.dart';
import '../pages/leaderboards_page.dart';

class ProfileContent extends StatelessWidget {
  final String selectedOption;
  final String selectedSubOption;

  const ProfileContent({
    super.key,
    required this.selectedOption,
    required this.selectedSubOption,
  });

  @override
  Widget build(BuildContext context) {
    // If no option is selected, show empty state
    if (selectedOption.isEmpty) {
      return const Center(
        child: Text('Select an option from the menu'),
      );
    }

    // Display different content based on selected option and sub-option
    switch (selectedOption) {
      case 'Profile':
        switch (selectedSubOption) {
          case 'Your Information':
            return const ProfileUIPage();
          case 'Progress':
            return const ProfileProgressPage();
          case 'Goals':
            return const ProfileGoalsPage();
          case 'Logs':
            return const ProfileLogsPage();
          default:
            return const ProfileUIPage();
        }

      case 'General Settings':
        return SettingsPage(
            key: ValueKey(selectedSubOption),
            selectedOption: selectedSubOption);

      case 'Leaderboards':
        // We only have global leaderboard now
        return const LeaderboardPage();

      case 'FAQs':
        return const FAQPage();

      case 'Contact':
        return const ContactPage();

      default:
        // Default content if option is not recognized
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_outline, size: 100),
              const SizedBox(height: 16),
              Text(
                'Select an option',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose an option from the menu to view content',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
    }
  }
}
