import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/audit_log.dart';
import '../models/category.dart';
import '../models/order.dart';
import '../models/product.dart';

class AdminFailure implements Exception {
  const AdminFailure(this.code);
  final String code;
}

class AdminDashboard {
  const AdminDashboard({
    required this.ordersToday,
    required this.pendingOrders,
    required this.processingOrders,
    required this.deliveredOrders,
    required this.lowStockProducts,
    required this.outOfStockProducts,
    required this.recentOrders,
  });
  final int ordersToday;
  final int pendingOrders;
  final int processingOrders;
  final int deliveredOrders;
  final int lowStockProducts;
  final int outOfStockProducts;
  final List<BmOrder> recentOrders;
}

class AdminUserSummary {
  const AdminUserSummary({
    required this.id,
    required this.phoneNumber,
    required this.role,
    required this.isActive,
  });
  final String id;
  final String phoneNumber;
  final String role;
  final bool isActive;
  factory AdminUserSummary.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? <String, dynamic>{};
    return AdminUserSummary(
      id: document.id,
      phoneNumber: data['phoneNumber'] as String? ?? '',
      role: data['role'] as String? ?? 'user',
      isActive: data['isActive'] as bool? ?? true,
    );
  }
}

abstract interface class AdminRepository {
  Future<bool> isCurrentUserAdmin();
  Future<AdminDashboard> dashboard();
  Future<List<BmOrder>> orders({String? status});
  Future<List<AdminUserSummary>> users();
  Future<List<Category>> categories();
  Future<List<Product>> products();
  Future<List<AuditLog>> auditLogs();
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Future<void> updatePaymentStatus(String orderId, PaymentStatus status);
  Future<void> updateAdminNote(String orderId, String note);
  Future<void> updateInventoryStatus(
      String productId, InventoryStatus status, int? stockQuantity);
  Future<void> setProductPrice(String productId, String locationId, num price);
  Future<void> setAdminRole(String targetUid, bool enabled);
}

class FirebaseAdminRepository implements AdminRepository {
  FirebaseAdminRepository(this.db, this.functions, this.auth);
  final FirebaseFirestore db;
  final FirebaseFunctions functions;
  final FirebaseAuth auth;

  @override
  Future<bool> isCurrentUserAdmin() async {
    if (Firebase.apps.isEmpty || auth.currentUser == null) return false;
    final token = await auth.currentUser!.getIdTokenResult(true);
    return token.claims?['admin'] == true || token.claims?['role'] == 'admin';
  }

  @override
  Future<AdminDashboard> dashboard() async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final ordersToday = await db
        .collection('orders')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .count()
        .get();
    final pending = await _orderCount('pending');
    final processing = await _orderCount('processing');
    final delivered = await _orderCount('delivered');
    final low = await _productCount('lowStock');
    final out = await _productCount('outOfStock');
    final recent = await orders();
    return AdminDashboard(
      ordersToday: ordersToday.count ?? 0,
      pendingOrders: pending,
      processingOrders: processing,
      deliveredOrders: delivered,
      lowStockProducts: low,
      outOfStockProducts: out,
      recentOrders: recent.take(5).toList(),
    );
  }

  Future<int> _orderCount(String status) async =>
      (await db
              .collection('orders')
              .where('orderStatus', isEqualTo: status)
              .count()
              .get())
          .count ??
      0;

  Future<int> _productCount(String status) async =>
      (await db
              .collection('products')
              .where('stockStatus', isEqualTo: status)
              .count()
              .get())
          .count ??
      0;

  @override
  Future<List<BmOrder>> orders({String? status}) async {
    Query<Map<String, dynamic>> query =
        db.collection('orders').orderBy('createdAt', descending: true);
    if (status != null) query = query.where('orderStatus', isEqualTo: status);
    final snapshot = await query.limit(30).get();
    return snapshot.docs
        .map((doc) => BmOrder.fromJson(doc.data(), id: doc.id))
        .toList();
  }

  @override
  Future<List<AdminUserSummary>> users() async =>
      (await db.collection('users').orderBy('phoneNumber').limit(50).get())
          .docs
          .map(AdminUserSummary.fromFirestore)
          .toList();

  @override
  Future<List<Category>> categories() async =>
      (await db.collection('categories').orderBy('sortOrder').limit(50).get())
          .docs
          .map(Category.fromFirestore)
          .toList();

  @override
  Future<List<Product>> products() async =>
      (await db.collection('products').limit(50).get())
          .docs
          .map(Product.fromFirestore)
          .toList();

  @override
  Future<List<AuditLog>> auditLogs() async => (await db
          .collection('auditLogs')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get())
      .docs
      .map(AuditLog.fromFirestore)
      .toList();

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) =>
      _call('updateOrderStatus', {'orderId': orderId, 'status': status.name});

  @override
  Future<void> updatePaymentStatus(String orderId, PaymentStatus status) =>
      _call('updatePaymentStatus',
          {'orderId': orderId, 'paymentStatus': status.name});

  @override
  Future<void> updateAdminNote(String orderId, String note) =>
      _call('updateAdminNote', {'orderId': orderId, 'adminNote': note});

  @override
  Future<void> updateInventoryStatus(
          String productId, InventoryStatus status, int? stockQuantity) =>
      _call('updateInventoryStatus', {
        'productId': productId,
        'stockStatus': status.name,
        'stockQuantity': stockQuantity,
      });

  @override
  Future<void> setProductPrice(
          String productId, String locationId, num price) =>
      _call('setProductPrice',
          {'productId': productId, 'locationId': locationId, 'price': price});

  @override
  Future<void> setAdminRole(String targetUid, bool enabled) =>
      _call('setAdminRole', {'targetUid': targetUid, 'enabled': enabled});

  Future<void> _call(String name, Map<String, Object?> data) async {
    try {
      await functions.httpsCallable(name).call<void>(data);
    } on FirebaseFunctionsException catch (error) {
      throw AdminFailure(error.code);
    }
  }
}

class UnavailableAdminRepository implements AdminRepository {
  const UnavailableAdminRepository();
  @override
  Future<bool> isCurrentUserAdmin() async => false;
  @override
  Future<AdminDashboard> dashboard() =>
      throw const AdminFailure('firebaseUnavailable');
  @override
  Future<List<AuditLog>> auditLogs() async => const <AuditLog>[];
  @override
  Future<List<Category>> categories() async => const <Category>[];
  @override
  Future<List<BmOrder>> orders({String? status}) async => const <BmOrder>[];
  @override
  Future<List<Product>> products() async => const <Product>[];
  @override
  Future<List<AdminUserSummary>> users() async => const <AdminUserSummary>[];
  @override
  Future<void> setAdminRole(String targetUid, bool enabled) =>
      throw const AdminFailure('firebaseUnavailable');
  @override
  Future<void> setProductPrice(
          String productId, String locationId, num price) =>
      throw const AdminFailure('firebaseUnavailable');
  @override
  Future<void> updateAdminNote(String orderId, String note) =>
      throw const AdminFailure('firebaseUnavailable');
  @override
  Future<void> updateInventoryStatus(
          String productId, InventoryStatus status, int? stockQuantity) =>
      throw const AdminFailure('firebaseUnavailable');
  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) =>
      throw const AdminFailure('firebaseUnavailable');
  @override
  Future<void> updatePaymentStatus(String orderId, PaymentStatus status) =>
      throw const AdminFailure('firebaseUnavailable');
}
