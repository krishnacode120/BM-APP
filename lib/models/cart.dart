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
  bool get hasBlockingValidation =>
      validation == CartItemValidation.priceUnavailable ||
      validation == CartItemValidation.productUnavailable ||
      validation == CartItemValidation.minimumQuantityInvalid ||
      validation == CartItemValidation.locationChanged;
  bool get isValid =>
      !hasBlockingValidation &&
      quantity >= minimumOrderQuantity &&
      (inventoryStatus == InventoryStatus.available ||
          inventoryStatus == InventoryStatus.lowStock);
  Map<String, dynamic> toJson() => <String, dynamic>{
        'productId': productId,
        'productName': productName,
        'productNameTamil': productNameTamil,
        'imageUrl': imageUrl,
        'unit': unit.name,
        'quantity': quantity,
        'minimumOrderQuantity': minimumOrderQuantity,
        'selectedLocationId': selectedLocationId,
        'displayedUnitPrice': displayedUnitPrice,
        'inventoryStatus': inventoryStatus.name,
        'addedAt': addedAt.toIso8601String(),
        'validation': validation.name,
      };
  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        productId: json['productId'] as String? ?? '',
        productName: json['productName'] as String? ?? '',
        productNameTamil: json['productNameTamil'] as String? ?? '',
        imageUrl: json['imageUrl'] as String?,
        unit: productUnitFromValue(json['unit'] as String?),
        quantity: (json['quantity'] as num? ?? 0).toInt(),
        minimumOrderQuantity:
            (json['minimumOrderQuantity'] as num? ?? 1).toInt(),
        selectedLocationId: json['selectedLocationId'] as String? ?? '',
        displayedUnitPrice: json['displayedUnitPrice'] as num? ?? 0,
        inventoryStatus:
            inventoryStatusFromValue(json['inventoryStatus'] as String?),
        addedAt: DateTime.tryParse(json['addedAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        validation: CartItemValidation.values.firstWhere(
            (value) => value.name == json['validation'],
            orElse: () => CartItemValidation.valid),
      );
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
  bool get hasPriceChanges =>
      items.any((item) => item.validation == CartItemValidation.priceChanged);
  bool get canCheckout =>
      items.isNotEmpty &&
      items.every((i) => i.isValid) &&
      (!hasPriceChanges || priceChangeAcknowledged);
  CartState copyWith({List<CartItem>? items, bool? priceChangeAcknowledged}) =>
      CartState(
          items: items ?? this.items,
          priceChangeAcknowledged:
              priceChangeAcknowledged ?? this.priceChangeAcknowledged);
}
