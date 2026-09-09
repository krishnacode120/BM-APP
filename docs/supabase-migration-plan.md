# Supabase migration — Stage A inventory and gated plan

Audited from `c24fe5d` on 2026-09-09. Work belongs to
`feature/supabase-migration`; master and Firebase remain the rollback source.
Existing unrelated `.metadata`, analyzer settings, DevTools and web changes are
preserved and excluded from migration commits.

## Current architecture and actual dependency use

Flutter 3.47.2 / Dart 3.13.2; feature-first Riverpod providers, GoRouter,
typed models, manual English/Tamil localization, shared design tokens/assets.
There is one cart implementation with account-scoped SharedPreferences and
revision guards; it revalidates location prices through repository contracts.

| Existing dependency/boundary | Actual use | Supabase destination |
| --- | --- | --- |
| firebase_core | Native initialization, configured/preview checks | Explicit immutable backend configuration |
| firebase_auth | Customer SMS callbacks, session state, admin email/password | Supabase Auth behind neutral identity/OTP interfaces |
| cloud_firestore | Catalog, location, prices, profiles, orders, admin reports, model mapping | PostgreSQL, RLS and read-only repository adapters |
| cloud_functions | Trusted orders/admin operations, device registration, CSV/retries | Narrow authenticated RPCs/Edge Functions in later stages |
| firebase_storage | Admin product image upload | Storage buckets/policies in Stage D |
| firebase_messaging | Native push permission, tokens, foreground/deep links | Retain FCM transport; UUID device mapping in Stage G |
| functions/src/index.ts | Atomic orders/numbering, status/payment/catalog/admin/audit | Transactional PostgreSQL commands; no client multi-insert order flow |
| functions/src/operational.ts | Leased notification/report outbox, retries, Graph writes | Private outbox plus trusted leased workers |

Customer UI, admin UI, logo, package/bundle `com.example.bm`, routes, cart,
localization, historical order models and all Firebase adapters stay in place.
SQL mapping extends existing typed models, not a duplicate domain model tree.
Current catalog queries are capped (30 products, 12 popular, 50 locations) and
have no pagination UI; the new adapter adds a bounded keyset page boundary.
Current Firestore search uses precomputed searchTerms; PostgreSQL uses indexed
simple-dictionary full-text search (English/Tamil/brand/keywords/category).
Substring/prefix matching is not equivalent; this is documented and tested.

## Existing data and migration safety

Firebase `bm-app-74ddb` stays on Spark. Earlier verification recorded development
catalog/settings data and an administrator, but that is not proof that current
orders/customer records are empty. A fresh counts-only Firestore check on
2026-09-09 found categories=8, products=7, locations=4, productPrices=28, users=1,
orders=0 and auditLogs=1 after CLI token refresh. Auth-only accounts were not
enumerated. No current Firestore orders require copying; user identity migration
still needs explicit verification/authorization. No customer data export or identity import is
authorized here. Counts-only verification is recorded separately when available.
Do not delete, seed over, or migrate any Firebase records automatically.

The user approved existing Supabase `eqnhxpqaytyskfmvnrmo` as development only.
Initial inspection found no public/app_private tables. Its region is
ap-southeast-2; latency and business data-residency suitability require review
before production. No paid project or SMS service is provisioned by this work.

## Schema and authorization design

Stage B: profiles (Auth UUID), categories, locations, products, product_prices,
private admin_memberships. Catalog text IDs preserve existing routes/references.
Product image URLs remain arrays/thumbnail in the initial adapter; normalized
product_images and Storage lifecycle follow in D. Status is an allow-listed
enum-like check, independent of optional integer quantity. Prices are numeric
INR with non-overlapping half-open effective periods and timestamptz timestamps.

Catalog SELECT is explicitly granted to anon/authenticated but RLS exposes only
active, visible records with active parents/locations. Client catalog writes are
denied, including admin clients until trusted mutations exist. Profiles are
created/synchronized from verified Auth identity by a restricted trigger;
customers can read their own active profile and update only display name and
preferences, never identity/verification/active status/role. Private memberships
are not exposed, use no user_metadata for authority, and cannot be client-edited.
All exposed tables have RLS and explicit grants. Privileged functions need an
empty search_path, qualified objects, narrow execute grants and independent
authorization. Future views must be security_invoker.

