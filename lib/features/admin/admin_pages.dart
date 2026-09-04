import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/bm_theme.dart';
import '../../core/widgets/bm_components.dart';
import '../../l10n/app_localizations.dart';
import '../../models/business_settings.dart';
import '../../models/category.dart';
import '../../models/location.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../models/report_sync.dart';
import '../../repositories/admin_repository.dart';
import '../../repositories/product_media_repository.dart';
import '../notifications/notification_providers.dart';
import '../settings/business_settings_providers.dart';
import '../settings/contact_bm.dart';
import 'admin_providers.dart';

part 'admin_categories_page.dart';
part 'admin_customers_page.dart';
part 'admin_products_page.dart';
part 'admin_reports_page.dart';
part 'admin_settings_page.dart';

AppLocalizations adminText(BuildContext context) =>
    AppLocalizations.maybeOf(context) ?? AppLocalizations(const Locale('en'));

class AdminGatePage extends ConsumerWidget {
  const AdminGatePage({this.orderId, super.key});
  final String? orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(adminAccessProvider);
    return access.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const _AdminDenied(),
      data: (allowed) => !allowed
          ? const _AdminDenied()
          : orderId == null
              ? const AdminShell()
              : AdminOrderDetailPage(orderId: orderId!),
    );
  }
}

class _AdminDenied extends StatelessWidget {
  const _AdminDenied();

  @override
  Widget build(BuildContext context) {
    final t = adminText(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const BmLogo(width: 100),
              const SizedBox(height: 24),
              Text(t.adminDenied, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/admin/login'),
                child: Text(t.adminLogin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final t = adminText(context);
    const pages = <Widget>[
      AdminDashboardPage(),
      AdminOrdersPage(),
      AdminCustomersPage(),
      AdminProductsPage(),
      AdminCategoriesPage(),
      AdminReportsPage(),
      AdminSettingsPage(),
    ];
    final destinations = <({IconData icon, String label})>[
      (icon: Icons.dashboard_outlined, label: t.dashboard),
      (icon: Icons.receipt_long_outlined, label: t.orders),
      (icon: Icons.people_outline_rounded, label: t.customers),
      (icon: Icons.inventory_2_outlined, label: t.products),
      (icon: Icons.category_outlined, label: t.categories),
      (icon: Icons.bar_chart_rounded, label: t.reports),
      (icon: Icons.settings_outlined, label: t.settings),
    ];
    return LayoutBuilder(
      builder: (_, constraints) {
        if (constraints.maxWidth < 850) {
          return Scaffold(
            appBar: AppBar(
              title: Row(children: <Widget>[
                const BmLogo(width: 58),
                const SizedBox(width: 10),
                Expanded(child: Text(destinations[index].label)),
              ]),
            ),
            drawer: NavigationDrawer(
              selectedIndex: index,
              onDestinationSelected: (value) {
                setState(() => index = value);
                Navigator.pop(context);
              },
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.fromLTRB(28, 28, 28, 14),
                  child: BmLogo(width: 86),
                ),
                for (final destination in destinations)
                  NavigationDrawerDestination(
                    icon: Icon(destination.icon),
                    label: Text(destination.label),
                  ),
              ],
            ),
            body: pages[index],
          );
        }
        return Scaffold(
          body: Row(children: <Widget>[
            NavigationRail(
              selectedIndex: index,
              onDestinationSelected: (value) => setState(() => index = value),
              labelType: constraints.maxWidth > 1120
                  ? NavigationRailLabelType.all
                  : NavigationRailLabelType.selected,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: BmLogo(mark: true, width: 42),
              ),
              destinations: <NavigationRailDestination>[
                for (final destination in destinations)
                  NavigationRailDestination(
                    icon: Icon(destination.icon),
                    label: Text(destination.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: pages[index]),
          ]),
        );
      },
    );
  }
}

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = adminText(context);
    return AdminPageFrame(
      title: t.dashboard,
      action: IconButton(
        tooltip: t.refresh,
        onPressed: () => ref.invalidate(adminDashboardProvider),
        icon: const Icon(Icons.refresh_rounded),
      ),
      child: ref.watch(adminDashboardProvider).when(
            loading: () => const BmAdminSkeleton(),
            error: (_, __) => BmEmptyState(
              title: t.unableDashboard,
              actionLabel: t.tryAgain,
              onAction: () => ref.invalidate(adminDashboardProvider),
            ),
            data: (data) => ListView(
              padding: const EdgeInsets.all(24),
              children: <Widget>[
                Wrap(spacing: 12, runSpacing: 12, children: <Widget>[
                  AdminMetric(t.ordersToday, '${data.ordersToday}',
                      Icons.today_outlined),
                  AdminMetric(t.totalOrders, '${data.totalOrders}',
                      Icons.receipt_long_outlined),
                  AdminMetric(t.pendingVerification, '${data.pendingOrders}',
                      Icons.fact_check_outlined),
                  AdminMetric(t.verifiedOrders, '${data.verifiedOrders}',
                      Icons.verified_outlined),
                  AdminMetric(t.processing, '${data.processingOrders}',
                      Icons.construction_outlined),
                  AdminMetric(t.completed, '${data.deliveredOrders}',
                      Icons.check_circle_outline_rounded),
                  AdminMetric(t.customers, '${data.totalCustomers}',
                      Icons.people_outline_rounded),
                  AdminMetric(t.products, '${data.totalProducts}',
                      Icons.inventory_2_outlined),
                  AdminMetric(t.availableProducts, '${data.activeProducts}',
                      Icons.check_box_outlined),
                  AdminMetric(t.todayRevenue, '₹${_money(data.todayRevenue)}',
                      Icons.currency_rupee_rounded),
                  AdminMetric(
                      t.recognizedRevenue,
                      '₹${_money(data.recognizedRevenue)}',
                      Icons.trending_up_rounded),
                  AdminMetric(t.paidOrders, '${data.paidOrders}',
                      Icons.payments_outlined),
                  AdminMetric(t.unpaidOrders, '${data.unpaidOrders}',
                      Icons.money_off_csred_outlined),
                  AdminMetric(
                      t.lowStock,
                      '${data.lowStockProducts + data.outOfStockProducts}',
                      Icons.warning_amber_rounded),
                ]),
                const SizedBox(height: 28),
                Text(t.recentOrders,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (data.recentOrders.isEmpty)
                  BmEmptyState(title: t.noOrders)
                else
                  for (final order in data.recentOrders)
                    AdminOrderTile(order: order),
              ],
            ),
          ),
    );
  }
}

class AdminOrdersPage extends ConsumerStatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  ConsumerState<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends ConsumerState<AdminOrdersPage> {
  String? status;

  @override
  Widget build(BuildContext context) {
    final t = adminText(context);
    final orders = ref.watch(adminOrdersProvider(status));
    return AdminPageFrame(
      title: t.orderManagement,
      child: Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: DropdownButtonFormField<String?>(
            initialValue: status,
            decoration: InputDecoration(labelText: t.filterByStatus),
            items: <DropdownMenuItem<String?>>[
              DropdownMenuItem(value: null, child: Text(t.all)),
              for (final item in OrderStatus.values)
                DropdownMenuItem(
                  value: item.name,
                  child: Text(t.orderStatus(item.name)),
                ),
            ],
            onChanged: (value) => setState(() => status = value),
          ),
        ),
        Expanded(
          child: orders.when(
            loading: () => const BmAdminSkeleton(),
            error: (_, __) => BmEmptyState(
              title: t.unableOrders,
              actionLabel: t.tryAgain,
              onAction: () => ref.invalidate(adminOrdersProvider(status)),
            ),
            data: (items) => items.isEmpty
                ? BmEmptyState(title: t.noOrders)
                : RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(adminOrdersProvider(status)),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: items.length,
                      itemBuilder: (_, index) => AdminOrderTile(
                        order: items[index],
                        editable: true,
                      ),
                    ),
                  ),
          ),
        ),
      ]),
    );
  }
}

