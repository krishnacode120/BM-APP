import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/order.dart';
import '../../core/widgets/bm_components.dart';
import '../cart/cart_notifier.dart';
import '../catalog/catalog_providers.dart';
import '../notifications/notification_providers.dart';
import '../auth/auth_providers.dart';
import '../settings/contact_bm.dart';
import 'order_providers.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  bool profileApplied = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final cart = ref.watch(cartProvider);
    final checkout = ref.watch(checkoutProvider);
    final location = ref.watch(selectedLocationProvider).valueOrNull;
    final customer = ref.watch(currentCustomerProvider).valueOrNull;
    if (!profileApplied && customer != null) {
      profileApplied = true;
      Future<void>.microtask(() {
        if (!mounted) return;
        final notifier = ref.read(checkoutProvider.notifier);
        notifier.updateCustomerName(customer.name);
        notifier.updatePhoneNumber(customer.phoneNumber);
      });
    }
    return Scaffold(
      appBar: AppBar(title: Text(t.submitOrder)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _SectionTitle(t.deliveryLocation),
        ListTile(
          leading: const Icon(Icons.location_on_outlined),
          title: Text(location?.displayName ?? t.selectLocation),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/locations'),
        ),
        _SectionTitle(t.customerDetails),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.person_outline_rounded),
          title: Text(customer?.name ?? t.customerName),
          subtitle: Text(customer?.phoneNumber ?? t.signInRequired),
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
        _SectionTitle(t.orderSummary),
        for (final item in cart.items)
          ListTile(
            title: Text(item.productName),
            subtitle: Text('${item.quantity} ${t.unitLabel(item.unit.name)}'),
            trailing: Text('₹${item.subtotal}'),
          ),
        const Divider(),
        _CheckoutRow(label: t.estimatedTotal, value: '₹${cart.subtotal}'),
        const SizedBox(height: 8),
        Text(t.finalPriceNotice),
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
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(t.confirmOrder),
                      content: Text(t.confirmOrderMessage),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: Text(t.cancel),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: Text(t.submitOrder),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) return;
                  final order =
                      await ref.read(checkoutProvider.notifier).submit(cart);
                  if (order != null && context.mounted) {
                    unawaited(_registerOrderNotifications());
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
          label: Text(checkout.isSubmitting ? t.placingOrder : t.submitOrder),
        ),
      ),
    );
  }

  Future<void> _registerOrderNotifications() async {
    try {
      await ref
          .read(notificationServiceProvider)
          .requestPermissionAndRegister();
    } catch (_) {
      // Order success never depends on notification transport availability.
    }
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
                itemBuilder: (_, index) => BmEntrance(
                  delay: Duration(milliseconds: (index * 35).clamp(0, 280)),
                  child: _OrderCard(order: items[index]),
                ),
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

class OrderSuccessPage extends StatefulWidget {
  const OrderSuccessPage({required this.order, super.key});
  final BmOrder order;

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage> {
  bool visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final order = widget.order;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 420),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: .5, end: visible ? 1 : .5),
                duration: const Duration(milliseconds: 520),
                curve: Curves.elasticOut,
                builder: (_, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: const Icon(Icons.check_circle_rounded,
                    size: 82, color: Color(0xFF2D8A52)),
              ),
              const SizedBox(height: 16),
              Text(t.orderSubmitted,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(order.orderNumber,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('${t.estimatedTotal}: ₹${order.estimatedSubtotal}'),
              const SizedBox(height: 16),
              Text(t.orderSuccessMessage, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              const CallAdminButton(),
              const SizedBox(height: 10),
              FilledButton(
                  onPressed: () => context.go('/orders/${order.id}'),
                  child: Text(t.viewOrder)),
              TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text(t.continueShopping)),
            ]),
          ),
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
          label: order.finalTotal == null ? t.estimatedTotal : t.finalTotal,
          value: '₹${order.displayTotal}'),
      const SizedBox(height: 16),
      Text('${t.customerName}: ${order.customerName}'),
      Text('${t.deliveryLocation}: ${order.locationName}'),
      if (order.deliveryAddress.isNotEmpty)
        Text('${t.address}: ${order.deliveryAddress}'),
      Text('${t.phoneNumber}: ${order.phoneNumber}'),
      Text('${t.orderDate}: ${_date(order.createdAt)}'),
      Text('${t.payment}: ${t.paymentStatus(order.paymentStatus.name)}'),
      if (order.customerNote?.isNotEmpty == true)
        Text('${t.orderNote}: ${order.customerNote}'),
      const SizedBox(height: 16),
      const CallAdminButton(),
      const SizedBox(height: 10),
      const ContactBmButton(compact: true),
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
        subtitle: Text(
          '${_date(order.createdAt)} · ${order.items.length} ${t.orders}\n'
          '${t.orderStatus(order.orderStatus.name)} · ${t.paymentStatus(order.paymentStatus.name)}',
        ),
        isThreeLine: true,
        trailing: Text('₹${order.displayTotal}'),
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
    if (status == OrderStatus.cancelled) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.cancel_outlined),
        title: Text(t.orderStatus(status.name)),
      );
    }
    const flow = <OrderStatus>[
      OrderStatus.pending,
      OrderStatus.verified,
      OrderStatus.confirmed,
      OrderStatus.processing,
      OrderStatus.ready,
      OrderStatus.completed,
    ];
    final currentIndex = flow.indexOf(status);
    final steps = flow.take(currentIndex + 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final step in steps)
          ListTile(
            leading: const Icon(Icons.radio_button_checked),
            title: Text(t.orderStatus(step.name)),
          )
      ],
    );
  }
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

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
