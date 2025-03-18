// UserModel class is used to store the user data that is fetched from the server.
// It has three properties: id, username, and email.
// The factory method fromJson is used to convert the JSON data to UserModel object.

class UserModel {
  final String id;
  final String username;
  final String email;

  // Constructor for UserModel (atributtes must be required)
  UserModel({
    required this.id,
    required this.username,
    required this.email,
  });

  // Factory method to convert JSON data to UserModel object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle MongoDB ObjectId format
    String extractId(dynamic idField) {
      if (idField == null) return '';
      if (idField is String) return idField;
      if (idField is Map && idField.containsKey('\$oid')) {
        return idField['\$oid'];
      }
      return idField.toString();
    }

    return UserModel(
      id: json.containsKey('_id') ? extractId(json['_id']) : (json['id'] ?? ''),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
    );
  }

  // Check if the user model is valid
  bool isValid() {
    return id.isNotEmpty && username.isNotEmpty && email.isNotEmpty;
  }
}
