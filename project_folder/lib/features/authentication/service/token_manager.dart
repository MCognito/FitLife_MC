import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _tokenKey = 'jwt_token';
  static const String _userIdKey = 'user_id';

  // Save JWT token to shared preferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get JWT token from shared preferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Remove JWT token from shared preferences (logout)
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Save user ID to shared preferences
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  // Get user ID from shared preferences
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Remove user ID from shared preferences (logout)
  static Future<void> removeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all authentication data (logout)
  static Future<void> clearAuthData() async {
    await removeToken();
    await removeUserId();
  }
}
