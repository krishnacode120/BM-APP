import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/audit_log.dart';
import '../../models/category.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../repositories/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) =>
    Firebase.apps.isEmpty
        ? const UnavailableAdminRepository()
        : FirebaseAdminRepository(FirebaseFirestore.instance,
            FirebaseFunctions.instance, FirebaseAuth.instance));

final adminAccessProvider = FutureProvider<bool>(
    (ref) => ref.watch(adminRepositoryProvider).isCurrentUserAdmin());
final adminDashboardProvider = FutureProvider<AdminDashboard>(
    (ref) => ref.watch(adminRepositoryProvider).dashboard());
final adminOrdersProvider = FutureProvider.family<List<BmOrder>, String?>(
    (ref, status) => ref.watch(adminRepositoryProvider).orders(status: status));
final adminUsersProvider = FutureProvider<List<AdminUserSummary>>(
    (ref) => ref.watch(adminRepositoryProvider).users());
final adminCategoriesProvider = FutureProvider<List<Category>>(
    (ref) => ref.watch(adminRepositoryProvider).categories());
final adminProductsProvider = FutureProvider<List<Product>>(
    (ref) => ref.watch(adminRepositoryProvider).products());
final adminAuditLogsProvider = FutureProvider<List<AuditLog>>(
    (ref) => ref.watch(adminRepositoryProvider).auditLogs());
