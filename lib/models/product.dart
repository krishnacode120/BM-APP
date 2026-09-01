import 'package:cloud_firestore/cloud_firestore.dart';

enum InventoryStatus { available, lowStock, outOfStock, comingSoon, hidden }

enum ProductUnit { piece, bag, load, kg, ton, meter, cubicFeet, other }

InventoryStatus inventoryStatusFromValue(String? value) =>
    InventoryStatus.values.firstWhere((status) => status.name == value,
        orElse: () => InventoryStatus.hidden);
ProductUnit productUnitFromValue(String? value) => ProductUnit.values
    .firstWhere((unit) => unit.name == value, orElse: () => ProductUnit.other);

class Product {
  const Product(
      {required this.id,
      required this.name,
      required this.nameTamil,
      required this.categoryId,
      required this.description,
      required this.descriptionTamil,
      required this.images,
      required this.thumbnail,
      required this.brand,
      required this.unit,
      required this.minimumOrderQuantity,
      required this.inventoryStatus,
      required this.stockQuantity,
      required this.specifications,
      required this.keywords,
      required this.isPopular,
      required this.isFeatured,
      required this.isActive,
      this.createdAt,
      this.updatedAt,
      this.createdBy,
      this.updatedBy});
  final String id;
  final String name;
  final String nameTamil;
  final String categoryId;
  final String description;
  final String descriptionTamil;
  final List<String> images;
  final String? thumbnail;
  final String brand;
  final ProductUnit unit;
  final int minimumOrderQuantity;
  final InventoryStatus inventoryStatus;
  final int? stockQuantity;
  final Map<String, String> specifications;
  final List<String> keywords;
  final bool isPopular;
  final bool isFeatured;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;
  bool get canOrder =>
      isActive &&
      (inventoryStatus == InventoryStatus.available ||
          inventoryStatus == InventoryStatus.lowStock);
  String localizedName(String languageCode) =>
      languageCode == 'ta' && nameTamil.isNotEmpty ? nameTamil : name;
  String localizedDescription(String languageCode) =>
      languageCode == 'ta' && descriptionTamil.isNotEmpty
          ? descriptionTamil
          : description;
  factory Product.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    final rawSpecs =
        data['specifications'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return Product(
        id: document.id,
        name: data['name'] as String? ?? '',
        nameTamil: data['nameTamil'] as String? ?? '',
        categoryId: data['categoryId'] as String? ?? '',
        description: data['description'] as String? ?? '',
        descriptionTamil: data['descriptionTamil'] as String? ?? '',
        images: List<String>.from(
            data['images'] as List<dynamic>? ?? const <dynamic>[]),
        thumbnail: data['thumbnail'] as String?,
        brand: data['brand'] as String? ?? '',
        unit: productUnitFromValue(data['unit'] as String?),
        minimumOrderQuantity:
            (data['minimumOrderQuantity'] as num? ?? 1).toInt(),
        inventoryStatus:
            inventoryStatusFromValue(data['stockStatus'] as String?),
        stockQuantity: (data['stockQuantity'] as num?)?.toInt(),
        specifications:
            rawSpecs.map((key, value) => MapEntry(key, value.toString())),
        keywords: List<String>.from(
            data['keywords'] as List<dynamic>? ?? const <dynamic>[]),
        isPopular: data['isPopular'] as bool? ?? false,
        isFeatured: data['isFeatured'] as bool? ?? false,
        isActive: data['isActive'] as bool? ?? false,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
        createdBy: data['createdBy'] as String?,
        updatedBy: data['updatedBy'] as String?);
  }
}
