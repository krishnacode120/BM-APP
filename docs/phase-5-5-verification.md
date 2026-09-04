# Phase 5.5 verification report

## Verified locally

- Flutter 3.47.2 / Dart 3.13.2 are installed.
- Android SDK 36 and Build Tools 36 are detected; Android licenses are accepted.
- Flutter static analysis and the complete automated Flutter suite pass.
- Functions TypeScript build/unit tests pass.
- Firestore security-rule tests pass against the local emulator.
- A debug Android APK can be built from this checkout.

## Implemented customer scope

The customer experience is intentionally limited to name-and-phone OTP identity, Home, Search, Categories, Product Details, an order list, Submit Order, success, My Orders, Language, Help/Call BM, and Logout. Wishlist, customer passwords, social login, online payment, coupons, delivery-rider tracking, and unrelated profile modules are not part of BM.

Customer documents are typed and phone verified. Session restore requires the current Firebase Auth phone and an active matching Firestore customer profile. Trusted order creation re-reads that profile and never trusts submitted customer identity or client price totals. The business order states are `pending`, `verified`, `confirmed`, `processing`, `ready`, `completed`, and `cancelled`; payment states are `unpaid`, `partial`, and `paid`.

## Implemented admin scope

The responsive admin application requires an email/password Firebase session, an admin custom claim, and an active Firestore admin profile. It includes real dashboard metrics, customers and calling, order verification/status/payment/final totals/notes, product/category forms, Storage image upload, inventory and visibility, non-destructive location pricing, reports/date filters/revenue chart/top materials, Unicode CSV exports, Excel-sync health/retry, business settings, password change, and logout. Important actions use confirmation dialogs and backend validation/audit.

## External configuration state

| Component | Current state |
| --- | --- |
| Android Firebase | `android/app/google-services.json` is absent |
| iOS Firebase | `ios/Runner/GoogleService-Info.plist` is absent |
| FlutterFire options | `lib/firebase_options.dart` is absent |
| Development project | No Firebase project is selected/authenticated in this checkout |
| Phone OTP/catalog/order/admin | Code-complete; live development-project test blocked by the missing configuration |
| FCM | Transactional code, templates, token lifecycle and tests exist; live device delivery is not verified |
| APNs | Requires macOS/Xcode, Apple credentials, APNs key and a physical iPhone |
| Microsoft Graph/Excel | Durable worker/retry/dead-letter code and unit tests exist; live workbook/secrets are not configured |
| Contact settings | Approved BM phone is present in the development seed; WhatsApp, email and support hours still need approved values |

The Firebase CLI is available locally through `npx firebase-tools`, but the machine is not authenticated. No deployment, admin bootstrap, real OTP, live push, or live Excel claim is made.

## Platform/device state

No Android emulator or physical Android/iOS device is connected. Windows and web browser targets are visible; Visual Studio C++ is absent, which affects only a Windows desktop build. iOS/iPad build, signing, APNs, and physical layout verification require macOS and Apple credentials.

## Deliberate development boundary

When Firebase is absent, `DemoCatalogRepository` supplies clearly development-only browsing content. Authentication, admin access, Storage upload, and order submission do not fake success. Remove or disable the preview adapter before a production release after real environment configuration is finalized.

## Remaining release blockers

Provide/select a development Firebase project, add platform configuration, enable Phone Auth/Firestore/Storage/Functions/FCM, deploy rules/indexes/functions, bootstrap an approved admin, enter approved contact values, configure Graph secrets/workbook, and complete the route-by-route physical-device checklist. Production identifiers, launcher/store assets, signing, legal content, and production project separation also require client approval.
