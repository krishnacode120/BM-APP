import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/order.dart';

class OrderFailure implements Exception {
  const OrderFailure(this.code);
  final String code;
}

abstract interface class OrderRepository {
  Future<BmOrder> createOrder(CreateOrderRequest request);
  Future<List<BmOrder>> getUserOrders({int limit = 20});
  Future<BmOrder?> getOrderById(String id);
}

class FirebaseOrderRepository implements OrderRepository {
  FirebaseOrderRepository(this.db, this.functions, this.auth);
  final FirebaseFirestore db;
  final FirebaseFunctions functions;
  final FirebaseAuth auth;

  @override
  Future<BmOrder> createOrder(CreateOrderRequest request) async {
    if (Firebase.apps.isEmpty) throw const OrderFailure('firebaseUnavailable');
    try {
      final callable = functions.httpsCallable('createOrder');
      final result =
          await callable.call<Map<String, dynamic>>(request.toJson());
      final data = result.data['order'];
      if (data is! Map<String, dynamic>) throw const OrderFailure('unknown');
      return BmOrder.fromJson(data);
    } on FirebaseFunctionsException catch (error) {
      throw OrderFailure(error.code);
    }
  }

  @override
  Future<List<BmOrder>> getUserOrders({int limit = 20}) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return const <BmOrder>[];
    final snapshot = await db
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => BmOrder.fromJson(doc.data(), id: doc.id))
        .toList();
  }

  @override
  Future<BmOrder?> getOrderById(String id) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await db.collection('orders').doc(id).get();
    if (!doc.exists || doc.data()?['userId'] != uid) return null;
    return BmOrder.fromJson(doc.data()!, id: doc.id);
  }
}

class UnavailableOrderRepository implements OrderRepository {
  const UnavailableOrderRepository({this.code = 'firebaseUnavailable'});
  final String code;
  @override
  Future<BmOrder> createOrder(CreateOrderRequest request) =>
      throw OrderFailure(code);
  @override
  Future<BmOrder?> getOrderById(String id) async =>
      code == 'migrationPending' ? throw OrderFailure(code) : null;
  @override
  Future<List<BmOrder>> getUserOrders({int limit = 20}) async =>
      code == 'migrationPending' ? throw OrderFailure(code) : const <BmOrder>[];
}
