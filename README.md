# BM — Building Materials Marketplace

BM is a bilingual Flutter application for customers to request construction materials and for BM administrators to manage the resulting operations. Customers use name-and-phone OTP authentication, browse location-priced materials, build an order request, submit it for manual verification, and call BM. There is no online payment flow.

The current UI release applies the approved warm-white/peach/orange BM visual system across the customer and admin experiences. It includes original BM SVG branding, a locally bundled construction-material hero, persisted language and onboarding choices, responsive catalog/search/detail/order flows, a minimal customer profile, and a responsive operational admin application. Trusted Firebase repositories and callable order/admin operations remain the data authority; clearly marked development preview content is used only when Firebase is not configured and cannot create fake orders.

## Milestone status

Implemented: project structure, Material 3 design system, routing, English/Tamil localization, splash/onboarding, login and OTP UI, Firebase Auth service boundary, role-safe user model, environment placeholders, home navigation, sample repository abstraction, and starter tests.

Milestone 2 adds Firestore-backed category, product, location and pricing repository contracts; location preference persistence; inventory-aware product display; category/product detail routes; and development seed records.

Milestone 3 adds a real cart, user-scoped local cart persistence, checkout, order success, order history/detail screens, immutable order snapshots, and a callable Cloud Function (`createOrder`) for server-authoritative order creation. The client sends only product IDs, quantities, delivery/customer details, and an idempotency key; the backend derives the authenticated user, resolves current prices, validates inventory/minimum quantities/location, generates the order number, and writes the order.

The completed admin surface at `/admin` requires both a Firebase custom admin claim and an active Firestore admin profile. It includes live customer/product/order/revenue metrics, customer detail and calling, guarded order/payment/final-total operations, product and category editing, product image upload, location pricing with price history, reports/revenue chart/top materials, CSV/report retries, business contact settings, password change, and logout.

Milestone 5 adds a durable operational outbox: FCM device-token registration, token refresh/deactivation, customer/admin order-event push templates, safe deep links, invalid-token cleanup, controlled retries, Microsoft Graph/Excel table synchronization, retry/dead-letter tracking, a private Reports & Sync admin page, and an authenticated CSV fallback. Notifications and reporting are side effects; orders remain successful when either destination is unavailable.

## Structure

- `lib/core` — configuration, theme, routing, reusable UI
- `lib/features` — feature-owned UI and state
- `lib/models` — typed domain entities
- `lib/repositories` — Firebase-backed data contracts plus explicit no-Firebase preview adapters
- `lib/services` — external platform/service boundaries
- `functions` — Firebase callable backend for trusted order creation
- `lib/l10n` — English and Tamil message catalogues
- `assets` — original BM branding and locally bundled approved artwork
- `docs` — architecture and setup decisions
- `test` — fast behavioural/widget coverage

## Local setup

1. Install Flutter (stable channel) and run `flutter doctor`.
2. Run `flutter pub get` in this directory.
3. Copy `.env.example` to `.env` if local tooling needs it. Do not commit it.
4. Development is configured for `bm-app-74ddb`. For another environment, register the platform apps and replace the ignored `google-services.json` / `GoogleService-Info.plist`, then regenerate `lib/firebase_options.dart` with FlutterFire CLI.
5. Development Email/Password and Phone Authentication plus Android debug SHA keys are enabled. Configure iOS APNs before testing on an iPhone.
6. Install backend dependencies with `npm install` in `functions/`, then run `npm run build`.
7. Run `flutter run --dart-define=BM_ENV=development`.

## Checks

```powershell
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

```powershell
cd functions
npm run build
```

See [docs/setup.md](docs/setup.md), [docs/architecture.md](docs/architecture.md), [docs/database.md](docs/database.md), [docs/security.md](docs/security.md), [docs/admin-guide.md](docs/admin-guide.md), [docs/notifications.md](docs/notifications.md), and [docs/reporting.md](docs/reporting.md).

The screen/route inventory, responsive behavior and deliberate demo boundaries are documented in [docs/ui-implementation.md](docs/ui-implementation.md). Artwork provenance is in [ASSET_SOURCES.md](ASSET_SOURCES.md).

Before client testing, read [docs/phase-5-5-verification.md](docs/phase-5-5-verification.md), [docs/client-review-checklist.md](docs/client-review-checklist.md), and [docs/real-device-test-checklist.md](docs/real-device-test-checklist.md). The project is not production-ready until development Firebase/device verification is complete.

The repository includes deliberately restrictive Firebase rules as a deployment-safe baseline. Expand them alongside the trusted Cloud Functions used for product, order and admin workflows; do not deploy permissive rules for development convenience.
