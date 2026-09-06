# Security baseline

Authentication hardening preserves the existing rules: OTP login never rewrites an existing profile's role, active status or verified phone. Admin/customer/cart/order caches reset when accounts change. CSV exports prefix formula-like string values to keep spreadsheet applications from executing user-entered formulas. Numeric report values remain numeric.

The approved iOS workflow restores Firebase client configuration from an Actions secret, not from Git. Its public unsigned artifact still embeds that client configuration as any mobile app does. No service-account credentials, admin passwords, Apple signing material or APNs private keys belong in the workflow or artifact.

Phone authentication is performed through Firebase Authentication. Role checks will use custom claims validated by Firestore rules and Cloud Functions; client-side role checks are display-only.

Customer profile creation is restricted to the signed-in UID, the `customer` role, an active/verified profile, and the exact Firebase Auth phone claim. A customer update cannot change role, verified state, phone, active state, or timestamps outside the allowed name/update fields. This closes the previous profile-role escalation path.

Production rules must isolate a user's profile, cart and orders. Privileged catalog, price, inventory, user, audit and admin operations require an admin claim. Service-account credentials belong only in trusted backend environments.

Milestone 3 keeps direct client writes to `orders`, `orderRequests`, and `counters` disabled. Customers can read only their own orders; they cannot set order ownership, status, payment status, final totals, or historical item prices. Trusted order creation happens through the authenticated Cloud Function, which runs with Admin SDK privileges and derives the user from Firebase Authentication.

Catalog, price and inventory writes remain denied to customers. Development seed data must be written through an admin process or emulator import, not by opening public write rules.

Admin backend authority is a Firebase custom claim: `admin == true` or `role == "admin"`. The `/admin` UI additionally requires an active Firestore profile with `role == admin`, while every callable repeats the authoritative claim check before mutation.

Customers cannot read audit logs, write products/categories/prices, upload product media, or change order state. Admins can read operational collections and perform catalog writes under claim-guarded rules; high-risk mutations are also exposed through trusted Cloud Functions that write audit entries.

Milestone 5 keeps `users/*/devices/*`, `notificationJobs`, `notificationLogs`, `reportSyncJobs`, and `reportSyncState` backend-write-only. Customers cannot read system jobs or device tokens, including their own token document. Admins can read safe job/report state but not tokens; FCM transport and Microsoft Graph credentials run only through Admin SDK Functions. Microsoft secrets are Firebase Functions secrets, never Firestore settings or Flutter values.
