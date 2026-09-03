import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';
import '../models/location.dart';
import '../models/product.dart';
import '../models/product_price.dart';

abstract interface class CategoryRepository {
  Future<List<Category>> activeCategories();
}

abstract interface class ProductRepository {
  Future<List<Product>> popularProducts();
  Future<List<Product>> products({String? categoryId, String? query});
  Future<Product?> byId(String id);
}

abstract interface class LocationRepository {
  Future<List<DeliveryLocation>> activeLocations();
}

abstract interface class PricingRepository {
  Future<ProductPrice?> currentPrice(String productId, String locationId);
}

class FirestoreCategoryRepository implements CategoryRepository {
  FirestoreCategoryRepository(this.db);
  final FirebaseFirestore db;
  @override
  Future<List<Category>> activeCategories() async => (await db
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .limit(30)
          .get())
      .docs
      .map(Category.fromFirestore)
      .toList();
}

class FirestoreProductRepository implements ProductRepository {
  FirestoreProductRepository(this.db);
  final FirebaseFirestore db;
  Query<Map<String, dynamic>> get _base => db
          .collection('products')
          .where('isActive', isEqualTo: true)
          .where('stockStatus', whereIn: <String>[
        'available',
        'lowStock',
        'outOfStock',
        'comingSoon'
      ]);
  @override
  Future<List<Product>> popularProducts() async =>
      (await _base.where('isPopular', isEqualTo: true).limit(12).get())
          .docs
          .map(Product.fromFirestore)
          .toList();
  @override
  Future<List<Product>> products({String? categoryId, String? query}) async {
    Query<Map<String, dynamic>> q = _base;
    if (categoryId != null) q = q.where('categoryId', isEqualTo: categoryId);
    final normalized = query?.trim().toLowerCase();
    if (normalized != null && normalized.isNotEmpty) {
      q = q.where('searchTerms', arrayContains: normalized);
    }
    return (await q.limit(30).get()).docs.map(Product.fromFirestore).toList();
  }

  @override
  Future<Product?> byId(String id) async {
    final doc = await db.collection('products').doc(id).get();
    return doc.exists && doc.data()?['isActive'] == true
        ? Product.fromFirestore(doc)
        : null;
  }
}

class FirestoreLocationRepository implements LocationRepository {
  FirestoreLocationRepository(this.db);
  final FirebaseFirestore db;
  @override
  Future<List<DeliveryLocation>> activeLocations() async => (await db
          .collection('locations')
          .where('active', isEqualTo: true)
          .orderBy('city')
          .limit(50)
          .get())
      .docs
      .map(DeliveryLocation.fromFirestore)
      .toList();
}

class FirestorePricingRepository implements PricingRepository {
  FirestorePricingRepository(this.db);
  final FirebaseFirestore db;
  @override
  Future<ProductPrice?> currentPrice(
      String productId, String locationId) async {
    final now = DateTime.now();
    final prices = (await db
            .collection('productPrices')
            .where('productId', isEqualTo: productId)
            .where('locationId', isEqualTo: locationId)
            .orderBy('effectiveFrom', descending: true)
            .limit(5)
            .get())
        .docs
        .map(ProductPrice.fromFirestore);
    for (final price in prices) {
      if (price.appliesAt(now)) return price;
    }
    return null;
  }
}

