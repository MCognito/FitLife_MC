import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import '../models/contact_model.dart';

class ContactService {
  // Dynamic base URL method
  static Future<String> getBaseUrl() async {
    if (kIsWeb) {
      return "http://localhost:5000/api/contact"; // Web (Chrome, Edge, etc.)
    } else if (Platform.isAndroid) {
      bool isEmulator = await _isAndroidEmulator();
      return isEmulator
          ? "http://10.0.2.2:5000/api/contact" // Android Emulator
          : "http://192.168.1.38:5000/api/contact"; // Default for other Android devices
    } else if (Platform.isIOS) {
      return "http://localhost:5000/api/contact"; // iOS Simulator
    } else {
      return "http://192.168.1.38:5000/api/contact"; // Default for other devices
    }
  }

  // Check if running on Android emulator
  static Future<bool> _isAndroidEmulator() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return !androidInfo.isPhysicalDevice;
  }

  // Function to send contact form data to the backend
  static Future<bool> sendContactForm(ContactModel contact) async {
    try {
      final baseUrl = await getBaseUrl();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(contact.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData["success"] == true;
      } else {
        print(
            "❌ ContactService Error: Status code ${response.statusCode}, Body: ${response.body}");
        return false;
      }
    } catch (error) {
      print("❌ ContactService Error: $error");
      return false;
    }
  }
}
