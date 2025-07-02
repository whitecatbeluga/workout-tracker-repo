# workout_tracker_repo

## Folder Structure Guide

- https://medium.com/flutter-community/flutter-scalable-folder-files-structure-8f860faafebd
- https://medium.com/@vortj/leveling-up-your-flutter-project-structure-fcb7099a3930

## How to run the workout_tracker_repo

Clone the repo

```
https://github.com/whitecatbeluga/workout-tracker-repo
```

You install Android Studio and Emulator and Java for gradle bundler and Dart

Here's the link how to install

```
https://docs.flutter.dev/get-started/install
```

After installing run this command if you want to use VScode

You must run the emulator installed from Android Studio if you don't have it yet you must download
it
or you can use your mobile phone.

Open CMD and navigate to the path where your Android SDK installed

```
cd "C:\Users\<YourUsername>\AppData\Local\Android\Sdk\emulator"
```

List available emulators

```
emulator -list-avds
```

Start the emulator

```
emulator -avd <avd_name>
```

Open new terminal and run flutter doctor to install the necessary tools

```
flutter doctor
```

After installing run the flutter app

```
flutter run
```

If your in WSL

```
flutter run -d web-server
```

If you want to use Android Studio

Steps:

- Download Android Studio
- Install Flutter plugin
- Install Emulator
- Select the downloaded emulator then press play/start button

## 📁 FOLDER STRUCTURE `LAYERED / CLEAN ARCHITECTURE`

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

## REMOVE BRANCH EXCEPT MASTER AND BETA

WINDOWS COMMAND

```
git branch | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne 'master' -and $_ -ne 'beta' } | ForEach-Object { git branch -d $_ }
```

BASH / WSL

```
git branch | grep -v "master" | grep -v "beta" | xargs git branch -D
```

SQUASH THE COMMIT TO 1

```
git reset --soft $(git merge-base beta HEAD)
```

```
git commit -m "message"
```

```
git push --force
```