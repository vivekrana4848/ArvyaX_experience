# ArvyaX Immersive Session App

A premium Flutter application designed for mindfulness, relaxation, and journaling.

## Architecture: Clean Architecture

This project follows Clean Architecture principles to ensure scalability, maintainability, and testability.

### Layers:
1.  **Data Layer** (`lib/data`, `lib/repositories`):
    *   Handles data retrieval from local JSON (`assets/data/ambience.json`).
    *   Manages persistent storage using **Hive** (`lib/repositories/journal_repository.dart`).
2.  **Model Layer** (`lib/models`):
    *   Defines core data entities like `Ambience` and `JournalEntry`.
    *   Includes Hive TypeAdapters for serialization.
3.  **Presentation Layer** (`lib/features`):
    *   **Ambience**: Home screen with search and filtering logic.
    *   **Player**: Immersive audio player with real-time timer and animations.
    *   **Journal**: Post-session reflection tools and history tracking.
4.  **Shared Layer** (`lib/shared`):
    *   **Providers**: Centralized state management using `Provider`.
    *   **Theme**: Curated Dark and Light modes for a premium feel.
    *   **Widgets**: Reusable UI components like the `MiniPlayer`.

## Key Features
*   **Immersive Audio**: Powered by `just_audio` with continuous looping.
*   **Session Timer**: Automatically ends sessions and prompts for journaling.
*   **Persistent Journal**: Hive-based local storage for all your reflections.
*   **Responsive UI**: Minimalist design that adapts to various screen sizes.
*   **Search & Filter**: Quickly find the perfect ambience for your mood.

## Running the App
1.  `flutter pub get`
2.  `flutter pub run build_runner build` (to generate Hive adapters)
3.  `flutter run`

## Dependencies
*   `provider`: State management
*   `just_audio`: Audio playback
*   `hive`: Local persistence
*   `path_provider`: File system access
*   `intl`: Date formatting
*   `uuid`: Unique identifier generation
