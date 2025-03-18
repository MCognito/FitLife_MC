// This file contains the validation logic for the authentication form fields
// The validation logic is separated from the UI logic to make the code more readable and maintainable
// The validation logic is implemented using the ViewModel pattern

class AuthValidationViewModel {
  // Validate the email field
  String? validateEmail(String? email) {
    // Check if the email is empty
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    // Check if the email is valid using a regular expression
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Validate the password field for registration
  String? validatePassword(String? password) {
    // Check if the password is empty
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    // Check if the password meets the backend requirements
    // Must have at least 8 characters, including uppercase, lowercase, number, and special character
    final passwordRegex = RegExp(
        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

    if (!passwordRegex.hasMatch(password)) {
      return 'Password must contain at least 8 characters, including uppercase, lowercase, number, and special character';
    }

    return null;
  }

  // Validate the password field for login (simplified)
  String? validateLoginPassword(String? password) {
    // Check if the password is empty
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  // Validate the username field
  String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Username is required';
    }
    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  // Validate the confirm password field
  String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}
