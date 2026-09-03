import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/bm_components.dart';
import '../../l10n/app_localizations.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../repositories/admin_repository.dart';
import 'admin_providers.dart';

AppLocalizations _adminText(BuildContext context) =>
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
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const BmLogo(width: 100),
                const SizedBox(height: 24),
                Text(AppLocalizations.maybeOf(context)?.adminDenied ??
                    'You are not authorized to access BM Admin.'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go('/admin/login'),
                  child: Text(AppLocalizations.maybeOf(context)?.admin ??
                      'Admin login'),
                ),
              ],
            ),
          ),
        ),
      );
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
    final t = _adminText(context);
    final pages = <Widget>[
      const AdminDashboardPage(),
      const AdminOrdersPage(),
      const AdminProductsPage(),
      const AdminCategoriesPage(),
      const AdminUsersPage(),
      const AdminDeliveryPage(),
      const AdminApprovalsPage(),
      const AdminAuditPage(),
      const AdminReportsPage(),
      const AdminSettingsPage(),
    ];
    final destinations = <({IconData icon, String label})>[
      (icon: Icons.dashboard_outlined, label: t.dashboard),
      (icon: Icons.receipt_long_outlined, label: t.orders),
      (icon: Icons.inventory_2_outlined, label: t.products),
      (icon: Icons.category_outlined, label: t.categories),
      (icon: Icons.people_outline, label: t.users),
      (icon: Icons.local_shipping_outlined, label: t.delivery),
      (icon: Icons.fact_check_outlined, label: t.approvals),
      (icon: Icons.history_outlined, label: t.audit),
      (icon: Icons.sync_outlined, label: t.reports),
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

class AdminDeliveryPage extends StatelessWidget {
  const AdminDeliveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = _adminText(context);
    return _AdminPage(
      title: t.delivery,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          BmEmptyState(
            title: t.delivery,
            message: t.deliveryIntegrationPending,
            icon: Icons.local_shipping_outlined,
          ),
        ],
      ),
    );
  }
}

class AdminApprovalsPage extends StatelessWidget {
  const AdminApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = _adminText(context);
    return _AdminPage(
      title: t.approvals,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          BmEmptyState(
            title: t.approvals,
            message: t.noPendingApprovals,
            icon: Icons.fact_check_outlined,
          ),
        ],
      ),
    );
  }
}

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = _adminText(context);
    final dashboard = ref.watch(adminDashboardProvider);
    return _AdminPage(
      title: t.dashboard,
      child: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(t.unableDashboard)),
        data: (data) => ListView(padding: const EdgeInsets.all(24), children: [
          Wrap(spacing: 12, runSpacing: 12, children: [
            _Metric(t.ordersToday, data.ordersToday),
            _Metric(t.pending, data.pendingOrders),
            _Metric(t.processing, data.processingOrders),
            _Metric(t.delivered, data.deliveredOrders),
            _Metric(t.lowStock, data.lowStockProducts),
            _Metric(t.outOfStock, data.outOfStockProducts),
          ]),
          const SizedBox(height: 24),
          Text(t.recentOrders, style: Theme.of(context).textTheme.titleLarge),
          for (final order in data.recentOrders) _AdminOrderTile(order: order),
        ]),
      ),
    );
  }
}

class AdminOrdersPage extends ConsumerStatefulWidget {
  const AdminOrdersPage({super.key});
  @override
  ConsumerState<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class AdminOrderDetailPage extends ConsumerWidget {
  const AdminOrderDetailPage({required this.orderId, super.key});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = _adminText(context);
    final order = ref.watch(adminOrderProvider(orderId));
    return Scaffold(
      appBar: AppBar(title: Text(t.orderDetails)),
      body: order.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(t.unableOrder)),
        data: (value) => value == null
            ? Center(child: Text(t.orderNotFound))
            : ListView(padding: const EdgeInsets.all(24), children: [
                Text(value.orderNumber,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text('${t.status}: ${t.orderStatus(value.orderStatus.name)}'),
                Text(
                    '${t.payment}: ${t.paymentStatus(value.paymentStatus.name)}'),
                Text('${t.location}: ${value.locationName}'),
                const Divider(height: 32),
                for (final item in value.items)
                  ListTile(
                    title: Text(item.productName),
                    subtitle: Text('${item.quantity} ${item.unit.name}'),
                    trailing: Text('₹${item.subtotal}'),
                  ),
              ]),
      ),
    );
  }
}

