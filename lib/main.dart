import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } on FirebaseException {
    // Local UI development remains available before Firebase platform files exist.
  }
  runApp(const BmApp());
}
