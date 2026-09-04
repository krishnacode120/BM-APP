# Architecture

The customer app follows a feature-first, layered structure: presentation widgets use Riverpod providers; providers depend on repository contracts; repositories hide Firebase/HTTP implementations; services encapsulate SDK calls. Domain models have no widget dependencies.

The sample catalog remains deliberately isolated for local UI development before Firebase platform files exist. Product, category, location, pricing and order UI code depends on repositories/providers, not Firestore directly.

Milestone 3 order flow:

Flutter cart UI -> `CartNotifier` -> `CartPricingService` -> checkout -> `OrderRepository.createOrder` -> callable Cloud Function `createOrder` -> Firestore transaction.

The Flutter client may show estimated totals for UX, but it is not authoritative for identity, final order validity, or pricing. The Cloud Function derives `request.auth.uid`, verifies the Auth phone against an active Firestore customer profile, sources the customer name/phone from that profile, reloads product/location/price documents, validates inventory and minimum quantities, creates immutable order item/customer/location snapshots, records an idempotency result, and returns the created order.

Admin access is never determined by UI routing alone. Firebase custom claims and Firestore security rules will enforce roles, while the app only renders role-appropriate navigation.

Milestone 4 admin flow:

`/admin` -> `AdminGatePage` -> Firebase ID token claim refresh -> `AdminShell`. Admin reads are scoped through `AdminRepository`; sensitive writes use callable functions such as `updateOrderStatus`, `updatePaymentStatus`, `updateInventoryStatus`, `setProductPrice`, and `setAdminRole`. The backend validates admin claims, state transitions, financial values, inventory states and price-history rollover before writing Firestore and audit logs.

Admin UI currently lives in the same Flutter project to share models and repositories, but it is separated under `lib/features/admin`.

## UI and preference boundaries

`AppPreferencesController` owns the persisted locale and onboarding completion flags. `MaterialApp.router` watches this state, so English/Tamil changes rebuild all localized surfaces without a second state-management system. Reusable presentation primitives live under `lib/core/widgets`; they have no Firestore dependency.

The customer UI continues to follow `Widget -> Riverpod provider/notifier -> repository -> Firebase` for catalog, prices, orders and admin operations. The no-Firebase preview selects `DemoCatalogRepository` at the repository boundary. It never impersonates production writes: phone auth and trusted order submission remain unavailable until development Firebase is configured.

Recent searches and the temporary order list are device conveniences. The customer profile is intentionally limited to identity, orders, language, contact and logout. Internal `CartNotifier` naming is retained for architectural compatibility, but the customer experience presents it as an order list and no payment checkout is performed. Order creation remains server-authoritative.

Customer statuses are `pending`, `verified`, `confirmed`, `processing`, `ready`, `completed`, and `cancelled`. Payment statuses are admin-managed as `unpaid`, `partial`, and `paid`. The backend transition map prevents arbitrary jumps or rollback from terminal states.

The admin login uses Firebase email/password only, followed by a custom-claim and Firestore-profile gate. A successful Firebase sign-in does not grant admin access without both checks. Admin presentation uses `AdminRepository`; catalog/settings mutations are claim-guarded callables, and image bytes go directly to the restricted `products/{productId}` Storage path.

Milestone 5 operational flow:

`createOrder` / trusted admin mutation -> same Firestore transaction writes business record + `notificationJobs`/`reportSyncJobs` outbox record -> Firestore worker or scheduled retry claims a leased job -> FCM or Microsoft Graph -> safe operational status/log.

The transaction never performs an external HTTP or FCM request. Workers are at-least-once and processors use stable job/order keys, controlled retry and dead-letter states. Flutter's `NotificationService` owns permission-aware token registration and allow-listed deep-link delivery; UI widgets do not call FCM or callable token APIs directly.
