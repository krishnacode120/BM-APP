# Architecture

The customer app follows a feature-first, layered structure: presentation widgets use Riverpod providers; providers depend on repository contracts; repositories hide Firebase/HTTP implementations; services encapsulate SDK calls. Domain models have no widget dependencies.

The sample catalog remains deliberately isolated for local UI development before Firebase platform files exist. Product, category, location, pricing and order UI code depends on repositories/providers, not Firestore directly.

Milestone 3 order flow:

Flutter cart UI -> `CartNotifier` -> `CartPricingService` -> checkout -> `OrderRepository.createOrder` -> callable Cloud Function `createOrder` -> Firestore transaction.

The Flutter client may show estimated totals for UX, but it is not authoritative for final order validity or pricing. The Cloud Function derives `request.auth.uid`, reloads product/location/price documents, validates inventory and minimum quantities, creates immutable order item/customer/location snapshots, records an idempotency result, and returns the created order.

Admin access is never determined by UI routing alone. Firebase custom claims and Firestore security rules will enforce roles, while the app only renders role-appropriate navigation.

Milestone 4 admin flow:

`/admin` -> `AdminGatePage` -> Firebase ID token claim refresh -> `AdminShell`. Admin reads are scoped through `AdminRepository`; sensitive writes use callable functions such as `updateOrderStatus`, `updatePaymentStatus`, `updateInventoryStatus`, `setProductPrice`, and `setAdminRole`. The backend validates admin claims, state transitions, financial values, inventory states and price-history rollover before writing Firestore and audit logs.

Admin UI currently lives in the same Flutter project to share models and repositories, but it is separated under `lib/features/admin`.

Milestone 5 operational flow:

`createOrder` / trusted admin mutation -> same Firestore transaction writes business record + `notificationJobs`/`reportSyncJobs` outbox record -> Firestore worker or scheduled retry claims a leased job -> FCM or Microsoft Graph -> safe operational status/log.

The transaction never performs an external HTTP or FCM request. Workers are at-least-once and processors use stable job/order keys, controlled retry and dead-letter states. Flutter's `NotificationService` owns permission-aware token registration and allow-listed deep-link delivery; UI widgets do not call FCM or callable token APIs directly.
