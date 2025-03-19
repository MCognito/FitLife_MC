import 'package:flutter/material.dart';
import '../../../authentication/service/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodel/settings_viewmodel.dart';
import '../../../../main.dart';
import 'change_password_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for the SettingsViewModel
final settingsViewModelProvider =
    ChangeNotifierProvider((ref) => SettingsViewModel(ref));

class SettingsPage extends ConsumerStatefulWidget {
  final String selectedOption;

  const SettingsPage({
    super.key,
    this.selectedOption = 'Theme',
  });

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  void initState() {
    super.initState();
    // Load user preferences when the page is initialized
    Future.microtask(
        () => ref.read(settingsViewModelProvider).loadUserPreferences());
  }

  Future<void> _deleteAccount() async {
    // Show confirmation dialog with more explanation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action will:\n\n'
          '• Permanently delete your account\n'
          '• Remove all your workouts and progress\n'
          '• Delete your scores and achievements\n'
          '• Remove all logs and streaks\n'
          '• Cannot be undone',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete My Account'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Deleting account...\nThis may take a moment.'),
            ],
          ),
        ),
      );
    }

    try {
      final viewModel = ref.read(settingsViewModelProvider);
      final success = await viewModel.deleteAccount();

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (success && mounted) {
        // Clear all app data and cache
        await _clearAllAppData();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your account has been permanently deleted'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to login screen
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      } else if (mounted) {
        // Show detailed error message
        String errorMessage = viewModel.errorMessage ?? 'Unknown error';
        String displayMessage = 'Failed to delete account';

        if (errorMessage.toLowerCase().contains('network')) {
          displayMessage =
              'Network error. Please check your connection and try again.';
        } else if (errorMessage.toLowerCase().contains('not found')) {
          displayMessage =
              'Account not found. It may have been already deleted.';
        } else if (errorMessage.toLowerCase().contains('unauthorized') ||
            errorMessage.toLowerCase().contains('token')) {
          displayMessage = 'Authentication error. Please log in again and try.';
        } else {
          displayMessage = 'Failed to delete account: $errorMessage';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(displayMessage),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _deleteAccount,
              textColor: Colors.white,
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        // Show general error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $e'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper method to clear all app data
  Future<void> _clearAllAppData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Clear any cached auth data
      final authService = AuthService();
      await authService.logout();

      print('All app data cleared successfully');
    } catch (e) {
      print('Error clearing app data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the ViewModel for changes
    final viewModel = ref.watch(settingsViewModelProvider);
    // Watch the theme mode for changes
    final themeMode = ref.watch(themeModeProvider);

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
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
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                viewModel.errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => viewModel.loadUserPreferences(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Get the selected option from the route arguments
    final selectedSubOption = widget.selectedOption;

    // Determine which section to show based on the selected sub-option
    Widget content;
    if (selectedSubOption == 'Preferences') {
      content = _buildPreferencesSection(context);
    } else if (selectedSubOption == 'Account') {
      content = _buildAccountSection(context);
    } else {
      // Default to preferences
      content = _buildPreferencesSection(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page title
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // Content based on selected option
          content,
        ],
      ),
    );
  }

  // Build the preferences section
  Widget _buildPreferencesSection(BuildContext context) {
    final viewModel = ref.read(settingsViewModelProvider);

    // Helper function to show snackbars with proper cleanup
    void showSnackBar(String message, {Color backgroundColor = Colors.blue}) {
      // Clear any existing snackbars first
      ScaffoldMessenger.of(context).clearSnackBars();

      // Then show the new snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preferences section
        _buildSectionHeader(context, 'Preferences'),

        // Appearance subsection
        _buildSubsectionHeader(context, 'Appearance'),
        _buildSwitchTile(
          'Dark Mode',
          'Switch between light and dark theme',
          Icons.dark_mode,
          viewModel.darkMode,
          (value) {
            // Clear any existing snackbars before theme change
            ScaffoldMessenger.of(context).clearSnackBars();

            viewModel.setDarkMode(value);
            // Apply theme change immediately
            ref.read(themeModeProvider.notifier).state =
                value ? ThemeMode.dark : ThemeMode.light;
          },
        ),

        // Notifications subsection
        _buildSubsectionHeader(context, 'Notifications'),
        _buildSwitchTile(
          'Push Notifications',
          'Receive reminders and updates',
          Icons.notifications,
          viewModel.notifications,
          (value) {
            // Set value without showing snackbar
            viewModel.setNotifications(value);
          },
        ),
        _buildSwitchTile(
          'Sound Effects',
          'Play sounds for notifications and actions',
          Icons.volume_up,
          viewModel.soundEffects,
          (value) {
            // Set value without showing snackbar
            viewModel.setSoundEffects(value);
          },
        ),

        // Privacy subsection
        _buildSubsectionHeader(context, 'Privacy'),
        _buildSwitchTile(
          'Public Profile',
          'Make your profile visible on leaderboards',
          Icons.public,
          viewModel.publicProfile,
          (value) => viewModel.setPublicProfile(value),
        ),

        // Language subsection
        _buildSubsectionHeader(context, 'Language'),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: viewModel.selectedLanguage,
                icon: const Icon(Icons.arrow_drop_down),
                items: viewModel.languages.map((String language) {
                  return DropdownMenuItem<String>(
                    value: language,
                    child: Text(language),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    // Set language without showing snackbar
                    viewModel.setLanguage(newValue);
                  }
                },
              ),
            ),
          ),
        ),

        // Save settings button
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              try {
                await viewModel.saveUserPreferences();
                if (mounted) {
                  // Show a combined message about saved settings and future implementations
                  showSnackBar(
                    'Settings saved successfully. Note that push notifications, sound effects, and language selection will be implemented in a future update.',
                    backgroundColor: Colors.green,
                  );
                }
              } catch (e) {
                if (mounted) {
                  showSnackBar(
                    'Failed to save settings: $e',
                    backgroundColor: Colors.red,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Save Settings'),
          ),
        ),
      ],
    );
  }

  // Build the account section
  Widget _buildAccountSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Account section
        _buildSectionHeader(context, 'Account'),

        // Security subsection
        _buildSubsectionHeader(context, 'Security'),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Change Password'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChangePasswordPage(),
              ),
            );
          },
        ),

        // Delete account option (always shown in Account section)
        const SizedBox(height: 16),
        _buildSubsectionHeader(context, 'Danger Zone'),
        ListTile(
          leading: const Icon(Icons.delete),
          title: const Text('Delete Account'),
          textColor: Colors.red,
          iconColor: Colors.red,
          onTap: _deleteAccount,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildSubsectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged, {
    Future<bool> Function()? onPermissionRequest,
  }) {
    return Card(
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        secondary: Icon(icon),
        value: value,
        onChanged: (newValue) async {
          // If turning on and permission request function is provided
          if (newValue && onPermissionRequest != null) {
            final permissionGranted = await onPermissionRequest();
            if (permissionGranted) {
              onChanged(newValue);
            }
          } else {
            onChanged(newValue);
          }
        },
      ),
    );
  }
}
