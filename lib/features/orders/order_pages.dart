import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/order.dart';
import '../cart/cart_notifier.dart';
import '../catalog/catalog_providers.dart';
import '../settings/contact_bm.dart';
import 'order_providers.dart';

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final cart = ref.watch(cartProvider);
    final checkout = ref.watch(checkoutProvider);
    final location = ref.watch(selectedLocationProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(t.checkout)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _SectionTitle(t.deliveryLocation),
        ListTile(
          leading: const Icon(Icons.location_on_outlined),
          title: Text(location?.displayName ?? t.selectLocation),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/locations'),
        ),
        _SectionTitle(t.customerName),
        TextField(
          decoration: InputDecoration(labelText: t.customerName),
          onChanged: ref.read(checkoutProvider.notifier).updateCustomerName,
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(labelText: t.phoneNumber),
          keyboardType: TextInputType.phone,
          onChanged: ref.read(checkoutProvider.notifier).updatePhoneNumber,
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(labelText: t.address),
          minLines: 2,
          maxLines: 3,
          onChanged: ref.read(checkoutProvider.notifier).updateDeliveryAddress,
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(labelText: t.orderNote),
          maxLength: 500,
          minLines: 2,
          maxLines: 4,
          onChanged: ref.read(checkoutProvider.notifier).updateCustomerNote,
        ),
        _SectionTitle(t.orders),
        for (final item in cart.items)
          ListTile(
            title: Text(item.productName),
            subtitle: Text('${item.quantity} ${t.unitLabel(item.unit.name)}'),
            trailing: Text('₹${item.subtotal}'),
          ),
        const Divider(),
        _CheckoutRow(label: t.estimatedTotal, value: '₹${cart.subtotal}'),
        const SizedBox(height: 8),
        Text(t.paymentNotice),
        const SizedBox(height: 8),
        const ContactBmButton(compact: true),
        if (checkout.errorCode != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(t.orderError(checkout.errorCode!),
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
      ]),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: checkout.isSubmitting ||
                  !checkout.detailsValid ||
                  !cart.canCheckout
              ? null
              : () async {
                  final order =
                      await ref.read(checkoutProvider.notifier).submit(cart);
                  if (order != null && context.mounted) {
                    context.go('/order-success', extra: order);
                  }
                },
          icon: checkout.isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.lock_outline),
          label: Text(checkout.isSubmitting ? t.placingOrder : t.placeOrder),
        ),
      ),
    );
  }
}

class OrderHistoryPage extends ConsumerWidget {
  const OrderHistoryPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final orders = ref.watch(ordersProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.orderHistory)),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(t.somethingWentWrong)),
        data: (items) => items.isEmpty
            ? Center(child: Text(t.noOrders))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (_, index) => _OrderCard(order: items[index]),
              ),
      ),
    );
  }
}

class OrderDetailPage extends ConsumerWidget {
  const OrderDetailPage({required this.orderId, super.key});
  final String orderId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final order = ref.watch(orderProvider(orderId));
    return Scaffold(
      appBar: AppBar(title: Text(t.orderDetails)),
      body: order.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(t.somethingWentWrong)),
        data: (value) => value == null
            ? Center(child: Text(t.somethingWentWrong))
            : OrderDetailBody(order: value),
      ),
    );
  }
}

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({required this.order, super.key});
  final BmOrder order;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.check_circle_outline, size: 72),
            const SizedBox(height: 16),
            Text(t.orderSubmitted,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(order.orderNumber,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('${t.estimatedTotal}: ₹${order.estimatedSubtotal}'),
            const SizedBox(height: 16),
            Text(t.finalPriceNotice, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(
                onPressed: () => context.go('/orders/${order.id}'),
                child: Text(t.viewOrder)),
            TextButton(
                onPressed: () => context.go('/home'),
                child: Text(t.continueShopping)),
          ]),
        ),
      ),
    );
  }
}

class OrderDetailBody extends StatelessWidget {
  const OrderDetailBody({required this.order, super.key});
  final BmOrder order;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(order.orderNumber, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      InputChip(label: Text(t.orderStatus(order.orderStatus.name))),
      const SizedBox(height: 16),
      _Timeline(status: order.orderStatus),
      const Divider(),
      for (final item in order.items)
        ListTile(
          title: Text(item.productName),
          subtitle: Text('${item.quantity} ${t.unitLabel(item.unit.name)}'),
          trailing: Text('₹${item.subtotal}'),
        ),
      const Divider(),
      _CheckoutRow(
          label: t.estimatedTotal, value: '₹${order.estimatedSubtotal}'),
      const SizedBox(height: 16),
      Text('${t.deliveryLocation}: ${order.locationName}'),
      if (order.deliveryAddress.isNotEmpty)
        Text('${t.address}: ${order.deliveryAddress}'),
      Text('${t.phoneNumber}: ${order.phoneNumber}'),
      Text('${t.paymentPending}: ${t.paymentStatus(order.paymentStatus.name)}'),
      if (order.customerNote?.isNotEmpty == true)
        Text('${t.orderNote}: ${order.customerNote}'),
      const SizedBox(height: 16),
      const ContactBmButton(),
    ]);
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final BmOrder order;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.receipt_long_outlined),
        title: Text(order.orderNumber),
        subtitle: Text('${order.items.length} ${t.orders}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('₹${order.estimatedSubtotal}'),
            Text(t.orderStatus(order.orderStatus.name)),
          ],
        ),
        onTap: () => context.push('/orders/${order.id}'),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.status});
  final OrderStatus status;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final steps = <OrderStatus>[OrderStatus.pending, status];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final step in steps.toSet())
          ListTile(
            leading: const Icon(Icons.radio_button_checked),
            title: Text(t.orderStatus(step.name)),
          )
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _CheckoutRow extends StatelessWidget {
  const _CheckoutRow({required this.label, required this.value});
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
