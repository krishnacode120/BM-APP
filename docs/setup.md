# Firebase and environment setup

Create distinct Firebase projects for development, staging, and production. Configure each mobile platform with its own Firebase config file; these files are ignored by Git. Run FlutterFire CLI after the Flutter SDK is installed if generated options are preferred.

Enable Phone Authentication, add Android SHA-1/SHA-256 values, configure APNs for iOS, and limit authorized domains for web/admin. Use `--dart-define=BM_ENV=development|staging|production`; no credential belongs in source code.

