import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/bm_theme.dart';
import '../../core/widgets/bm_components.dart';
import '../../l10n/app_localizations.dart';
import '../../models/category.dart';
import '../cart/cart_notifier.dart';
import '../auth/auth_providers.dart';
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
    final cartCount = ref.watch(cartProvider.select((cart) => cart.itemCount));
    final customer = ref.watch(currentCustomerProvider).valueOrNull;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(categoriesProvider);
            ref.invalidate(popularProductsProvider);
            await Future.wait(<Future<Object?>>[
              ref.read(categoriesProvider.future),
              ref.read(popularProductsProvider.future),
            ]);
          },
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: <Widget>[
                      InkWell(
                        onTap: () => context.push('/locations'),
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: <Widget>[
                              const Icon(Icons.location_on_rounded,
                                  color: BmColors.orange),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(t.deliverTo,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall),
                                  Text(
                                      location?.displayName ?? t.selectLocation,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700)),
                                ],
                              ),
                              const Icon(Icons.keyboard_arrow_down_rounded),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: t.orderSummary,
                        onPressed: () => context.push('/cart'),
                        icon: Badge(
                          isLabelVisible: cartCount > 0,
                          label: Text('$cartCount'),
                          child: const Icon(Icons.playlist_add_check_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverList.list(
                  children: <Widget>[
                    Text(
                        customer == null
                            ? t.goodMorning
                            : t.goodMorningName(customer.name),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(t.todayQuestion,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 18),
                    Semantics(
                      button: true,
                      label: t.searchHint,
                      child: TextField(
                        readOnly: true,
                        onTap: () => context.push('/search'),
                        decoration: InputDecoration(
                          hintText: t.searchHint,
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: const Icon(Icons.tune_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    BmSectionHeader(
                      title: t.shopByCategory,
                      actionLabel: t.viewAll,
                      onAction: () => context.push('/categories'),
                    ),
                    const SizedBox(height: 12),
                    categories.when(
                      loading: () =>
                          const SizedBox(height: 132, child: BmLoading()),
                      error: (_, __) => BmErrorState(
                        onRetry: () => ref.invalidate(categoriesProvider),
                      ),
                      data: (items) => _CategoryGrid(items: items),
                    ),
                    const SizedBox(height: 28),
                    BmSectionHeader(
                      title: t.popularMaterials,
                      actionLabel: t.viewAll,
                      onAction: () => context.push('/categories'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 284,
                      child:
                          CatalogProductList(value: popular, horizontal: true),
                    ),
                    const SizedBox(height: 28),
                    _PromotionBanner(t: t),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) context.push('/search');
          if (index == 2) context.push('/orders');
          if (index == 3) context.push('/profile');
        },
        destinations: <NavigationDestination>[
          NavigationDestination(
              icon: const Icon(Icons.home_rounded), label: t.home),
          NavigationDestination(
              icon: const Icon(Icons.search_rounded), label: t.search),
          NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined), label: t.orders),
          NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded), label: t.profile),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.items});
  final List<Category> items;

  static const icons = <IconData>[
    Icons.view_in_ar_rounded,
    Icons.landscape_outlined,
    Icons.inventory_2_outlined,
    Icons.grain_rounded,
    Icons.reorder_rounded,
    Icons.grid_4x4_rounded,
    Icons.foundation_outlined,
    Icons.more_horiz_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    if (items.isEmpty) return BmEmptyState(title: t.noCategories);
    return LayoutBuilder(
      builder: (_, constraints) {
        final count = constraints.maxWidth >= 760 ? 8 : 4;
        final width = (constraints.maxWidth - ((count - 1) * 10)) / count;
        return Wrap(
          spacing: 10,
          runSpacing: 14,
          children: <Widget>[
            for (var i = 0; i < items.length; i++)
              SizedBox(
                width: width,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push('/category/${items[i].id}',
                      extra: items[i].localizedName(t.locale.languageCode)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: BmColors.lightOrange,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(icons[i % icons.length],
                              color: BmColors.orange),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          items[i].localizedName(t.locale.languageCode),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PromotionBanner extends StatelessWidget {
  const _PromotionBanner({required this.t});
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) => Container(
        height: 188,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: BmColors.peach,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: BmColors.border),
        ),
        child: Stack(
          children: <Widget>[
            const Positioned(
              right: -34,
              top: 0,
              bottom: 0,
              width: 250,
              child: BmImage(
                source: 'assets/images/banners/materials_hero.png',
                borderRadius: 0,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      BmColors.peach,
                      BmColors.peach.withValues(alpha: .98),
                      BmColors.peach.withValues(alpha: .12),
                    ],
                    stops: const <double>[0, .43, .74],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 22,
              bottom: 20,
              width: 205,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(t.featuredDeal,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(t.featuredDealBody, maxLines: 3),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => context.push('/categories'),
                    child: Text(t.shopNow),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
