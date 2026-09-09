# Admin migration — Stage F design only

Existing Firebase admin pages/repositories remain for rollback. Supabase builds
show a migration-pending error at admin login, not a fabricated admin dashboard.
Stage B only creates deny-all app_private.admin_memberships keyed to Auth UUID.
There is no migrated administrator or client bootstrap command yet.

Later bootstrap must be a privileged, audited operation for a verified Auth UUID,
not a username/password hard-coded in Flutter. Mutations check active profile and
membership on every request, validate transition and field allow-lists, and write
append-only audit logs in the same transaction. Protect the last super-admin
with transaction locking. Customer fields must never grant roles via metadata.

Port order/payment/final-total operations, catalog/inventory/location pricing,
Storage uploads, settings, user management and CSV/report retries incrementally.
SQL reports must preserve paid + non-cancelled recognized revenue and aggregate
in the database rather than copying the current bounded 500-order calculation.
Test least privilege, revocation, escalation, customer ownership and concurrency.
