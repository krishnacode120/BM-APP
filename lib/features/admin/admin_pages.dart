import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../models/order.dart';
import '../../models/product.dart';
import '../../repositories/admin_repository.dart';
import 'admin_providers.dart';

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
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('You are not authorized to access BM Admin.')),
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
    final pages = <Widget>[
      const AdminDashboardPage(),
      const AdminOrdersPage(),
      const AdminProductsPage(),
      const AdminCategoriesPage(),
      const AdminUsersPage(),
      const AdminAuditPage(),
      const AdminReportsPage(),
      const AdminSettingsPage(),
    ];
    return Scaffold(
      body: Row(children: [
        NavigationRail(
          selectedIndex: index,
          onDestinationSelected: (value) => setState(() => index = value),
          labelType: NavigationRailLabelType.all,
          destinations: const [
            NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined), label: Text('Dashboard')),
            NavigationRailDestination(
                icon: Icon(Icons.receipt_long_outlined), label: Text('Orders')),
            NavigationRailDestination(
                icon: Icon(Icons.inventory_2_outlined),
                label: Text('Products')),
            NavigationRailDestination(
                icon: Icon(Icons.category_outlined), label: Text('Categories')),
            NavigationRailDestination(
                icon: Icon(Icons.people_outline), label: Text('Users')),
            NavigationRailDestination(
                icon: Icon(Icons.history_outlined), label: Text('Audit')),
            NavigationRailDestination(
                icon: Icon(Icons.sync_outlined), label: Text('Reports')),
            NavigationRailDestination(
                icon: Icon(Icons.settings_outlined), label: Text('Settings')),
          ],
        ),
        const VerticalDivider(width: 1),
        Expanded(child: pages[index]),
      ]),
    );
  }
}

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(adminDashboardProvider);
    return _AdminPage(
      title: 'Dashboard',
      child: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Unable to load dashboard')),
        data: (data) => ListView(padding: const EdgeInsets.all(24), children: [
          Wrap(spacing: 12, runSpacing: 12, children: [
            _Metric('Orders Today', data.ordersToday),
            _Metric('Pending', data.pendingOrders),
            _Metric('Processing', data.processingOrders),
            _Metric('Delivered', data.deliveredOrders),
            _Metric('Low Stock', data.lowStockProducts),
            _Metric('Out of Stock', data.outOfStockProducts),
          ]),
          const SizedBox(height: 24),
          Text('Recent Orders', style: Theme.of(context).textTheme.titleLarge),
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
    final order = ref.watch(adminOrderProvider(orderId));
    return Scaffold(
      appBar: AppBar(title: const Text('Order details')),
      body: order.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Unable to load order')),
        data: (value) => value == null
            ? const Center(child: Text('Order not found'))
            : ListView(padding: const EdgeInsets.all(24), children: [
                Text(value.orderNumber,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text('Status: ${value.orderStatus.name}'),
                Text('Payment: ${value.paymentStatus.name}'),
                Text('Location: ${value.locationName}'),
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
    final orders = ref.watch(adminOrdersProvider(status));
    return _AdminPage(
      title: 'Orders',
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<String?>(
            initialValue: status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: null, child: Text('All')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
              DropdownMenuItem(value: 'processing', child: Text('Processing')),
              DropdownMenuItem(value: 'ready', child: Text('Ready')),
              DropdownMenuItem(
                  value: 'outForDelivery', child: Text('Out for Delivery')),
              DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
            onChanged: (value) => setState(() => status = value),
          ),
        ),
        Expanded(
          child: orders.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) =>
                const Center(child: Text('Unable to load orders')),
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
  Widget build(BuildContext context, WidgetRef ref) => Card(
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
                        label: Text(status.name),
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
                        label: Text(status.name),
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

class AdminProductsPage extends ConsumerWidget {
  const AdminProductsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(adminProductsProvider);
    return _AdminPage(
      title: 'Products',
      action: FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Add Product')),
      child: products.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Unable to load products')),
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
  Widget build(BuildContext context, WidgetRef ref) => Card(
        child: ListTile(
          title: Text(product.name),
          subtitle:
              Text('${product.categoryId} · ${product.inventoryStatus.name}'),
          trailing: DropdownButton<InventoryStatus>(
            value: product.inventoryStatus,
            items: [
              for (final status in InventoryStatus.values)
                DropdownMenuItem(value: status, child: Text(status.name)),
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

class AdminCategoriesPage extends ConsumerWidget {
  const AdminCategoriesPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(adminCategoriesProvider);
    return _AdminPage(
      title: 'Categories',
      child: categories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Unable to load categories')),
        data: (items) => ListView(children: [
          for (final category in items)
            ListTile(
                title: Text(category.name),
                subtitle: Text('Sort ${category.sortOrder}')),
        ]),
      ),
    );
  }
}

class AdminUsersPage extends ConsumerWidget {
  const AdminUsersPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(adminUsersProvider);
    return _AdminPage(
      title: 'Users',
      child: users.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Unable to load users')),
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
    final logs = ref.watch(adminAuditLogsProvider);
    return _AdminPage(
      title: 'Audit Logs',
      child: logs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Unable to load audit logs')),
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
    final reporting = ref.watch(adminReportingProvider);
    return _AdminPage(
      title: 'Reports & Sync',
      action: OutlinedButton.icon(
        onPressed: () async {
          try {
            final csv =
                await ref.read(adminRepositoryProvider).exportOrdersCsv();
            await Clipboard.setData(ClipboardData(text: csv));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Orders CSV copied to clipboard.')));
            }
          } on AdminFailure {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Unable to create CSV export.')));
            }
          }
        },
        icon: const Icon(Icons.download_outlined),
        label: const Text('Copy Orders CSV'),
      ),
      child: reporting.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Unable to load sync status')),
        data: (data) => ListView(padding: const EdgeInsets.all(24), children: [
          Wrap(spacing: 12, runSpacing: 12, children: [
            _Metric('Total Orders', data.totalOrders),
            _Metric('Synced', data.synced),
            _Metric('Pending', data.pending),
            _Metric('Failed', data.failed),
          ]),
          const SizedBox(height: 24),
          Text('Reporting sync', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
              'Firestore is the source of truth. Excel may update after a short delay.'),
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
                        child: const Text('Retry sync'),
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
  Widget build(BuildContext context) => const _AdminPage(
        title: 'Settings',
        child: Center(
            child: Text(
                'Business settings foundation: business phone, WhatsApp, support email, currency and maintenance mode.')),
      );
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
