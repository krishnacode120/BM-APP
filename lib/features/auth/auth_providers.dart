import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((_) => Firebase.apps.isEmpty
    ? const UnavailableAuthService()
    : FirebasePhoneAuthService(FirebaseAuth.instance));
