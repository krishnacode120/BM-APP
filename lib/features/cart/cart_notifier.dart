import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/cart.dart';
import '../../models/location.dart';
import '../../models/product.dart';
import '../../services/cart_pricing_service.dart';
import '../catalog/catalog_providers.dart';

final cartPricingServiceProvider = Provider<CartPricingService>((ref) =>
    CartPricingService(ref.watch(productRepositoryProvider),
        ref.watch(pricingRepositoryProvider)));
final cartProvider =
    NotifierProvider<CartNotifier, CartState>(CartNotifier.new);

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    ref.listen<AsyncValue<DeliveryLocation?>>(selectedLocationProvider,
        (previous, next) {
      final previousId = previous?.valueOrNull?.id;
      final nextId = next.valueOrNull?.id;
      if (previousId != null &&
          nextId != null &&
          previousId != nextId &&
          state.items.isNotEmpty) {
        unawaited(revalidate(nextId));
      }
    });
    unawaited(_load());
    return const CartState();
  }

  String? add(Product product,
      {required int quantity, required String locationId, required num price}) {
    if (!product.canOrder) return 'Product unavailable';
    if (quantity < product.minimumOrderQuantity) return 'Minimum order not met';
    final item = CartItem(
        productId: product.id,
        productName: product.name,
        productNameTamil: product.nameTamil,
        imageUrl: product.thumbnail,
        unit: product.unit,
        quantity: quantity,
        minimumOrderQuantity: product.minimumOrderQuantity,
        selectedLocationId: locationId,
        displayedUnitPrice: price,
        inventoryStatus: product.inventoryStatus,
        addedAt: DateTime.now());
    final index = state.items.indexWhere(
        (i) => i.productId == product.id && i.selectedLocationId == locationId);
    final items = [...state.items];
    if (index >= 0) {
      items[index] =
          items[index].copyWith(quantity: items[index].quantity + quantity);
    } else {
      items.add(item);
    }
    _setState(CartState(items: items));
    return null;
  }

  void setQuantity(String id, int quantity) {
    if (quantity < 1) return;
    _setState(state.copyWith(items: [
      for (final item in state.items)
        if (item.productId == id)
          item.copyWith(
              quantity: quantity,
              validation: quantity < item.minimumOrderQuantity
                  ? CartItemValidation.minimumQuantityInvalid
                  : CartItemValidation.valid)
        else
          item
    ], priceChangeAcknowledged: false));
  }

  void remove(String id) => _setState(state.copyWith(
      items: state.items.where((i) => i.productId != id).toList(),
      priceChangeAcknowledged: state.items.length <= 1));
  void clear() => _setState(const CartState());
  void acknowledgePriceChanges() =>
      _setState(state.copyWith(priceChangeAcknowledged: true));
  Future<void> revalidate(String locationId) async {
    final service = ref.read(cartPricingServiceProvider);
    final items = await Future.wait(
        state.items.map((i) => service.revalidate(i, locationId)));
    _setState(CartState(
        items: items,
        priceChangeAcknowledged:
            items.every((i) => i.validation == CartItemValidation.valid)));
  }

  void _setState(CartState value) {
    state = value;
    unawaited(_save(value));
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_storageKey());
    if (encoded == null) return;
    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic>) return;
    state = CartState(
        items: decoded
            .whereType<Map<String, dynamic>>()
            .map(CartItem.fromJson)
            .toList());
  }

  Future<void> _save(CartState value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey(),
        jsonEncode(value.items.map((item) => item.toJson()).toList()));
  }

  String _storageKey() {
    if (Firebase.apps.isEmpty) return 'cart_guest';
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return 'cart_${userId ?? 'guest'}';
  }
}
