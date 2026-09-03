import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/bm_theme.dart';
import '../../core/widgets/bm_components.dart';
import '../../l10n/app_localizations.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../cart/cart_notifier.dart';
import '../profile/customer_pages.dart';
import '../settings/contact_bm.dart';
import 'catalog_providers.dart';

class LocationSelectorPage extends ConsumerStatefulWidget {
  const LocationSelectorPage({super.key});

  @override
  ConsumerState<LocationSelectorPage> createState() =>
      _LocationSelectorPageState();
}

class _LocationSelectorPageState extends ConsumerState<LocationSelectorPage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locations = ref.watch(locationsProvider);
    final selected = ref.watch(selectedLocationProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(t.selectLocation)),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: TextField(
                onChanged: (value) =>
                    setState(() => query = value.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: t.search,
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
            ),
            Expanded(
              child: locations.when(
                loading: () => const BmLoading(),
                error: (_, __) => BmEmptyState(
                  title: t.locationLoadError,
                  actionLabel: t.tryAgain,
                  onAction: () => ref.invalidate(locationsProvider),
                ),
                data: (items) {
                  final filtered = items
                      .where((item) =>
                          item.displayName.toLowerCase().contains(query) ||
                          item.district.toLowerCase().contains(query))
                      .toList();
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: <Widget>[
                      if (selected != null) ...<Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(t.currentLocation,
                              style: Theme.of(context).textTheme.titleMedium),
                        ),
                        _LocationTile(
                          name: selected.displayName,
                          district: selected.district,
                          selected: true,
                          onTap: () {},
                        ),
                        const SizedBox(height: 18),
                      ],
                      for (final location in filtered)
                        if (location.id != selected?.id)
                          _LocationTile(
                            name: location.displayName,
                            district: location.district,
                            selected: false,
                            onTap: () async {
                              await ref
                                  .read(selectedLocationProvider.notifier)
                                  .select(location);
                              ref.invalidate(popularProductsProvider);
                              if (context.mounted) context.pop();
                            },
                          ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.name,
    required this.district,
    required this.selected,
    required this.onTap,
  });
  final String name;
  final String district;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          minTileHeight: 72,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: BmColors.lightOrange,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.location_on_outlined, color: BmColors.orange),
          ),
          title:
              Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(district),
          trailing: Icon(
            selected ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
            color: selected ? BmColors.orange : BmColors.secondaryText,
          ),
          onTap: onTap,
        ),
      );
}

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.categories),
        actions: <Widget>[
          IconButton(
            tooltip: t.search,
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: t.cart,
            onPressed: () => context.push('/cart'),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),
      body: ref.watch(categoriesProvider).when(
            loading: () => const BmLoading(),
            error: (_, __) =>
                BmErrorState(onRetry: () => ref.invalidate(categoriesProvider)),
            data: (items) => items.isEmpty
                ? BmEmptyState(title: t.noCategories)
                : LayoutBuilder(
                    builder: (_, constraints) {
                      final columns = constraints.maxWidth > 720 ? 4 : 2;
                      return GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.18,
                        ),
                        itemCount: items.length,
                        itemBuilder: (_, index) =>
                            _CategoryCard(category: items[index]),
                      );
                    },
                  ),
          ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});
  final Category category;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/category/${category.id}',
            extra: category.localizedName(t.locale.languageCode)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: BmImage(source: category.imageUrl, borderRadius: 14),
              ),
              const SizedBox(height: 10),
              Text(category.localizedName(t.locale.languageCode),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium),
              Text(category.localizedDescription(t.locale.languageCode),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryProductsPage extends ConsumerWidget {
  const CategoryProductsPage(
      {required this.categoryId, required this.title, super.key});
  final String categoryId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: <Widget>[
            IconButton(
              tooltip: AppLocalizations.of(context).search,
              onPressed: () => context.push('/search'),
              icon: const Icon(Icons.search_rounded),
            ),
            IconButton(
              tooltip: AppLocalizations.of(context).cart,
              onPressed: () => context.push('/cart'),
              icon: const Icon(Icons.shopping_bag_outlined),
            ),
          ],
        ),
        body:
            CatalogProductList(value: ref.watch(productsProvider(categoryId))),
      );
}

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final controller = TextEditingController();
  Timer? debounce;
  String query = '';
  List<String> recent = <String>[];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (mounted) {
        setState(() =>
            recent = prefs.getStringList('bm_recent_searches') ?? <String>[]);
      }
    });
  }

  @override
  void dispose() {
    debounce?.cancel();
    controller.dispose();
    super.dispose();
  }

  void _change(String value) {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => query = value.trim());
    });
  }

  Future<void> _remember(String value) async {
    if (value.trim().isEmpty) return;
    recent = <String>[
      value.trim(),
      ...recent.where((item) => item != value.trim())
    ].take(6).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bm_recent_searches', recent);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final results =
        query.isEmpty ? null : ref.watch(searchProductsProvider(query));
    return Scaffold(
      appBar: AppBar(title: Text(t.search)),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: TextField(
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: _change,
                onSubmitted: (value) {
                  _remember(value);
                  setState(() => query = value.trim());
                },
                decoration: InputDecoration(
                  hintText: t.searchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: controller.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: t.clear,
                          onPressed: () {
                            controller.clear();
                            setState(() => query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
            ),
            Expanded(
              child: results == null
                  ? _RecentSearches(
                      recent: recent,
                      onSelect: (value) {
                        controller.text = value;
                        setState(() => query = value);
                      },
                      onClear: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('bm_recent_searches');
                        setState(() => recent = <String>[]);
                      },
                    )
                  : CatalogProductList(value: results, searchEmpty: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  const _RecentSearches(
      {required this.recent, required this.onSelect, required this.onClear});
  final List<String> recent;
  final ValueChanged<String> onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        if (recent.isNotEmpty) ...<Widget>[
          BmSectionHeader(
              title: t.recentSearches, actionLabel: t.clear, onAction: onClear),
          const SizedBox(height: 8),
          for (final item in recent)
            ListTile(
              leading: const Icon(Icons.history_rounded),
              title: Text(item),
              trailing: const Icon(Icons.north_west_rounded, size: 18),
              onTap: () => onSelect(item),
            ),
        ],
        const SizedBox(height: 20),
        Text(t.popularMaterials, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <String>[
            'brick',
            'cement',
            'M-Sand',
            '20mm',
            'செங்கல்',
            'சிமெண்டு'
          ]
              .map((item) => ActionChip(
                  label: Text(item), onPressed: () => onSelect(item)))
              .toList(),
        ),
      ],
    );
  }
}

class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({required this.productId, super.key});
  final String productId;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  int quantity = 1;
  int imageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.productDetails),
        actions: <Widget>[
          Consumer(builder: (_, ref, __) {
            final saved =
                ref.watch(wishlistProvider).contains(widget.productId);
            return IconButton(
              tooltip: t.wishlist,
              onPressed: () =>
                  ref.read(wishlistProvider.notifier).toggle(widget.productId),
              icon: Icon(
                  saved
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: saved ? BmColors.orange : null),
            );
          }),
          IconButton(
            tooltip: t.cart,
            onPressed: () => context.push('/cart'),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),
      body: ref.watch(productProvider(widget.productId)).when(
            loading: () => const BmLoading(),
            error: (_, __) => BmErrorState(
                onRetry: () =>
                    ref.invalidate(productProvider(widget.productId))),
            data: (product) {
              if (product == null) {
                return BmEmptyState(title: t.productUnavailable);
              }
              if (quantity < product.minimumOrderQuantity) {
                quantity = product.minimumOrderQuantity;
              }
              return _detail(context, product);
            },
          ),
    );
  }

  Widget _detail(BuildContext context, Product product) {
    final t = AppLocalizations.of(context);
    final location = ref.watch(selectedLocationProvider).valueOrNull;
    final price = location == null
        ? null
        : ref
            .watch(productPriceProvider(
                (productId: product.id, locationId: location.id)))
            .valueOrNull;
    final images = product.images.isNotEmpty
        ? product.images
        : <String>[
            if (product.thumbnail != null) product.thumbnail!,
            'assets/images/banners/materials_hero.png'
          ];
    final total = price == null ? null : price.price * quantity;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: <Widget>[
        Hero(
          tag: 'product-${product.id}',
          child: AspectRatio(
            aspectRatio: 1.28,
            child: BmImage(
                source: images[imageIndex.clamp(0, images.length - 1)],
                borderRadius: 22),
          ),
        ),
        if (images.length > 1) ...<Widget>[
          const SizedBox(height: 12),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) => InkWell(
                onTap: () => setState(() => imageIndex = index),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 64,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: imageIndex == index
                            ? BmColors.orange
                            : BmColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: BmImage(source: images[index], borderRadius: 9),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 22),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(product.localizedName(t.locale.languageCode),
                      style: Theme.of(context).textTheme.headlineSmall),
                  if (product.brand.isNotEmpty) Text(product.brand),
                ],
              ),
            ),
            BmStatusChip(
                label: _status(t, product.inventoryStatus),
                tone: _statusTone(product.inventoryStatus)),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          price == null
              ? t.priceOnRequest
              : '₹${_money(price.price)} / ${t.unitLabel(product.unit.name)}',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: BmColors.orange),
        ),
        const SizedBox(height: 8),
        Text(
            '${t.minimumOrder}: ${product.minimumOrderQuantity} ${t.unitLabel(product.unit.name)}'),
        const Divider(height: 34),
        Row(
          children: <Widget>[
            Text(t.quantity, style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            _QuantityButton(
              icon: Icons.remove,
              onTap: quantity > product.minimumOrderQuantity
                  ? () => setState(() => quantity--)
                  : null,
            ),
            SizedBox(
                width: 58,
                child: Text('$quantity',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium)),
            _QuantityButton(
                icon: Icons.add, onTap: () => setState(() => quantity++)),
          ],
        ),
        if (total != null) ...<Widget>[
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Text(t.total),
              const Spacer(),
              Text('₹${_money(total)}',
                  style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ],
        const Divider(height: 34),
        Text(t.description, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(product.localizedDescription(t.locale.languageCode)),
        if (product.specifications.isNotEmpty) ...<Widget>[
          const SizedBox(height: 26),
          Text(t.specifications, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: BmColors.border),
            ),
            child: Column(
              children: product.specifications.entries
                  .map((entry) => ListTile(
                        dense: true,
                        title: Text(entry.key),
                        trailing: Text(entry.value,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ))
                  .toList(),
            ),
          ),
        ],
        const SizedBox(height: 24),
        const ContactBmButton(),
        const SizedBox(height: 12),
        BmPrimaryButton(
          label: price == null ? t.contactBm : t.addToCart,
          icon: price == null
              ? Icons.chat_bubble_outline_rounded
              : Icons.add_shopping_cart_rounded,
          onPressed: product.canOrder && location != null && price != null
              ? () {
                  final error = ref.read(cartProvider.notifier).add(
                        product,
                        quantity: quantity,
                        locationId: location.id,
                        price: price.price,
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error ?? t.addedToCart)));
                }
              : null,
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => IconButton.outlined(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        constraints: const BoxConstraints.tightFor(width: 42, height: 42),
      );
}

