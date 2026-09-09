# Supabase development setup (Stage B)

Use the existing approved development project eqnhxpqaytyskfmvnrmo. Never put a
service-role/secret key, SMS credential, Firebase admin password or Apple signing
key in Flutter. Use the modern publishable key from Project Settings > API Keys.

Copy config/supabase.example.json to config/supabase.local.json and fill its URL
and publishable key. The local file is ignored. Run:

```powershell
flutter pub get
flutter run --dart-define-from-file=config/supabase.local.json
flutter build apk --debug --dart-define-from-file=config/supabase.local.json
```

Without BM_BACKEND=supabase, Firebase remains selected. Invalid/missing Supabase
configuration does not fall back to Firebase or demo catalog. Backend selection
is build-time, not a runtime account switch. Supabase uses SDK-managed persisted
sessions and separate local cart/location keys. Stage B deliberately blocks
order/admin operations, uploads, legacy FCM registration and contact settings;
these need subsequent migration, not fallback data.

## SQL and RLS tests

CLI pinned to 2.117.0; PostgreSQL 17. Migrations are CLI-generated, committed and
reviewable. Use npx --yes supabase@2.117.0 --help and command --help before use.
The local config exposes public only, requires explicit grants, and disables
seeding. Do not run db reset against remote data. Docker is not installed on the
current Windows machine, so the complete local Supabase stack was not run.

An isolated PostgreSQL harness is included:

```powershell
./supabase/tests/run-foundation.ps1
```

It verifies its loopback test cluster, creates a fresh test database, applies
migrations transactionally, then runs rollback-only synthetic SQL fixtures. It
uses only the ignored build/supabase-pg-test directory and port 55439, never the
installed PostgreSQL service or remote project. Test Auth tables/roles emulate
only the Auth SQL contract, not the real GoTrue/SMS/PostgREST services. Stop a
manually started test cluster when finished. Do NOT execute standalone_bootstrap
on Supabase. For managed deployment apply only the migration via the trusted
migration tool after tests and approval; record its migration version/advisors.

## Optional demo data

supabase/seed.sql is opt-in and not run by app startup or migration. Review the
[DEMO] records, then explicitly set app.bm_development_seed = 'approved' in a
privileged development SQL session and execute the seed. Never enable this in
production. Existing rows are not overwritten; overlapping price inserts are
ignored. No real customers or orders are copied. The approved remote action for
this stage is schema-only: an empty catalog is expected until seed/import is
separately approved.

## iOS

Use the existing iOS unsigned workflow with backend=supabase after placing the
same public-client JSON in Actions secret BM_SUPABASE_CONFIG_JSON. Its output
contains client configuration, as all mobile apps do. An unsigned Runner.app ZIP
is not an installable IPA. Apple Developer signing/provisioning and macOS/Xcode
are required for an installable device IPA/TestFlight distribution. Windows
cannot perform a local iOS build. Package/bundle IDs remain com.example.bm.
