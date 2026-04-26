# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run on a connected device / emulator
flutter run

# Analyze (must be clean before committing)
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/log_entry_test.dart

# Generate launcher icons (requires assets/icon/app_icon.png)
dart run flutter_launcher_icons

# Deploy Firestore security rules
firebase deploy --only firestore:rules

# Deploy Firebase Storage security rules
firebase deploy --only storage

# Deploy Cloud Functions
firebase deploy --only functions

# Set the Google Routes API key secret (required for directions feature)
firebase functions:secrets:set GOOGLE_ROUTES_API_KEY

# Deploy all Firebase backend config used by the app
firebase deploy --only firestore:rules,storage,functions
```

## Architecture

### App name
Display name is **AdventureLog** everywhere user-facing. The Dart package identifier remains `adventure_logger` throughout (imports, DB name, channel name) — do not rename those.

### State management
Provider (`ChangeNotifier`) throughout. Four top-level providers registered in `main.dart`:
- `AuthProvider` — wraps `FirebaseAuthService`, exposes `AuthStatus` enum and the current `User?`
- `LogProvider` — owns the private `LogEntry` list. It self-initializes from `FirebaseAuth.instance.currentUser` and listens to `authStateChanges()`; do not manually call `setUser(null)` from screens during startup. `saveLog()` accepts `notify: bool` — callers must read `SettingsProvider.notificationsEnabled` and pass it through; the provider does not read settings itself
- `SettingsProvider` — persists to Hive; must be `await init()`-ed before `runApp`
- `CommunityProvider` — owns public community feed state, profile setup, and Helpful reaction state

### Data flow (offline-first)
`LogProvider` reads SQLite first (instant), then fires a background Firestore sync. Writes go to both simultaneously (Firestore is best-effort for private log backup). `DatabaseService` is a singleton at DB version 3; `_onUpgrade` adds `firestore_id`, `user_id`, and `visibility`.

`LogEntry.visibility` is `'private'` or `'public'` and defaults to `'private'`. When a log is public, `LogProvider` mirrors a privacy-safe copy into `public_logs/{docId}` through `UserService`. Public mirrors never include `latitude`, `longitude`, or `locationName`.

### Navigation
All routes are declared in `AppRouter` (named constants + `onGenerateRoute`). After authentication, every entry point navigates to `/shell` (not `/home`). The shell (`MainShell`) uses an `IndexedStack` with five tabs: Logs / Community / Explore / Stats / Settings.

Auth flow: `SplashScreen` checks `onboarding_done` (SharedPreferences), then checks `FirebaseAuth.instance.currentUser` and routes to `/shell` or `/login`. There is no biometric gate on launch.

### Community sharing
Community is a public sharing layer for sanitized adventure logs:

- User profiles live at `users/{uid}` with `displayName`, optional `photoURL`, `bio`, and `createdAt`.
- Private logs stay under `users/{uid}/logs/{docId}` and remain owner-only.
- Public log feed documents live at `public_logs/{docId}` and are readable by signed-in users.
- Public log photos are uploaded to Firebase Storage under `public_log_photos/{uid}/{docId}.jpg`; the feed stores only `photoURL` and `storagePath`.
- Public mirrors include title, notes, lux reading, timestamp, author info, verification flag, and Helpful reaction count.
- Public mirrors intentionally do not include exact GPS coordinates or human-readable location names. Firestore rules reject `public_logs` documents containing `locationName`, `latitude`, or `longitude`.
- Helpful reactions are stored in `public_logs/{docId}/reactions/{uid}` and mirrored via `reactionCount`.

### Native light sensor
The pub `light` package is not used. Instead, `MainActivity.kt` registers `Sensor.TYPE_LIGHT` directly and streams values over an `EventChannel` named `com.calebarthur.adventure_logger/light`. `SensorService` (Dart) consumes this channel via `readOnce()` (3 s timeout) or `startListening()`. If the device has no sensor, the channel emits an error and `SensorService` records `luxReading = -1`.

### Explore feature (3-level navigation)
```
ExploreScreen            — category grid (6 categories, hardcoded)
  └─ AdventurePlacesScreen     — place list for a category
       └─ AdventurePlaceDetailScreen  — full detail: photo, description, map, directions
