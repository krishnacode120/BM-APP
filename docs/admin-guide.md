# BM Admin Guide

BM Admin is available at `/admin` in the Flutter app. It is intentionally separated from customer navigation and requires Firebase custom claims.

## Authorization

Admin authority is a Firebase Authentication custom claim:

- `admin: true`
- or `role: "admin"`

The Firestore `users/{uid}.role` value is only a mirrored profile/display field. Do not treat it as the security source.

## First Admin Bootstrap

Create the first admin only from a trusted backend environment:

```powershell
cd functions
node scripts/bootstrap-admin.js <firebase-auth-uid>
```

The script sets Firebase custom claims, mirrors the role into `users/{uid}`, and writes an `ADMIN_CREATED` audit log. It requires Admin SDK credentials or an emulator/trusted Firebase runtime. Do not create a public first-admin registration screen.

## Admin Operations

Milestone 4 includes callable functions for:

- `updateOrderStatus`
- `updatePaymentStatus`
- `updateOrderFinancials`
- `updateAdminNote`
- `upsertProduct`
- `upsertCategory`
- `updateInventoryStatus`
- `setProductPrice`
- `setAdminRole`
- `updateBusinessSettings`

Each function requires auth and an admin claim. Order status transitions are validated server-side. Price changes expire existing active prices and create new `productPrices` records, preserving order history.

## Admin UI

The admin application includes:

- Firestore dashboard metrics for customers, products, orders, statuses and recognized revenue
- Searchable customer list, order history, verified/account state and Call Customer
- Guarded order verification/status/payment/final-total/note operations
- Product add/edit, inventory/visibility controls, Storage image upload and location pricing
- Category add/edit/enable/disable
- Reports, seven-day revenue chart, top materials, CSV fallback and report retry visibility
- Editable public business contact settings, admin password change and secure logout

Order transitions are `pending -> verified -> confirmed -> processing -> ready -> completed`; cancellation is permitted only from non-terminal operational states. Every important status, payment, price, catalog and settings change is confirmed in the UI and validated/audited by the backend.

## Emulator Tests

Run:

```powershell
npx firebase-tools emulators:exec --only firestore "cd functions && npm run test:rules"
```

The security tests verify customer order isolation, normal-user catalog write denial, admin catalog write access, audit-log protection, and unauthenticated protected-read denial.

## Deferred to Milestone 5

Milestone 5 adds **Reports & Sync**. It shows total orders plus synced/pending/failed report work, safe failure codes and a trusted Retry sync action. It also exposes a private callable CSV fallback copied to the device clipboard. The content is sensitive operational data; do not share exports outside authorized business workflows.

Excel sync is eventually consistent. A report error does not mean an order failed; inspect the Firestore order first, correct Microsoft Graph/secret configuration, then retry the job. See [reporting.md](reporting.md) and [notifications.md](notifications.md).
