// This file contains the AuthService class which is responsible for handling the authentication logic in the application.
// The class contains two methods, register and login, which are responsible for registering and logging in users respectively.
// The methods make use of the http package to make API calls to the backend server.
// The register method sends a POST request to the /register endpoint with the user's username, email, and password as the request body.
// The login method sends a POST request to the /login endpoint with the user's email and password as the request body.
// Both methods return a boolean value indicating whether the operation was successful or not.
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Base URL of the backend server
  final String baseUrl = "http://localhost:5000/api/auth";

  // Method to register a new user
  Future<bool> register(String username, String email, String password) async {
    final response = await http.post(
      // Send a POST request to the /register endpoint
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
          {"username": username, "email": email, "password": password}),
    );

    // Check if the request was successful
    if (response.statusCode == 201) {
      return true;
    } else {
      return false; // This ensures failure cases return false
    }
  }

  // Method to log in a user
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      // Send a POST request to the /login endpoint
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}
