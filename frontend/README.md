# DeliveryFlow Frontend

Flutter mobile application for the DeliveryFlow delivery management system.

## Features

- **Authentication**: Login and registration with JWT tokens
- **Order Management**: Create, view, and track delivery orders
- **Real-time Tracking**: Live GPS tracking with Google Maps
- **Push Notifications**: Firebase Cloud Messaging integration
- **Material Design 3**: Modern UI following Material Design principles

## Tech Stack

- Flutter (Dart)
- Provider (State Management)
- Google Maps Flutter
- Socket.io Client
- HTTP Client
- Flutter Secure Storage

## Getting Started

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Configure Google Maps API:
   - Add your Google Maps API key to `android/app/src/main/AndroidManifest.xml`
   - Add your Google Maps API key to `ios/Runner/AppDelegate.swift`

3. Run the application:
```bash
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── constants/     # API endpoints, colors, strings
│   ├── theme/         # Material Design 3 theme
│   └── utils/         # Validation and helper functions
├── data/
│   ├── models/        # Data models (User, Order)
│   ├── providers/     # State management (Provider pattern)
│   └── services/      # API services and Socket.io
├── presentation/
│   ├── screens/       # App screens/pages
│   └── widgets/       # Reusable UI components
└── main.dart          # Application entry point
```

## Key Features

- **Cross-platform**: Runs on both Android and iOS
- **Real-time Updates**: Socket.io integration for live tracking
- **Offline Support**: Basic offline functionality
- **Material Design 3**: Modern UI with consistent theming
- **State Management**: Provider pattern for efficient state handling