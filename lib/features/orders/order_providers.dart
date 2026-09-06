import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/cart.dart';
import '../../models/order.dart';
import '../../repositories/order_repository.dart';
import '../cart/cart_notifier.dart';
import '../catalog/catalog_providers.dart';
import '../auth/auth_providers.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) =>
    Firebase.apps.isEmpty
        ? const UnavailableOrderRepository()
        : FirebaseOrderRepository(FirebaseFirestore.instance,
            FirebaseFunctions.instance, FirebaseAuth.instance));

final ordersProvider = FutureProvider<List<BmOrder>>((ref) async {
  final repository = ref.watch(orderRepositoryProvider);
  if (await ref.watch(firebaseAuthStateProvider.future) == null) return [];
  return repository.getUserOrders();
});

final orderProvider = FutureProvider.family<BmOrder?, String>((ref, id) async {
  final repository = ref.watch(orderRepositoryProvider);
  if (await ref.watch(firebaseAuthStateProvider.future) == null) return null;
  return repository.getOrderById(id);
});

final checkoutProvider =
    NotifierProvider<CheckoutNotifier, CheckoutState>(CheckoutNotifier.new);

class CheckoutState {
  const CheckoutState({
    this.customerName = '',
    this.phoneNumber = '',
    this.deliveryAddress = '',
    this.customerNote = '',
    this.idempotencyKey,
    this.isSubmitting = false,
    this.errorCode,
  });
  final String customerName;
  final String phoneNumber;
  final String deliveryAddress;
  final String customerNote;
  final String? idempotencyKey;
  final bool isSubmitting;
  final String? errorCode;
  bool get detailsValid =>
      customerName.trim().isNotEmpty &&
      phoneNumber.trim().length >= 8 &&
      customerNote.length <= 500;
  CheckoutState copyWith({
    String? customerName,
    String? phoneNumber,
    String? deliveryAddress,
    String? customerNote,
    String? idempotencyKey,
    bool? isSubmitting,
    String? errorCode,
    bool clearError = false,
  }) =>
      CheckoutState(
        customerName: customerName ?? this.customerName,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        deliveryAddress: deliveryAddress ?? this.deliveryAddress,
        customerNote: customerNote ?? this.customerNote,
        idempotencyKey: idempotencyKey ?? this.idempotencyKey,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        errorCode: clearError ? null : errorCode ?? this.errorCode,
      );
}

class CheckoutNotifier extends Notifier<CheckoutState> {
  int _session = 0;
  @override
  CheckoutState build() {
    ref.watch(
        firebaseAuthStateProvider.select((value) => value.valueOrNull?.uid));
    _session++;
    ref.onDispose(() => _session++);
    return const CheckoutState();
  }

  void updateCustomerName(String value) =>
      state = state.copyWith(customerName: value, clearError: true);
  void updatePhoneNumber(String value) =>
      state = state.copyWith(phoneNumber: value, clearError: true);
  void updateDeliveryAddress(String value) =>
      state = state.copyWith(deliveryAddress: value, clearError: true);
  void updateCustomerNote(String value) =>
      state = state.copyWith(customerNote: value, clearError: true);

  Future<BmOrder?> submit(CartState cart) async {
    final session = _session;
    if (state.isSubmitting) return null;
    final location = ref.read(selectedLocationProvider).valueOrNull;
    if (location == null) {
      state = state.copyWith(errorCode: 'missingLocation');
      return null;
    }
    if (!state.detailsValid) {
      state = state.copyWith(errorCode: 'invalidCustomerDetails');
      return null;
    }
    if (!cart.canCheckout) {
      state = state.copyWith(errorCode: 'invalidCart');
      return null;
    }
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await ref.read(cartProvider.notifier).revalidate(location.id);
    } catch (_) {
      if (session == _session) {
        state = state.copyWith(isSubmitting: false, errorCode: 'invalidCart');
      }
      return null;
    }
    if (session != _session) return null;
    final latestCart = ref.read(cartProvider);
    if (!latestCart.canCheckout) {
      state = state.copyWith(isSubmitting: false, errorCode: 'invalidCart');
      return null;
    }
    final key = state.idempotencyKey ?? _newIdempotencyKey();
    state = state.copyWith(
        idempotencyKey: key, isSubmitting: true, errorCode: null);
    final request = CreateOrderRequest(
      idempotencyKey: key,
      locationId: location.id,
      customerName: state.customerName.trim(),
      phoneNumber: state.phoneNumber.trim(),
      deliveryAddress: state.deliveryAddress.trim(),
      customerNote:
          state.customerNote.trim().isEmpty ? null : state.customerNote.trim(),
      items: latestCart.items
          .map((item) => CreateOrderRequestItem(
              productId: item.productId, quantity: item.quantity))
          .toList(),
    );
    try {
      final order =
          await ref.read(orderRepositoryProvider).createOrder(request);
      if (session != _session) return null;
      ref.read(cartProvider.notifier).clear();
      ref.invalidate(ordersProvider);
      state = const CheckoutState();
      return order;
    } on OrderFailure catch (error) {
      if (session != _session) return null;
      state = state.copyWith(isSubmitting: false, errorCode: error.code);
      return null;
    } catch (_) {
      if (session == _session) {
        state = state.copyWith(isSubmitting: false, errorCode: 'unknown');
      }
      return null;
    }
  }
}

String _newIdempotencyKey() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}
