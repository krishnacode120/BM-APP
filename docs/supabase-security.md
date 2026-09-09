# Supabase authorization baseline

Public catalog SELECT is explicitly granted to anon/authenticated and filtered by
RLS. Inactive categories/locations/products and hidden products (including their
prices) cannot be read. Active catalog browsing is intentionally public. Profile
SELECT is own UUID + active only. Only authenticated active verified-phone
customers can UPDATE name/preferred_language/selected_location_id. Column grants
deny identity, phone, verification, active status and timestamps; RLS denies
other-user rows and inactive selected locations. No client profile INSERT/DELETE.

Auth's restricted SECURITY DEFINER trigger synchronizes id and verified phone
from auth.users; it never copies user_metadata roles or reactivates accounts.
The definer has empty search_path, qualified references and no client EXECUTE.
app_private is not API-exposed and grants no client access. admin_memberships is
RLS-enabled, deny-all to clients; initial admin bootstrap/management is deferred.
Do not import Firebase admin claims or treat an email/phone as admin authority.
Read RPCs are SECURITY INVOKER and obey RLS. No order/admin mutation RPC exists.
Catalog and price writes are denied to customers AND admin client sessions until
validated server commands exist. Service secrets belong only in trusted workers.

Future admin functions must check current active profile/membership each time,
use least privileges, audit transactions, and defend revocation/concurrent last
super-admin removal. Future order snapshots and private outbox records deny all
customer mutation. Public views must use security_invoker=true. Storage stays
unprovisioned in Stage B, with no public upload policy added. Firebase security
rules remain untouched for rollback.

Run foundation.sql security cases plus project security/performance advisors
after each migration. The standalone Auth harness cannot certify managed Auth
service configuration, actual SMS, or device-session security. CI/client files
contain only public URL/key; never use sb_secret_* or a legacy service-role JWT.
