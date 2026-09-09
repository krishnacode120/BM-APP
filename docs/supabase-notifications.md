# Notifications — Stage G design only

FCM remains the intended native push transport. Stage B disables legacy Firebase
Auth/Functions device registration in Supabase mode so UUID sessions never write
Firebase user/device records. It does not claim live push delivery.

Later user_devices is private and UUID-owned, with trusted token registration,
rotation and deactivation. Transactional order events create private notification
jobs. Workers lease bounded jobs with FOR UPDATE SKIP LOCKED, retry transient
errors, remove invalid tokens and record safe logs/dead letters. Preserve the
current pending/processing/retrying/completed/failed/dead-letter semantics and
localized customer/admin templates plus allow-listed deep links. FCM service
account/APNs credentials must remain server-side; notification payloads should
avoid private address/phone data. Test Android and signed iPhone/APNs in reality.
