# FitLife

FitLife is a comprehensive fitness mobile application developed using Flutter. The application aims to help users track their fitness journey, set goals, and maintain a healthy lifestyle.

## Features

### User Authentication

- **Registration and Login**: Secure user registration and login system.
- **JWT Authentication**: Token-based authentication for secure API requests.
- **Profile Management**: Users can create and manage their profiles.

### Profile Management

- **Personal Information**: Users can add and update their details including:
  - Age
  - Height
  - Gender
  - Date of Birth
- **Fitness Statistics**: Track progress with a level system based on activity and experience points earned.
- **User Preferences**: Customise the app experience with:
  - Dark/Light mode toggle
  - Notification settings
  - Sound effects toggle
  - Language selection
  - Unit system (Metric/Imperial)
  - Profile privacy settings

### Activity Tracking

- **Workout Tracking**: Log and monitor workout sessions.
- **Yoga Sessions**: Access and track yoga routines.
- **Step Counter**: Monitor daily steps.
- **Water Intake**: Log your daily water consumption.
- **Weight Tracking**: Monitor weight changes over time.

### Streak System

- **Daily Streaks**: Keep track of consecutive days of activity.
- **Streak Maintenance**: Enjoy a grace period system to maintain streaks.
- **Streak Statistics**: View current and longest streaks.

### Leaderboard

- **Global Rankings**: Compare progress with users worldwide.
- **Friend Rankings**: (Planned) Compare with friends.
- **Level-Based Sorting**: Users are ranked by their fitness level.

### User Interface

- **Bottom Navigation**: Easily switch between:
  - Gym/Workout Tracker
  - Yoga
  - Library
  - Profile
- **Modern Design**: Clean, intuitive, and responsive layouts.
- **Profile Dashboard**: Visual representation of your fitness progress.

## Recent Updates

### Change Password Functionality

- **Dedicated Page**: A new Change Password page that fits the app’s modern theme.
- **Email Notification**: Users receive an email confirming the password change (without additional links or buttons).

### Swipe-to-Delete Workouts

- **Gesture Control**: Swipe left on a workout to delete it.
- **Confirmation Dialog**: A prompt ensures that the deletion is intentional.
- **Data Consistency**: The deletion updates both the frontend and backend.

### UI Enhancements

- **Consistent Styling**: Improved colors, fonts, and layouts for a cohesive user experience.
- **Improved Navigation**: Responsive design updates for better usability.

## Technical Implementation

### Architecture

- **MVVM Pattern**: Separation of concerns using the Model-View-ViewModel architecture.
- **Service Layer**: Dedicated services for handling API communication.
- **Repository Pattern**: Abstraction layer for data access.

### Backend Integration

- **RESTful API**: Communication with a Node.js/Express backend.
- **MongoDB**: NoSQL database used for data storage.
- **JWT Authentication**: Secure API endpoints with token-based authentication.

### State Management

- **Provider Pattern**: Reactive state management.
- **ChangeNotifier**: Observable classes trigger UI updates.

### Data Persistence

- **Shared Preferences**: Local storage for user settings and cached data.
- **HTTP Client**: API communication using the http package.

## Getting Started

### Prerequisites

- **Flutter SDK** (latest version)
- **Dart SDK** (latest version)
- **Android Studio** or **VS Code** with Flutter extensions
- **Node.js** and **MongoDB** for backend (currently running locally)

### Installation

1. Clone the repository
   ```
   git clone https://github.coventry.ac.uk/pandyam2/FitLife
   ```
2. Navigate to the project directory
   ```
   cd FitLife/project_folder
   ```
3. Install dependencies
   ```
   flutter pub get
   ```
4. Run the application
   ```
   flutter run
   ```
