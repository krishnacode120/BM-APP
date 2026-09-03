# Firebase and environment setup

Create distinct Firebase projects for development, staging, and production. Configure each mobile platform with its own Firebase config file; these files are ignored by Git. Run FlutterFire CLI after the Flutter SDK is installed if generated options are preferred.

Enable Phone Authentication, add Android SHA-1/SHA-256 values, configure APNs for iOS, and limit authorized domains for web/admin. Use `--dart-define=BM_ENV=development|staging|production`; no credential belongs in source code.

For Milestone 3 order testing, configure Firebase Auth, Firestore, and Cloud Functions in a development project or emulator suite. Install backend dependencies from `functions/` with `npm install`, compile with `npm run build`, and deploy only to development until the flow is verified.

The local catalog fallback remains available without Firebase, but order submission intentionally returns a Firebase configuration error instead of creating a fake local order.

Run Firestore rules tests with:

```powershell
npx firebase-tools emulators:exec --only firestore "cd functions && npm run test:rules"
```

Bootstrap the first admin from a trusted machine/environment only:

```powershell
cd functions
node scripts/bootstrap-admin.js <firebase-auth-uid>
```

This requires Admin SDK credentials or a trusted Firebase environment. Never commit service-account JSON.

## Milestone 5 operational setup

Configure only a development Firebase project first. Add Android `google-services.json` and iOS `GoogleService-Info.plist` (both ignored), enable Cloud Messaging, deploy rules/indexes/functions, then follow [notifications.md](notifications.md) for Android/iOS/APNs validation. Do not request notification permission on splash; BM asks from its notification settings screen with an order-update rationale.

For Microsoft reporting, create the development workbook/tables before deploying workers and set the seven Graph values with `firebase functions:secrets:set`. Follow the least-privilege app registration and recovery procedure in [reporting.md](reporting.md). Missing credentials deliberately create a private failed sync state rather than a fake Excel success.

### Development Firebase workflow

1. Create a Firebase project explicitly for development; its ID does not need to be `bm-dev`.
2. Register Android using the currently temporary `com.example.bm`, download `google-services.json`, and place it in `android/app/`.
3. Register iOS using the currently temporary `com.example.bm`, then add `GoogleService-Info.plist` to `ios/Runner` from macOS/Xcode.
4. Run `flutterfire configure` only after agreeing the development identifiers; generated `firebase_options.dart` may be committed if it contains only Firebase public configuration.
5. Enable Firestore, Storage and Phone Authentication; add Android SHA-1/SHA-256 fingerprints and authorized domains where applicable.
6. Install Functions dependencies and deploy only to development: `firebase deploy --only firestore:rules,firestore:indexes,storage,functions`.
7. Create an admin with the trusted bootstrap script documented in [admin-guide.md](admin-guide.md).
8. Seed only development data from a trusted shell:

```powershell
cd functions
$env:BM_ALLOW_DEVELOPMENT_SEED='true'
$env:BM_SEED_ENV='development'
node scripts/seed-development-data.js
```

9. Replace the `settings/app` contact placeholders with approved business phone, WhatsApp, email and support hours through an authorized admin process. This document is publicly readable; never place secrets in it.
10. Configure FCM/APNs and Graph secrets using [notifications.md](notifications.md) and [reporting.md](reporting.md), then follow [real-device-test-checklist.md](real-device-test-checklist.md).

### Local Android prerequisite

Before a development APK can be built on this workstation, install Android SDK 36 and Android BuildTools 28.0.3 from Android Studio's SDK Manager, then run `flutter doctor --android-licenses`. Confirm `flutter doctor -v` has no Android-toolchain error before starting an emulator or running `flutter build apk --debug`.
