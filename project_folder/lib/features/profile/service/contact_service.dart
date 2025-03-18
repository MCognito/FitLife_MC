import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/contact_model.dart';
import '../../../config/api_config.dart';

class ContactService {
  // Dynamic base URL method
  static Future<String> getBaseUrl() async {
    return '${ApiConfig.baseUrl}/api/contact';
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
