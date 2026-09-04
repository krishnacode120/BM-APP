import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/bm_theme.dart';
import '../../core/widgets/bm_components.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_providers.dart';
import '../notifications/notification_providers.dart';
import '../settings/contact_bm.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final customer = ref.watch(currentCustomerProvider);
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
            child: customer.when(
              loading: () => const SizedBox(height: 68, child: BmLoading()),
              error: (_, __) => _CustomerIdentity(
                name: t.account,
                phone: t.phoneLogin,
                verifiedLabel: null,
              ),
              data: (value) => _CustomerIdentity(
                name: value?.name ?? t.account,
                phone: value?.phoneNumber ?? t.phoneLogin,
                verifiedLabel:
                    value?.phoneVerified == true ? t.phoneVerified : null,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _ProfileTile(
            icon: Icons.receipt_long_outlined,
            label: t.orderHistory,
            onTap: () => context.push('/orders'),
          ),
          _ProfileTile(
            icon: Icons.translate_rounded,
            label: t.language,
            onTap: () => context.push('/language'),
          ),
          _ProfileTile(
            icon: Icons.support_agent_rounded,
            label: t.support,
            onTap: () => context.push('/support'),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context, ref),
            icon: const Icon(Icons.logout_rounded),
            label: Text(t.logout),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.logout),
        content: Text(t.logoutConfirmation),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(t.logout),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(notificationServiceProvider).deactivateCurrentDevice();
    await ref.read(customerRepositoryProvider).signOut();
    ref.invalidate(currentCustomerProvider);
    if (context.mounted) context.go('/login');
  }
}

class _CustomerIdentity extends StatelessWidget {
  const _CustomerIdentity({
    required this.name,
    required this.phone,
    required this.verifiedLabel,
  });

  final String name;
  final String phone;
  final String? verifiedLabel;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          const CircleAvatar(
            radius: 34,
            backgroundColor: BmColors.orange,
            child: Icon(Icons.person_rounded, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 3),
                Text(phone),
                if (verifiedLabel != null) ...<Widget>[
                  const SizedBox(height: 8),
                  BmStatusChip(
                    label: verifiedLabel!,
                    tone: BmStatusTone.success,
                  ),
                ],
              ],
            ),
          ),
        ],
      );
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          minTileHeight: 62,
          leading: Icon(icon, color: BmColors.orange),
          title:
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
      );
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
          const BmLogo(width: 104),
          const SizedBox(height: 24),
          Text(t.howCanWeHelp,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(t.callAdminHelp),
          const SizedBox(height: 20),
          const CallAdminButton(),
          const SizedBox(height: 12),
          const ContactBmButton(),
        ],
      ),
    );
  }
}
