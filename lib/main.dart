import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Local UI development remains available before Firebase platform files exist.
    // On web, firebase_core_web throws an AssertionError (not FirebaseException)
    // when FirebaseOptions are not provided, so we catch all exceptions.
  }
  runApp(const BmApp());
}
