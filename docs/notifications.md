# Notifications

BM uses Firebase Cloud Messaging (FCM) for transactional operational messages. Push delivery is best-effort: Firestore orders remain the source of truth and an order is never rejected because notification delivery fails.

## Device registration

After the first successful order submission, Flutter contextually requests notification permission and, when granted, obtains an FCM token and calls `registerDeviceToken`. Tokens are stored at `users/{uid}/devices/{stableDeviceId}` so one account can have several active devices. The callable stores platform, locale, app version, role snapshot, enabled flag and timestamps. Tokens never appear in the customer or normal admin UI.

Token refreshes update the same device document. `deactivateDeviceToken` disables the current device before logout; callers must run it before `FirebaseAuth.signOut()`. A new login cannot overwrite a different user's document because the callable derives the path from `request.auth.uid`.

## Events and deep links

Customer events are `ORDER_CREATED`, `ORDER_VERIFIED`, `ORDER_CONFIRMED`, `ORDER_PROCESSING`, `ORDER_READY`, `ORDER_COMPLETED`, `ORDER_CANCELLED`, and `PAYMENT_PAID`. Admin events are `NEW_ORDER` and a deduplicated `LOW_STOCK` transition.

Payload data contains only event type, IDs, order number and an allow-listed route. It never includes address, notes, phone number, device token, or order-item payload. Customer taps open `/orders/{orderId}`; admin taps open `/admin/orders/{orderId}`. Foreground messages use one in-app snackbar rather than a duplicate local notification. English and Tamil customer text is selected from the stored device locale; MVP admin text is English.

## Android setup

1. Register the Android app matching `android/app/build.gradle.kts` in the **development** Firebase project.
2. Put `google-services.json` at `android/app/google-services.json` (ignored by Git).
3. Build on Android 13+ and grant `POST_NOTIFICATIONS` after submitting the first test order.
4. Confirm the native `bm_order_updates` notification channel is visible in device settings.

## iOS setup

1. On macOS, open `ios/Runner.xcworkspace` and add the development `GoogleService-Info.plist` to Runner.
2. In Apple Developer and Xcode, enable Push Notifications and Background Modes / Remote notifications.
3. Upload an APNs authentication key (or certificate) to the development Firebase project.
4. Run on a real iPhone, sign in, enable notifications, create/update an order, tap the push and verify the order deep link.

iOS push is not verified until those Apple/Firebase steps have been completed on a development project.

## Delivery and recovery

`notificationJobs` is a durable at-least-once outbox. The worker deduplicates identical tokens, removes invalid/unregistered tokens, retries transient provider failures after 1, 5, 30 and 120 minutes, then marks the job `DEAD_LETTER`. Jobs with no active token complete as `NO_ACTIVE_TOKENS`; this is not represented as a false "sent" result. Operational results are recorded in `notificationLogs` without raw provider errors or PII.
