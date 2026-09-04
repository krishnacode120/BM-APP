part of 'admin_pages.dart';

class AdminCustomersPage extends ConsumerStatefulWidget {
  const AdminCustomersPage({super.key});

  @override
  ConsumerState<AdminCustomersPage> createState() => _AdminCustomersPageState();
}

class _AdminCustomersPageState extends ConsumerState<AdminCustomersPage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final t = adminText(context);
    return AdminPageFrame(
      title: t.customerManagement,
      child: ref.watch(adminUsersProvider).when(
            loading: () => const BmAdminSkeleton(),
            error: (_, __) => BmEmptyState(
              title: t.unableUsers,
              actionLabel: t.tryAgain,
              onAction: () => ref.invalidate(adminUsersProvider),
            ),
            data: (users) {
              final normalized = query.trim().toLowerCase();
              final visible = users
                  .where((user) =>
                      normalized.isEmpty ||
                      user.name.toLowerCase().contains(normalized) ||
                      user.phoneNumber.contains(normalized))
                  .toList();
              return Column(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: TextField(
                    onChanged: (value) => setState(() => query = value),
                    decoration: InputDecoration(
                      labelText: t.searchCustomers,
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                Expanded(
                  child: visible.isEmpty
                      ? BmEmptyState(title: t.noCustomers)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: visible.length,
                          itemBuilder: (_, index) {
                            final user = visible[index];
                            return Card(
                              child: ListTile(
                                minTileHeight: 74,
                                leading: const CircleAvatar(
                                  backgroundColor: BmColors.lightOrange,
                                  child: Icon(Icons.person_outline_rounded,
                                      color: BmColors.orange),
                                ),
                                title: Text(user.name.isEmpty
                                    ? t.unnamedCustomer
                                    : user.name),
                                subtitle: Text(
                                  '${user.phoneNumber}\n${user.phoneVerified ? t.phoneVerified : t.phoneNotVerified}',
                                ),
                                isThreeLine: true,
                                trailing: BmStatusChip(
                                  label: user.isActive ? t.active : t.inactive,
                                  tone: user.isActive
                                      ? BmStatusTone.success
                                      : BmStatusTone.neutral,
                                ),
                                onTap: () => showModalBottomSheet<void>(
                                  context: context,
                                  isScrollControlled: true,
                                  showDragHandle: true,
                                  builder: (_) => FractionallySizedBox(
                                    heightFactor: .86,
                                    child: _CustomerDetail(user: user),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ]);
            },
          ),
    );
  }
}

class _CustomerDetail extends ConsumerWidget {
  const _CustomerDetail({required this.user});
  final AdminUserSummary user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = adminText(context);
    final orders = ref.watch(adminUserOrdersProvider(user.id));
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(user.name.isEmpty ? t.unnamedCustomer : user.name,
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(user.phoneNumber),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => launchBmUri(
            context,
            Uri(scheme: 'tel', path: user.phoneNumber),
          ),
          icon: const Icon(Icons.call_rounded),
          label: Text(t.callCustomer),
        ),
        const SizedBox(height: 18),
        Text(t.orderHistory, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Expanded(
          child: orders.when(
            loading: () => const BmLoading(),
            error: (_, __) => BmEmptyState(title: t.unableOrders),
            data: (items) => items.isEmpty
                ? BmEmptyState(title: t.noOrders)
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, index) {
                      final order = items[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(order.orderNumber),
                        subtitle: Text(t.orderStatus(order.orderStatus.name)),
                        trailing: Text('₹${_money(order.displayTotal)}'),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/admin/orders/${order.id}');
                        },
                      );
                    },
                  ),
          ),
        ),
      ]),
    );
  }
}
