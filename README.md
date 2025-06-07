# Fasting Tracker App

A Flutter application for tracking intermittent fasting sessions with Firebase authentication and cloud storage.

## Features

- 🔐 **User Authentication**: Email/password login and registration
- 📊 **Fasting Tracking**: Start, stop, and monitor fasting sessions
- ☁️ **Cloud Storage**: All data synced to Firebase Firestore
- 📱 **Cross-Platform**: Works on iOS, Android, and other Flutter-supported platforms
- 🔔 **Notifications**: Local notifications for fasting reminders

## Firebase Setup

This app is already configured with Firebase. Here's what's been set up:

### 1. Firebase Project

- Project ID: `fasting-app-c37bc`
- Project Name: "Fasting App"

### 2. Firebase Services Enabled

- **Authentication**: Email/Password sign-in
- **Firestore Database**: For storing fasting data
- **Firebase Storage**: For future file storage needs

### 3. Platform Configuration

- ✅ Android app registered
- ✅ iOS app registered
- ✅ Firebase configuration files generated

## Getting Started

### Prerequisites

- Flutter SDK (>=3.2.3)
- Firebase CLI
- Node.js (>=20.0.0 for Firebase CLI)

### Installation

1. **Clone the repository**

   ```bash
   git clone <your-repo-url>
   cd flutter_application_1
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Firebase Setup** (Already done, but for reference)

   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools

   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli

   # Login to Firebase
   firebase login

   # Configure Firebase for Flutter
   flutterfire configure --project=fasting-app-c37bc
   ```

4. **Enable Authentication in Firebase Console**

   - Go to [Firebase Console](https://console.firebase.google.com/project/fasting-app-c37bc/authentication/providers)
   - Click on "Email/Password" provider
   - Enable "Email/Password" authentication
   - Save the changes

5. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point with Firebase initialization
├── firebase_options.dart     # Auto-generated Firebase configuration
├── models/
│   ├── fasting_session.dart  # Fasting session data model
│   └── fasting_type.dart     # Fasting type definitions
├── services/
│   ├── auth_service.dart     # Firebase Authentication service
│   ├── firestore_service.dart # Firestore database service
│   ├── storage_service.dart  # Local storage service
│   └── notification_service.dart # Local notifications
├── providers/
│   └── fasting_provider.dart # State management for fasting data
├── screens/
│   ├── auth/
│   │   ├── auth_wrapper.dart # Authentication state wrapper
│   │   ├── login_screen.dart # Login screen
│   │   └── signup_screen.dart # Registration screen
│   ├── home_screen.dart      # Main app screen
│   └── history_screen.dart   # Fasting history
```

## Firebase Services Used

### Authentication (`auth_service.dart`)

- Email/password registration and login
- Password reset functionality
- User session management
- Account deletion and email updates

### Firestore Database (`firestore_service.dart`)

- User fasting sessions storage
- Real-time data synchronization
- User statistics tracking
- Batch operations for performance

### Data Structure

```
users/{userId}/
├── fasting_sessions/{sessionId}
│   ├── startTime: Timestamp
│   ├── endTime: Timestamp?
│   ├── fastingTypeName: String
│   ├── targetDuration: Number (minutes)
│   ├── completed: Boolean
│   └── createdAt: Timestamp
└── user_stats/stats
    ├── totalSessions: Number
    ├── totalFastingTime: Number
    ├── longestFast: Number
    └── averageFastDuration: Number
```

## Usage

1. **First Time Setup**

   - Open the app
   - Create an account with email and password
   - Start tracking your fasting sessions

2. **Authentication**

   - Login with your email and password
   - Use "Forgot Password" to reset if needed
   - All data is automatically synced to your account

3. **Fasting Tracking**
   - Start a new fasting session
   - Monitor progress in real-time
   - View your fasting history
   - All data is automatically saved to the cloud

## Development

### Adding New Features

1. Create new services in `lib/services/`
2. Add data models in `lib/models/`
3. Create screens in `lib/screens/`
4. Update providers for state management

### Firebase Rules

The app uses the default Firestore security rules. For production, consider updating `firestore.rules` with more specific rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Troubleshooting

### Common Issues

1. **Firebase not initialized**

   - Ensure `firebase_options.dart` exists
   - Check that Firebase.initializeApp() is called in main()

2. **Authentication errors**

   - Verify Email/Password is enabled in Firebase Console
   - Check network connectivity

3. **Firestore permission errors**
   - Ensure user is authenticated
   - Check Firestore security rules

### Getting Help

- Check the [Flutter Firebase documentation](https://firebase.flutter.dev/)
- Review [Firebase Console](https://console.firebase.google.com/project/fasting-app-c37bc) for your project
- Check Flutter and Firebase versions compatibility

## License

This project is licensed under the MIT License - see the LICENSE file for details.
