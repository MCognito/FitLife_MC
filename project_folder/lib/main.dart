// Main file of the project
import 'package:flutter/material.dart';
import 'features/authentication/view/pages/login_page.dart';
import 'resources/theme/color_style.dart';
import 'package:provider/provider.dart'
    as provider; // Add prefix to provider package
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import flutter_riverpod
import 'features/authentication/viewmodel/auth_view_model.dart';
import 'features/navigation/main_navigation.dart';
import 'features/profile/viewmodel/contact_viewmodel.dart'; // Import ContactViewModel
import 'features/authentication/viewmodel/terms_and_conditions_viewmodel.dart'; // Import TermsConditionsViewModel
import 'features/profile/viewmodel/settings_viewmodel.dart'; // Import SettingsViewModel
import 'package:shared_preferences/shared_preferences.dart';
import 'features/profile/service/profile_service.dart';
import 'features/authentication/service/token_manager.dart';

// Global key for the app to force refresh when theme changes
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Provider for AuthViewModel that uses ProviderContainer
final authViewModelProvider = Provider<AuthViewModel>((ref) {
  return AuthViewModel(ref);
});

// Provider for theme mode
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.dark; // Default to dark theme
});

// Function to get the theme mode from backend if possible
Future<bool> getThemeModeFromBackend() async {
  try {
    // Check if user is logged in
    final userId = await TokenManager.getUserId();
    if (userId == null) {
      return true; // Default to dark theme if not logged in
    }

    // Try to get user profile from backend
    final profileService = ProfileService();
    final userProfile = await profileService.getUserProfile();

    // Return the darkMode preference
    return userProfile.preferences.darkMode;
  } catch (e) {
    print('Error getting theme from backend: $e');
    return true; // Default to dark theme on error
  }
}

// Main function that runs the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load theme preference from SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Try to get theme from backend first, then fallback to SharedPreferences
  bool isDarkMode;
  try {
    isDarkMode = await getThemeModeFromBackend();
    // Update SharedPreferences with backend value
    await prefs.setBool('darkMode', isDarkMode);
  } catch (e) {
    // If backend fails, use SharedPreferences
    isDarkMode = prefs.getBool('darkMode') ?? true;
  }

  runApp(
    ProviderScope(
      // Wrap with ProviderScope for Riverpod
      overrides: [
        // Override the default theme mode with the saved preference
        themeModeProvider.overrideWith(
            (ref) => isDarkMode ? ThemeMode.dark : ThemeMode.light),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final authViewModel = ref.watch(authViewModelProvider);
          final themeMode = ref.watch(themeModeProvider);

          return provider.MultiProvider(
            providers: [
              provider.ChangeNotifierProvider.value(value: authViewModel),
              provider.ChangeNotifierProvider(
                  create: (_) => ContactViewModel()),
              provider.ChangeNotifierProvider(
                  create: (_) => TermsConditionsViewModel()),
              provider.ChangeNotifierProvider(
                  create: (_) => SettingsViewModel(ref)),
            ],
            child: MyApp(themeMode: themeMode),
          );
        },
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ThemeMode themeMode;

  const MyApp({super.key, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: ValueKey(themeMode), // Force rebuild when theme changes
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      // Add text scaling to prevent overflow on small screens
      builder: (context, child) {
        // Limit text scaling to prevent overflow
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor:
                MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.0),
          ),
          child: child!,
        );
      },
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => MainNavigation(),
      },
    );
  }
}
