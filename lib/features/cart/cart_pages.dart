import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../l10n/app_localizations.dart';
import '../../core/widgets/bm_components.dart';
import '../../models/cart.dart';
import '../catalog/catalog_providers.dart';
import 'cart_notifier.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final cart = ref.watch(cartProvider);
    final location = ref.watch(selectedLocationProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(t.cart)),
      body: cart.items.isEmpty
          ? _EmptyCart(t: t)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                for (final item in cart.items) CartItemCard(item: item),
                const SizedBox(height: 16),
                _CartTotals(cart: cart),
              ],
            ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : SafeArea(
              minimum: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: () async {
                  if (location == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(t.selectLocation)));
                    return;
                  }
                  await ref.read(cartProvider.notifier).revalidate(location.id);
                  final latest = ref.read(cartProvider);
                  if (!context.mounted) return;
                  if (latest.items.any((item) =>
                      item.validation == CartItemValidation.priceChanged)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(t.cartPricesChanged)));
                    return;
                  }
                  if (latest.canCheckout) {
                    unawaited(context.push('/checkout'));
                  } else {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(t.reviewCart)));
                  }
                },
                icon: const Icon(Icons.lock_outline),
                label: Text(t.checkout),
              ),
            ),
    );
  }
}

class CartItemCard extends ConsumerWidget {
  const CartItemCard({required this.item, super.key});
  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final unit = t.unitLabel(item.unit.name);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _ProductImage(url: item.imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('₹${item.displayedUnitPrice} / $unit'),
                    Text(
                        '${t.minimumOrder}: ${item.minimumOrderQuantity} $unit'),
                  ]),
            ),
            IconButton(
              tooltip: t.productUnavailable,
              onPressed: () =>
                  ref.read(cartProvider.notifier).remove(item.productId),
              icon: const Icon(Icons.delete_outline),
            )
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Semantics(
              label: 'decrease quantity',
              button: true,
              child: IconButton.filledTonal(
                onPressed: item.quantity <= 1
                    ? null
                    : () => ref
                        .read(cartProvider.notifier)
                        .setQuantity(item.productId, item.quantity - 1),
                icon: const Icon(Icons.remove),
              ),
            ),
            SizedBox(
              width: 96,
              child: Center(
                  child: Text('${item.quantity}',
                      style: Theme.of(context).textTheme.titleMedium)),
            ),
            Semantics(
              label: 'increase quantity',
              button: true,
              child: IconButton.filledTonal(
                onPressed: () => ref
                    .read(cartProvider.notifier)
                    .setQuantity(item.productId, item.quantity + 1),
                icon: const Icon(Icons.add),
              ),
            ),
            const Spacer(),
            Text('₹${item.subtotal}',
                style: Theme.of(context).textTheme.titleMedium),
          ]),
          if (item.validation != CartItemValidation.valid)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _ValidationBadge(validation: item.validation),
            ),
        ]),
      ),
    );
  }
}

class _CartTotals extends ConsumerWidget {
  const _CartTotals({required this.cart});
  final CartState cart;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final hasPriceChange = cart.items
        .any((item) => item.validation == CartItemValidation.priceChanged);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _TotalRow(label: t.subtotal, value: '₹${cart.subtotal}'),
          const Divider(),
          _TotalRow(label: t.estimatedTotal, value: '₹${cart.subtotal}'),
          const SizedBox(height: 8),
          Text(t.finalPriceNotice),
          if (hasPriceChange)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: FilledButton.tonalIcon(
                onPressed: () =>
                    ref.read(cartProvider.notifier).acknowledgePriceChanges(),
                icon: const Icon(Icons.check_circle_outline),
                label: Text(t.acknowledgePrices),
              ),
            )
        ]),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      );
}

class _ValidationBadge extends StatelessWidget {
  const _ValidationBadge({required this.validation});
  final CartItemValidation validation;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final message = switch (validation) {
      CartItemValidation.priceChanged => t.priceUpdated,
      CartItemValidation.priceUnavailable => t.priceUnavailable,
      CartItemValidation.productUnavailable => t.productUnavailable,
      CartItemValidation.minimumQuantityInvalid => t.minimumOrderInvalid,
      CartItemValidation.locationChanged => t.cartPricesChanged,
      CartItemValidation.valid => '',
    };
    return Semantics(
      label: message,
      child: InputChip(
        avatar: const Icon(Icons.warning_amber_outlined, size: 18),
        label: Text(message),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({this.url});
  final String? url;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 64,
        height: 64,
        child: BmImage(source: url, borderRadius: 8),
      );
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.t});
  final AppLocalizations t;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.shopping_cart_outlined, size: 56),
            const SizedBox(height: 12),
            Text(t.cartEmpty, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(t.emptyCartMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
                onPressed: () => context.go('/home'),
                child: Text(t.browseMaterials)),
          ]),
        ),
      );
}