class AdminOrderDetailPage extends ConsumerWidget {
  const AdminOrderDetailPage({required this.orderId, super.key});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = adminText(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.orderDetails)),
      body: ref.watch(adminOrderProvider(orderId)).when(
            loading: () => const BmLoading(),
            error: (_, __) => BmEmptyState(title: t.unableOrder),
            data: (order) => order == null
                ? BmEmptyState(title: t.orderNotFound)
                : _AdminOrderDetail(order: order),
          ),
    );
  }
}

class _AdminOrderDetail extends ConsumerWidget {
  const _AdminOrderDetail({required this.order});
  final BmOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = adminText(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        Row(children: <Widget>[
          Expanded(
            child: Text(order.orderNumber,
                style: Theme.of(context).textTheme.headlineSmall),
          ),
          BmStatusChip(label: t.orderStatus(order.orderStatus.name)),
        ]),
        const SizedBox(height: 12),
        Text('${t.customerName}: ${order.customerName}'),
        Text('${t.phoneNumber}: ${order.phoneNumber}'),
        Text('${t.location}: ${order.locationName}'),
        if (order.deliveryAddress.isNotEmpty)
          Text('${t.address}: ${order.deliveryAddress}'),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => launchBmUri(
            context,
            Uri(scheme: 'tel', path: order.phoneNumber),
          ),
          icon: const Icon(Icons.call_rounded),
          label: Text(t.callCustomer),
        ),
        const Divider(height: 32),
        for (final item in order.items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item.productName),
            subtitle: Text(
                '${item.quantity} ${t.unitLabel(item.unit.name)} × ₹${_money(item.priceAtOrder)}'),
            trailing: Text('₹${_money(item.subtotal)}'),
          ),
        const Divider(),
        _DetailRow(t.estimatedTotal, '₹${_money(order.estimatedSubtotal)}'),
        if (order.finalTotal != null)
          _DetailRow(t.finalTotal, '₹${_money(order.finalTotal!)}'),
        _DetailRow(t.payment, t.paymentStatus(order.paymentStatus.name)),
        if (order.customerNote?.isNotEmpty == true) ...<Widget>[
          const SizedBox(height: 16),
          Text('${t.orderNote}: ${order.customerNote}'),
        ],
        if (order.adminNote?.isNotEmpty == true)
          Text('${t.adminNote}: ${order.adminNote}'),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            for (final next in _nextStatuses(order.orderStatus))
              FilledButton.tonal(
                onPressed: () => _updateOrderStatus(context, ref, order, next),
                child: Text(t.orderStatus(next.name)),
              ),
            OutlinedButton.icon(
              onPressed: () => _editFinancials(context, ref, order),
              icon: const Icon(Icons.currency_rupee_rounded),
              label: Text(t.confirmFinalAmount),
            ),
            OutlinedButton.icon(
              onPressed: () => _editNote(context, ref, order),
              icon: const Icon(Icons.note_alt_outlined),
              label: Text(t.adminNote),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(t.paymentStatusLabel,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<PaymentStatus>(
          segments: <ButtonSegment<PaymentStatus>>[
            for (final status in PaymentStatus.values)
              ButtonSegment(
                value: status,
                label: Text(t.paymentStatus(status.name)),
              ),
          ],
          selected: <PaymentStatus>{order.paymentStatus},
          onSelectionChanged: (selection) =>
              _updatePayment(context, ref, order, selection.first),
        ),
      ],
    );
  }
}

