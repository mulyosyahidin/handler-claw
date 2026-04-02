# HandlerClaw Mobile

Mobile application for HandlerClaw project built with Flutter. This app serves as the frontend for managing and receiving notifications from the HandlerClaw system.

## 🚀 Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** Riverpod 3.x
- **Navigation:** GoRouter
- **Networking:** Dio
- **Push Notifications:** Firebase Cloud Messaging (FCM)
- **Local Notifications:** `flutter_local_notifications`
- **Security:** `flutter_secure_storage` for token management
- **UI Components:** `CherryToast` for interactive feedback
- **Theming:** Custom Light/Dark theme support

## 🏗️ Architecture

The project follows a modular, feature-based architecture with a clear separation of concerns using the **DTO-Entity-Mapper** pattern:

- **Entities:** Domain models used within the application logic and UI.
- **DTOs (Data Transfer Objects):** Models representing API requests and responses.
- **Mappers:** Responsible for converting DTOs to Entities and vice versa.
- **Services:** Responsible for API communication and external data fetching.
- **Controllers (Providers):** Manage state logic using Riverpod.

### Folder Structure

```text
lib/
├── app/          # App-wide configuration (Router, Main App Entry)
├── core/         # Core utilities (Theme, Notification Handler, Constants)
├── features/     # Feature-based modules (Auth, Help, Home, Notifications)
│   ├── [feature]/
│   │   ├── data/           # Services and DTOs
│   │   ├── domain/         # Entities and Mappers
│   │   └── presentation/   # UI Pages, Widgets, and Controllers
├── shared/       # Shared components and utilities
└── main.dart     # Application bootstrap
```

## ✨ Features

- **Real-time Notifications:** Instant delivery via FCM with background and foreground handling.
- **Notification Inbox:** Paginated list view of received system notifications.
- **Notification Details:** Deep-dive into specific notification content.
- **Secure Authentication:** JWT-based login with persistent session management.
- **Device Management:** Automatic registration of device tokens for push notifications.
- **Dynamic Theming:** Seamless switching between light and dark modes based on system settings.

## 🛠️ Getting Started

### Prerequisites

- Flutter SDK (^3.11.1)
- Android Studio / VS Code with Flutter extension
- Firebase Project (configured via `firebase_options.dart`)

### Setup

1. **Clone the repository.**
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Configure Environment Variables:**
   The app uses `--dart-define` for configuration. For manual builds:
   ```bash
   --dart-define=API_BASE_URL=https://your-api.com/api
   ```

### Running the App

```bash
# Debug mode
flutter run

# build release APK
flutter build apk --release --dart-define=API_BASE_URL=https://your-api.com/api
```

## 🤖 CI/CD

Automated builds and distribution are handled via GitHub Actions.
- **Build & Distribute Android (APK)**: Automatically compiles and uploads the release APK to **Firebase App Distribution** on every push to the `development` branch.
- For more details, see the root [`.github/README.md`](../.github/README.md).