class CatalogProductList extends StatelessWidget {
  const CatalogProductList(
      {required this.value,
      this.horizontal = false,
      this.searchEmpty = false,
      super.key});
  final AsyncValue<List<Product>> value;
  final bool horizontal;
  final bool searchEmpty;

  @override
  Widget build(BuildContext context) => value.when(
        loading: () => const BmLoading(),
        error: (_, __) => BmEmptyState(
          title: AppLocalizations.of(context).somethingWentWrong,
          message: AppLocalizations.of(context).unableToLoadMaterials,
          icon: Icons.cloud_off_outlined,
        ),
        data: (items) {
          final t = AppLocalizations.of(context);
          if (items.isEmpty) {
            return BmEmptyState(
              title: searchEmpty ? t.noSearchResults : t.noProducts,
              message: searchEmpty ? t.tryAnotherSearch : null,
            );
          }
          if (horizontal) {
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 4),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) => SizedBox(
                  width: 210,
                  child: ProductCard(product: items[index], compact: true)),
            );
          }
          return LayoutBuilder(
            builder: (_, constraints) {
              if (constraints.maxWidth >= 700) {
                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 360,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: .78,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, index) =>
                      ProductCard(product: items[index], compact: true),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) => ProductCard(product: items[index]),
              );
            },
          );
        },
      );
}

