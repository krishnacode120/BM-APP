import 'product.dart';

enum CartItemValidation {
  valid,
  priceChanged,
  priceUnavailable,
  productUnavailable,
  minimumQuantityInvalid,
  locationChanged
}

class CartItem {
  const CartItem(
      {required this.productId,
      required this.productName,
      required this.productNameTamil,
      required this.imageUrl,
      required this.unit,
      required this.quantity,
      required this.minimumOrderQuantity,
      required this.selectedLocationId,
      required this.displayedUnitPrice,
      required this.inventoryStatus,
      required this.addedAt,
      this.validation = CartItemValidation.valid});
  final String productId;
  final String productName;
  final String productNameTamil;
  final String? imageUrl;
  final ProductUnit unit;
  final int quantity;
  final int minimumOrderQuantity;
  final String selectedLocationId;
  final num displayedUnitPrice;
  final InventoryStatus inventoryStatus;
  final DateTime addedAt;
  final CartItemValidation validation;
  num get subtotal => displayedUnitPrice * quantity;
  bool get isValid =>
      validation == CartItemValidation.valid &&
      quantity >= minimumOrderQuantity &&
      (inventoryStatus == InventoryStatus.available ||
          inventoryStatus == InventoryStatus.lowStock);
  CartItem copyWith(
          {int? quantity,
          num? displayedUnitPrice,
          InventoryStatus? inventoryStatus,
          CartItemValidation? validation,
          String? selectedLocationId}) =>
      CartItem(
          productId: productId,
          productName: productName,
          productNameTamil: productNameTamil,
          imageUrl: imageUrl,
          unit: unit,
          quantity: quantity ?? this.quantity,
          minimumOrderQuantity: minimumOrderQuantity,
          selectedLocationId: selectedLocationId ?? this.selectedLocationId,
          displayedUnitPrice: displayedUnitPrice ?? this.displayedUnitPrice,
          inventoryStatus: inventoryStatus ?? this.inventoryStatus,
          addedAt: addedAt,
          validation: validation ?? this.validation);
}

class CartState {
  const CartState(
      {this.items = const <CartItem>[], this.priceChangeAcknowledged = false});
  final List<CartItem> items;
  final bool priceChangeAcknowledged;
  int get itemCount => items.length;
  num get subtotal => items
      .where((i) => i.isValid)
      .fold<num>(0, (sum, item) => sum + item.subtotal);
  bool get canCheckout =>
      items.isNotEmpty &&
      items.every((i) => i.isValid) &&
      priceChangeAcknowledged;
  CartState copyWith({List<CartItem>? items, bool? priceChangeAcknowledged}) =>
      CartState(
          items: items ?? this.items,
          priceChangeAcknowledged:
              priceChangeAcknowledged ?? this.priceChangeAcknowledged);
}
