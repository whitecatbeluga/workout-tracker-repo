# workout_tracker_repo

## Folder Structure Guide
- https://medium.com/flutter-community/flutter-scalable-folder-files-structure-8f860faafebd
- https://medium.com/@vortj/leveling-up-your-flutter-project-structure-fcb7099a3930
## How to run the workout_tracker_repo 

- flutter run 

if using wsl use this
- flutter run -d web-server


## 📁 FOLDER STRUCTURE `CLEAN ARCHITECTURE`

**domain** – Contains core business models, plain Dart classes, and interfaces.

**page** – UI screens of the app. Each page can be a `StatelessWidget` or `StatefulWidget`.

**routes** – Defines route names and maps them to corresponding pages/screens.

**services** – Holds business logic, external integrations, and service layers.

**widgets** – Contains reusable UI components/widgets that are shared across multiple pages.

**utils** – Utility functions, formatters, constants, extensions.

**config** – Environment configurations, API keys.

**theme** – Centralized theme definitions, color palette, typography.

## CODE STRUCTURE

**Domain -> Entity** = pure workout object (no Firebase code).

**WorkoutModel** = DTO that converts between Firestore and entity.

**WorkoutService** = low-level Firebase access.

**WorkoutRepositoryImpl** = bridges service + entity.

**UI uses WorkoutRepositoryImpl through the domain interface.**


