import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth_service.dart';
import '../../models/customer_profile.dart';
import '../../repositories/customer_repository.dart';

final authServiceProvider = Provider<AuthService>((_) => Firebase.apps.isEmpty
    ? const UnavailableAuthService()
    : FirebasePhoneAuthService(FirebaseAuth.instance));

final customerRepositoryProvider = Provider<CustomerRepository>((_) =>
    Firebase.apps.isEmpty
        ? const UnavailableCustomerRepository()
        : FirebaseCustomerRepository(
            FirebaseFirestore.instance, FirebaseAuth.instance));

final currentCustomerProvider = FutureProvider<CustomerProfile?>(
    (ref) => ref.watch(customerRepositoryProvider).currentProfile());
