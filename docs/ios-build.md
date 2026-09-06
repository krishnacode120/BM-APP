# iOS build and authentication verification

## Development configuration

- The current Firebase development project is `bm-app-74ddb`; the registered iOS bundle ID is `com.example.bm`.
- `ios/Runner/GoogleService-Info.plist` remains ignored by Git, but is required by the Runner resources build phase. Download the matching iOS configuration from Firebase before a local build. Dart defines alone do not replace this resource.
- `Info.plist` registers the Firebase Auth callback scheme `app-1-544513391401-ios-7ab18c51a78f6391f39538`. This is the registered Google app ID with colons replaced by hyphens and the SDK's `app-` prefix. Update it when registering a different Firebase iOS app.
- Runner enables Push Notifications and Background Modes (fetch / remote notifications). Its entitlement uses development APNs in Debug and production APNs in Release/Profile. No Apple team, signing identity, provisioning profile or APNs key has been invented or committed.
- Keep Firebase App Delegate swizzling enabled. The standard Flutter AppDelegate/SceneDelegate integration remains intact.

## GitHub build

The manual **iOS unsigned build** workflow uses a standard macOS runner and pinned action revisions. In repository Settings > Secrets and variables > Actions, `BM_FIREBASE_IOS_PLIST_BASE64` contains the base64-encoded native plist. The user approved storing this as an Actions secret and publishing the resulting unsigned artifact. Never print the plist or encode a service-account key into this secret.

Run the workflow from the Actions tab on the desired branch. It restores and validates the development plist, runs `flutter pub get`, `flutter analyze`, `flutter test`, then:

```sh
flutter build ios --release --no-codesign --dart-define=BM_ENV=development
```

On success, the `BM-ios-unsigned` artifact contains a zipped `Runner.app`, retained for seven days. This proves an iOS device binary compiled, **not** that it can be installed, that SMS works, or that it is ready for the App Store. App binaries contain Firebase client configuration even when source configuration is stored as an Actions secret. Repository/artifact visibility must be acceptable before publishing.

## Installable iPhone build

Windows cannot run Xcode or produce a signed iOS release locally. On a Mac, restore the ignored plist, run `flutter pub get`, open `ios/Runner.xcworkspace`, select the legitimate Apple development team, and provision the app with Push Notifications enabled. Use a distribution-appropriate profile for release builds. Confirm ownership of the final unique bundle identifier before external distribution; if changed, re-register the Firebase app and replace its plist/callback scheme.

After signing is configured:

```sh
flutter build ipa --release --dart-define=BM_ENV=development
```

Upload the APNs authentication key to the matching Firebase iOS app from a trusted console. Verify both silent-push app verification on a physical device and reCAPTCHA fallback with Background App Refresh disabled. The iOS simulator uses the fallback. Review API-key restrictions/authorized domains for the Firebase auth handler without weakening Firestore rules.

## OTP verification boundary

`bm-app-74ddb` remains Spark as requested. Enabling the Phone provider does not enable real SMS on Spark: current [Firebase Auth limits](https://firebase.google.com/docs/auth/limits) require Blaze for verification SMS. Use Firebase Console > Authentication > Sign-in method > Phone > phone numbers for testing, with a fictional number and private six-digit test code. Do not use the admin's real phone as a fictional test account. Do not commit test codes or ship an app-verification bypass.

The automated tests use fakes to cover native callback failures/timeouts, automatic sign-in, manual OTP, resend tokens (including iOS null tokens), cancellation, missing users, failed profile writes and small-screen Tamil UI. They do not contact Firebase or send SMS.

Real-device checks still required:

- Admin email/password sign-in, incorrect password, disabled account and admin claim/profile denial.
- Configured fictional phone number/code through the real Firebase SDK on iPhone.
- Wrong code, expired code, resend, network interruption, background/foreground and Back navigation.
- APNs silent verification and reCAPTCHA return to the app.
- Signing, iPhone install, cold start, and customer/admin sign-out/account switching.
- Live order/admin callables remain unavailable on this Spark project; validate them with emulators, not fake success states.

Sources: [Flutter iOS deployment](https://docs.flutter.dev/deployment/ios), [Firebase Flutter phone authentication](https://firebase.google.com/docs/auth/flutter/phone-auth), [Firebase Apple phone authentication](https://firebase.google.com/docs/auth/ios/phone-auth).
