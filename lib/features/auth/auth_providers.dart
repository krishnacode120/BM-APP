import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/backend_config.dart';
import '../../models/auth_identity.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_auth_service.dart';
import '../../models/customer_profile.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/supabase_customer_repository.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  if (ref.watch(backendConfigProvider).isSupabase) {
    try {
      return SupabasePhoneAuthService(ref.watch(supabaseClientProvider));
    } on BackendUnavailable {
      return const UnavailableAuthService();
    }
  }
  return Firebase.apps.isEmpty
      ? const UnavailableAuthService()
      : FirebasePhoneAuthService(FirebaseAuth.instance);
});

// Auth changes, not token refreshes, invalidate account-specific caches.
final authStateProvider = StreamProvider<AuthIdentity?>((ref) {
  if (ref.watch(backendConfigProvider).isSupabase) {
    try {
      final client = ref.watch(supabaseClientProvider);
      Stream<AuthIdentity?> sessions() async* {
        final current = client.auth.currentUser;
        yield current == null ? null : supabaseIdentity(current);
        yield* client.auth.onAuthStateChange.map((event) =>
            event.session == null
                ? null
                : supabaseIdentity(event.session!.user));
      }

      return sessions().distinct(
          (a, b) => a?.uid == b?.uid && a?.phoneNumber == b?.phoneNumber);
    } on BackendUnavailable {
      return Stream.value(null);
    }
  }
  return Firebase.apps.isEmpty
      ? Stream.value(null)
      : FirebaseAuth.instance.authStateChanges().map((user) => user == null
          ? null
          : AuthIdentity(uid: user.uid, phoneNumber: user.phoneNumber));
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  if (ref.watch(backendConfigProvider).isSupabase) {
    try {
      return SupabaseCustomerRepository(ref.watch(supabaseClientProvider));
    } on BackendUnavailable {
      return const UnavailableCustomerRepository();
    }
  }
  return Firebase.apps.isEmpty
      ? const UnavailableCustomerRepository()
      : FirebaseCustomerRepository(
          FirebaseFirestore.instance, FirebaseAuth.instance);
});

final currentCustomerProvider = FutureProvider<CustomerProfile?>((ref) async {
  final repository = ref.watch(customerRepositoryProvider);
  final user = await ref.watch(authStateProvider.future);
  if (user == null) return null;
  return repository.currentProfile();
});
