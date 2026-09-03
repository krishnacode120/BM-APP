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

Each function requires auth and an admin claim. Order status transitions are validated server-side. Price changes expire existing active prices and create new `productPrices` records, preserving order history.

## Admin UI

The admin shell includes:

- Dashboard metrics
- Orders with status/payment operations
- Products with inventory status controls
- Categories list
- Users list
- Audit log list
- Settings foundation

The current UI is an operational foundation. Rich add/edit forms, product image picker/upload flow, detailed user profiles and advanced search remain future hardening work.

## Emulator Tests

Run:

```powershell
npx firebase-tools emulators:exec --only firestore "cd functions && npm run test:rules"
```

The security tests verify customer order isolation, normal-user catalog write denial, admin catalog write access, audit-log protection, and unauthenticated protected-read denial.

## Deferred to Milestone 5

Excel synchronization, FCM notifications, reporting exports and production notification deep links are intentionally not implemented in Milestone 4.
