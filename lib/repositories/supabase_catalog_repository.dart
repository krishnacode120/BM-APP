import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';
import '../models/location.dart';
import '../models/product.dart';
import '../models/product_price.dart';
import 'catalog_repositories.dart';

/// SQL wire mapping into the existing domain types. No Firestore SDK conversion.
class SupabaseCatalogMapping {
  static DateTime? date(Object? value) =>
      value == null ? null : DateTime.parse(value as String);
  static Category category(Map<String, dynamic> row) => Category(
      id: row['id'] as String,
      name: row['name'] as String,
      nameTamil: row['name_tamil'] as String,
      description: row['description'] as String,
      descriptionTamil: row['description_tamil'] as String,
      imageUrl: row['image_url'] as String?,
      sortOrder: row['sort_order'] as int,
      isActive: row['is_active'] == true,
      createdAt: date(row['created_at']),
      updatedAt: date(row['updated_at']));
  static DeliveryLocation location(Map<String, dynamic> row) =>
      DeliveryLocation(
          id: row['id'] as String,
          city: row['city'] as String,
          district: row['district'] as String,
          state: row['state'] as String,
          country: row['country'] as String,
          isActive: row['active'] == true);
  static Product product(Map<String, dynamic> row) => Product(
      id: row['id'] as String,
      name: row['name'] as String,
      nameTamil: row['name_tamil'] as String,
      categoryId: row['category_id'] as String,
      description: row['description'] as String,
      descriptionTamil: row['description_tamil'] as String,
      images: List<String>.from(row['images'] as List),
      thumbnail: row['thumbnail'] as String?,
      brand: row['brand'] as String,
      unit: productUnitFromValue(row['unit'] as String),
      minimumOrderQuantity: row['minimum_order_quantity'] as int,
      inventoryStatus: inventoryStatusFromValue(row['stock_status'] as String),
      stockQuantity: row['stock_quantity'] as int?,
      specifications: (row['specifications'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v.toString())),
      keywords: List<String>.from(row['keywords'] as List),
      isPopular: row['is_popular'] == true,
      isFeatured: row['is_featured'] == true,
      isActive: row['is_active'] == true,
      createdAt: date(row['created_at']),
      updatedAt: date(row['updated_at']),
      createdBy: row['created_by'] as String?,
      updatedBy: row['updated_by'] as String?);
  static ProductPrice price(Map<String, dynamic> row) => ProductPrice(
      id: row['id'] as String,
      productId: row['product_id'] as String,
      locationId: row['location_id'] as String,
      price: row['price'] as num,
      effectiveFrom: DateTime.parse(row['effective_from'] as String),
      effectiveTo: date(row['effective_to']),
      updatedAt: date(row['updated_at']),
      updatedBy: row['updated_by'] as String?);
}

class SupabaseCatalogRepository
    implements
        CategoryRepository,
        ProductRepository,
        LocationRepository,
        PricingRepository {
  SupabaseCatalogRepository(this.client);
  final SupabaseClient client;

  @override
  Future<List<Category>> activeCategories() async => (await client
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('sort_order')
          .order('id')
          .limit(30))
      .map(SupabaseCatalogMapping.category)
      .toList();
  @override
  Future<List<DeliveryLocation>> activeLocations() async => (await client
          .from('locations')
          .select()
          .eq('active', true)
          .order('city')
          .order('id')
          .limit(50))
      .map(SupabaseCatalogMapping.location)
      .toList();
  @override
  Future<List<Product>> popularProducts() => page(popular: true, limit: 12);
  @override
  Future<List<Product>> products({String? categoryId, String? query}) =>
      page(categoryId: categoryId, query: query);

  /// Keyset pagination: pass the last returned ID; no growing OFFSET scans.
  Future<List<Product>> page(
      {String? categoryId,
      String? query,
      String? afterId,
      int limit = 30,
      bool popular = false}) async {
    final normalized = query?.trim().toLowerCase();
    final rows = await client.rpc('catalog_products', params: {
      'p_category': categoryId,
      'p_query': normalized == '' ? null : normalized,
      'p_after': afterId,
      'p_limit': limit.clamp(1, 50),
      'p_popular': popular,
    }) as List<dynamic>;
    return rows
        .map((row) =>
            SupabaseCatalogMapping.product(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Product?> byId(String id) async {
    final row = await client
        .from('products')
        .select()
        .eq('id', id)
        .eq('is_active', true)
        .neq('stock_status', 'hidden')
        .maybeSingle();
    return row == null ? null : SupabaseCatalogMapping.product(row);
  }

  @override
  Future<ProductPrice?> currentPrice(
      String productId, String locationId) async {
    final rows = await client.rpc('current_product_price', params: {
      'p_product_id': productId,
      'p_location_id': locationId,
    }) as List<dynamic>;
    // Missing price remains null. Effective dates are resolved using server time.
    return rows.isEmpty
        ? null
        : SupabaseCatalogMapping.price(rows.single as Map<String, dynamic>);
  }
}
