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

### If keys were ever pushed to GitHub

Rotate or **restrict** keys in [Google Cloud Console](https://console.cloud.google.com/) → APIs & Services → Credentials (Android/iOS key restrictions by package / bundle). Firebase keys in client apps are normal, but they should not live in a public repo history—prefer keeping generated files gitignored.

## Flutter resources

- [Flutter documentation](https://docs.flutter.dev/)
