import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/cart.dart';
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
  CartState build() => const CartState();
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
    state = CartState(items: items);
    return null;
  }

  void setQuantity(String id, int quantity) {
    state = state.copyWith(items: [
      for (final item in state.items)
        if (item.productId == id)
          item.copyWith(
              quantity: quantity,
              validation: quantity < item.minimumOrderQuantity
                  ? CartItemValidation.minimumQuantityInvalid
                  : CartItemValidation.valid)
        else
          item
    ], priceChangeAcknowledged: false);
  }

  void remove(String id) => state = state.copyWith(
      items: state.items.where((i) => i.productId != id).toList());
  void clear() => state = const CartState();
  void acknowledgePriceChanges() =>
      state = state.copyWith(priceChangeAcknowledged: true);
  Future<void> revalidate(String locationId) async {
    final service = ref.read(cartPricingServiceProvider);
    final items = await Future.wait(
        state.items.map((i) => service.revalidate(i, locationId)));
    state = CartState(
        items: items,
        priceChangeAcknowledged:
            items.every((i) => i.validation == CartItemValidation.valid));
  }
}