class AdminOrderTile extends ConsumerWidget {
  const AdminOrderTile({required this.order, this.editable = false, super.key});
  final BmOrder order;
  final bool editable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = adminText(context);
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            minTileHeight: 82,
            leading: const CircleAvatar(
              backgroundColor: BmColors.lightOrange,
              child: Icon(Icons.receipt_long_outlined, color: BmColors.orange),
            ),
            title: Text(order.orderNumber),
            subtitle: Text(
              '${order.customerName} · ${t.orderStatus(order.orderStatus.name)}\n${order.phoneNumber}',
            ),
            isThreeLine: true,
            trailing: Text('₹${_money(order.displayTotal)}'),
            onTap: () => context.push('/admin/orders/${order.id}'),
          ),
          if (editable) ...<Widget>[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: () => launchBmUri(
                      context,
                      Uri(scheme: 'tel', path: order.phoneNumber),
                    ),
                    icon: const Icon(Icons.call_outlined),
                    label: Text(t.callCustomer),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/admin/orders/${order.id}'),
                    icon: const Icon(Icons.visibility_outlined),
                    label: Text(t.viewOrder),
                  ),
                  if (order.orderStatus == OrderStatus.pending)
                    FilledButton.icon(
                      onPressed: () => _updateOrderStatus(
                        context,
                        ref,
                        order,
                        OrderStatus.verified,
                      ),
                      icon: const Icon(Icons.verified_outlined),
                      label: Text(t.verifyOrder),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> _updateOrderStatus(BuildContext context, WidgetRef ref,
    BmOrder order, OrderStatus status) async {
  final t = adminText(context);
  final confirmed = await _confirm(
    context,
    t.updateOrderStatus,
    t.confirmStatusChange(t.orderStatus(status.name)),
  );
  if (!confirmed) return;
  try {
    await ref.read(adminRepositoryProvider).updateOrderStatus(order.id, status);
    ref.invalidate(adminOrdersProvider);
    ref.invalidate(adminOrderProvider(order.id));
    ref.invalidate(adminDashboardProvider);
  } on AdminFailure catch (error) {
    if (context.mounted) _showAdminError(context, error.code);
  }
}

Future<void> _updatePayment(BuildContext context, WidgetRef ref, BmOrder order,
    PaymentStatus status) async {
  if (status == order.paymentStatus) return;
  final t = adminText(context);
  final confirmed = await _confirm(
    context,
    t.updatePaymentStatus,
    t.confirmPaymentChange(t.paymentStatus(status.name)),
  );
  if (!confirmed) return;
  try {
    await ref
        .read(adminRepositoryProvider)
        .updatePaymentStatus(order.id, status);
    ref.invalidate(adminOrdersProvider);
    ref.invalidate(adminOrderProvider(order.id));
    ref.invalidate(adminDashboardProvider);
    ref.invalidate(adminReportingProvider);
  } on AdminFailure catch (error) {
    if (context.mounted) _showAdminError(context, error.code);
  }
}

Future<void> _editFinancials(
    BuildContext context, WidgetRef ref, BmOrder order) async {
  final t = adminText(context);
  final subtotal = TextEditingController(
      text: '${order.confirmedSubtotal ?? order.estimatedSubtotal}');
  final delivery = TextEditingController(text: '${order.deliveryCharge}');
  final values = await showDialog<(num, num)>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(t.confirmFinalAmount),
      content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        TextField(
          controller: subtotal,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: t.confirmedSubtotal),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: delivery,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: t.deliveryCharge),
        ),
      ]),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(t.cancel),
        ),
        FilledButton(
          onPressed: () {
            final a = num.tryParse(subtotal.text);
            final b = num.tryParse(delivery.text);
            if (a != null && a >= 0 && b != null && b >= 0) {
              Navigator.pop(dialogContext, (a, b));
            }
          },
          child: Text(t.save),
        ),
      ],
    ),
  );
  subtotal.dispose();
  delivery.dispose();
  if (values == null) return;
  try {
    await ref
        .read(adminRepositoryProvider)
        .updateOrderFinancials(order.id, values.$1, values.$2);
    ref.invalidate(adminOrderProvider(order.id));
    ref.invalidate(adminOrdersProvider);
    ref.invalidate(adminReportingProvider);
  } on AdminFailure catch (error) {
    if (context.mounted) _showAdminError(context, error.code);
  }
}

