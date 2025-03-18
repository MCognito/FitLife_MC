import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/profile_flyout_menu.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_content.dart';
import '../../../authentication/service/auth_service.dart';
import '../../../authentication/providers/user_provider.dart';
import '../../../home/providers/workout_provider.dart';
import '../../../authentication/service/logout_service.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfilePage> createState() => ProfilePageState();
}

// Make the state class public so it can be accessed with a GlobalKey
class ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isFlyoutOpen = false;
  String _selectedOption = 'Profile';
  String _selectedSubOption = 'Your Information';
  bool _hasSelectedOption = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    // Set default selected option to Profile and Your Information
    _selectedOption = 'Profile';
    _selectedSubOption = 'Your Information';
    _hasSelectedOption = true;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Method to reset to user information subgroup
  void resetToUserInformation() {
    setState(() {
      _selectedOption = 'Profile';
      _selectedSubOption = 'Your Information';
      _hasSelectedOption = true;

      // Close the flyout if it's open
      if (_isFlyoutOpen) {
        _isFlyoutOpen = false;
        _animationController.reverse();
      }
    });
  }

  // Public method to navigate to a specific option
  void navigateTo(String option, [String? subOption]) {
    _selectOption(option, subOption);
  }

  void _toggleFlyout() {
    setState(() {
      _isFlyoutOpen = !_isFlyoutOpen;
      if (_isFlyoutOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _selectOption(String option, [String? subOption]) {
    setState(() {
      _selectedOption = option;
      _hasSelectedOption = true;

      if (subOption != null) {
        _selectedSubOption = subOption;
      } else {
        // Default sub-option for each main option
        switch (option) {
          case 'Profile':
            _selectedSubOption = 'Your Information';
            break;
          case 'General Settings':
            _selectedSubOption = 'Preferences';
            break;
          case 'Leaderboards':
            _selectedSubOption = 'Global';
            break;
          default:
            _selectedSubOption = '';
        }
      }

      // Close the flyout after selection on mobile
      if (MediaQuery.of(context).size.width < 600) {
        _isFlyoutOpen = false;
        _animationController.reverse();
      }
    });
  }

  Future<void> _handleLogout() async {
    // Use the new LogoutService to handle logout
    await LogoutService.performLogout(context, ref);
  }

  // Get the appropriate title based on selected options
  String _getAppBarTitle() {
    if (_selectedOption == 'Profile') {
      return _selectedSubOption;
    } else if (_selectedSubOption.isNotEmpty) {
      return _selectedSubOption;
    } else {
      return _selectedOption;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrLarger = screenWidth >= 600;
    final menuWidth =
        isTabletOrLarger ? screenWidth * 0.25 : screenWidth * 0.75;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        centerTitle: true,
        leading: isTabletOrLarger
            ? null
            : IconButton(
                icon: AnimatedIcon(
                  icon: AnimatedIcons.menu_close,
                  progress: _animationController,
                ),
                onPressed: _toggleFlyout,
              ),
      ),
      body: SafeArea(
        child: Row(
          children: [
            // Flyout menu - always visible on tablet/desktop, animated on mobile
            if (isTabletOrLarger || _isFlyoutOpen)
              SizedBox(
                width: menuWidth,
                child: ProfileFlyoutMenu(
                  selectedOption: _selectedOption,
                  selectedSubOption: _selectedSubOption,
                  onOptionSelected: _selectOption,
                  onLogout: _handleLogout,
                  width: menuWidth,
                  isTabletOrLarger: isTabletOrLarger,
                ),
              ),

            // Main content area - only show content when flyout is closed
            if (!_isFlyoutOpen || isTabletOrLarger)
              Expanded(
                child: ProfileContent(
                  selectedOption: _selectedOption,
                  selectedSubOption: _selectedSubOption,
                ),
              ),
            // Empty space when flyout is open on mobile
            if (_isFlyoutOpen && !isTabletOrLarger)
              Expanded(
                child: Container(),
              ),
          ],
        ),
      ),
    );
  }
}
