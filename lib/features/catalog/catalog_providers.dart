import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/category.dart';
import '../../models/location.dart';
import '../../models/product.dart';
import '../../models/product_price.dart';
import '../../repositories/catalog_repositories.dart';
import '../../core/config/backend_config.dart';
import '../../repositories/supabase_catalog_repository.dart';

final demoCatalogProvider = Provider<bool>((ref) =>
    !ref.watch(backendConfigProvider).isSupabase && Firebase.apps.isEmpty);
final supabaseCatalogProvider = Provider<SupabaseCatalogRepository>(
    (ref) => SupabaseCatalogRepository(ref.watch(supabaseClientProvider)));
final categoryRepositoryProvider = Provider<CategoryRepository>(
    (ref) => ref.watch(backendConfigProvider).isSupabase
        ? ref.watch(supabaseCatalogProvider)
        : ref.watch(demoCatalogProvider)
            ? DemoCatalogRepository()
            : FirestoreCategoryRepository(FirebaseFirestore.instance));
final productRepositoryProvider = Provider<ProductRepository>(
    (ref) => ref.watch(backendConfigProvider).isSupabase
        ? ref.watch(supabaseCatalogProvider)
        : ref.watch(demoCatalogProvider)
            ? DemoCatalogRepository()
            : FirestoreProductRepository(FirebaseFirestore.instance));
final locationRepositoryProvider = Provider<LocationRepository>(
    (ref) => ref.watch(backendConfigProvider).isSupabase
        ? ref.watch(supabaseCatalogProvider)
        : ref.watch(demoCatalogProvider)
            ? DemoCatalogRepository()
            : FirestoreLocationRepository(FirebaseFirestore.instance));
final pricingRepositoryProvider = Provider<PricingRepository>(
    (ref) => ref.watch(backendConfigProvider).isSupabase
        ? ref.watch(supabaseCatalogProvider)
        : ref.watch(demoCatalogProvider)
            ? DemoCatalogRepository()
            : FirestorePricingRepository(FirebaseFirestore.instance));
final categoriesProvider = FutureProvider<List<Category>>(
    (ref) => ref.watch(categoryRepositoryProvider).activeCategories());
final locationsProvider = FutureProvider<List<DeliveryLocation>>(
    (ref) => ref.watch(locationRepositoryProvider).activeLocations());
final popularProductsProvider = FutureProvider<List<Product>>(
    (ref) => ref.watch(productRepositoryProvider).popularProducts());
final productsProvider = FutureProvider.family<List<Product>, String?>(
    (ref, categoryId) =>
        ref.watch(productRepositoryProvider).products(categoryId: categoryId));
final searchProductsProvider = FutureProvider.family<List<Product>, String>(
    (ref, query) =>
        ref.watch(productRepositoryProvider).products(query: query));
final productProvider = FutureProvider.family<Product?, String>(
    (ref, id) => ref.watch(productRepositoryProvider).byId(id));
final productPriceProvider = FutureProvider.family<ProductPrice?,
        ({String productId, String locationId})>(
    (ref, key) => ref
        .watch(pricingRepositoryProvider)
        .currentPrice(key.productId, key.locationId));
final selectedLocationProvider =
    AsyncNotifierProvider<SelectedLocationNotifier, DeliveryLocation?>(
        SelectedLocationNotifier.new);

class SelectedLocationNotifier extends AsyncNotifier<DeliveryLocation?> {
  static const key = 'selectedLocationId';
  String get storageKey =>
      ref.read(backendConfigProvider).isSupabase ? 'supabase_$key' : key;
  @override
  Future<DeliveryLocation?> build() async {
    final locations = await ref.watch(locationsProvider.future);
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(storageKey);
    return locations
            .where((l) => l.id == saved)
            .cast<DeliveryLocation?>()
            .firstOrNull ??
        (locations.isEmpty ? null : locations.first);
  }

  Future<void> select(DeliveryLocation location) async {
    state = AsyncData(location);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, location.id);
  }
}
