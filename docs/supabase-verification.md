# Stage A/B verification — 2026-09-09

Scope: audit/design plus a development-only Supabase foundation. This is not a
complete Firebase replacement. Stage C managed SMS/device authentication and
Stages D–H remain gated. Branch: feature/supabase-migration from c24fe5d.

## Implemented

- Explicit build-time backend configuration and ignored public-client JSON.
- Backend-neutral identity/OTP boundary retaining native Firebase behavior.
- Supabase SMS request/verify adapter, server-verified profile rename and sessions.
- Read-only catalog, English/Tamil full-text search, keyset repository boundary,
  active/hidden filtering, numeric server-time location pricing.
- Account/backend-isolated cart keys; existing UI and cart logic preserved.
- Explicit Supabase order/admin/media/push/contact-settings unavailability.
- PostgreSQL foundation, least-privilege grants/RLS, private memberships, price
  history constraints, Auth profile trigger, synthetic SQL tests and opt-in seed.
- Staged architecture, identity/order/admin/outbox/Storage migration designs.

## Exact checks

| Check | Result |
| --- | --- |
| flutter pub get | Passed; Supabase Flutter pinned 2.17.2, lockfile updated |
| dart format . | Passed; subsequent lib/test formatting passed |
| flutter analyze --no-pub | No issues found |
| flutter test --no-pub | 55 passed (44 existing + 11 Supabase tests) |
| npm test --prefix functions | Passed TypeScript build + both backend suites |
| Standalone PostgreSQL 17 migration | Fresh database apply passed |
| SQL/RLS regression | 40 assertions: 24 positive, 13 access denials, 3 constraints |
| Repeatable SQL harness | Passed fresh bm_foundation_a5b12d9a79dd; fixtures rolled back |
| Managed development migration | Applied successfully, version 20260909113138 |
| Actual anonymous catalog REST | categories/locations/products/product_prices HTTP 200, empty |
| Actual anonymous read RPCs | catalog_products/current_product_price HTTP 200, empty |
| Actual anonymous profile/admin API | profiles HTTP 401; private membership endpoint HTTP 404 |
| RLS inspection | Enabled on all six created tables |
| Android Supabase debug build | Passed, 128.4-second Gradle build |
| iOS workflow YAML | Parsed; Firebase/Supabase choice validated |
| iOS Supabase device build | Passed on GitHub macos-26 at a4d87a8 |
| Downloaded iOS artifact | Checksum verified; real ARM64 Mach-O Runner, Info.plist and development Supabase host present |

The managed catalog is intentionally empty: approval covered foundation schema,
not a data import/seed. No customer PII, Firebase users/orders or admin credentials
were copied. The local Auth harness verifies SQL behavior but is not GoTrue.
SDK HTTP fixtures are tests, never app fallback behavior.

## Build downloads and provenance

Application source: a4d87a88b2209ea6b9c501cad5fd2688f39b5681.
[Successful iOS run](https://github.com/krishnacode120/BM-APP/actions/runs/34346695944),
artifact 10102171860 (BM-ios-supabase-unsigned). GitHub retention expires
2026-09-16; local copies remain in build/releases.

- Android: build/releases/BM-supabase-foundation-debug.apk, 188,102,170 bytes.
  SHA256 D215027456D515ECDACF3D86F96FD6A4349F26F383D1F0B1268DCACC16F1BCC9.
- iOS: build/releases/BM-supabase-foundation-ios-unsigned.zip, 17,151,473 bytes.
  SHA256 42E63A7866AC3B45BCCF5D09837FB148CE718FCCC79BF0F5AFFB3DD91A07A063.
- Outer GitHub artifact checksum matched its API digest:
  0fad8571e1060c42e89967d48c47ebf4838fb0d78dfc57a4453a208bf8c48a66.

The iOS ZIP contains Runner.app with an ARM64 executable, not an APK. It is
unsigned and cannot be installed directly on an iPhone. A signed IPA/TestFlight
release needs Apple signing/provisioning and actual device verification.

## Advisories and limitations

Security advisor: no WARN/ERROR; one intentional INFO for deny-all private
admin_memberships without policies. Do not add a permissive policy to silence
[that advisory](https://supabase.com/docs/guides/database/database-linter?lint=0008_rls_enabled_no_policy).
Performance advisor: 13
[unused-index INFO notices](https://supabase.com/docs/guides/database/database-linter?lint=0005_unused_index)
on the newly empty database. Retain integrity/FK/query indexes; reassess with
real query statistics, not an empty-project measurement.

Phone login is disabled in the managed project. The default provider label is
Twilio, but live provider credentials/delivery were not verified. No SMS sent,
paid plan enabled, Storage bucket provisioned, or backend order/admin function
deployed. Real OTP, restored-device sessions, FCM/APNs and Microsoft Graph tests
remain pending. Stage B does not provide an installable signed iPhone app.

Android emits a future compatibility warning about the retained cloud_functions
plugin applying Kotlin Gradle Plugin. Current build succeeds; update/remove this
rollback dependency at an approved later stage rather than silently upgrading
the entire Firebase dependency stack.

Existing catalog UI still shows the first bounded page; pagination UI and Storage
uploads follow in D. Contact settings and all operational writes require their
own Supabase migration. Session secure-storage hardening and abuse controls
belong to the managed-auth gate; no production readiness is claimed.

## Files

New: lib/core/config/backend_config.dart; lib/models/auth_identity.dart;
lib/services/supabase_auth_service.dart; lib/repositories/supabase_catalog_repository.dart
and supabase_customer_repository.dart; test/supabase_foundation_test.dart;
config/supabase.example.json; supabase/config.toml, migrations, seed.sql and tests;
the docs/supabase-* migration documents.

Modified: pubspec.yaml/lock; .gitignore; README; .github/workflows/ios-build.yml;
lib/main.dart; auth_service and customer/order repository boundaries;
auth/admin/catalog/cart/order/notification/settings providers; login/OTP/home/
checkout development messaging; English/Tamil localizations; existing OTP,
session and notification regression tests.

The original .metadata, analysis_options.yaml, devtools_options.yaml and web/
changes are unrelated user work and excluded from this stage's commit. Existing
Firebase Functions, rules, native IDs, branding/assets and routes are preserved.

## Deployment record and rollback

The migration was first generated by Supabase CLI 2.117.0 as
20260909044859_foundation.sql. The managed migration API assigned 20260909113138;
the local filename was aligned to that returned version without changing SQL or
rewriting remote history. No remote seed ran. Local client config is ignored;
GitHub stores BM_SUPABASE_CONFIG_JSON as an encrypted Actions secret.

Rollback rebuilds with BM_BACKEND=firebase (default), using unchanged native
Firebase client configuration and implementations. No database drop is needed.
Never cut over real orders/users until identity mapping, reconciliation,
transaction/idempotency, permissions and device tests pass. Next: Stage C SMS
provider setup and actual Auth/profile verification, then Stage D catalog data.
