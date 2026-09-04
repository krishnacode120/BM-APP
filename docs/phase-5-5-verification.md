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
| Android Firebase | `com.example.bm` is registered in `bm-app-74ddb`; the generated local `google-services.json` is installed and ignored by Git |
| iOS Firebase | `com.example.bm` is registered in `bm-app-74ddb`; the local ignored `GoogleService-Info.plist` is installed and referenced by the Runner resources build phase |
| FlutterFire options | Android/iOS app identifiers are wired into startup; API-key literals were removed from tracked Dart and are supplied by ignored native files or build-time defines |
| Development project | `bm-app-74ddb` is selected and the Firebase CLI is authenticated on this workstation |
| Authentication | Email/password and Phone providers are enabled; the Android debug SHA-1/SHA-256 fingerprints are registered |
| Firestore | The default database was created in immutable multi-region `nam5`; restrictive rules and indexes are deployed; 48 clearly identified development documents are seeded |
| Catalog | Live customer-shaped queries return 8 active categories, 4 active locations and 7 visible products through the deployed rules/indexes |
| Storage | The project deliberately remains on Spark, so a bucket is not provisioned and live product-image upload is unavailable |
| Functions | Backend code builds and tests locally, but callable order/admin/notification/reporting operations are deliberately not deployed while the project remains on Spark |
| Admin bootstrap | Initial development admin created; `admin: true` / `role: admin` claims, active Firestore profile and audit record were verified; the account email is intentionally not stored in the repository |
| FCM | Transactional code, templates, token lifecycle and tests exist; live device delivery is not verified |
| APNs | Requires macOS/Xcode, Apple credentials, APNs key and a physical iPhone |
| Microsoft Graph/Excel | Durable worker/retry/dead-letter code and unit tests exist; live workbook/secrets are not configured |
| Contact settings | Approved BM phone is present in the development seed; WhatsApp, email and support hours still need approved values |

Firebase CLI 15.29.0 and FlutterFire CLI 1.4.1 are installed and authenticated. Firestore rules/indexes are deployed and development data is seeded. No Functions/Storage deployment, admin bootstrap, real OTP, live push, or live Excel claim is made yet.

## Platform/device state

No Android emulator or physical Android/iOS device is connected. Windows and web browser targets are visible; Visual Studio C++ is absent, which affects only a Windows desktop build. iOS/iPad build, signing, APNs, and physical layout verification require macOS and Apple credentials.

## Deliberate development boundary

When Firebase is absent, `DemoCatalogRepository` supplies clearly development-only browsing content. Authentication, admin access, Storage upload, and order submission do not fake success. Remove or disable the preview adapter before a production release after real environment configuration is finalized.

## Remaining release blockers

The client chose to retain the Spark plan. Storage uploads and Cloud Functions-backed order/admin/notification/reporting operations are therefore documented limitations rather than pending deployment work. Verify the Spark-compatible authentication/catalog/admin-read paths on a physical device, complete remaining contact values, and finish the applicable route-by-route device checklist. Production identifiers, launcher/store assets, signing, and legal content also require client approval.
