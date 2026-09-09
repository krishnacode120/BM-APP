import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/backend_config.dart';

import 'core/app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = BackendConfig.fromEnvironment();
  if (config.isSupabase) {
    if (config.isValidSupabase) {
      try {
        await Supabase.initialize(
            url: config.url, publishableKey: config.publishableKey);
        initializedSupabaseClient = Supabase.instance.client;
      } catch (_) {
        debugPrint(
            'BM development backend initialization failed. Check setup.');
      }
    }
    runApp(const BmApp());
    return;
  }
  try {
    if (DefaultFirebaseOptions.hasEnvironmentConfiguration) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      // Android/iOS read the ignored native Firebase configuration files.
      await Firebase.initializeApp();
    }
  } catch (error) {
    // Log only the error type/code: native messages may include client config.
    // Preview remains available, while auth correctly reports unavailability.
    final code = error is FirebaseException ? error.code : error.runtimeType;
    debugPrint(
        'BM Firebase initialization failed ($code). Check platform setup.');
  }
  runApp(const BmApp());
}
