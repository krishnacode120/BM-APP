# PostgreSQL foundation

Implemented migration: 20260909113138_foundation.sql. Tables: public.profiles,
categories, locations, products, product_prices; app_private.admin_memberships.
All have RLS. Auth users are UUID-owned; catalog IDs are text to preserve route
and future legacy mappings. Snake_case SQL maps into existing Dart domain types.
Product images are URL arrays + thumbnail; normalized images/storage follow in D.
Inventory uses available/lowStock/outOfStock/comingSoon/hidden, separately from
nullable stock_quantity. Product units preserve piece/bag/load/kg/ton/meter/
cubicFeet/other. Minimum quantities are positive integers. Prices numeric(14,2)
are INR, never formatted strings. All timestamps are timestamptz.

A GiST exclusion constraint prevents overlapping [effective_from,effective_to)
periods for a product/location; btree_gist lives in extensions without a pinned
extension version. A trigger permits only closing an open price period, not
changing price identity/value or deleting history. Server-time current_product_price
returns zero or one visible row; no applicable price means inquiry, never zero.
SQL monetary storage is exact; Dart's existing num is display/estimate only.
Future order totals must be computed by PostgreSQL and snapshot prices forever.

catalog_products is SECURITY INVOKER, keyset-paged by id, capped at 50, defaults
30 (popular 12). Products use GIN indexed simple-dictionary search_vector across
English/Tamil names, brand, keywords and category. Category rename refreshes its
products' vectors. Plain-text full-word AND search is not Firestore searchTerms
prefix/substring equivalence. The existing UI displays the first bounded page;
load-more UI is a Stage D task. Categories/locations retain 30/50 UI bounds.
Foreign-key, active-sort, category, popular and price lookup indexes are included.
Existing Riverpod family caches avoid repeated reads; no new realtime listeners.

Future orders/items/history, idempotency/fingerprint, devices/jobs/audit/settings
schema is designed in supabase-migration-plan.md, not implemented in Stage B.
