# AdventureLog

AdventureLog is an Android-first Flutter trail-safety and documentation app for
hikers, student trekking groups, guides, and outdoor adventurers in Ghana. Users
can create verified field logs with photos, GPS coordinates, ambient light
readings, timestamps, and notes; store them offline; sync them to Firebase; get
directions to Ghana adventure destinations; and share privacy-safe public logs
with the community.

The Dart package name remains `adventure_logger`.

## Core features

- Offline-first personal trail logs backed by SQLite.
- Firebase Authentication with email/password and Google Sign-In.
- Camera/gallery photo attachment with local file persistence.
- GPS capture and reverse geocoded private location names.
- Native Android ambient light sensor integration through a Kotlin
  `EventChannel`.
- Speech-to-text input for log title and notes.
- Text-to-speech log playback with pause, resume, and stop controls.
- SMS emergency location handoff through the device SMS composer.
- Local notifications after successful log saves.
- Search, edit, delete, and detail views for personal logs.
- Stats dashboard for log count, lux distribution, locations, and activity.
- Explore tab with 6 Ghana adventure categories and 24 destinations.
- Embedded Google Map destination preview and route polyline.
- Directions powered by Firebase Cloud Functions and Google Routes API v2.
- Community feed for public, privacy-safe log sharing.
- Firebase Storage upload for public community log photos.
- Helpful reactions on public logs.

## Privacy model

Personal logs can store exact GPS coordinates and reverse-geocoded location
names because they belong to the signed-in user. Public community logs are a
separate sanitized copy:

- Public sharing is opt-in; logs default to private.
- Public logs never include `latitude`, `longitude`, or `locationName`.
- Firestore rules reject public log documents containing those location fields.
- Private log photos stay on-device.
- Only photos for public community logs are uploaded to Firebase Storage under
  `public_log_photos/{uid}/{docId}.jpg`.
- Explore images use public Wikimedia Commons URLs instead of Firebase Storage
  to avoid unnecessary storage/download costs.

## Architecture

The app uses Provider (`ChangeNotifier`) for state management with four
top-level providers:

- `AuthProvider` - Firebase Auth, Google Sign-In, sign-out, and current user
  state.
- `LogProvider` - SQLite loading, personal log CRUD, Firestore private sync,
  local notifications, and public mirror updates.
- `SettingsProvider` - Hive-backed settings for emergency contact, TTS rate,
  and notifications.
- `CommunityProvider` - public feed, profile setup/editing, and Helpful
  reactions.

The main shell uses five tabs:

1. Logs
2. Community
3. Explore
4. Stats
5. Settings

Important data paths:

- SQLite logs table: local personal log source of truth, database version 3.
- Firestore private logs: `users/{uid}/logs/{docId}`.
- Firestore user profiles: `users/{uid}`.
- Firestore public feed: `public_logs/{docId}`.
- Firestore reactions: `public_logs/{docId}/reactions/{uid}`.
- Firebase Storage public photos: `public_log_photos/{uid}/{docId}.jpg`.
- Cloud Function: `getRoute` in `us-central1`.

## Tech stack

- Flutter / Dart
- Provider
- SQLite via `sqflite`
- Hive and SharedPreferences
- Firebase Core, Auth, Firestore, Storage, and Cloud Functions
- Google Sign-In
- Google Maps Flutter and Google Routes API v2
- `geolocator` and `geocoding`
- `image_picker`
- `flutter_local_notifications`
- `flutter_tts`
- `speech_to_text`
- `url_launcher`
- `cached_network_image`
- Native Android Kotlin `EventChannel` for `Sensor.TYPE_LIGHT`

## Firebase setup

Firebase config files are intentionally not committed because they contain
project-specific identifiers and keys. After cloning:

1. Install the FlutterFire CLI:

   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Generate local Firebase configuration:

   ```bash
   flutterfire configure
   ```

   This creates:

   - `lib/firebase_options.dart`
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist` if iOS is configured

3. Install Flutter packages:

   ```bash
   flutter pub get
   ```

See `lib/firebase_options.dart.example` for the expected shape of
`firebase_options.dart`.

## Google Maps and directions setup

AdventureLog uses the Android Maps SDK for the embedded map and a Firebase
Cloud Function for Google Routes API calls. The Routes API key is not shipped in
the Flutter client.

Enable these APIs in the Google Cloud project connected to Firebase:

- Maps SDK for Android
- Routes API
- Cloud Functions
- Cloud Build
- Secret Manager

Add the Android Maps SDK key locally in `android/local.properties`:

```properties
MAPS_API_KEY=your_android_maps_sdk_key
```

Store the Routes API key as a Firebase Functions secret:

```bash
firebase functions:secrets:set GOOGLE_ROUTES_API_KEY
firebase deploy --only functions
```

Recommended key restrictions:

- Restrict the Android key to package `app.adventure.logger` and the app SHA-1
  fingerprint.
- Restrict the server key to the Routes API.

## Firebase backend deployment

Deploy the security rules and backend function from the project root:

```bash
firebase deploy --only firestore:rules
firebase deploy --only storage
firebase deploy --only functions
```

Or deploy all Firebase backend pieces together:

```bash
firebase deploy --only firestore:rules,storage,functions
```

## Android build and test commands

Run the app on a connected Android device or emulator:

```bash
flutter run
```

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Build a debug APK:

```bash
flutter build apk --debug
```

Expected debug APK output:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

The Android application ID is `app.adventure.logger`. The Android build uses
minimum SDK 24.

## Notes on secrets and generated files

Do not commit local Firebase and Maps config files containing project-specific
keys. If a key is ever pushed to GitHub, rotate it or restrict it immediately in
Google Cloud Console.

Gitignored/generated files include:

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `ios/Flutter/MapsApiKey.xcconfig`

## Image attribution

Explore destination images are loaded from Wikimedia Commons public file URLs.
Image ownership and licensing remain with the original Wikimedia Commons
contributors. The images are used as externally hosted public destination
images for this educational project and are not stored in Firebase Storage.
