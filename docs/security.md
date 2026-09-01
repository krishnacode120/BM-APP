# Security baseline

Phone authentication is performed through Firebase Authentication. Role checks will use custom claims validated by Firestore rules and Cloud Functions; client-side role checks are display-only.

Production rules must isolate a user's profile, cart and orders. Privileged catalog, price, inventory, user, audit and admin operations require an admin claim. Service-account credentials belong only in trusted backend environments.

