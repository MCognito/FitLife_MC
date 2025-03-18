import 'package:flutter/material.dart';
import '../../../authentication/service/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodel/settings_viewmodel.dart';
import '../../../../main.dart';
import 'change_password_page.dart';

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
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final viewModel = ref.read(settingsViewModelProvider);
    final success = await viewModel.deleteAccount();

    if (success && mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully')),
      );

      // Navigate to login screen
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    } else if (mounted) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Failed to delete account: ${viewModel.errorMessage}')),
      );
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
            // Show "to be implemented" message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Push notifications feature will be implemented in a future update'),
                duration: Duration(seconds: 3),
              ),
            );
            viewModel.setNotifications(value);
          },
        ),
        _buildSwitchTile(
          'Sound Effects',
          'Play sounds for notifications and actions',
          Icons.volume_up,
          viewModel.soundEffects,
          (value) {
            // Show "to be implemented" message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Sound effects feature will be implemented in a future update'),
                duration: Duration(seconds: 3),
              ),
            );
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
                    viewModel.setLanguage(newValue);
                  }
                },
              ),
            ),
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