class DemoCatalogRepository
    implements
        CategoryRepository,
        ProductRepository,
        LocationRepository,
        PricingRepository {
  static final categories = <Category>[
    Category(
        id: 'bricks',
        name: 'Bricks',
        nameTamil: 'செங்கற்கள்',
        description: 'Durable materials for every build',
        descriptionTamil: 'ஒவ்வொரு கட்டுமானத்திற்கும் உறுதியான பொருட்கள்',
        imageUrl: null,
        sortOrder: 1,
        isActive: true),
    Category(
        id: 'cement',
        name: 'Cement',
        nameTamil: 'சிமெண்டு',
        description: 'Reliable cement for strong foundations',
        descriptionTamil: 'வலுவான அடித்தளத்திற்கான சிமெண்டு',
        imageUrl: null,
        sortOrder: 2,
        isActive: true),
    Category(
        id: 'sand',
        name: 'Sand',
        nameTamil: 'மணல்',
        description: 'Quality construction sand',
        descriptionTamil: 'தரமான கட்டுமான மணல்',
        imageUrl: null,
        sortOrder: 3,
        isActive: true),
    Category(
        id: 'jelly',
        name: 'Jelly',
        nameTamil: 'ஜல்லி',
        description: 'Graded aggregates for concrete work',
        descriptionTamil: 'கான்கிரீட் வேலைக்கான தரப்படுத்தப்பட்ட ஜல்லி',
        imageUrl: null,
        sortOrder: 4,
        isActive: true),
    Category(
        id: 'steel',
        name: 'Steel',
        nameTamil: 'ஸ்டீல்',
        description: 'TMT reinforcement steel',
        descriptionTamil: 'வலுவூட்டும் டிஎம்டி ஸ்டீல்',
        imageUrl: null,
        sortOrder: 5,
        isActive: true),
    Category(
        id: 'blocks',
        name: 'Concrete Blocks',
        nameTamil: 'கான்கிரீட் பிளாக்குகள்',
        description: 'Hollow and solid blocks',
        descriptionTamil: 'ஹாலோ மற்றும் சாலிட் பிளாக்குகள்',
        imageUrl: null,
        sortOrder: 6,
        isActive: true),
    Category(
        id: 'rmc',
        name: 'RMC',
        nameTamil: 'ரெடி மிக்ஸ் கான்கிரீட்',
        description: 'Ready-mix concrete for project sites',
        descriptionTamil: 'கட்டுமான தளங்களுக்கான ரெடி மிக்ஸ் கான்கிரீட்',
        imageUrl: null,
        sortOrder: 7,
        isActive: true),
    Category(
        id: 'other',
        name: 'Other Materials',
        nameTamil: 'மற்ற பொருட்கள்',
        description: 'More essentials for your site',
        descriptionTamil: 'உங்கள் தளத்திற்கான மேலும் அத்தியாவசிய பொருட்கள்',
        imageUrl: null,
        sortOrder: 8,
        isActive: true)
  ];
  static final locations = <DeliveryLocation>[
    DeliveryLocation(
        id: 'karaikudi',
        city: 'Karaikudi',
        district: 'Sivaganga',
        state: 'Tamil Nadu',
        country: 'India',
        isActive: true),
    DeliveryLocation(
        id: 'madurai',
        city: 'Madurai',
        district: 'Madurai',
        state: 'Tamil Nadu',
        country: 'India',
        isActive: true),
    DeliveryLocation(
        id: 'coimbatore',
        city: 'Coimbatore',
        district: 'Coimbatore',
        state: 'Tamil Nadu',
        country: 'India',
        isActive: true),
    DeliveryLocation(
        id: 'chennai',
        city: 'Chennai',
        district: 'Chennai',
        state: 'Tamil Nadu',
        country: 'India',
        isActive: true)
  ];
  static final demoProducts = <Product>[
    Product(
        id: 'red-clay-brick',
        name: 'Red Clay Brick',
        nameTamil: 'செங்கல்',
        categoryId: 'bricks',
        description: 'Machine-cut clay bricks for durable walls.',
        descriptionTamil:
            'உறுதியான சுவர்களுக்கான இயந்திர வெட்டிய களிமண் செங்கற்கள்.',
        images: const <String>[],
        thumbnail: null,
        brand: 'BM Select',
        unit: ProductUnit.piece,
        minimumOrderQuantity: 500,
        inventoryStatus: InventoryStatus.available,
        stockQuantity: null,
        specifications: const {
          'Material': 'Clay',
          'Size': '230mm × 110mm × 70mm'
        },
        keywords: const ['brick', 'red brick', 'செங்கல்'],
        isPopular: true,
        isFeatured: true,
        isActive: true),
    Product(
        id: 'opc-cement',
        name: 'OPC Cement',
        nameTamil: 'ஓபிசி சிமெண்டு',
        categoryId: 'cement',
        description: 'High strength ordinary Portland cement.',
        descriptionTamil: 'அதிக வலிமை கொண்ட சாதாரண போர்ட்லாண்ட் சிமெண்டு.',
        images: const <String>[],
        thumbnail: null,
        brand: 'BM Select',
        unit: ProductUnit.bag,
        minimumOrderQuantity: 10,
        inventoryStatus: InventoryStatus.lowStock,
        stockQuantity: null,
        specifications: const {'Grade': '53 grade'},
        keywords: const ['cement', 'சிமெண்டு'],
        isPopular: true,
        isFeatured: false,
        isActive: true),
    Product(
        id: 'm-sand',
        name: 'M-Sand',
        nameTamil: 'எம்-சாண்ட்',
        categoryId: 'sand',
        description: 'Washed manufactured sand for construction.',
        descriptionTamil: 'கட்டுமானத்திற்கான கழுவிய தயாரிப்பு மணல்.',
        images: const <String>[],
        thumbnail: null,
        brand: 'BM Select',
        unit: ProductUnit.load,
        minimumOrderQuantity: 1,
        inventoryStatus: InventoryStatus.outOfStock,
        stockQuantity: null,
        specifications: const {'Type': 'Manufactured sand'},
        keywords: const ['sand', 'm sand', 'மணல்'],
        isPopular: true,
        isFeatured: false,
        isActive: true),
    _demoProduct(
      id: 'fly-ash-brick',
      name: 'Fly Ash Brick',
      tamil: 'ஃப்ளை ஆஷ் செங்கல்',
      category: 'bricks',
      description: 'Uniform eco-conscious bricks for masonry.',
      tamilDescription: 'கட்டுமானத்திற்கான சீரான ஃப்ளை ஆஷ் செங்கற்கள்.',
      unit: ProductUnit.piece,
      minimum: 500,
      status: InventoryStatus.available,
      keywords: const <String>['brick', 'fly ash', 'செங்கல்'],
    ),
    _demoProduct(
      id: 'hollow-block',
      name: 'Hollow Concrete Block',
      tamil: 'ஹாலோ கான்கிரீட் பிளாக்',
      category: 'blocks',
      description: 'Lightweight block for faster wall construction.',
      tamilDescription: 'வேகமான சுவர் கட்டுமானத்திற்கான இலகுரக பிளாக்.',
      unit: ProductUnit.piece,
      minimum: 100,
      status: InventoryStatus.available,
      keywords: const <String>['block', 'hollow', 'concrete', 'பிளாக்'],
    ),
    _demoProduct(
      id: '20mm-jelly',
      name: '20mm Jelly',
      tamil: '20மிமீ ஜல்லி',
      category: 'jelly',
      description: 'Graded 20mm aggregate for structural concrete.',
      tamilDescription: 'கட்டமைப்பு கான்கிரீட்டிற்கான 20மிமீ ஜல்லி.',
      unit: ProductUnit.load,
      minimum: 1,
      status: InventoryStatus.available,
      keywords: const <String>['20mm', 'jelly', 'aggregate', 'ஜல்லி'],
      popular: true,
    ),
    _demoProduct(
      id: 'tmt-steel-12mm',
      name: '12mm TMT Steel',
      tamil: '12மிமீ டிஎம்டி ஸ்டீல்',
      category: 'steel',
      description: 'High-strength reinforcement bar.',
      tamilDescription: 'அதிக வலிமை கொண்ட கட்டுமான ஸ்டீல் கம்பி.',
      unit: ProductUnit.ton,
      minimum: 1,
      status: InventoryStatus.lowStock,
      keywords: const <String>['steel', 'tmt', '12mm', 'ஸ்டீல்'],
      popular: true,
    ),
    _demoProduct(
      id: 'rmc-m20',
      name: 'RMC M20',
      tamil: 'எம்20 ரெடி மிக்ஸ் கான்கிரீட்',
      category: 'rmc',
      description: 'Plant-batched M20 ready-mix concrete.',
      tamilDescription: 'ஆலையில் தயாரிக்கப்பட்ட எம்20 ரெடி மிக்ஸ் கான்கிரீட்.',
      unit: ProductUnit.cubicFeet,
      minimum: 100,
      status: InventoryStatus.comingSoon,
      keywords: const <String>['rmc', 'm20', 'concrete', 'கான்கிரீட்'],
    ),
    _demoProduct(
      id: 'binding-wire',
      name: 'Binding Wire',
      tamil: 'பைண்டிங் கம்பி',
      category: 'other',
      description: 'Flexible binding wire for reinforcement work.',
      tamilDescription: 'ஸ்டீல் கட்டும் வேலைக்கான பைண்டிங் கம்பி.',
      unit: ProductUnit.kg,
      minimum: 5,
      status: InventoryStatus.available,
      keywords: const <String>['wire', 'binding', 'கம்பி'],
    )
  ];

  static Product _demoProduct({
    required String id,
    required String name,
    required String tamil,
    required String category,
    required String description,
    required String tamilDescription,
    required ProductUnit unit,
    required int minimum,
    required InventoryStatus status,
    required List<String> keywords,
    bool popular = false,
  }) =>
      Product(
        id: id,
        name: name,
        nameTamil: tamil,
        categoryId: category,
        description: description,
        descriptionTamil: tamilDescription,
        images: const <String>[],
        thumbnail: null,
        brand: 'BM Select',
        unit: unit,
        minimumOrderQuantity: minimum,
        inventoryStatus: status,
        stockQuantity: null,
        specifications: const <String, String>{'Quality': 'BM verified'},
        keywords: keywords,
        isPopular: popular,
        isFeatured: popular,
        isActive: true,
      );
  @override
  Future<List<Category>> activeCategories() async => categories;
  @override
  Future<List<DeliveryLocation>> activeLocations() async => locations;
  @override
  Future<List<Product>> popularProducts() async =>
      demoProducts.where((p) => p.isPopular).toList();
  @override
  Future<Product?> byId(String id) async =>
      demoProducts.where((p) => p.id == id).cast<Product?>().firstOrNull;
  @override
  Future<List<Product>> products({String? categoryId, String? query}) async {
    final q = query?.toLowerCase();
    return demoProducts
        .where((p) =>
            (categoryId == null || p.categoryId == categoryId) &&
            (q == null ||
                q.isEmpty ||
                p.name.toLowerCase().contains(q) ||
                p.nameTamil.contains(q) ||
                p.brand.toLowerCase().contains(q) ||
                p.keywords.any((k) => k.contains(q))))
        .toList();
  }

  @override
  Future<ProductPrice?> currentPrice(
      String productId, String locationId) async {
    const prices = <String, num>{
      'red-clay-brick:karaikudi': 8,
      'red-clay-brick:madurai': 8.5,
      'red-clay-brick:coimbatore': 9,
      'red-clay-brick:chennai': 10,
      'opc-cement:karaikudi': 430,
      'opc-cement:madurai': 435,
      'fly-ash-brick:karaikudi': 7.5,
      'hollow-block:karaikudi': 42,
      '20mm-jelly:karaikudi': 4200,
      'tmt-steel-12mm:karaikudi': 61500,
      'binding-wire:karaikudi': 78
    };
    final value = prices['$productId:$locationId'];
    return value == null
        ? null
        : ProductPrice(
            id: 'demo-$productId-$locationId',
            productId: productId,
            locationId: locationId,
            price: value,
            effectiveFrom: DateTime(2020));
  }
}
