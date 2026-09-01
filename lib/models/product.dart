enum InventoryStatus { available, lowStock, outOfStock, comingSoon, hidden }

class Product {
  const Product(
      {required this.id,
      required this.name,
      required this.tamilName,
      required this.category,
      required this.unit,
      required this.minimumOrder,
      required this.inventoryStatus,
      required this.price});
  final String id;
  final String name;
  final String tamilName;
  final String category;
  final String unit;
  final int minimumOrder;
  final InventoryStatus inventoryStatus;
  final int price;
}
