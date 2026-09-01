import 'package:bm/models/cart.dart';
import 'package:bm/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final item = CartItem(
      productId: 'p',
      productName: 'Brick',
      productNameTamil: 'செங்கல்',
      imageUrl: null,
      unit: ProductUnit.piece,
      quantity: 500,
      minimumOrderQuantity: 500,
      selectedLocationId: 'k',
      displayedUnitPrice: 8,
      inventoryStatus: InventoryStatus.available,
      addedAt: DateTime(2026));
  test('subtotal is unit price times quantity',
      () => expect(item.subtotal, 4000));
  test('minimum quantity invalidates item',
      () => expect(item.copyWith(quantity: 499).isValid, isFalse));
  test(
      'cart excludes invalid item from estimated subtotal',
      () => expect(
          CartState(items: [item, item.copyWith(quantity: 1)]).subtotal, 4000));
}