class ProductCard extends ConsumerWidget {
  const ProductCard({required this.product, this.compact = false, super.key});
  final Product product;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(selectedLocationProvider).valueOrNull;
    final price = location == null
        ? null
        : ref
            .watch(productPriceProvider(
                (productId: product.id, locationId: location.id)))
            .valueOrNull;
    final t = AppLocalizations.of(context);
    final image = product.thumbnail ??
        (product.images.isNotEmpty ? product.images.first : null);
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(product.localizedName(t.locale.languageCode),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(product.localizedDescription(t.locale.languageCode),
            maxLines: 2, overflow: TextOverflow.ellipsis),
        const Spacer(),
        Text(
          price == null
              ? t.priceOnRequest
              : '₹${_money(price.price)} / ${t.unitLabel(product.unit.name)}',
          style: const TextStyle(
              color: BmColors.orange, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        Text('${t.minimumOrder}: ${product.minimumOrderQuantity}',
            style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 7),
        BmStatusChip(
            label: _status(t, product.inventoryStatus),
            tone: _statusTone(product.inventoryStatus)),
      ],
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/product/${product.id}'),
        child: compact
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: Hero(
                          tag: 'product-${product.id}',
                          child: BmImage(source: image, borderRadius: 14)),
                    ),
                    const SizedBox(height: 10),
                    Expanded(flex: 6, child: details),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 154,
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 126,
                        child: Hero(
                            tag: 'product-${product.id}',
                            child: BmImage(source: image, borderRadius: 14)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: details),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

String _money(num value) {
  final asDouble = value.toDouble();
  return asDouble == asDouble.roundToDouble()
      ? asDouble.toInt().toString()
      : asDouble.toStringAsFixed(2);
}

String _status(AppLocalizations t, InventoryStatus status) => switch (status) {
      InventoryStatus.available => t.available,
      InventoryStatus.lowStock => t.lowStock,
      InventoryStatus.outOfStock => t.outOfStock,
      InventoryStatus.comingSoon => t.comingSoon,
      InventoryStatus.hidden => '',
    };

BmStatusTone _statusTone(InventoryStatus status) => switch (status) {
      InventoryStatus.available => BmStatusTone.success,
      InventoryStatus.lowStock => BmStatusTone.warning,
      InventoryStatus.outOfStock => BmStatusTone.error,
      InventoryStatus.comingSoon => BmStatusTone.info,
      InventoryStatus.hidden => BmStatusTone.neutral,
    };
