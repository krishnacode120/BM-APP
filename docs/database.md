# Planned Firestore collections

`users`, `roles`, `locations`, `categories`, `products`, `productPrices`, `carts`, `orders`, `auditLogs`, and `notifications` are separate collections. Order items will snapshot product name, unit, quantity and price, so historic orders never depend on mutable catalog records.

Location pricing is modeled as a product/location mapping, never as values embedded in UI code.

Milestone 2 queries active categories by `sortOrder`, active products by category/popularity, and `productPrices` by product/location/effective date. Create Firestore composite indexes for `products(isActive, stockStatus, isPopular)` and `productPrices(productId, locationId, effectiveFrom DESC)`. Development seed data is isolated in `DemoCatalogRepository`; use an Admin SDK script to create identical Firestore documents, never client writes.
