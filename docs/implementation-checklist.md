# Implementation checklist

- [x] Milestone 1: app foundation, localization, onboarding, auth boundary and home shell
- [x] Milestone 2: Firestore catalog, search, locations and price resolver
- [x] Milestone 3: cart UI, checkout, idempotent trusted order creation foundation and order history
- [x] Milestone 4: secure admin operations, customer/order/catalog/pricing/report/settings UI and emulator rules tests
- [x] Milestone 5: durable FCM and trusted Excel/Graph synchronization foundation
- [ ] Milestone 6: rules, offline/performance QA, release builds and store assets

## Reference UI implementation

- [x] Original BM logo, mark and white SVG variants
- [x] Original local construction-material hero with recorded provenance
- [x] Persisted English/Tamil first-run selection
- [x] Animated splash and three-step onboarding
- [x] Customer home, categories, debounced search and responsive product cards
- [x] Location-aware price, unit, minimum order and inventory states
- [x] Product image gallery, quantity controls, estimated order value and order-list integration
- [x] Minimal profile with identity, orders, language, contact and secure logout
- [x] Order history/detail with the verified business status flow
- [x] Separate admin login, role gate and responsive navigation shell
- [x] Admin dashboard, customers, guarded orders/payments, product/category CRUD, media, pricing, reports and settings
- [x] Customer profile role/phone escalation protection
- [x] Customer identity is sourced from the verified profile during trusted order creation
- [x] Loading, empty, error and unavailable states use shared components
- [x] Analyzer clean and automated Flutter suite passing
- [x] Register Android/iOS Firebase apps and generate FlutterFire options for `bm-app-74ddb`
- [x] Enable development Email/Password and Phone Authentication and register Android debug SHA fingerprints
- [x] Deploy restrictive Firestore rules/indexes and seed 48 development catalog/settings documents
- [ ] Validate all screens on physical small Android, typical Android and iPhone devices
- [ ] Replace temporary platform launcher icons after final brand approval
- [x] Keep `bm-app-74ddb` on Spark; live Storage/Functions capabilities are intentionally excluded by the client decision
- [x] Bootstrap the initial Firebase admin account with admin claims, an active profile and an audit record (account email is not stored in the repository)
- [ ] Verify Firebase-authenticated customer/admin paths against `bm-app-74ddb` on a physical device
