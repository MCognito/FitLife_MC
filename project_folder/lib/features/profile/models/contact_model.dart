class ContactModel {
  final String name;
  final String email;
  final String subject;
  final String message;
  final String category;

  ContactModel({
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    required this.category,
  });

  // Convert model to JSON for API request
  Map<String, String> toJson() {
    return {
      "name": name,
      "email": email,
      "subject": subject,
      "message": message,
      "category": category,
    };
  }
}
