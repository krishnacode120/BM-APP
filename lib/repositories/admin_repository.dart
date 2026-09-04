import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/audit_log.dart';
import '../models/business_settings.dart';
import '../models/category.dart';
import '../models/location.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/report_sync.dart';

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
    this.totalCustomers = 0,
    this.totalProducts = 0,
    this.totalOrders = 0,
    this.verifiedOrders = 0,
    this.paidOrders = 0,
    this.unpaidOrders = 0,
    this.activeProducts = 0,
    this.todayRevenue = 0,
    this.recognizedRevenue = 0,
    required this.lowStockProducts,
    required this.outOfStockProducts,
    required this.recentOrders,
  });
  final int ordersToday;
  final int pendingOrders;
  final int processingOrders;
  final int deliveredOrders;
  final int totalCustomers;
  final int totalProducts;
  final int totalOrders;
  final int verifiedOrders;
  final int paidOrders;
  final int unpaidOrders;
  final int activeProducts;
  final num todayRevenue;
  final num recognizedRevenue;
  final int lowStockProducts;
  final int outOfStockProducts;
  final List<BmOrder> recentOrders;
}

class AdminUserSummary {
  const AdminUserSummary({
    required this.id,
    this.name = '',
    required this.phoneNumber,
    required this.role,
    required this.isActive,
    this.phoneVerified = false,
    this.createdAt,
  });
  final String id;
  final String name;
  final String phoneNumber;
  final String role;
  final bool isActive;
  final bool phoneVerified;
  final DateTime? createdAt;
  factory AdminUserSummary.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? <String, dynamic>{};
    return AdminUserSummary(
      id: document.id,
      name: data['name'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      role: data['role'] as String? ?? 'user',
      isActive: data['isActive'] as bool? ?? true,
      phoneVerified: data['phoneVerified'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

class AdminReportingSummary {
  const AdminReportingSummary({
    required this.totalOrders,
    required this.synced,
    required this.pending,
    required this.failed,
    required this.recentJobs,
    this.recognizedRevenue = 0,
    this.completedOrders = 0,
    this.cancelledOrders = 0,
    this.pendingOrders = 0,
    this.paidTotal = 0,
    this.unpaidTotal = 0,
    this.todayRevenue = 0,
    this.monthlyRevenue = 0,
    this.topMaterials = const <AdminMaterialTotal>[],
    this.revenueByDay = const <AdminRevenuePoint>[],
    this.sourceOrders = const <BmOrder>[],
  });
  final int totalOrders;
  final int synced;
  final int pending;
  final int failed;
  final List<ReportSyncJob> recentJobs;
  final num recognizedRevenue;
  final int completedOrders;
  final int cancelledOrders;
  final int pendingOrders;
  final num paidTotal;
  final num unpaidTotal;
  final num todayRevenue;
  final num monthlyRevenue;
  final List<AdminMaterialTotal> topMaterials;
  final List<AdminRevenuePoint> revenueByDay;
  final List<BmOrder> sourceOrders;

  AdminReportingSummary forRange(DateTime from, DateTime through) =>
      _buildReportingSummary(
        orders: sourceOrders
            .where((order) =>
                !order.createdAt.isBefore(from) &&
                order.createdAt.isBefore(through.add(const Duration(days: 1))))
            .toList(),
        synced: synced,
        pending: pending,
        failed: failed,
        recentJobs: recentJobs,
        from: from,
        through: through,
      );
}

class AdminMaterialTotal {
  const AdminMaterialTotal(this.name, this.quantity,
      {this.orderCount = 0, this.revenue = 0});
  final String name;
  final num quantity;
  final int orderCount;
  final num revenue;
}

class AdminRevenuePoint {
  const AdminRevenuePoint(this.date, this.amount);
  final DateTime date;
  final num amount;
}

AdminReportingSummary _buildReportingSummary({
  required List<BmOrder> orders,
  required int synced,
  required int pending,
  required int failed,
  required List<ReportSyncJob> recentJobs,
  required DateTime from,
  required DateTime through,
  int? totalOrdersOverride,
}) {
  final valid = orders
      .where((order) => order.orderStatus != OrderStatus.cancelled)
      .toList();
  final recognizedRevenue =
      orders.fold<num>(0, (total, order) => total + order.recognizedRevenue);
  final unpaidTotal = valid
      .where((order) => order.paymentStatus != PaymentStatus.paid)
      .fold<num>(0, (total, order) => total + order.displayTotal);
  final today = DateTime.now();
  final monthStart = DateTime(today.year, today.month);
  final todayStart = DateTime(today.year, today.month, today.day);
  final todayRevenue = orders
      .where((order) => !order.createdAt.isBefore(todayStart))
      .fold<num>(0, (total, order) => total + order.recognizedRevenue);
  final monthlyRevenue = orders
      .where((order) => !order.createdAt.isBefore(monthStart))
      .fold<num>(0, (total, order) => total + order.recognizedRevenue);
  final quantities = <String, num>{};
  final orderCounts = <String, int>{};
  final revenues = <String, num>{};
  for (final order in valid) {
    final seen = <String>{};
    for (final item in order.items) {
      quantities.update(item.productName, (value) => value + item.quantity,
          ifAbsent: () => item.quantity);
      if (seen.add(item.productName)) {
        orderCounts.update(item.productName, (value) => value + 1,
            ifAbsent: () => 1);
      }
      if (order.paymentStatus == PaymentStatus.paid) {
        revenues.update(item.productName, (value) => value + item.subtotal,
            ifAbsent: () => item.subtotal);
      }
    }
  }
  final topMaterials = quantities.entries
      .map((entry) => AdminMaterialTotal(
            entry.key,
            entry.value,
            orderCount: orderCounts[entry.key] ?? 0,
            revenue: revenues[entry.key] ?? 0,
          ))
      .toList()
    ..sort((a, b) => b.quantity.compareTo(a.quantity));
  final normalizedFrom = DateTime(from.year, from.month, from.day);
  final normalizedThrough = DateTime(through.year, through.month, through.day);
  final days =
      normalizedThrough.difference(normalizedFrom).inDays.clamp(0, 365);
  final revenueByDay = List<AdminRevenuePoint>.generate(days + 1, (index) {
    final day = normalizedFrom.add(Duration(days: index));
    final amount = orders
        .where((order) =>
            order.createdAt.year == day.year &&
            order.createdAt.month == day.month &&
            order.createdAt.day == day.day)
        .fold<num>(0, (total, order) => total + order.recognizedRevenue);
    return AdminRevenuePoint(day, amount);
  });
  return AdminReportingSummary(
    totalOrders: totalOrdersOverride ?? orders.length,
    synced: synced,
    pending: pending,
    failed: failed,
    recentJobs: recentJobs,
    recognizedRevenue: recognizedRevenue,
    completedOrders: orders
        .where((order) => order.orderStatus == OrderStatus.completed)
        .length,
    cancelledOrders: orders
        .where((order) => order.orderStatus == OrderStatus.cancelled)
        .length,
    pendingOrders: orders
        .where((order) => order.orderStatus == OrderStatus.pending)
        .length,
    paidTotal: recognizedRevenue,
    unpaidTotal: unpaidTotal,
    todayRevenue: todayRevenue,
    monthlyRevenue: monthlyRevenue,
    topMaterials: topMaterials.take(5).toList(),
    revenueByDay: revenueByDay,
    sourceOrders: orders,
  );
}

abstract interface class AdminRepository {
  Future<bool> isCurrentUserAdmin();
  Future<AdminDashboard> dashboard();
  Future<List<BmOrder>> orders({String? status});
  Future<BmOrder?> orderById(String orderId);
  Future<List<AdminUserSummary>> users();
  Future<List<BmOrder>> ordersForUser(String userId);
  Future<List<Category>> categories();
  Future<List<Product>> products();
  Future<List<DeliveryLocation>> locations();
  Future<Map<String, num>> currentPrices(String productId);
  Future<List<AuditLog>> auditLogs();
  Future<AdminReportingSummary> reporting();
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Future<void> updatePaymentStatus(String orderId, PaymentStatus status);
  Future<void> updateAdminNote(String orderId, String note);
  Future<void> updateOrderFinancials(
      String orderId, num confirmedSubtotal, num deliveryCharge);
  Future<void> updateInventoryStatus(
      String productId, InventoryStatus status, int? stockQuantity);
  Future<void> setProductPrice(String productId, String locationId, num price);
  Future<void> setAdminRole(String targetUid, bool enabled);
  Future<String> upsertProduct(Map<String, Object?> product);
  Future<String> upsertCategory(Map<String, Object?> category);
  Future<BusinessSettings> businessSettings();
  Future<void> updateBusinessSettings(BusinessSettings settings);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> signOut();
  Future<void> retryReportSync(String orderId);
  Future<String> exportOrdersCsv({String? orderStatus});
  Future<String> exportReportCsv(String reportType);
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
    final hasClaim =
        token.claims?['admin'] == true || token.claims?['role'] == 'admin';
    if (!hasClaim) return false;
    final profile =
        await db.collection('users').doc(auth.currentUser!.uid).get();
    return profile.exists &&
        profile.data()?['role'] == 'admin' &&
        profile.data()?['isActive'] != false;
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
    final delivered = await _orderCount('completed');
    final low = await _productCount('lowStock');
    final out = await _productCount('outOfStock');
    final customerCount = await db
        .collection('users')
        .where('role', isEqualTo: 'customer')
        .count()
        .get();
    final productCount = await db.collection('products').count().get();
    final orderCount = await db.collection('orders').count().get();
    final verified = await _orderCount('verified');
    final paidCount = await db
        .collection('orders')
        .where('paymentStatus', isEqualTo: 'paid')
        .count()
        .get();
    final unpaidCount = await db
        .collection('orders')
        .where('paymentStatus', whereIn: <String>['unpaid', 'partial'])
        .count()
        .get();
    final activeProductCount = await db
        .collection('products')
        .where('isActive', isEqualTo: true)
        .where('stockStatus', whereIn: <String>['available', 'lowStock'])
        .count()
        .get();
    final paidOrders = await db
        .collection('orders')
        .where('paymentStatus', isEqualTo: 'paid')
        .limit(500)
        .get();
    final revenue = paidOrders.docs
        .map((document) => BmOrder.fromJson(document.data(), id: document.id))
        .fold<num>(0, (total, order) => total + order.recognizedRevenue);
    final todayRevenue = paidOrders.docs
        .map((document) => BmOrder.fromJson(document.data(), id: document.id))
        .where((order) => !order.createdAt.isBefore(start))
        .fold<num>(0, (total, order) => total + order.recognizedRevenue);
    final recent = await orders();
    return AdminDashboard(
      ordersToday: ordersToday.count ?? 0,
      pendingOrders: pending,
      processingOrders: processing,
      deliveredOrders: delivered,
      totalCustomers: customerCount.count ?? 0,
      totalProducts: productCount.count ?? 0,
      totalOrders: orderCount.count ?? 0,
      verifiedOrders: verified,
      paidOrders: paidCount.count ?? 0,
      unpaidOrders: unpaidCount.count ?? 0,
      activeProducts: activeProductCount.count ?? 0,
      todayRevenue: todayRevenue,
      recognizedRevenue: revenue,
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
  Future<BmOrder?> orderById(String orderId) async {
    final document = await db.collection('orders').doc(orderId).get();
    if (!document.exists) return null;
    return BmOrder.fromJson(document.data()!, id: document.id);
  }

  @override
  Future<List<AdminUserSummary>> users() async =>
      (await db.collection('users').orderBy('phoneNumber').limit(50).get())
          .docs
          .map(AdminUserSummary.fromFirestore)
          .where((user) => user.role == 'customer')
          .toList();

  @override
  Future<List<BmOrder>> ordersForUser(String userId) async => (await db
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get())
      .docs
      .map((document) => BmOrder.fromJson(document.data(), id: document.id))
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
  Future<List<DeliveryLocation>> locations() async =>
      (await db.collection('locations').where('active', isEqualTo: true).get())
          .docs
          .map(DeliveryLocation.fromFirestore)
          .toList();

  @override
  Future<Map<String, num>> currentPrices(String productId) async {
    final snapshot = await db
        .collection('productPrices')
        .where('productId', isEqualTo: productId)
        .where('effectiveTo', isNull: true)
        .get();
    return <String, num>{
      for (final document in snapshot.docs)
        if (document.data()['locationId'] is String &&
            document.data()['price'] is num)
          document.data()['locationId'] as String:
              document.data()['price'] as num,
    };
  }

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
  Future<AdminReportingSummary> reporting() async {
    final results = await Future.wait([
      db.collection('orders').count().get(),
      _reportCount('COMPLETED'),
      _reportCount('PENDING'),
      _reportCount('PROCESSING'),
      _reportCount('RETRYING'),
      _reportCount('FAILED'),
      _reportCount('DEAD_LETTER'),
      db
          .collection('reportSyncJobs')
          .orderBy('updatedAt', descending: true)
          .limit(50)
          .get(),
      db
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .limit(500)
          .get(),
    ]);
    final jobs = results[7] as QuerySnapshot<Map<String, dynamic>>;
    final orderDocuments = results[8] as QuerySnapshot<Map<String, dynamic>>;
    final orders = orderDocuments.docs
        .map((document) => BmOrder.fromJson(document.data(), id: document.id))
        .toList();
    final today = DateTime.now();
    return _buildReportingSummary(
      orders: orders,
      synced: (results[1] as AggregateQuerySnapshot).count ?? 0,
      pending: ((results[2] as AggregateQuerySnapshot).count ?? 0) +
          ((results[3] as AggregateQuerySnapshot).count ?? 0) +
          ((results[4] as AggregateQuerySnapshot).count ?? 0),
      failed: ((results[5] as AggregateQuerySnapshot).count ?? 0) +
          ((results[6] as AggregateQuerySnapshot).count ?? 0),
      recentJobs: jobs.docs.map(ReportSyncJob.fromFirestore).toList(),
      from: DateTime(today.year, today.month, today.day)
          .subtract(const Duration(days: 29)),
      through: DateTime(today.year, today.month, today.day),
      totalOrdersOverride: (results[0] as AggregateQuerySnapshot).count ?? 0,
    );
  }

  Future<AggregateQuerySnapshot> _reportCount(String status) => db
      .collection('reportSyncJobs')
      .where('status', isEqualTo: status)
      .count()
      .get();

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
  Future<void> updateOrderFinancials(
          String orderId, num confirmedSubtotal, num deliveryCharge) =>
      _call('updateOrderFinancials', {
        'orderId': orderId,
        'confirmedSubtotal': confirmedSubtotal,
        'deliveryCharge': deliveryCharge,
      });

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

  @override
  Future<String> upsertProduct(Map<String, Object?> product) async {
    final data = await _callResult('upsertProduct', product);
    return data['id'] as String? ?? '';
  }

  @override
  Future<String> upsertCategory(Map<String, Object?> category) async {
    final data = await _callResult('upsertCategory', category);
    return data['id'] as String? ?? '';
  }

  @override
  Future<BusinessSettings> businessSettings() async {
    final document = await db.collection('settings').doc('app').get();
    return document.exists
        ? BusinessSettings.fromFirestore(document)
        : BusinessSettings.developmentFallback;
  }

  @override
  Future<void> updateBusinessSettings(BusinessSettings settings) =>
      _call('updateBusinessSettings', settings.toJson());

  @override
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    final user = auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw const AdminFailure('unauthenticated');
    }
    try {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: currentPassword),
      );
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (error) {
      throw AdminFailure(error.code);
    }
  }

  @override
  Future<void> signOut() => auth.signOut();

  @override
  Future<void> retryReportSync(String orderId) =>
      _call('retryReportSync', {'orderId': orderId});

  @override
  Future<String> exportOrdersCsv({String? orderStatus}) async {
    return exportReportCsv('orders', orderStatus: orderStatus);
  }

  @override
  Future<String> exportReportCsv(String reportType,
      {String? orderStatus}) async {
    try {
      final result = await functions
          .httpsCallable('exportOrdersCsv')
          .call<Map<String, dynamic>>({
        'reportType': reportType,
        'orderStatus': orderStatus,
      });
      return result.data['csv'] as String? ?? '';
    } on FirebaseFunctionsException catch (error) {
      throw AdminFailure(error.code);
    }
  }

  Future<void> _call(String name, Map<String, Object?> data) async {
    try {
      await functions.httpsCallable(name).call<void>(data);
    } on FirebaseFunctionsException catch (error) {
      throw AdminFailure(error.code);
    }
  }

  Future<Map<String, dynamic>> _callResult(
      String name, Map<String, Object?> data) async {
    try {
      final result =
          await functions.httpsCallable(name).call<Map<String, dynamic>>(data);
      return result.data;
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
  Future<AdminReportingSummary> reporting() =>
      throw const AdminFailure('firebaseUnavailable');
  @override
  Future<List<Category>> categories() async => const <Category>[];
  @override
  Future<List<BmOrder>> orders({String? status}) async => const <BmOrder>[];
  @override
  Future<BmOrder?> orderById(String orderId) async => null;
  @override
  Future<List<Product>> products() async => const <Product>[];
  @override
  Future<List<AdminUserSummary>> users() async => const <AdminUserSummary>[];
  @override
  Future<List<BmOrder>> ordersForUser(String userId) async => const <BmOrder>[];
  @override
  Future<List<DeliveryLocation>> locations() async =>
      const <DeliveryLocation>[];
  @override
  Future<Map<String, num>> currentPrices(String productId) async =>
      const <String, num>{};
  @override
  Future<void> setAdminRole(String targetUid, bool enabled) =>
      throw const AdminFailure('firebaseUnavailable');
  @override
  Future<String> upsertProduct(Map<String, Object?> product) =>
      throw const AdminFailure('firebaseUnavailable');
  @override
  Future<String> upsertCategory(Map<String, Object?> category) =>
      throw const AdminFailure('firebaseUnavailable');
  @override
  Future<BusinessSettings> businessSettings() =>
      throw const AdminFailure('firebaseUnavailable');
  @override
  Future<void> updateBusinessSettings(BusinessSettings settings) =>
      throw const AdminFailure('firebaseUnavailable');
  @override
  Future<void> changePassword(String currentPassword, String newPassword) =>
      throw const AdminFailure('firebaseUnavailable');
  @override
  Future<void> signOut() async {}
  @override
  Future<void> retryReportSync(String orderId) =>
      throw const AdminFailure('firebaseUnavailable');
  @override
  Future<String> exportOrdersCsv({String? orderStatus}) =>
      throw const AdminFailure('firebaseUnavailable');
  @override
  Future<String> exportReportCsv(String reportType, {String? orderStatus}) =>
      throw const AdminFailure('firebaseUnavailable');
  @override
  Future<void> setProductPrice(
          String productId, String locationId, num price) =>
      throw const AdminFailure('firebaseUnavailable');
  @override
  Future<void> updateAdminNote(String orderId, String note) =>
      throw const AdminFailure('firebaseUnavailable');
  @override
  Future<void> updateOrderFinancials(
          String orderId, num confirmedSubtotal, num deliveryCharge) =>
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
