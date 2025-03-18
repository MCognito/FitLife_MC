import 'package:flutter_test/flutter_test.dart';
import 'package:fitlife/features/authentication/model/user_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserModel Tests', () {
    test('UserModel.fromJson correctly parses JSON data', () {
      // Arrange
      final json = {
        '_id': '507f1f77bcf86cd799439011',
        'username': 'testuser',
        'email': 'test@example.com',
        'createdAt': '2023-01-01T00:00:00.000Z',
        'updatedAt': '2023-01-02T00:00:00.000Z'
      };

      // Act
      final userModel = UserModel.fromJson(json);

      // Assert
      expect(userModel.id, '507f1f77bcf86cd799439011');
      expect(userModel.username, 'testuser');
      expect(userModel.email, 'test@example.com');
    });

    test('UserModel.fromJson handles MongoDB ObjectId format', () {
      // Arrange
      final json = {
        '_id': {'\$oid': '507f1f77bcf86cd799439011'},
        'username': 'testuser',
        'email': 'test@example.com'
      };

      // Act
      final userModel = UserModel.fromJson(json);

      // Assert
      expect(userModel.id, '507f1f77bcf86cd799439011');
      expect(userModel.username, 'testuser');
      expect(userModel.email, 'test@example.com');
    });

    test('UserModel.isValid returns true for valid model', () {
      // Arrange
      final userModel = UserModel(
          id: '507f1f77bcf86cd799439011',
          username: 'testuser',
          email: 'test@example.com');

      // Act & Assert
      expect(userModel.isValid(), true);
    });

    test('UserModel.isValid returns false for invalid model', () {
      // Arrange
      final userModel = UserModel(id: '', username: '', email: '');

      // Act & Assert
      expect(userModel.isValid(), false);
    });
  });

  group('Authentication Validation Tests', () {
    test('Email validation should reject empty emails', () {
      expect(isValidEmail(''), false);
    });

    test('Email validation should reject invalid email formats', () {
      expect(isValidEmail('notanemail'), false);
      expect(isValidEmail('missing@domain'), false);
      expect(isValidEmail('@nodomain.com'), false);
    });

    test('Email validation should accept valid email formats', () {
      expect(isValidEmail('test@example.com'), true);
      expect(isValidEmail('user.name@domain.co.uk'), true);
    });

    test('Password validation should reject empty passwords', () {
      expect(isValidPassword(''), false);
    });

    test('Password validation should reject short passwords', () {
      expect(isValidPassword('pass'), false);
    });

    test('Password validation should accept valid passwords', () {
      expect(isValidPassword('Password123!'), true);
    });
  });
}

// Simple validation functions for testing
bool isValidEmail(String email) {
  if (email.isEmpty) return false;
  final emailRegExp =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return emailRegExp.hasMatch(email);
}

bool isValidPassword(String password) {
  return password.length >= 8;
}
