# Security baseline

Phone authentication is performed through Firebase Authentication. Role checks will use custom claims validated by Firestore rules and Cloud Functions; client-side role checks are display-only.

Production rules must isolate a user's profile, cart and orders. Privileged catalog, price, inventory, user, audit and admin operations require an admin claim. Service-account credentials belong only in trusted backend environments.

Milestone 3 keeps direct client writes to `orders`, `orderRequests`, and `counters` disabled. Customers can read only their own orders; they cannot set order ownership, status, payment status, final totals, or historical item prices. Trusted order creation happens through the authenticated Cloud Function, which runs with Admin SDK privileges and derives the user from Firebase Authentication.

Catalog, price and inventory writes remain denied to customers. Development seed data must be written through an admin process or emulator import, not by opening public write rules.
