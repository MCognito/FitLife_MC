import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/service/auth_service.dart';
import '../../../authentication/service/logout_service.dart';
import '../../service/profile_service.dart';
import '../../models/user_profile.dart';

class ProfileFlyoutMenu extends ConsumerStatefulWidget {
  final String selectedOption;
  final String selectedSubOption;
  final Function(String, [String?]) onOptionSelected;
  final VoidCallback onLogout;
  final double width;
  final bool isTabletOrLarger;

  const ProfileFlyoutMenu({
    super.key,
    required this.selectedOption,
    required this.selectedSubOption,
    required this.onOptionSelected,
    required this.onLogout,
    required this.width,
    required this.isTabletOrLarger,
  });

  @override
  ConsumerState<ProfileFlyoutMenu> createState() => _ProfileFlyoutMenuState();
}

class _ProfileFlyoutMenuState extends ConsumerState<ProfileFlyoutMenu> {
  final ProfileService _profileService = ProfileService();
  bool _isLoading = true;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      // Get user info first (username and email)
      final userInfo = await _profileService.getUserInfo();

      // Then get the full profile
      final profile = await _profileService.getUserProfile();

      if (mounted) {
        setState(() {
          // Create a merged profile with user info and profile data
          _userProfile = profile.copyWith(
            username: userInfo['username'] ?? 'User',
            email: userInfo['email'] ?? 'user@example.com',
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading profile in flyout menu: $e");

      // Try to get just the user info if profile fails
      try {
        final userInfo = await _profileService.getUserInfo();
        if (mounted) {
          setState(() {
            // Create a basic profile with just user info
            _userProfile = UserProfile(
              userId: '',
              username: userInfo['username'] ?? 'User',
              email: userInfo['email'] ?? 'user@example.com',
              personalInfo: UserPersonalInfo(),
              fitnessStats: UserFitnessStats(),
              preferences: UserPreferences(),
            );
            _isLoading = false;
          });
        }
      } catch (userInfoError) {
        print("Error loading user info: $userInfoError");
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: widget.isTabletOrLarger ? 1 : 4,
      child: Container(
        width: widget.width,
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            // Profile image and user info
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(height: 12),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : Column(
                          children: [
                            Text(
                              _userProfile?.username ?? 'User Name',
                              style: Theme.of(context).textTheme.titleLarge,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              _userProfile?.email ?? 'user@example.com',
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Menu options
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile section with sub-options
                    _buildExpandableOption(
                      context,
                      'Profile',
                      Icons.person,
                      ['Your Information', 'Progress', 'Goals', 'Logs'],
                    ),

                    // General Settings section with sub-options
                    _buildExpandableOption(
                      context,
                      'General Settings',
                      Icons.settings,
                      ['Preferences', 'Account'],
                    ),

                    // Leaderboards section
                    _buildExpandableOption(
                      context,
                      'Leaderboards',
                      Icons.leaderboard,
                      ['Global'],
                    ),

                    // FAQs section
                    _buildOption(
                      context,
                      'FAQs',
                      Icons.question_answer,
                    ),

                    // Contact section
                    _buildOption(
                      context,
                      'Contact',
                      Icons.contact_mail,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            // Logout button
            _buildLogoutTile(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableOption(
    BuildContext context,
    String title,
    IconData icon,
    List<String> subOptions,
  ) {
    final isSelected = widget.selectedOption == title;

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        initiallyExpanded: isSelected,
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
        ),
        leading: Icon(icon),
        children: subOptions.map((subOption) {
          final isSubSelected =
              isSelected && widget.selectedSubOption == subOption;

          return ListTile(
            title: Text(
              subOption,
              overflow: TextOverflow.ellipsis,
            ),
            leading: const SizedBox(width: 16),
            selected: isSubSelected,
            selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
            onTap: () => widget.onOptionSelected(title, subOption),
            contentPadding: const EdgeInsets.only(left: 32.0, right: 16.0),
            dense: true,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final isSelected = widget.selectedOption == title;

    return ListTile(
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
      ),
      leading: Icon(icon),
      selected: isSelected,
      selectedTileColor:
          isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      onTap: () => widget.onOptionSelected(title),
      dense: true,
    );
  }

  Widget _buildLogoutTile() {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: const Text(
        'Logout',
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () async {
        await LogoutService.performLogout(context, ref);

        if (widget.onLogout != null) {
          widget.onLogout();
        }
      },
    );
  }
}
