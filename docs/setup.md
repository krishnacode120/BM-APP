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