class _AdminOrdersPageState extends ConsumerState<AdminOrdersPage> {
  String? status;
  @override
  Widget build(BuildContext context) {
    final t = _adminText(context);
    final orders = ref.watch(adminOrdersProvider(status));
    return _AdminPage(
      title: t.orders,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<String?>(
            initialValue: status,
            decoration: InputDecoration(labelText: t.status),
            items: [
              DropdownMenuItem(value: null, child: Text(t.all)),
              DropdownMenuItem(
                  value: 'pending', child: Text(t.orderStatus('pending'))),
              DropdownMenuItem(
                  value: 'confirmed', child: Text(t.orderStatus('confirmed'))),
              DropdownMenuItem(
                  value: 'processing',
                  child: Text(t.orderStatus('processing'))),
              DropdownMenuItem(
                  value: 'ready', child: Text(t.orderStatus('ready'))),
              DropdownMenuItem(
                  value: 'outForDelivery',
                  child: Text(t.orderStatus('outForDelivery'))),
              DropdownMenuItem(
                  value: 'delivered', child: Text(t.orderStatus('delivered'))),
              DropdownMenuItem(
                  value: 'cancelled', child: Text(t.orderStatus('cancelled'))),
            ],
            onChanged: (value) => setState(() => status = value),
          ),
        ),
        Expanded(
          child: orders.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(child: Text(t.unableOrders)),
            data: (items) => ListView(children: [
              for (final order in items)
                _AdminOrderTile(order: order, editable: true),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _AdminOrderTile extends ConsumerWidget {
  const _AdminOrderTile({required this.order, this.editable = false});
  final BmOrder order;
  final bool editable;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = _adminText(context);
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.receipt_long_outlined),
        title: Text(order.orderNumber),
        subtitle: Text('${order.customerName} · ${order.phoneNumber}'),
        trailing: Text('₹${order.estimatedSubtotal}'),
        children: editable
            ? [
                Wrap(spacing: 8, children: [
                  for (final status in OrderStatus.values)
                    ActionChip(
                      label: Text(t.orderStatus(status.name)),
                      onPressed: () async {
                        await ref
                            .read(adminRepositoryProvider)
                            .updateOrderStatus(order.id, status);
                        ref.invalidate(adminOrdersProvider);
                        ref.invalidate(adminDashboardProvider);
                      },
                    ),
                ]),
                Wrap(spacing: 8, children: [
                  for (final status in PaymentStatus.values)
                    ActionChip(
                      label: Text(t.paymentStatus(status.name)),
                      onPressed: () async {
                        await ref
                            .read(adminRepositoryProvider)
                            .updatePaymentStatus(order.id, status);
                        ref.invalidate(adminOrdersProvider);
                      },
                    ),
                ]),
              ]
            : const [],
      ),
    );
  }
}

class AdminProductsPage extends ConsumerWidget {
  const AdminProductsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = _adminText(context);
    final products = ref.watch(adminProductsProvider);
    return _AdminPage(
      title: t.products,
      action: FilledButton.icon(
          onPressed: () => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(t.trustedCatalogNotice))),
          icon: const Icon(Icons.add),
          label: Text(t.addProduct)),
      child: products.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(t.unableProducts)),
        data: (items) => ListView(children: [
          for (final product in items) _ProductAdminTile(product: product),
        ]),
      ),
    );
  }
}

class _ProductAdminTile extends ConsumerWidget {
  const _ProductAdminTile({required this.product});
  final Product product;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = _adminText(context);
    return Card(
      child: ListTile(
        title: Text(product.name),
        subtitle: Text(
            '${product.categoryId} · ${t.inventoryLabel(product.inventoryStatus.name)}'),
        trailing: DropdownButton<InventoryStatus>(
          value: product.inventoryStatus,
          items: [
            for (final status in InventoryStatus.values)
              DropdownMenuItem(
                  value: status, child: Text(t.inventoryLabel(status.name))),
          ],
          onChanged: (status) async {
            if (status == null) return;
            await ref.read(adminRepositoryProvider).updateInventoryStatus(
                product.id, status, product.stockQuantity);
            ref.invalidate(adminProductsProvider);
            ref.invalidate(adminDashboardProvider);
          },
        ),
      ),
    );
  }
}

