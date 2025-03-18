import 'dart:convert';
import 'dart:io' show Platform, SocketException;
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/library_item.dart';
import '../../authentication/service/token_manager.dart'; // Import the token manager

class LibraryService {
  // Dynamic base URL method
  static Future<String> getBaseUrl() async {
    if (kIsWeb) {
      return "http://localhost:5000/api/library"; // Web (Chrome, Edge, etc.)
    } else if (Platform.isAndroid) {
      bool isEmulator = await _isAndroidEmulator();
      return isEmulator
          ? "http://10.0.2.2:5000/api/library" // Android Emulator
          : "http://192.168.1.38:5000/api/library"; // Default for other Android devices
    } else if (Platform.isIOS) {
      return "http://localhost:5000/api/library"; // iOS Simulator
    } else {
      return "http://192.168.1.38:5000/api/library"; // Default for other devices
    }
  }

  // Check if the app is running on an Android emulator
  static Future<bool> _isAndroidEmulator() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    // Check common emulator properties
    bool isEmulator = androidInfo.isPhysicalDevice == false ||
        androidInfo.hardware.contains("ranchu") ||
        androidInfo.hardware.contains("goldfish") ||
        androidInfo.fingerprint.contains("generic");

    return isEmulator;
  }

  // Get auth headers with JWT token
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await TokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all library items
  Future<List<LibraryItem>> getLibraryItems() async {
    try {
      final baseUrl = await getBaseUrl();
      final headers = await _getAuthHeaders();
      print('Fetching library items from: $baseUrl'); // Debug log

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      print('Response status code: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        final items = data.map((json) => LibraryItem.fromJson(json)).toList();
        print('Parsed ${items.length} library items'); // Debug log
        return items;
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        throw Exception("Authentication failed. Please login again.");
      } else {
        print(
            "Failed to load library items. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception("Failed to load library items");
      }
    } catch (e) {
      print("Error in getLibraryItems: $e");
      throw Exception("Failed to load library items: $e");
    }
  }

  // Get library items by category
  Future<List<LibraryItem>> getLibraryItemsByCategory(String category) async {
    try {
      final baseUrl = await getBaseUrl();
      final headers = await _getAuthHeaders();

      final response = await http.get(
        Uri.parse("$baseUrl/category/$category"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => LibraryItem.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        throw Exception("Authentication failed. Please login again.");
      } else {
        print(
            "Failed to load library items. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception("Failed to load library items");
      }
    } catch (e) {
      print("Error in getLibraryItemsByCategory: $e");
      throw Exception("Failed to load library items: $e");
    }
  }

  // Add a new library item (admin only)
  Future<LibraryItem> addLibraryItem(LibraryItem item) async {
    try {
      final baseUrl = await getBaseUrl();
      final headers = await _getAuthHeaders();

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(item.toJson()),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return LibraryItem.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception("Authentication failed. Please login again.");
      } else if (response.statusCode == 403) {
        throw Exception("You don't have permission to add library items.");
      } else {
        print(
            "Failed to add library item. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception("Failed to add library item");
      }
    } catch (e) {
      print("Error in addLibraryItem: $e");
      throw Exception("Failed to add library item: $e");
    }
  }
}
