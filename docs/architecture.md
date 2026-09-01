# Architecture

The customer app follows a feature-first, layered structure: presentation widgets use Riverpod providers; providers depend on repository contracts; repositories hide Firebase/HTTP implementations; services encapsulate SDK calls. Domain models have no widget dependencies.

The present sample catalog is deliberately a development-only repository. Replace it with a Firestore implementation in Milestone 2; UI code will depend on `ProductRepository`, not Firestore directly.

Admin access is never determined by UI routing alone. Firebase custom claims and Firestore security rules will enforce roles, while the app only renders role-appropriate navigation.

