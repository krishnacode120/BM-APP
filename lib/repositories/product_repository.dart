import '../models/product.dart';

abstract interface class ProductRepository {
  Future<List<Product>> popularProducts();
}

/// Development-only data for the foundation UI. Firestore replaces this in Milestone 2.
class SampleProductRepository implements ProductRepository {
  @override
  Future<List<Product>> popularProducts() async => const <Product>[
        Product(
            id: 'red-clay-brick',
            name: 'Red Clay Brick',
            tamilName: 'செங்கல்',
            category: 'Bricks',
            unit: 'Piece',
            minimumOrder: 500,
            inventoryStatus: InventoryStatus.available,
            price: 8),
        Product(
            id: 'opc-cement',
            name: 'OPC Cement',
            tamilName: 'சிமெண்டு',
            category: 'Cement',
            unit: 'Bag',
            minimumOrder: 10,
            inventoryStatus: InventoryStatus.available,
            price: 430),
      ];
}
