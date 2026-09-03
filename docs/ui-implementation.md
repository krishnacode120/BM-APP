# BM reference UI implementation

## Visual system

The interface uses a warm white canvas, peach support surfaces and BM orange for primary actions. Shared tokens are defined in `lib/core/theme/bm_theme.dart`. Cards use subtle borders, 12–24 px radii and low shadows. Inventory uses text and icons/chips in addition to colour.

Branding is provided as reusable SVG wordmark, inverse wordmark and compact mark. The promotional/onboarding material image is stored locally; provenance is recorded in `ASSET_SOURCES.md`.

## Customer route inventory

- `/splash`, `/language`, `/onboarding`
- `/login`, `/otp`
- `/home`, `/categories`, `/category/:id`, `/search`
- `/product/:id`, `/wishlist`, `/locations`
- `/cart`, `/checkout`, `/order-success`
- `/orders`, `/orders/:id`, `/orders/:id/tracking`
- `/profile`, `/addresses`, `/notifications`, `/notification-settings`
- `/settings`, `/support`, `/about`

## Admin route inventory

- `/admin/login` performs Firebase email/password sign-in.
- `/admin` and `/admin/orders/:id` remain behind the custom-claim gate.
- The responsive shell exposes dashboard, orders, products, categories, users, delivery, approvals, audit, reports and settings.

## Responsive behavior

- Customer content uses flexible wraps/grids and maximum-width constraints rather than fixed phone widths.
- Category and product grids increase columns on wider windows.
- The admin shell uses a drawer below 850 px and a navigation rail on wider layouts.
- Safe areas protect bottom actions and text is allowed to wrap for Tamil.
- All primary controls retain Material minimum touch targets and semantic tooltips/labels.

## Data and demo boundaries

When Firebase is configured, catalog, pricing, order and admin providers use the existing production-shaped Firebase repositories. When Firebase is absent, the repository provider exposes identifiable development categories/products/locations so the interface can be reviewed. The login screen labels this limitation and allows UI preview; checkout still cannot create a fake confirmed order.

Recent searches, wishlist IDs and saved addresses use `SharedPreferences`. These are local preference features, not claims of cloud synchronization. Delivery assignment and approval screens are prepared UI foundations and state that trusted backend integration is pending.

## Verification

Run:

```powershell
flutter pub get
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

Development Firebase and real-device acceptance are still required before production release.
