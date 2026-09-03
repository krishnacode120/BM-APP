# Phase 5.5 verification report

## Current code status

Flutter compiles through static analysis and its automated tests. Catalog browsing uses Firestore when Firebase initializes; otherwise `DemoCatalogRepository` supplies three categories, three locations and three products for local UI work. Checkout/order creation intentionally does not fall back: it returns a Firebase-unavailable failure. Phone OTP now calls Firebase Auth and cannot navigate to Home unless credential verification succeeds.

## Firebase configuration state

| Component | Current state |
| --- | --- |
| Android Firebase | Missing `android/app/google-services.json` |
| iOS Firebase | Missing `ios/Runner/GoogleService-Info.plist` |
| FlutterFire options | Missing `lib/firebase_options.dart` |
| Firestore/Auth/Functions/Storage | Code, rules and repositories exist; no development project is configured or live-tested |
| FCM | Code and Android channel exist; no Firebase project/device token/live push verified |
| Microsoft Graph/Excel | Backend architecture exists; secrets/workbook/live sync not configured |

## Android build environment

`flutter doctor -v` finds Android SDK 34 but requires Android SDK 36, Android BuildTools 28.0.3 and accepted Android licenses. No Android device/emulator is connected. The debug APK task did not produce an APK, so Android installation is **not verified**. Install the missing SDK components through Android Studio, run `flutter doctor --android-licenses`, start an emulator or attach a device, then rerun `flutter build apk --debug` and the real-device checklist.

## Identifiers and branding

- Flutter package/name: `bm` / `BM`, version `0.1.0+1`.
- Android application ID and namespace: `com.example.bm`; label: `bm`.
- iOS bundle identifier: `com.example.bm`; display name: `bm`.
- These are temporary/example identifiers and require client approval before production.
- There is no real BM logo asset. Splash uses a text `BM` circle. Android/iOS launcher icons are generated Flutter defaults; there is no notification/store icon asset beyond the launcher defaults.
- Theme: orange `#F57C00`, ink `#1C1B1F`, canvas `#FFFBFF`, muted `#6D6A72`; Material 3 seed-derived secondary/error/success colors; cards 18px, inputs 14px. No separate spacing token system or custom font is implemented.

## Actual data storage

- Firebase Authentication supplies the customer UID and phone identity after real OTP verification.
- `users`: customer profile/role mirror; normal users can read/write their own document under rules. OTP success now mirrors the verified phone number into the user's own profile document; Auth/claims remain authoritative.
- Selected location and cart are local `SharedPreferences`; cart key is user/guest scoped when Firebase is initialized.
- Products, locations, categories and prices use Firestore repositories. Product images are URL fields; no real development images are seeded.
- `orders` contains customer/address/location/item snapshots, estimated total, status and payment status. `orderRequests` stores idempotency ownership/order ID. `counters/orders` generates human order numbers. Historic item prices cannot change because the order item stores `priceAtOrder`.
- `auditLogs`, `notificationJobs`, `notificationLogs`, `reportSyncJobs`, `reportSyncState` and `users/{uid}/devices/{deviceId}` are backend operational structures.
- `settings/app` is the central public customer-contact document: `businessName`, `businessPhone`, `whatsappNumber`, `supportEmail`, `defaultCurrency`, `supportHours`. Never store Graph/Firebase secrets there.

## Demo, placeholders and review findings

- **Safe development fallback:** `lib/repositories/catalog_repositories.dart` and `catalog_providers.dart` use demo catalog data only when Firebase is not initialized.
- **Needs Firebase configuration:** platform Firebase files, FlutterFire options, real OTP, catalog/order/admin live reads/writes, FCM and Graph secrets.
- **Needs client content:** real business contact values, logo/app icon/splash artwork, product images, final catalog/prices, approved identifiers.
- **Intentional placeholders:** `+91XXXXXXXXXX`, text splash, generated launcher icons, no Graph credentials.
- **Needs removal before production:** `com.example.bm`, Android generated TODO comments, and the Firebase-absent demo catalog path.
- Customer-facing localization is substantial but incomplete: onboarding slide text/Skip and several catalog/error/cart semantics are hard-coded English. Admin UI is English-only by design for now. Tamil layout has not been run on a real small device.

## Flow assessment

| Flow | Status |
| --- | --- |
| Splash/onboarding/home/catalog/cart UI | Implemented locally with demo fallback |
| OTP, customer profile creation | Implemented, but blocked from live Firebase/phone verification |
| Firestore catalog/location price | Implemented, blocked by development Firebase/data |
| Checkout/trusted order | Implemented, blocked by development Firebase/Functions |
| Order history/detail | Implemented, blocked by development Firebase data |
| Admin gate/order/inventory/price/audit/reports | Foundation implemented, blocked by custom-claim development Firebase test |
| Product/category forms, user detail/settings editor | Foundation/partial |
| FCM/Graph/Excel | Implemented architecture, not live verified |

## Viewing data after setup

Use Firebase Console: **Authentication → Users** for phone identities; **Firestore Database → Data** for users, catalog, orders and operational collections; **Storage → Files** for `products/{productId}/...`; **Functions** for callable/worker logs. Excel rows are viewed in the configured private OneDrive/SharePoint workbook, not Firebase Console.

## Release blockers

Development Firebase configuration, real OTP/order/admin tests, FCM/Graph live tests, contact values, logo/icon approval, final identifiers, production project separation and legal/domain content remain blockers. The project is not production-ready; it can move to supervised client testing after development Firebase setup and the real-device checklist are completed.
