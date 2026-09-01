# BM — Building Materials Marketplace

BM is a Flutter customer app foundation for purchasing and enquiring about construction materials. It supports English and Tamil, an onboarding flow, phone OTP authentication boundaries, location-aware product abstractions, and a lightweight marketplace home experience.

## Milestone status

Implemented: project structure, Material 3 design system, routing, English/Tamil localization, splash/onboarding, login and OTP UI, Firebase Auth service boundary, role-safe user model, environment placeholders, home navigation, sample repository abstraction, and starter tests.

Milestone 2 adds Firestore-backed category, product, location and pricing repository contracts; location preference persistence; inventory-aware product display; category/product detail routes; and development seed records. Firebase project credentials, real OTP execution, cart, orders, admin portal, FCM, and Excel synchronization remain pending. The app intentionally never claims Firebase is enabled when platform configuration is absent.

## Structure

- `lib/core` — configuration, theme, routing, reusable UI
- `lib/features` — feature-owned UI and state
- `lib/models` — typed domain entities
- `lib/repositories` — data contracts and temporary development implementation
- `lib/services` — external platform/service boundaries
- `lib/l10n` — English and Tamil message catalogues
- `docs` — architecture and setup decisions
- `test` — fast behavioural/widget coverage

## Local setup

1. Install Flutter (stable channel) and run `flutter doctor`.
2. Run `flutter pub get` in this directory.
3. Copy `.env.example` to `.env` if local tooling needs it. Do not commit it.
4. Create Firebase development/staging/production projects. Add `google-services.json` under `android/app/` and `GoogleService-Info.plist` under `ios/Runner/` for the active environment.
5. Enable Firebase Phone Authentication and configure Android SHA keys / iOS APNs as required.
6. Run `flutter run --dart-define=BM_ENV=development`.

## Checks

```powershell
flutter format .
flutter analyze
flutter test
```

See [docs/setup.md](docs/setup.md), [docs/architecture.md](docs/architecture.md), [docs/database.md](docs/database.md), and [docs/security.md](docs/security.md).

The repository includes deliberately restrictive Firebase rules as a deployment-safe baseline. Expand them alongside the trusted Cloud Functions used for product, order and admin workflows; do not deploy permissive rules for development convenience.
