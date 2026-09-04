# Firebase and environment setup

Use distinct Firebase projects for development, staging, and production. Development currently uses `bm-app-74ddb`. Its Android/iOS apps and FlutterFire options are configured; the native config files remain local and ignored by Git.

Email/password and Phone Authentication are enabled in development, and the Android debug SHA-1/SHA-256 values are registered. APNs/iOS device setup and authorized-domain review remain. Use `--dart-define=BM_ENV=development|staging|production`; no credential belongs in source code.

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

Configure only a development Firebase project first. The local Android `google-services.json`, iOS `GoogleService-Info.plist` (both ignored), and committed public `lib/firebase_options.dart` currently target `bm-app-74ddb`. Firestore rules/indexes are deployed and development seed data is installed. Storage provisioning and Functions deployment require an explicitly approved Blaze upgrade. Follow [notifications.md](notifications.md) for Android/iOS/APNs validation. Do not request notification permission on splash; BM requests it contextually after the customer's first successful order, with an order-update rationale.

For Microsoft reporting, create the development workbook/tables before deploying workers and set the seven Graph values with `firebase functions:secrets:set`. Follow the least-privilege app registration and recovery procedure in [reporting.md](reporting.md). Missing credentials deliberately create a private failed sync state rather than a fake Excel success.

### Development Firebase workflow

1. The selected development project is `bm-app-74ddb`; its default Firestore database uses immutable multi-region `nam5`.
2. Android and iOS are registered with the currently temporary identifier `com.example.bm`; their downloaded native configuration stays ignored by Git.
3. `lib/firebase_options.dart` contains Firebase public configuration and is committed so Android/iOS startup is compile-safe.
4. Email/password and Phone Authentication are enabled, and Android debug SHA-1/SHA-256 fingerprints are registered. Review authorized domains and complete iOS/APNs configuration before external testing.
5. Firestore rules/indexes are deployed and 48 development category/product/location/price/settings documents have been seeded. Never rerun a development seed against production.
6. After explicitly approving a Blaze upgrade, provision Storage and deploy only the development Functions/Storage rules: `firebase deploy --only storage,functions`.
7. Create an admin with the trusted bootstrap script documented in [admin-guide.md](admin-guide.md).
8. Seed only development data from a trusted shell:

```powershell
cd functions
$env:BM_ALLOW_DEVELOPMENT_SEED='true'
$env:BM_SEED_ENV='development'
node scripts/seed-development-data.js
```

9. The development seed uses the approved BM phone `+917708538700`. Complete the WhatsApp, email and support-hours values through an authorized admin process. This document is publicly readable; never place secrets in it.
10. Configure FCM/APNs and Graph secrets using [notifications.md](notifications.md) and [reporting.md](reporting.md), then follow [real-device-test-checklist.md](real-device-test-checklist.md).

### Local Android prerequisite

This workstation has Android SDK 36 and Build Tools 36 installed and its Android licenses accepted. On a new workstation, install the SDK/platform/build tools required by the current Flutter/Gradle configuration from Android Studio's SDK Manager, run `flutter doctor --android-licenses`, and confirm `flutter doctor -v` has no Android-toolchain error before starting an emulator or running `flutter build apk --debug`.