Future<void> _editNote(
    BuildContext context, WidgetRef ref, BmOrder order) async {
  final t = adminText(context);
  final controller = TextEditingController(text: order.adminNote ?? '');
  final note = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(t.adminNote),
      content: TextField(
        controller: controller,
        maxLength: 1000,
        minLines: 3,
        maxLines: 6,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(t.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
          child: Text(t.save),
        ),
      ],
    ),
  );
  controller.dispose();
  if (note == null) return;
  try {
    await ref.read(adminRepositoryProvider).updateAdminNote(order.id, note);
    ref.invalidate(adminOrderProvider(order.id));
  } on AdminFailure catch (error) {
    if (context.mounted) _showAdminError(context, error.code);
  }
}

List<OrderStatus> _nextStatuses(OrderStatus status) => switch (status) {
      OrderStatus.pending => <OrderStatus>[
          OrderStatus.verified,
          OrderStatus.cancelled,
        ],
      OrderStatus.verified => <OrderStatus>[
          OrderStatus.confirmed,
          OrderStatus.cancelled,
        ],
      OrderStatus.confirmed => <OrderStatus>[
          OrderStatus.processing,
          OrderStatus.cancelled,
        ],
      OrderStatus.processing => <OrderStatus>[
          OrderStatus.ready,
          OrderStatus.cancelled,
        ],
      OrderStatus.ready => <OrderStatus>[
          OrderStatus.completed,
          OrderStatus.cancelled,
        ],
      OrderStatus.completed || OrderStatus.cancelled => const <OrderStatus>[],
    };

Future<bool> _confirm(
    BuildContext context, String title, String message) async {
  final t = adminText(context);
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(t.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(t.confirm),
            ),
          ],
        ),
      ) ??
      false;
}

void _showAdminError(BuildContext context, String code) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(adminText(context).adminError(code))),
    );

class AdminPageFrame extends StatelessWidget {
  const AdminPageFrame({
    required this.title,
    required this.child,
    this.action,
    super.key,
  });
  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
          child: Row(children: <Widget>[
            Expanded(
              child:
                  Text(title, style: Theme.of(context).textTheme.headlineSmall),
            ),
            if (action != null) action!,
          ]),
        ),
        Expanded(child: child),
      ]);
}

class AdminMetric extends StatelessWidget {
  const AdminMetric(this.label, this.value, this.icon, {super.key});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 190,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(icon, color: BmColors.orange),
                const SizedBox(height: 12),
                Text(value, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(label),
              ],
            ),
          ),
        ),
      );
}

class BmAdminSkeleton extends StatefulWidget {
  const BmAdminSkeleton({super.key});

  @override
  State<BmAdminSkeleton> createState() => _BmAdminSkeletonState();
}

class _BmAdminSkeletonState extends State<BmAdminSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (_, __) => ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: 6,
          itemBuilder: (_, index) => Container(
            height: index == 0 ? 110 : 72,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: BmColors.border.withValues(
                alpha: .45 + (controller.value * .35),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: <Widget>[
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
      );
}

String _money(num value) =>
    value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
