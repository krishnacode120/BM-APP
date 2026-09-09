# Authentication proof of concept

A backend-neutral AuthIdentity/AuthSessionResult now joins the existing AuthService,
OTP controller and CustomerRepository; Firebase adapters convert their native
credentials and remain tested. Supabase delegates SMS send to signInWithOtp and
verification to verifyOTP(type:sms, phone, token), never generates a local code.
Request success is not sign-in success. A verified matching phone and session are
required, followed by a server-verified identity/profile save before navigation.
RLS and Auth triggers own identity/verification; the client updates only name.
SDK sessions persist/refresh; provider identity changes invalidate user caches.
Supabase logout is local-device scope. UI uses the existing name/Indian-phone
validation, six-digit autofill, cancellation guards, English/Tamil error mapping,
and a 60-second resend countdown (server policy remains authoritative).

On 2026-09-09 the approved project's public settings reported phone=false,
phone_autoconfirm=false, sms_provider=twilio. This is a disabled default, not proof
that Twilio credentials exist. No SMS was sent, no provider credentials changed,
no paid plan selected. Real phone sign-in cannot work until provider setup.

Current [Supabase phone documentation](https://supabase.com/docs/guides/auth/phone-login)
lists MessageBird, Twilio, Vonage and community-supported TextLocal. Confirm
provider availability, per-message costs and account-specific sender setup before
selecting one. [Twilio India guidelines](https://www.twilio.com/en-us/guidelines/in/sms)
and [pricing](https://www.twilio.com/en-us/sms/pricing/in) need review for the
actual route/account; India DLT/template/sender obligations differ by route.
Do not assume free SMS or bypass registration. Obtain user-approved provider
credentials in Supabase's server configuration, enable Phone, set SMS limits and
expiry, plan CAPTCHA/abuse protection, and test delivery/invalid/expired/resend
on a real Android and signed iPhone. No live password/OTP belongs in Git.

Stage C remains pending: real managed OTP, session recovery after app restart,
refresh expiry, blocked accounts, admin Auth, secure-storage assessment and
account/ownership migration. Supabase UUIDs are not Firebase UIDs. No automatic
user import or phone-based historical order takeover is implemented.