Later schema: product_images; order_number sequence; orders and order_items
immutable snapshots; private order_requests unique(user_id,idempotency_key);
append-only order_status_history/admin_audit_logs; public business_settings;
private user_devices, notification_jobs/logs, report_sync_jobs/state and secrets.
Order/admin-sensitive fields never receive customer UPDATE grants. Customers
read only owned order rows/items; admins require current active membership and
profile, not stale token metadata. Trusted commands write audit rows atomically.

## Trusted order transaction (Stage E, not implemented in B)

Authenticate JWT and derive auth.uid(); verify active confirmed-phone profile.
Validate normalized payload sizes, unique product IDs, positive integer/minimum
quantities, active category/product/location, orderable status and effective
price using server time. Lock/recheck applicable rows in deterministic ID order.
Canonicalize payload and hash a versioned fingerprint. Insert/lock request by
unique(user_id,key); same fingerprint returns the original order, changed
fingerprint is rejected. Current Firebase request records do NOT store a
fingerprint; do not copy that incompatibility. Allocate a sequence number (gaps
are acceptable), store numeric price/unit/name/customer/location snapshots,
order/items/status/audit and outbox in ONE transaction, then commit. A crash
must leave all or none. Test same-key concurrent calls, retry after timeout,
changed payload, stale prices, inactive users, stock/minimum validation and
rollback before allowing cutover. Email/SMS/Graph never run inside that txn.

Firebase UIDs are strings, not Supabase UUIDs. Any future migration needs a
privileged explicit mapping table, verified account linking and reconciliation
of ownership/history; never match a client-supplied phone/email alone. Local
Supabase cart/session keys must be separate from Firebase keys. No silent
dual-write or cross-backend fallback is allowed.

## Stage gates

- [x] A: inventory, feature map and security/order design.
- [x] B implementation: configuration, SQL foundation/RLS, OTP and catalog proof
  of concept; local SQL + Flutter tests and development API validation passed.
  See supabase-verification.md for build results and remaining real-service gates.
- [ ] C: real provider-backed SMS, session restoration/logout/account changes,
  profile/preferences and admin authentication with device verification.
- [ ] D: catalog pagination UI, image Storage, data import/reconciliation.
- [ ] E: trusted atomic ordering, fingerprint idempotency and order history.
- [ ] F: validated admin operations, membership management, audit and SQL reports.
- [ ] G: UUID device registry, FCM/APNs and leased Graph/Excel outbox workers.
- [ ] H: full regression, reconciliation, signed-device testing, approved
  cutover/rollback rehearsal, and only then removal of unused Firebase pieces.

The Stage B build deliberately disables ordering/admin/media/legacy push in
Supabase mode. It is a development foundation, not a fully migrated BM app.
Default Firebase builds preserve existing behavior; only an explicit build-time
backend selection activates Supabase. Missing Supabase configuration fails
closed rather than displaying a fake/demo catalog.

## Configuration, costs and risks

Client: project HTTPS URL and modern publishable key via ignored configuration
or CI. These are public mobile configuration, not admin/service-role credentials.
Server secrets stay outside Flutter/Git. Phone auth needs an enabled SMS provider
and its secret credentials in Supabase; provider pricing, sender registration,
India DLT/template and delivery requirements must be approved before real SMS.
Supported candidates must be checked against current Supabase documentation;
no free-SMS promise and no embedded bypass/test OTP in the production app.

Rollback selects Firebase in a rebuilt app; no schema drops or Firebase history
rewrites. Before any later production cutover, establish backups, reconciliation,
maintenance/write routing and backward-compatible app versions. Current tests
and builds are reported separately from real SMS, signed iPhone, FCM and Graph
verification. A public unsigned iOS artifact is not an installable IPA.
