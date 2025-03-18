import 'package:flutter/material.dart';
import '../models/contact_model.dart';
import '../service/contact_service.dart';

class ContactViewModel extends ChangeNotifier {
  bool isSubmitting = false;

  // Function to handle contact form submission
  Future<void> submitContactForm(
      BuildContext context, ContactModel contact) async {
    isSubmitting = true;
    notifyListeners(); // Update UI state

    bool success = await ContactService.sendContactForm(contact);

    isSubmitting = false;
    notifyListeners(); // Update UI state after response

    // Show success or error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? "Your message has been sent successfully!"
            : "Failed to send message. Please try again."),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}
