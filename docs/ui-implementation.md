# BM customer and admin UI

## Visual system

BM uses a warm white canvas, peach support surfaces, and BM orange for primary actions. Shared tokens live in `lib/core/theme/bm_theme.dart`; reusable cards, states, animations, skeletons, logo treatments, and buttons live in `lib/core/widgets/bm_components.dart`. Inventory and order states always combine text/icons with colour.

## Customer routes

- `/splash`, `/language`, `/onboarding`
- `/login`, `/signup`, `/otp`
- `/home`, `/categories`, `/category/:id`, `/search`
- `/product/:id`, `/locations`
- `/cart`, `/checkout`, `/order-success`
- `/orders`, `/orders/:id`
- `/profile`, `/support`

Customer identity is deliberately name plus Indian mobile number verified by Firebase phone OTP. There are no customer passwords, social login, wishlist, coupons, online payment, address book, rider workflow, map tracking, or fake delivery tracking routes.

## Admin routes

- `/admin/login` performs Firebase email/password sign-in.
- `/admin` and `/admin/orders/:id` require both an active admin Firestore profile and an admin custom claim.
- The responsive shell exposes Dashboard, Orders, Customers, Products, Categories, Reports, and Settings.

The admin screens operate on Firestore/Storage/Functions data for customer lookup and calling, guarded status/payment/final-value changes, catalog and price history, inventory, CSV/reporting, sync recovery, contact settings, password change, and logout.

## Responsive and accessibility behavior

- Customer content uses flexible grids, wraps, and maximum-width constraints rather than fixed phone widths.
- Admin navigation changes from a drawer to a rail on wider layouts.
- Safe areas protect bottom actions, text wraps for Tamil, and controls keep Material touch targets.
- Loading skeletons, localized empty/error states, retry actions, semantic labels, and non-colour status text are used throughout.

## Data and development boundary

With Firebase configured, catalog, pricing, orders, settings, and admin features use production-shaped Firebase repositories. Without Firebase, only the clearly identified catalog preview adapter is available; OTP, admin access, media upload, and order submission never report fake success.

## Verification

Run:

```powershell
flutter clean
flutter pub get
dart format .
flutter analyze
flutter test
cd functions
npm test
cd ..
npx firebase-tools emulators:exec --only firestore "cd functions && npm run test:rules"
flutter build apk --debug
```

Development Firebase client configuration is installed. Firestore rules/indexes are deployed and the catalog/settings seed is present. Storage/Functions deployment (Blaze plan required), admin bootstrap, and physical-device acceptance remain required before production release.
