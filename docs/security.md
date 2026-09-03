# Security baseline

Phone authentication is performed through Firebase Authentication. Role checks will use custom claims validated by Firestore rules and Cloud Functions; client-side role checks are display-only.

Production rules must isolate a user's profile, cart and orders. Privileged catalog, price, inventory, user, audit and admin operations require an admin claim. Service-account credentials belong only in trusted backend environments.

Milestone 3 keeps direct client writes to `orders`, `orderRequests`, and `counters` disabled. Customers can read only their own orders; they cannot set order ownership, status, payment status, final totals, or historical item prices. Trusted order creation happens through the authenticated Cloud Function, which runs with Admin SDK privileges and derives the user from Firebase Authentication.

Catalog, price and inventory writes remain denied to customers. Development seed data must be written through an admin process or emulator import, not by opening public write rules.

Milestone 4 uses Firebase custom claims as the admin authority: `admin == true` or `role == "admin"`. Firestore user profile roles may mirror claims for display, but they are not the source of security truth. The `/admin` route checks refreshed token claims, and backend callable functions repeat the same check before every mutation.

Customers cannot read audit logs, write products/categories/prices, upload product media, or change order state. Admins can read operational collections and perform catalog writes under claim-guarded rules; high-risk mutations are also exposed through trusted Cloud Functions that write audit entries.

Milestone 5 keeps `users/*/devices/*`, `notificationJobs`, `notificationLogs`, `reportSyncJobs`, and `reportSyncState` backend-write-only. Customers cannot read system jobs or device tokens, including their own token document. Admins can read safe job/report state but not tokens; FCM transport and Microsoft Graph credentials run only through Admin SDK Functions. Microsoft secrets are Firebase Functions secrets, never Firestore settings or Flutter values.