```

`AdventurePlace` requires `latitude` and `longitude` (non-nullable `double`) — all 24 places in `ghana_adventures.dart` have real GPS coordinates.

`AdventurePlaceDetailScreen` embeds a `GoogleMap` widget and calls `DirectionsService` on load to draw a route polyline between the user's current location and the destination.

### Directions / Cloud Functions backend
`DirectionsService` (`lib/core/services/directions_service.dart`) calls a Firebase Cloud Function `getRoute` deployed to `us-central1`. The function (`functions/index.js`) hits the **Google Routes API v2** (`routes.googleapis.com/directions/v2:computeRoutes`) using a secret key stored as `GOOGLE_ROUTES_API_KEY` in Firebase Secrets Manager. The function requires the caller to be authenticated.

The function returns `distanceMeters`, `durationSeconds`, and `encodedPolyline` (polyline 5 encoding). `DirectionsService._decodePolyline()` decodes it to a `List<LatLng>` for rendering.

If the function call fails (network, quota, no route found), `AdventurePlaceDetailScreen` degrades gracefully — it still shows the straight-line distance and the "Open in Google Maps" button.

### Feature structure
```
lib/
  core/
    models/       LogEntry, LogStatistics
    services/     Singletons: DatabaseService, FirestoreService, FirebaseAuthService,
                  SensorService, TtsService, SmsService, NotificationService,
                  CameraService, LocationService, AuthService (biometric helper),
                  DirectionsService (Cloud Functions → Google Routes API),
                  UserService (profiles, public logs, Storage photos, reactions)
    utils/        AppTheme, AppRouter, constants
  features/
    auth/         AuthProvider + screens (Splash, Login, Signup) + GoogleSignInButton
    logs/         LogProvider + screens (Home, NewLog, EditLog, LogDetail) + widgets
    social/       Community feed, public log detail, profile, avatars, reactions
    explore/      AdventureCategory/AdventurePlace models, ghana_adventures.dart (hardcoded
                  with real lat/lng), ExploreScreen, AdventurePlacesScreen,
                  AdventurePlaceDetailScreen
    stats/        StatsScreen (derives LogStatistics from LogProvider; no extra provider)
    settings/     SettingsProvider (Hive) + SettingsScreen
    onboarding/   OnboardingScreen (sets onboarding_done on finish)
    shell/        MainShell (IndexedStack bottom nav, 5 tabs)
functions/
  index.js        — getRoute Cloud Function (Node.js, Firebase Functions v2)
storage.rules     — Firebase Storage rules for public community log photos
```

### Firebase / package IDs
- Android `applicationId`: `app.adventure.logger` (matches `google-services.json`)
- Android Kotlin namespace: `com.calebarthur.adventure_logger`
- Firestore path: `users/{uid}/logs/{docId}` — rules enforce owner-only access
- Public feed path: `public_logs/{docId}` — signed-in read access, author writes, no location fields
- Storage path: `public_log_photos/{uid}/{docId}.jpg` — signed-in reads, owner writes/deletes
- Cloud Function region: `us-central1`
- `firebase_options.dart` is gitignored; `firebase_options.dart.example` is the template

### Key constraints
- `CachedNetworkImage` callbacks must use named parameters (`context, url, error`), not `_, __, ___` — the linter flags `unnecessary_underscores`.
- `isCoreLibraryDesugaringEnabled = true` is required in `android/app/build.gradle.kts` for `flutter_local_notifications`.
- App is portrait-locked (`setPreferredOrientations` in `main()`).
- `saveLog()` callers must read `SettingsProvider.notificationsEnabled` themselves and pass `notify:` — `LogProvider` has no reference to `SettingsProvider`.
- Public sharing must remain privacy-safe: do not add location fields back into `public_logs` or Community UI.
- Explore images remain public Wikimedia URLs to avoid Firebase Storage download costs for static destination assets.
