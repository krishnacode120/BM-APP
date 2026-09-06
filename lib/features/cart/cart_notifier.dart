import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/cart.dart';
import '../../models/location.dart';
import '../../models/product.dart';
import '../../services/cart_pricing_service.dart';
import '../catalog/catalog_providers.dart';
import '../auth/auth_providers.dart';

final cartPricingServiceProvider = Provider<CartPricingService>((ref) =>
    CartPricingService(ref.watch(productRepositoryProvider),
        ref.watch(pricingRepositoryProvider)));
final cartProvider =
    NotifierProvider<CartNotifier, CartState>(CartNotifier.new);

class CartNotifier extends Notifier<CartState> {
  int _revision = 0;
  String _key = 'cart_guest';
  @override
  CartState build() {
    final uid = ref.watch(firebaseAuthStateProvider).valueOrNull?.uid;
    _key = 'cart_${uid ?? 'guest'}';
    final revision = ++_revision;
    ref.onDispose(() => _revision++);
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
    unawaited(_load(_key, revision));
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
    final revision = ++_revision;
    final service = ref.read(cartPricingServiceProvider);
    final items = await Future.wait(
        state.items.map((i) => service.revalidate(i, locationId)));
    if (revision != _revision) return;
    _setState(CartState(
        items: items,
        priceChangeAcknowledged:
            items.every((i) => i.validation == CartItemValidation.valid)));
  }

  void _setState(CartState value) {
    _revision++;
    state = value;
    unawaited(_save(value, _key));
  }

  Future<void> _load(String key, int revision) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (revision != _revision) return;
      final encoded = prefs.getString(key);
      if (encoded == null) return;
      final decoded = jsonDecode(encoded);
      if (decoded is! List<dynamic>) return;
      state = CartState(
          items: decoded
              .whereType<Map<String, dynamic>>()
              .map(CartItem.fromJson)
              .toList());
    } on FormatException {
      // Corrupt local cache must not crash login or replace another account.
    } on TypeError {
      // Older or malformed local records can be discarded safely.
    }
  }

  Future<void> _save(CartState value, String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        key, jsonEncode(value.items.map((item) => item.toJson()).toList()));
  }
}
