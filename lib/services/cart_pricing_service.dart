import '../models/cart.dart';
import '../repositories/catalog_repositories.dart';

class CartPricingService {
  CartPricingService(this.products, this.prices);
  final ProductRepository products;
  final PricingRepository prices;
  Future<CartItem> revalidate(CartItem item, String locationId) async {
    final product = await products.byId(item.productId);
    if (product == null || !product.isActive) {
      return item.copyWith(validation: CartItemValidation.productUnavailable);
    }
    if (!product.canOrder) {
      return item.copyWith(
          inventoryStatus: product.inventoryStatus,
          validation: CartItemValidation.productUnavailable);
    }
    if (item.quantity < product.minimumOrderQuantity) {
      return item.copyWith(
          validation: CartItemValidation.minimumQuantityInvalid);
    }
    final price = await prices.currentPrice(item.productId, locationId);
    if (price == null) {
      return item.copyWith(
          validation: CartItemValidation.priceUnavailable,
          selectedLocationId: locationId);
    }
    final changed = item.displayedUnitPrice != price.price ||
        item.selectedLocationId != locationId;
    return item.copyWith(
        displayedUnitPrice: price.price,
        selectedLocationId: locationId,
        inventoryStatus: product.inventoryStatus,
        validation: changed
            ? CartItemValidation.priceChanged
            : CartItemValidation.valid);
  }
}
