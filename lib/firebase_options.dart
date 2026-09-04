// Generated from FlutterFire CLI output, with API keys supplied at build time.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static const _androidApiKey = String.fromEnvironment(
    'BM_FIREBASE_ANDROID_API_KEY',
  );
  static const _iosApiKey = String.fromEnvironment(
    'BM_FIREBASE_IOS_API_KEY',
  );

  /// Whether this build supplied the API key needed for explicit options.
  ///
  /// Mobile development normally uses the ignored native Firebase config
  /// files. CI or other build environments may instead inject the matching
  /// key with `--dart-define` without committing it to source control.
  static bool get hasEnvironmentConfiguration {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _androidApiKey.isNotEmpty,
      TargetPlatform.iOS => _iosApiKey.isNotEmpty,
      _ => false,
    };
  }

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: _androidApiKey,
    appId: '1:544513391401:android:1169832d06ebce88f39538',
    messagingSenderId: '544513391401',
    projectId: 'bm-app-74ddb',
    storageBucket: 'bm-app-74ddb.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: _iosApiKey,
    appId: '1:544513391401:ios:7ab18c51a78f6391f39538',
    messagingSenderId: '544513391401',
    projectId: 'bm-app-74ddb',
    storageBucket: 'bm-app-74ddb.firebasestorage.app',
    iosBundleId: 'com.example.bm',
  );
}
