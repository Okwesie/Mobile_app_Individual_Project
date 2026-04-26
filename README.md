# Adventure Logger

Trail documentation Flutter app (offline-first logs, optional Firebase backup).

## Firebase setup (required to build)

Config files are **not committed** (they contain API keys). After cloning:

1. Install CLI: `dart pub global activate flutterfire_cli`
2. From the project root: `flutterfire configure`  
   Select your Firebase project and platforms. This generates **locally**:

   - `lib/firebase_options.dart`
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist` (if iOS enabled)

3. Run `flutter pub get` and build as usual.

See `lib/firebase_options.dart.example` for the expected shape of `firebase_options.dart`.

## Google Maps and directions setup

Explore destination directions use Google Maps SDK keys in the app and a
Firebase Function for route calculations.

Enable these APIs in the same Google Cloud project used by Firebase:

- Maps SDK for Android
- Maps SDK for iOS
- Routes API
- Cloud Functions and Cloud Build

Add the Android Maps SDK key locally in `android/local.properties`:

```properties
MAPS_API_KEY=your_android_maps_sdk_key
```

Add the iOS Maps SDK key locally in `ios/Flutter/MapsApiKey.xcconfig`:

```xcconfig
GOOGLE_MAPS_API_KEY=your_ios_maps_sdk_key
```

Store the server Routes API key as a Firebase Functions secret:

```bash
firebase functions:secrets:set GOOGLE_ROUTES_API_KEY
firebase deploy --only functions
```

Restrict the Android key to package `app.adventure.logger` plus your SHA-1
fingerprints, restrict the iOS key to the app bundle identifier, and restrict
the server key to the Routes API.

### If keys were ever pushed to GitHub

Rotate or **restrict** keys in [Google Cloud Console](https://console.cloud.google.com/) → APIs & Services → Credentials (Android/iOS key restrictions by package / bundle). Firebase keys in client apps are normal, but they should not live in a public repo history—prefer keeping generated files gitignored.

## Flutter resources

- [Flutter documentation](https://docs.flutter.dev/)
