import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/state/app_preferences.dart';
import '../../core/theme/bm_theme.dart';
import '../../core/widgets/bm_components.dart';
import '../../l10n/app_localizations.dart';
import '../settings/contact_bm.dart';

final wishlistProvider = StateNotifierProvider<WishlistController, Set<String>>(
    (ref) => WishlistController());

class WishlistController extends StateNotifier<Set<String>> {
  WishlistController() : super(<String>{}) {
    SharedPreferences.getInstance().then((prefs) {
      state = (prefs.getStringList('bm_wishlist') ?? <String>[]).toSet();
    });
  }

  Future<void> toggle(String id) async {
    state =
        state.contains(id) ? ({...state}..remove(id)) : <String>{...state, id};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bm_wishlist', state.toList());
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.profile)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: BmColors.peach,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: <Widget>[
                const CircleAvatar(
                  radius: 34,
                  backgroundColor: BmColors.orange,
                  child:
                      Icon(Icons.person_rounded, color: Colors.white, size: 34),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(t.account,
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(t.phoneLogin),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _ProfileTile(
              icon: Icons.receipt_long_outlined,
              label: t.orderHistory,
              route: '/orders'),
          _ProfileTile(
              icon: Icons.favorite_border_rounded,
              label: t.wishlist,
              route: '/wishlist'),
          _ProfileTile(
              icon: Icons.location_on_outlined,
              label: t.addresses,
              route: '/addresses'),
          _ProfileTile(
              icon: Icons.notifications_none_rounded,
              label: t.notifications,
              route: '/notifications'),
          _ProfileTile(
              icon: Icons.support_agent_rounded,
              label: t.support,
              route: '/support'),
          _ProfileTile(
              icon: Icons.settings_outlined,
              label: t.settings,
              route: '/settings'),
          _ProfileTile(
              icon: Icons.info_outline_rounded,
              label: t.about,
              route: '/about'),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.logout_rounded),
            label: Text(t.logout),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile(
      {required this.icon, required this.label, required this.route});
  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          minTileHeight: 62,
          leading: Icon(icon, color: BmColors.orange),
          title:
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(route),
        ),
      );
}

class WishlistPage extends ConsumerWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final ids = ref.watch(wishlistProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.wishlist)),
      body: ids.isEmpty
          ? BmEmptyState(
              title: t.noWishlist,
              message: t.noWishlistBody,
              icon: Icons.favorite_border_rounded,
              actionLabel: t.startShopping,
              onAction: () => context.go('/home'),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: ids
                  .map((id) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.favorite_rounded,
                              color: BmColors.orange),
                          title: Text(id.replaceAll('-', ' ')),
                          trailing: IconButton(
                            tooltip: t.clear,
                            onPressed: () =>
                                ref.read(wishlistProvider.notifier).toggle(id),
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                          onTap: () => context.push('/product/$id'),
                        ),
                      ))
                  .toList(),
            ),
    );
  }
}

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  List<String> addresses = <String>[];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (mounted) {
        setState(() =>
            addresses = prefs.getStringList('bm_addresses') ?? <String>[]);
      }
    });
  }

  Future<void> _add() async {
    final t = AppLocalizations.of(context);
    final name = TextEditingController();
    final details = TextEditingController();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(t.addAddress, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
                controller: name,
                decoration: InputDecoration(labelText: t.addressName)),
            const SizedBox(height: 12),
            TextField(
                controller: details,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(labelText: t.addressDetails)),
            const SizedBox(height: 18),
            BmPrimaryButton(
              label: t.save,
              onPressed: () {
                if (name.text.trim().isNotEmpty &&
                    details.text.trim().isNotEmpty) {
                  Navigator.pop(
                      context, '${name.text.trim()}|${details.text.trim()}');
                }
              },
            ),
          ],
        ),
      ),
    );
    name.dispose();
    details.dispose();
    if (result == null) return;
    setState(() => addresses.add(result));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bm_addresses', addresses);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.addresses)),
      body: addresses.isEmpty
          ? BmEmptyState(
              title: t.addresses,
              message: t.addressDetails,
              icon: Icons.location_on_outlined)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (_, index) {
                final parts = addresses[index].split('|');
                return Card(
                  child: ListTile(
                    leading:
                        const Icon(Icons.home_outlined, color: BmColors.orange),
                    title: Text(parts.first),
                    subtitle: Text(
                        parts.length > 1 ? parts.sublist(1).join('|') : ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () async {
                        setState(() => addresses.removeAt(index));
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setStringList('bm_addresses', addresses);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add_rounded),
        label: Text(t.addAddress),
      ),
    );
  }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final language = ref.watch(appPreferencesProvider).locale.languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: ListTile(
              leading:
                  const Icon(Icons.translate_rounded, color: BmColors.orange),
              title: Text(t.language),
              subtitle: Text(language == 'ta' ? t.tamil : t.english),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/language'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_outlined,
                  color: BmColors.orange),
              title: Text(t.notifications),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/notification-settings'),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationCenterPage extends StatelessWidget {
  const NotificationCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.notificationCenter)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: BmColors.lightOrange,
                child:
                    Icon(Icons.receipt_long_outlined, color: BmColors.orange),
              ),
              title: Text(t.orderConfirmed),
              subtitle: Text(t.orderConfirmedBody),
              trailing: const Text('Demo', style: TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.support)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Text(t.support, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(t.supportChatDemo),
          const SizedBox(height: 20),
          const ContactBmButton(),
          const SizedBox(height: 16),
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.help_outline_rounded,
                  color: BmColors.orange),
              title: Text(t.faq),
              children: <Widget>[
                ListTile(title: Text(t.paymentNotice)),
                ListTile(title: Text(t.finalPriceNotice)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.about)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const BmLogo(width: 130),
              const SizedBox(height: 24),
              Text(t.appTagline, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              const Text('Version 0.1.0',
                  style: TextStyle(color: BmColors.secondaryText)),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({required this.orderId, super.key});
  final String orderId;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final statuses = <String>[
      'confirmed',
      'processing',
      'ready',
      'outForDelivery',
      'delivered'
    ];
    return Scaffold(
      appBar: AppBar(title: Text(t.orderTracking)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          Text(orderId, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          for (var i = 0; i < statuses.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    width: 36,
                    child: Column(
                      children: <Widget>[
                        Icon(
                            i < 2
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked,
                            color: i < 2 ? BmColors.success : BmColors.border),
                        if (i < statuses.length - 1)
                          Expanded(
                              child: Container(
                                  width: 2,
                                  color: i < 1
                                      ? BmColors.success
                                      : BmColors.border)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 28),
                      child: Text(t.orderStatus(statuses[i]),
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
