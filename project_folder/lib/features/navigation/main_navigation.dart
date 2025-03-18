import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/view/pages/workout_tracker.dart';
// Import commented out but not deleted
// import '../yoga/view/pages/yoga_page.dart';
import '../library/view/pages/library_page.dart';
import '../profile/view/pages/profile_page.dart';
import '../../main.dart';
import '../profile/service/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _selectedIndex = 0;
  final GlobalKey<ProfilePageState> _profileKey = GlobalKey<ProfilePageState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      WorkoutTracker(),
      // YogaPage(), // Yoga page removed but commented for future reference
      LibraryPage(),
      ProfilePage(key: _profileKey),
    ];

    // Load theme from backend when navigation is initialized
    _loadThemeFromBackend();
  }

  Future<void> _loadThemeFromBackend() async {
    try {
      // Get user profile from backend
      final profileService = ProfileService();
      final userProfile = await profileService.getUserProfile();

      // Get the dark mode preference
      final isDarkMode = userProfile.preferences.darkMode;

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkMode', isDarkMode);

      // Update theme mode provider
      ref.read(themeModeProvider.notifier).state =
          isDarkMode ? ThemeMode.dark : ThemeMode.light;

      print("Theme loaded from backend: isDarkMode=$isDarkMode");
    } catch (e) {
      print("Error loading theme from backend: $e");
    }
  }

  void _onItemTapped(int index) {
    // If tapping on profile tab while already on profile tab
    // Updated index check for profile (now index 2 instead of 3)
    if (index == 2 && _selectedIndex == 2) {
      // Reset profile page to user information subgroup
      _profileKey.currentState?.resetToUserInformation();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the theme mode for changes
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Gym',
          ),
          // Yoga item removed
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14.0,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12.0,
        ),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 8.0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
