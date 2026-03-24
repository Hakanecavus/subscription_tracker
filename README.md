# Subscription Tracker

A Flutter application for tracking subscriptions and recurring payments.

## Architecture

This project follows Clean Architecture principles with:

- **Domain Layer**: Business logic, entities, and repository contracts
- **Data Layer**: Models, data sources, and repository implementations
- **Presentation Layer**: UI, providers, and screens

### Project Structure

```
lib/
├── core/                    # Core utilities and configurations
│   ├── constants/          # App constants
│   ├── errors/             # Failure classes
│   ├── theme/              # App theme and typography
│   └── utils/              # Utility classes and extensions
├── data/                   # Data layer
│   ├── datasources/        # Local and remote data sources
│   ├── models/             # Data models
│   └── repositories/       # Repository implementations
├── domain/                 # Domain layer
│   ├── entities/           # Business entities
│   ├── repositories/       # Repository contracts
│   └── usecases/           # Business use cases
├── presentation/            # Presentation layer
│   ├── providers/          # State management
│   ├── screens/            # UI screens
│   └── widgets/            # Reusable widgets
└── main.dart               # Application entry point
```

## Tech Stack

- **State Management**: Riverpod
- **Navigation**: Go Router
- **Database**: SQLite (sqflite)
- **Notifications**: flutter_local_notifications
- **Background Tasks**: workmanager
- **Charts**: fl_chart
- **Security**: local_auth + flutter_secure_storage
- **Code Generation**: Freezed + json_serializable

## Features

- Track subscriptions with customizable billing cycles
- Category management with custom colors
- Monthly/yearly cost analytics
- Upcoming payment reminders
- Biometric authentication
- Dark/Light theme support
- Local data backup and export

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter pub run build_runner build` to generate code
4. Run `flutter run` to start the application

## Code Generation

```bash
# Generate code once
flutter pub run build_runner build

# Generate code and watch for changes
flutter pub run build_runner watch

# Generate code (delete conflicting outputs)
flutter pub run build_runner build --delete-conflicting-outputs
```

## Testing

```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage
```

## Building

```bash
# Debug build
flutter build apk

# Release build
flutter build apk --release

# iOS build (requires macOS)
flutter build ios

# Web build
flutter build web
```

## License

This project is licensed under the MIT License.
