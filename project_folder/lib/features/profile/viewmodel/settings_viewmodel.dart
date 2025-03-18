import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import '../service/profile_service.dart';
import '../models/user_profile.dart';
import '../../authentication/service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart'; // Import for themeModeProvider

class SettingsViewModel extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  final Object? _ref;

  bool _isLoading = true;
  String? _errorMessage;

  // Settings state
  bool _darkMode = false;
  bool _notifications = true; // Local state only, not stored in backend
  bool _soundEffects = true; // Local state only, not stored in backend
  String _selectedLanguage = 'English';
  bool _publicProfile = false;

  // Language options
  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese'
  ];

  // Constructor with optional ref
  SettingsViewModel([this._ref]);

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get darkMode => _darkMode;
  bool get notifications => _notifications;
  bool get soundEffects => _soundEffects;
  String get selectedLanguage => _selectedLanguage;
  bool get publicProfile => _publicProfile;
  List<String> get languages => _languages;

  // Setters
  void setDarkMode(bool value) {
    if (_darkMode == value) return; // No change, do nothing

    _darkMode = value;

    // Update theme mode provider if ref is available
    if (_ref != null && _ref is ProviderRef) {
      (_ref as ProviderRef).read(themeModeProvider.notifier).state =
          value ? ThemeMode.dark : ThemeMode.light;
    }

    // Save to SharedPreferences immediately
    _saveDarkModePreference(value);

    // Save to backend immediately
    _saveDarkModeToBackend(value);

    notifyListeners();
  }

  // Save dark mode preference to SharedPreferences
  Future<void> _saveDarkModePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }

  // Save dark mode preference to backend
  Future<void> _saveDarkModeToBackend(bool value) async {
    try {
      // Get current preferences from backend
      final userProfile = await _profileService.getUserProfile();

      // Create updated preferences
      final updatedPreferences = UserPreferences(
        darkMode: value,
        language: userProfile.preferences.language,
        unitSystem: userProfile.preferences.unitSystem,
        publicProfile: userProfile.preferences.publicProfile,
        notifications: userProfile.preferences.notifications,
        soundEffects: userProfile.preferences.soundEffects,
      );

      // Update preferences in the backend
      await _profileService.updatePreferences(updatedPreferences);

      print("Dark mode updated in backend: $value");
    } catch (e) {
      print("Error updating dark mode in backend: $e");
      // Don't throw, just log the error
    }
  }

  void setNotifications(bool value) {
    _notifications = value;
    notifyListeners();
  }

  void setSoundEffects(bool value) {
    _soundEffects = value;
    notifyListeners();
  }

  void setPublicProfile(bool value) {
    _publicProfile = value;
    notifyListeners();
  }

  void setLanguage(String value) {
    if (_languages.contains(value)) {
      _selectedLanguage = value;
      notifyListeners();
    }
  }

  // Load user preferences from the backend
  Future<void> loadUserPreferences() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userProfile = await _profileService.getUserProfile();
      final prefs = await SharedPreferences.getInstance();

      // Get darkMode from backend first, then fallback to SharedPreferences
      _darkMode = userProfile.preferences.darkMode;

      // Save the backend value to SharedPreferences to keep them in sync
      await prefs.setBool('darkMode', _darkMode);

      // Load notifications and sound effects from local storage instead of backend
      _notifications = prefs.getBool('notifications') ?? true;
      _soundEffects = prefs.getBool('soundEffects') ?? true;
      _selectedLanguage = userProfile.preferences.language;
      _publicProfile = userProfile.preferences.publicProfile;

      // Update theme mode provider if ref is available
      if (_ref != null && _ref is ProviderRef) {
        (_ref as ProviderRef).read(themeModeProvider.notifier).state =
            _darkMode ? ThemeMode.dark : ThemeMode.light;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load preferences: $e';
      _isLoading = false;
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  // Save user preferences to the backend
  Future<void> saveUserPreferences() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Save notifications and sound effects to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications', _notifications);
      await prefs.setBool('soundEffects', _soundEffects);
      await prefs.setBool('darkMode', _darkMode);

      // Create UserPreferences object (without notifications and sound effects)
      final updatedPreferences = UserPreferences(
        darkMode: _darkMode,
        language: _selectedLanguage,
        unitSystem:
            'Metric', // Default to Metric as we're not exposing this option
        publicProfile: _publicProfile,
        // Include notifications and sound effects for backend storage
        notifications: _notifications,
        soundEffects: _soundEffects,
      );

      // Update preferences in the backend
      await _profileService.updatePreferences(updatedPreferences);

      // Apply theme change immediately
      if (_ref != null && _ref is ProviderRef) {
        (_ref as ProviderRef).read(themeModeProvider.notifier).state =
            _darkMode ? ThemeMode.dark : ThemeMode.light;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to save preferences: $e';
      _isLoading = false;
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  // Delete user account
  Future<bool> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call the delete account API
      await _authService.deleteAccount();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete account: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
