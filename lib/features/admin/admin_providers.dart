import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/audit_log.dart';
import '../../models/business_settings.dart';
import '../../models/category.dart';
import '../../models/location.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../repositories/admin_repository.dart';
import '../../repositories/product_media_repository.dart';
import '../auth/auth_providers.dart';
import '../../core/config/backend_config.dart';

typedef AdminSignIn = Future<void> Function({
  required String email,
  required String password,
});

final adminSignInProvider = Provider<AdminSignIn>((ref) => ({
      required String email,
      required String password,
    }) async {
      if (ref.read(backendConfigProvider).isSupabase) {
        throw const AdminFailure('migrationPending');
      }
      if (Firebase.apps.isEmpty) {
        throw const AdminFailure('firebaseUnavailable');
      }
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseException catch (error) {
        throw AdminFailure(error.code);
      }
    });

final adminRepositoryProvider = Provider<AdminRepository>((ref) =>
    ref.watch(backendConfigProvider).isSupabase || Firebase.apps.isEmpty
        ? const UnavailableAdminRepository()
        : FirebaseAdminRepository(FirebaseFirestore.instance,
            FirebaseFunctions.instance, FirebaseAuth.instance));

final productMediaRepositoryProvider = Provider<ProductMediaRepository>((ref) =>
    ref.watch(backendConfigProvider).isSupabase || Firebase.apps.isEmpty
        ? const UnavailableProductMediaRepository()
        : FirebaseProductMediaRepository(FirebaseStorage.instance));

final adminAccessProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  final user = await ref.watch(authStateProvider.future);
  if (user == null) return false;
  return repository.isCurrentUserAdmin();
});

// Access is rechecked whenever the Firebase account changes. Admin data also
// depends on this result so cached records cannot survive a session change.
final authorizedAdminRepositoryProvider =
    FutureProvider<AdminRepository>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  if (!await ref.watch(adminAccessProvider.future)) {
    throw const AdminFailure('permission-denied');
  }
  return repository;
});

final adminDashboardProvider = FutureProvider<AdminDashboard>((ref) async =>
    (await ref.watch(authorizedAdminRepositoryProvider.future)).dashboard());
final adminOrdersProvider = FutureProvider.family<List<BmOrder>, String?>(
    (ref, status) async =>
        (await ref.watch(authorizedAdminRepositoryProvider.future))
            .orders(status: status));
final adminOrderProvider = FutureProvider.family<BmOrder?, String>((ref,
        id) async =>
    (await ref.watch(authorizedAdminRepositoryProvider.future)).orderById(id));
final adminUsersProvider = FutureProvider<List<AdminUserSummary>>((ref) async =>
    (await ref.watch(authorizedAdminRepositoryProvider.future)).users());
final adminUserOrdersProvider = FutureProvider.family<List<BmOrder>, String>(
    (ref, id) async =>
        (await ref.watch(authorizedAdminRepositoryProvider.future))
            .ordersForUser(id));
final adminCategoriesProvider = FutureProvider<List<Category>>((ref) async =>
    (await ref.watch(authorizedAdminRepositoryProvider.future)).categories());
final adminProductsProvider = FutureProvider<List<Product>>((ref) async =>
    (await ref.watch(authorizedAdminRepositoryProvider.future)).products());
final adminLocationsProvider = FutureProvider<List<DeliveryLocation>>(
    (ref) async => (await ref.watch(authorizedAdminRepositoryProvider.future))
        .locations());
final adminBusinessSettingsProvider = FutureProvider<BusinessSettings>(
    (ref) async => (await ref.watch(authorizedAdminRepositoryProvider.future))
        .businessSettings());
final adminAuditLogsProvider = FutureProvider<List<AuditLog>>((ref) async =>
    (await ref.watch(authorizedAdminRepositoryProvider.future)).auditLogs());
final adminReportingProvider = FutureProvider<AdminReportingSummary>(
    (ref) async => (await ref.watch(authorizedAdminRepositoryProvider.future))
        .reporting());
