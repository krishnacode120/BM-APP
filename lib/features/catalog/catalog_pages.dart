import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import 'catalog_providers.dart';

class LocationSelectorPage extends ConsumerWidget {
  const LocationSelectorPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locations = ref.watch(locationsProvider);
    final selected = ref.watch(selectedLocationProvider).valueOrNull;
    return Scaffold(
        appBar:
            AppBar(title: Text(AppLocalizations.of(context).selectLocation)),
        body: locations.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) =>
                const Center(child: Text('Unable to load locations')),
            data: (items) => ListView(
                children: items
                    .map((location) => ListTile(
                        leading: Icon(location.id == selected?.id
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off),
                        title: Text(location.displayName),
                        onTap: () {
                          ref
                              .read(selectedLocationProvider.notifier)
                              .select(location);
                          context.pop();
                        }))
                    .toList())));
  }
}

class CategoryProductsPage extends ConsumerWidget {
  const CategoryProductsPage(
      {required this.categoryId, required this.title, super.key});
  final String categoryId;
  final String title;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
      appBar: AppBar(title: Text(title)),
      body: CatalogProductList(value: ref.watch(productsProvider(categoryId))));
}

class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({required this.productId, super.key});
  final String productId;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
      appBar: AppBar(),
      body: ref.watch(productProvider(productId)).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Unable to load product')),
          data: (p) => p == null
              ? const Center(child: Text('Product unavailable'))
              : ListView(padding: const EdgeInsets.all(20), children: <Widget>[
                  ProductTile(product: p),
                  const SizedBox(height: 16),
                  Text(p.localizedDescription(
                      AppLocalizations.of(context).locale.languageCode)),
                  const SizedBox(height: 16),
                  ...p.specifications.entries.map((e) =>
                      ListTile(title: Text(e.key), trailing: Text(e.value))),
                  FilledButton.tonal(
                      onPressed: () {},
                      child: Text(AppLocalizations.of(context).contactBm))
                ])));
}

class CatalogProductList extends StatelessWidget {
  const CatalogProductList({required this.value, super.key});
  final AsyncValue<List<Product>> value;
  @override
  Widget build(BuildContext context) => value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) =>
          Center(child: Text(AppLocalizations.of(context).tryAgain)),
      data: (items) => items.isEmpty
          ? Center(child: Text(AppLocalizations.of(context).noProducts))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (_, i) => ProductTile(product: items[i])));
}

class ProductTile extends ConsumerWidget {
  const ProductTile({required this.product, super.key});
  final Product product;
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
    return Card(
        child: ListTile(
            leading: product.thumbnail == null
                ? const Icon(Icons.inventory_2_outlined)
                : Image.network(product.thumbnail!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image_outlined)),
            title: Text(product.localizedName(t.locale.languageCode)),
            subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(price == null
                      ? t.priceOnRequest
                      : '₹${price.price} / ${product.unit.name}'),
                  Text('${t.minimumOrder}: ${product.minimumOrderQuantity}'),
                  Text(_status(t, product.inventoryStatus))
                ]),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/product/${product.id}')));
  }
}

String _status(AppLocalizations t, InventoryStatus status) => switch (status) {
      InventoryStatus.available => t.available,
      InventoryStatus.lowStock => t.lowStock,
      InventoryStatus.outOfStock => t.outOfStock,
      InventoryStatus.comingSoon => t.comingSoon,
      InventoryStatus.hidden => ''
    };
