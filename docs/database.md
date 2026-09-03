# Planned Firestore collections

`users`, `roles`, `locations`, `categories`, `products`, `productPrices`, `orders`, `orderRequests`, `counters`, `auditLogs`, and `notifications` are separate collections. Order items snapshot product name, Tamil name, image URL, unit, quantity, price and subtotal, so historic orders never depend on mutable catalog records.

Location pricing is modeled as a product/location mapping, never as values embedded in UI code.

Milestone 2 queries active categories by `sortOrder`, active products by category/popularity, and `productPrices` by product/location/effective date. Create Firestore composite indexes for `products(isActive, stockStatus, isPopular)` and `productPrices(productId, locationId, effectiveFrom DESC)`. Development seed data is isolated in `DemoCatalogRepository`; use an Admin SDK script to create identical Firestore documents, never client writes.

Milestone 3 order queries:

- `orders` where `userId == currentUser.uid`, ordered by `createdAt DESC`, limited to 20.
- `orders/{orderId}` read is additionally checked client-side against the current user, and Firestore rules enforce ownership.
- `orderRequests/{userId}_{idempotencyKey}` is backend-only and stores the successful `orderId` for safe retries.
- `counters/orders.next` is backend-only and used inside a transaction to generate customer-friendly numbers such as `BM10001`.

Required indexes:

- `orders(userId ASC, createdAt DESC)`
- `productPrices(productId ASC, locationId ASC, effectiveFrom DESC)`
- `products(isActive ASC, stockStatus ASC, isPopular ASC)`
- `products(isActive ASC, stockStatus ASC, categoryId ASC)`
- `products(isActive ASC, stockStatus ASC, searchTerms ARRAY_CONTAINS)`
- `products(isActive ASC, stockStatus ASC, categoryId ASC, searchTerms ARRAY_CONTAINS)`
