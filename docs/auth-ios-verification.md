# Authentication and iOS verification — 2026-09-06

## Changes

- `54e162e`: native OTP callback stream and route-owned controller; request timeouts; same-phone resend tokens; automatic/manual profile completion; null-user and failed-profile protection; localized admin/auth errors; small-screen Tamil OTP layout.
- The same change invalidates customer/admin/order caches across authentication changes, isolates cart persistence, rejects stale checkout responses, and preserves existing customer role/active/phone fields in profile transactions.
- Backend price queries exclude scheduled future prices before the bounded result window; CSV exporters keep formula-like user text literal.
- iOS now declares Firebase's callback URL scheme, push/background capabilities, APNs entitlements and photo-library purpose text. Native configuration remains ignored; the user approved restoring it through an Actions secret and publishing the configured unsigned artifact.
- `ef534d9`: removed six unused, empty asset-directory declarations that existed locally but failed analysis on a fresh macOS Git checkout. No image assets were deleted.

## Executed checks

| Check | Result |
| --- | --- |
| Flutter toolchain | Flutter 3.47.2 stable / Dart 3.13.2 |
| `flutter pub get` | Passed |
| `dart format lib test` | Passed |
| `flutter analyze` | No issues found after fixes |
| `flutter test` | 44 tests passed |
| `npm test` in `functions` | TypeScript build and both backend test programs passed |
| Firestore emulator security tests | 8 passed on `demo-bm-test`; no live writes |
| Android debug build | Passed; `build/app/outputs/flutter-apk/app-debug.apk` |
| Native iOS build | Passed on macOS: [GitHub Actions run](https://github.com/krishnacode120/BM-APP/actions/runs/34034425229); unsigned `Runner.app` (44.4 MB) |

The security tests ran with `firebase emulators:exec --project demo-bm-test --only firestore "npm --prefix functions run test:rules -- --timeout 15000"`. Expected permission-denied messages are negative test assertions, not failing tests.

The first Mac run stopped on the asset-manifest issue before Xcode compilation. The second run, for source commit `ef534d9c1ec03564493a9e8171f8bd7fff68d860`, passed clean-checkout analysis, all Flutter tests, Swift Package Manager dependency resolution, Xcode compilation and artifact upload. Local Windows Flutter tests alone are not evidence of an iOS build.

## Downloaded iOS artifact

- [GitHub artifact](https://github.com/krishnacode120/BM-APP/actions/runs/34034425229/artifacts/9989785654), expires September 13, 2026.
- Local archive: `build/ios-ci/ef534d9/BM-ios-unsigned.zip` (16,890,586 bytes).
- SHA-256: `BBF2E9A52E24E24D28EF4E20E6F2F1A71A0ECFFEA8911722363FEC5D64ECCD6B`.
- Archive checks confirm a native 64-bit Mach-O `Runner.app/Runner` binary and bundled `Runner.app/GoogleService-Info.plist`. Configuration values were not printed or committed.
- This is an unsigned device app archive, not a signed IPA or simulator app. It cannot be installed directly on an iPhone without appropriate Apple signing/provisioning.

## Unverified / remaining

- Apple signing, an installable IPA, iPhone installation, and physical-device UI/authentication checks.
- APNs key registration, silent-push verification, reCAPTCHA return flow, and a real Firebase test-number sign-in. OTP automated tests use fakes and send no SMS.
- Spark is unchanged. Real verification SMS requires Blaze under current Firebase limits; use fictional Firebase test phone numbers/codes or emulators instead. Enabling the Phone provider is not sufficient for live SMS.
- Live Functions, Storage, order/admin mutations, notifications and Excel/report synchronization remain subject to the existing Spark/environment restrictions. No backend deployment was performed.
- The Android build reports a non-blocking future Kotlin Gradle Plugin compatibility warning for `cloud_functions`. Dependencies were not broadly upgraded; this should be addressed in a separately tested FlutterFire migration.
- Existing unrelated changes in `.metadata`, `analysis_options.yaml`, `devtools_options.yaml`, and `web/` were preserved and excluded from these commits.

See [ios-build.md](ios-build.md) for build/signing instructions and authoritative Firebase/Flutter references.
