# Order migration — Stage E design only

Stage B keeps the existing cart UI, local persistence and repository-based price
revalidation; Supabase keys are isolated from Firebase carts. Order repository
operations explicitly fail with migrationPending in Supabase builds. Nothing
falls back to Firebase and no fake order success is possible.

The trusted SQL transaction/fingerprint design is in supabase-migration-plan.md.
Use auth.uid(), active verified profile, locked/rechecked products/location and
server-time prices. Validate positive integer/minimum quantities and normalized
payload. unique(user_id,idempotency_key) plus versioned canonical fingerprint
must serialize concurrent requests and reject changed payload reuse. The existing
Firebase foundation lacks fingerprint comparison; do not reproduce that gap.
Allocate sequence, snapshot all order/item names/units/prices/customer/location,
write status history and private notification/report outbox atomically. Retried
requests return the same owned order. Network uncertainty must preserve key and
cart until confirmed. Never create an order with separate client inserts.

Before E completion run concurrent integration tests, atomic rollback injection,
price-change acknowledgment, inventory validation, ownership reads and immutable
history tests. No checkout/payment/admin-order system was migrated by Stage B.
