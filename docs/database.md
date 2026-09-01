# Planned Firestore collections

`users`, `roles`, `locations`, `categories`, `products`, `productPrices`, `carts`, `orders`, `auditLogs`, and `notifications` are separate collections. Order items will snapshot product name, unit, quantity and price, so historic orders never depend on mutable catalog records.

Location pricing is modeled as a product/location mapping, never as values embedded in UI code.

