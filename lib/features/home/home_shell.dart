import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../repositories/product_repository.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int selected = 0;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final pages = <Widget>[
      const _HomePage(),
      _EmptyPage(title: t.orders, icon: Icons.receipt_long_outlined),
      _EmptyPage(title: t.cart, icon: Icons.shopping_cart_outlined),
      _EmptyPage(title: t.profile, icon: Icons.person_outline)
    ];
    return Scaffold(
        body: pages[selected],
        bottomNavigationBar: NavigationBar(
            selectedIndex: selected,
            onDestinationSelected: (value) => setState(() => selected = value),
            destinations: <NavigationDestination>[
              NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: t.home),
              NavigationDestination(
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: t.orders),
              NavigationDestination(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: t.cart),
              NavigationDestination(
                  icon: const Icon(Icons.person_outline), label: t.profile)
            ]));
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();
  @override
  Widget build(BuildContext context) => SafeArea(
      child: FutureBuilder<List<Product>>(
          future: SampleProductRepository().popularProducts(),
          builder: (_, snapshot) {
            final products = snapshot.data ?? <Product>[];
            return ListView(
                padding: const EdgeInsets.all(20),
                children: <Widget>[
                  const Row(children: <Widget>[
                    Icon(Icons.location_on_outlined),
                    SizedBox(width: 8),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                          Text('Deliver to',
                              style: TextStyle(color: Colors.grey)),
                          Text('Karaikudi, Tamil Nadu',
                              style: TextStyle(fontWeight: FontWeight.w600))
                        ])),
                    Icon(Icons.notifications_none),
                    SizedBox(width: 16),
                    Badge(
                        label: Text('0'),
                        child: Icon(Icons.shopping_cart_outlined))
                  ]),
                  const SizedBox(height: 24),
                  Text('Good Morning! 👋',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text('What construction material do you need?',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 22),
                  TextField(
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: AppLocalizations.of(context).searchHint)),
                  const SizedBox(height: 28),
                  _Section(
                      title: AppLocalizations.of(context).shopByCategory,
                      child: const _Categories()),
                  const SizedBox(height: 24),
                  _Section(
                      title: AppLocalizations.of(context).popularMaterials,
                      child: SizedBox(
                          height: 214,
                          child: snapshot.hasData
                              ? ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: products.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (_, i) =>
                                      _ProductCard(product: products[i]))
                              : const Center(
                                  child: CircularProgressIndicator()))),
                  const SizedBox(height: 24),
                  Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: const Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Best quality materials at best prices',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                SizedBox(height: 8),
                                Text(
                                    'Prices are confirmed for your delivery location.'),
                                SizedBox(height: 12),
                                FilledButton(
                                    onPressed: null, child: Text('Shop now'))
                              ]))),
                ]);
          }));
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              TextButton(onPressed: () {}, child: const Text('View all'))
            ]),
        child
      ]);
}

class _Categories extends StatelessWidget {
  const _Categories();
  @override
  Widget build(BuildContext context) {
    const categories = <String>['Bricks', 'Sand', 'Cement', 'Jelly', 'Steel'];
    return SizedBox(
        height: 92,
        child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => SizedBox(
                width: 74,
                child: Column(children: <Widget>[
                  CircleAvatar(
                      radius: 27,
                      child: Icon(<IconData>[
                        Icons.grid_view,
                        Icons.landscape,
                        Icons.inventory_2,
                        Icons.scatter_plot,
                        Icons.hardware
                      ][i])),
                  const SizedBox(height: 6),
                  Text(categories[i],
                      maxLines: 1, overflow: TextOverflow.ellipsis)
                ]))));
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});
  final Product product;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: 165,
      child: Card(
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Expanded(
                        child: Center(
                            child: Icon(Icons.inventory_2_outlined, size: 56))),
                    Text(product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('₹${product.price} / ${product.unit}'),
                    const SizedBox(height: 8),
                    SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                            onPressed: product.inventoryStatus ==
                                    InventoryStatus.available
                                ? () {}
                                : null,
                            child: const Text('Add')))
                  ]))));
}

class _EmptyPage extends StatelessWidget {
  const _EmptyPage({required this.title, required this.icon});
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Icon(icon, size: 56),
        const SizedBox(height: 12),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        const Text('Coming in the next milestone')
      ]));
}
