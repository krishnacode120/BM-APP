# BM real-device test checklist

Use a development Firebase project and development seed data. Do not run this against production.

1. Install the development debug APK on an Android phone.
2. Launch and verify the text-only BM splash and onboarding.
3. Verify English, then Tamil, including long product and cart text.
4. Request an OTP with a real permitted test phone number; enter the valid code.
5. In Firebase Console, verify the Auth user at **Authentication → Users**.
6. In Firestore, verify any customer profile data at **Firestore Database → Data → users**.
7. Select Karaikudi, open a product, and compare its displayed price with `productPrices`.
8. Add the minimum quantity to cart; test merge, decrement, remove, location change and price revalidation.
9. Complete checkout; verify one order, immutable item/location/price snapshots and `orderRequests` idempotency data in Firestore.
10. Repeat the same submission only through the app retry path and verify no duplicate order.
11. Open Order History and Order Detail.
12. Configure a test business contact in `settings/app`; test Call, WhatsApp and email actions.
13. Sign in with a custom-claim admin, open `/admin`, update status/payment/inventory and inspect `auditLogs`.
14. Enable notification permission, verify device registration, create/update an order, receive and tap push, and verify the deep link.
15. Configure Microsoft Graph secrets and workbook tables; verify Orders and OrderItems rows update without duplicates.
16. Log out using the eventual account UI and confirm the device token is disabled before a different account uses the device.
17. Test a second user: they must not see the first user's orders or jobs.

The current customer shell does not yet expose a sign-out button, so item 16 is a release follow-up rather than a completed live test.
