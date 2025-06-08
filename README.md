# WinkChat

## Project Description

WinkChat is a Minimum Viable Product (MVP) mobile application designed to facilitate human connections based on personality and conversation, rather than physical appearance. The app aims to break communication barriers, reduce the fear of rejection, and combat loneliness by enabling anonymous text-based chat with users located in defined administrative geographical areas (e.g., voivodeship, city, country). It focuses on a simple, text-based interaction flow to validate the core product hypothesis.

## Demo

![Demo aplikacji WinkChat](assets/gifs/demo.gif)

## Tech Stack

**Frontend (Mobile Application):**

- **Framework:** Flutter 3.29.3
- **Programming Language:** Dart 3.7.2
- **Key Libraries/Packages:**
  - `firebase_core: ^2.32.0`: Core Firebase plugin for Flutter
  - `firebase_auth: ^4.17.5`: Firebase Auth plugin for Flutter
  - `cloud_firestore: ^4.15.5`: Firestore plugin for Flutter
  - `dio: ^5.8.0+1`: A powerful HTTP client for Dart
  - `riverpod: ^2.6.1`: A simple state-management library
  - `flutter_riverpod: ^2.6.1`: Riverpod integration for Flutter
  - `equatable: ^2.0.7`: A library to compare objects
  - `flutter_dotenv: ^5.2.1`: For managing environment variables
  - `font_awesome_flutter: ^10.8.0`: The official Font Awesome icon pack
  - `cupertino_icons: ^1.0.8`: iOS-style icons
- **Testing Tools:**
  - `flutter_test`: Core testing framework for unit and widget tests
  - `integration_test`: Package for integration testing
  - `flutter_driver`: Tool for end-to-end testing
  - `mockito`: A popular mocking library.
  - `fake_cloud_firestore`: A library to create a fake in-memory Firestore instance for testing.
  - Firebase Test Lab: Cloud-based app testing infrastructure

**Backend:**

- **Platform:** Firebase
- **Database:** Firestore (or other Firebase database service as needed)
- **Key Firebase Services:**
  - Firebase Authentication (User authentication system)
  - Firebase Realtime Database / Firestore (Real-time chat handling)
  - Firebase Cloud Functions (Backend logic)

## Getting Started Locally

To get a local copy up and running, follow these simple steps.

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/GrzSwa/wink_chat.git
    cd wink_chat
    ```

2.  **Ensure Flutter SDK is installed:**

    Make sure you have the Flutter SDK installed and configured on your system. Refer to the official [Flutter documentation](https://flutter.dev/docs/get-started) for installation guides.

3.  **Get dependencies:**

    Navigate to the project directory and run:

    ```bash
    flutter pub get
    ```

4.  **Set up Firebase:**

    This project relies on a Firebase backend. You will need to set up your own Firebase project and configure the application to connect to it. Refer to the official [Firebase documentation](https://firebase.google.com/docs/flutter/setup) for installation and setup guides for Flutter.

5.  **Run the application:**

    Connect a device or start an emulator and run the app:

    ```bash
    flutter run
    ```

## Available Scripts

In the project directory, you can run:

- `flutter run`: Runs the app on a connected device or simulator.
- `flutter build <platform>`: Builds the app for a specific platform (e.g., `android`, `ios`).
- `flutter test`: Runs all tests.
- `flutter analyze`: Analyzes the project for potential issues.
- `flutter clean`: Cleans the build output.
- `flutter pub get`: Fetches all the dependencies for the project.
- `flutter pub upgrade`: Updates the dependencies to their latest versions.

## Project Scope (MVP)

This project is an MVP focusing on the core anonymous text-based chat functionality. The key features included are:

- User registration and login (email/password).
- Anonymous profile setup (nickname, gender).
- Selection of administrative location scope for searching (voivodeship, city, country).
- Searching and listing active users within the selected location (displaying only nickname, gender, activity status).
- Initiating a conversation via chat request.
- Chat screen displaying active conversations and pending requests.
- Real-time text messaging within active chats.
- Basic user reporting system with manual verification after 10 reports.

The following functionalities are explicitly **out of scope** for this MVP:

- Sending/receiving multimedia (photos, videos, voice messages).
- User profiles with photos.
- Advanced search filters (e.g., age, interests).
- Automatic user matching algorithms.
- Push notifications for new messages/requests.
- Advanced moderation and security features.
- In-app identity reveal or contact information exchange.
- Group chats.
- UI customization.
- Monetization features (ads, premium subscriptions).
- Geolocation based on precise user radius.
- Real-time notification of new chat requests outside the chat screen.

## Project Status

This project is currently in its Minimum Viable Product (MVP) phase. It includes core features for anonymous text-based chat based on location and personality, as defined in the project scope.

## License

MIT License

## Testing

The project includes comprehensive testing setup with:

- **Unit Tests:** Using Flutter Test Framework with minimum 80% code coverage
- **Widget Tests:** For UI components, responsiveness, and accessibility
- **Integration Tests:** For Firebase integration and inter-module communication
- **E2E Tests:** For main user flows including authentication and chat scenarios
- **Performance Tests:** For chat system load testing, concurrent connections, and Firebase response times

For detailed testing information, refer to `.ai/test-plan.md`.
