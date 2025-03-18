# FitLife App Tests

This directory contains tests for the FitLife application, organized by feature.

## Test Structure

- `widget_test.dart`: Basic app initialization test
- Feature-specific test directories:
  - `authentication/`: Tests for login, registration, password reset, and auth services
  - `home/`: Tests for workout tracking and other home screen features
  - `library/`: Tests for exercise library functionality
  - `navigation/`: Tests for app navigation
  - `profile/`: Tests for user profile and goals

## Authentication Tests

The `authentication/` directory contains the following tests:

- `login_test.dart`: Tests for the login page UI and validation
- `registration_test.dart`: Tests for the registration page UI and validation
- `password_reset_test.dart`: Tests for the password reset functionality
- `auth_service_test.dart`: Tests for the authentication service

## Running Tests

### Prerequisites

Before running the tests, make sure you have the following dependencies installed:

```bash
flutter pub get
```

### Running All Tests

To run all tests in the project:

```bash
flutter test
```

### Running Tests for a Specific Feature

To run tests for a specific feature:

```bash
flutter test test/authentication/
flutter test test/home/
flutter test test/library/
flutter test test/navigation/
flutter test test/profile/
```

### Running a Single Test File

To run a specific test file:

```bash
flutter test test/authentication/login_test.dart
```

## Generating Mock Classes

The tests use `mockito` for mocking dependencies. To generate mock classes:

```bash
flutter pub run build_runner build
```

This will generate the necessary mock files for the tests.

## Troubleshooting

If you encounter issues with the tests:

1. Make sure all dependencies are up to date: `flutter pub get`
2. Clear the build cache: `flutter clean`
3. Regenerate mock classes: `flutter pub run build_runner build --delete-conflicting-outputs`
4. Check that the app can run normally: `flutter run`