class AdminCategoriesPage extends ConsumerWidget {
  const AdminCategoriesPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = _adminText(context);
    final categories = ref.watch(adminCategoriesProvider);
    return _AdminPage(
      title: t.categories,
      child: categories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(t.unableCategories)),
        data: (items) => ListView(children: [
          for (final category in items)
            ListTile(
                title: Text(category.name),
                subtitle: Text('${t.sortOrder} ${category.sortOrder}')),
        ]),
      ),
    );
  }
}

class AdminUsersPage extends ConsumerWidget {
  const AdminUsersPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = _adminText(context);
    final users = ref.watch(adminUsersProvider);
    return _AdminPage(
      title: t.users,
      child: users.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(t.unableUsers)),
        data: (items) => ListView(children: [
          for (final user in items)
            ListTile(
              leading: const Icon(Icons.person_outline),
              title:
                  Text(user.phoneNumber.isEmpty ? user.id : user.phoneNumber),
              subtitle: Text(user.role),
            ),
        ]),
      ),
    );
  }
}

class AdminAuditPage extends ConsumerWidget {
  const AdminAuditPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = _adminText(context);
    final logs = ref.watch(adminAuditLogsProvider);
    return _AdminPage(
      title: t.auditLogs,
      child: logs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(t.unableAudit)),
        data: (items) => ListView(children: [
          for (final log in items)
            ListTile(
              leading: const Icon(Icons.history_outlined),
              title: Text(log.action),
              subtitle: Text(
                  '${log.entityType}/${log.entityId} · ${log.actorUserId}'),
            ),
        ]),
      ),
    );
  }
}

class AdminReportsPage extends ConsumerWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = _adminText(context);
    final reporting = ref.watch(adminReportingProvider);
    return _AdminPage(
      title: t.reportsAndSync,
      action: OutlinedButton.icon(
        onPressed: () async {
          try {
            final csv =
                await ref.read(adminRepositoryProvider).exportOrdersCsv();
            await Clipboard.setData(ClipboardData(text: csv));
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(t.csvCopied)));
            }
          } on AdminFailure {
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(t.csvError)));
            }
          }
        },
        icon: const Icon(Icons.download_outlined),
        label: Text(t.copyOrdersCsv),
      ),
      child: reporting.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(t.unableSync)),
        data: (data) => ListView(padding: const EdgeInsets.all(24), children: [
          Wrap(spacing: 12, runSpacing: 12, children: [
            _Metric(t.totalOrders, data.totalOrders),
            _Metric(t.synced, data.synced),
            _Metric(t.pending, data.pending),
            _Metric(t.failed, data.failed),
          ]),
          const SizedBox(height: 24),
          Text(t.reportingSync, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(t.reportingSourceTruth),
          const SizedBox(height: 12),
          for (final job in data.recentJobs)
            Card(
              child: ListTile(
                leading: Icon(job.needsAttention
                    ? Icons.error_outline
                    : Icons.sync_outlined),
                title: Text(job.orderNumber ?? job.orderId),
                subtitle: Text(
                    '${job.status.name} · attempts: ${job.attemptCount}'
                    '${job.lastError == null ? '' : ' · ${job.lastError}'}'),
                trailing: job.needsAttention
                    ? TextButton(
                        onPressed: () async {
                          await ref
                              .read(adminRepositoryProvider)
                              .retryReportSync(job.orderId);
                          ref.invalidate(adminReportingProvider);
                        },
                        child: Text(t.retrySync),
                      )
                    : null,
              ),
            ),
        ]),
      ),
    );
  }
}

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final t = _adminText(context);
    return _AdminPage(
      title: t.settings,
      child: Center(child: Text(t.settingsFoundation)),
    );
  }
}

class _AdminPage extends StatelessWidget {
  const _AdminPage({required this.title, required this.child, this.action});
  final String title;
  final Widget child;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            if (action != null) action!,
          ]),
        ),
        Expanded(child: child),
      ]);
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 180,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label),
              const SizedBox(height: 8),
              Text('$value', style: Theme.of(context).textTheme.headlineSmall),
            ]),
          ),
        ),
      );
}
