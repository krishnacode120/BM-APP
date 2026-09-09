# Reporting — Stage G design only

PostgreSQL will be authoritative; Excel is an eventually consistent private
reporting destination. Stage B does not deploy Graph workers or migrate reports.
Keep existing Firebase operational code as rollback reference. Port the Orders
and OrderItems column mapping from docs/reporting.md, stable order-ID/item-key
upsert behavior, bounded leased workers, 1/5/30/120-minute transient retries and
five-attempt dead letter threshold. Order success must not depend on Graph.

Outbox writes occur in the same transaction as each relevant order mutation.
Guard against an old worker acknowledging a newer order version, lease expiry,
duplicate messages and a successful Graph write whose acknowledgment was lost.
Graph credentials belong in server secrets/Vault, not public settings or Flutter.
Validate actual Microsoft workbook endpoint permission support and a private
workbook/table before selecting an authorization flow; existing code compilation
is not proof the configured Graph flow works. Admin-only CSV preserves Tamil
UTF-8/BOM and formula-injection protection, without public export URLs.
