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

final adminRepositoryProvider = Provider<AdminRepository>((ref) =>
    Firebase.apps.isEmpty
        ? const UnavailableAdminRepository()
        : FirebaseAdminRepository(FirebaseFirestore.instance,
            FirebaseFunctions.instance, FirebaseAuth.instance));

final productMediaRepositoryProvider = Provider<ProductMediaRepository>((ref) =>
    Firebase.apps.isEmpty
        ? const UnavailableProductMediaRepository()
        : FirebaseProductMediaRepository(FirebaseStorage.instance));

final adminAccessProvider = FutureProvider<bool>(
    (ref) => ref.watch(adminRepositoryProvider).isCurrentUserAdmin());
final adminDashboardProvider = FutureProvider<AdminDashboard>(
    (ref) => ref.watch(adminRepositoryProvider).dashboard());
final adminOrdersProvider = FutureProvider.family<List<BmOrder>, String?>(
    (ref, status) => ref.watch(adminRepositoryProvider).orders(status: status));
final adminOrderProvider = FutureProvider.family<BmOrder?, String>(
    (ref, id) => ref.watch(adminRepositoryProvider).orderById(id));
final adminUsersProvider = FutureProvider<List<AdminUserSummary>>(
    (ref) => ref.watch(adminRepositoryProvider).users());
final adminUserOrdersProvider = FutureProvider.family<List<BmOrder>, String>(
    (ref, id) => ref.watch(adminRepositoryProvider).ordersForUser(id));
final adminCategoriesProvider = FutureProvider<List<Category>>(
    (ref) => ref.watch(adminRepositoryProvider).categories());
final adminProductsProvider = FutureProvider<List<Product>>(
    (ref) => ref.watch(adminRepositoryProvider).products());
final adminLocationsProvider = FutureProvider<List<DeliveryLocation>>(
    (ref) => ref.watch(adminRepositoryProvider).locations());
final adminBusinessSettingsProvider = FutureProvider<BusinessSettings>(
    (ref) => ref.watch(adminRepositoryProvider).businessSettings());
final adminAuditLogsProvider = FutureProvider<List<AuditLog>>(
    (ref) => ref.watch(adminRepositoryProvider).auditLogs());
final adminReportingProvider = FutureProvider<AdminReportingSummary>(
    (ref) => ref.watch(adminRepositoryProvider).reporting());
