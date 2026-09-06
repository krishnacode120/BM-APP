# Firebase and environment setup

For iOS builds, APNs/reCAPTCHA setup, signing and the GitHub Actions secret, see [ios-build.md](ios-build.md). Real phone verification SMS currently requires Firebase Blaze; this project must remain Spark, so use fictional Firebase test numbers/codes or the Auth emulator. Admin email/password authentication does not require an SMS upgrade.

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

Configure only a development Firebase project first. The local Android `google-services.json` and iOS `GoogleService-Info.plist` (both ignored) target `bm-app-74ddb`. The committed `lib/firebase_options.dart` retains non-secret app/project identifiers but reads API keys from build-time Dart defines when explicit options are required. Firestore rules/indexes are deployed and development seed data is installed. The client chose to retain the Spark plan, so do not provision Storage or deploy Functions; use the emulator suite to validate those code paths. Follow [notifications.md](notifications.md) for platform prerequisites if that scope is revisited.

For Microsoft reporting, create the development workbook/tables before deploying workers and set the seven Graph values with `firebase functions:secrets:set`. Follow the least-privilege app registration and recovery procedure in [reporting.md](reporting.md). Missing credentials deliberately create a private failed sync state rather than a fake Excel success.

### Development Firebase workflow

1. The selected development project is `bm-app-74ddb`; its default Firestore database uses immutable multi-region `nam5`.
2. Android and iOS are registered with the currently temporary identifier `com.example.bm`; their downloaded native configuration stays ignored by Git. The Xcode Runner target requires `GoogleService-Info.plist` in its resources; restore it locally or through the approved Actions secret before building.
3. `lib/firebase_options.dart` contains non-secret Firebase project/app identifiers. API-key literals must not be committed. Normal mobile builds read the ignored native files; CI may inject `BM_FIREBASE_ANDROID_API_KEY` or `BM_FIREBASE_IOS_API_KEY` using `--dart-define` from its secret store.
4. Email/password and Phone Authentication are enabled, and Android debug SHA-1/SHA-256 fingerprints are registered. Review authorized domains and complete iOS/APNs configuration before external testing.
5. Firestore rules/indexes are deployed and 48 development category/product/location/price/settings documents have been seeded. Never rerun a development seed against production.
6. Do not provision Storage or deploy Functions while the Spark-plan decision remains. Continue validating those code paths with the local emulator suite.
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
