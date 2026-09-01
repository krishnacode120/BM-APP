import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../catalog/catalog_pages.dart';
import '../catalog/catalog_providers.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final categories = ref.watch(categoriesProvider);
    final popular = ref.watch(popularProductsProvider);
    final location = ref.watch(selectedLocationProvider).valueOrNull;
    return Scaffold(
      body: SafeArea(
          child: ListView(padding: const EdgeInsets.all(20), children: <Widget>[
        ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Deliver to'),
            subtitle: Text(location?.displayName ?? t.selectLocation),
            trailing: const Icon(Icons.expand_more),
            onTap: () => context.push('/locations')),
        Text('What construction material do you need?',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        Text(t.shopByCategory, style: Theme.of(context).textTheme.titleLarge),
        categories.when(
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => Text(t.tryAgain),
            data: (items) => Wrap(spacing: 8, children: <Widget>[
                  for (final c in items)
                    ActionChip(
                        label: Text(c.localizedName(t.locale.languageCode)),
                        onPressed: () => context.push('/category/${c.id}',
                            extra: c.localizedName(t.locale.languageCode)))
                ])),
        const SizedBox(height: 24),
        Text(t.popularMaterials, style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 260, child: CatalogProductList(value: popular)),
      ])),
      bottomNavigationBar: NavigationBar(destinations: <NavigationDestination>[
        NavigationDestination(
            icon: const Icon(Icons.home_outlined), label: t.home),
        NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined), label: t.orders),
        NavigationDestination(
            icon: const Icon(Icons.shopping_cart_outlined), label: t.cart),
        NavigationDestination(
            icon: const Icon(Icons.person_outline), label: t.profile)
      ]),
    );
  }
}
