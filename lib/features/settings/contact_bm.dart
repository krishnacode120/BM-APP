import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import 'business_settings_providers.dart';

class ContactBmButton extends ConsumerWidget {
  const ContactBmButton({this.compact = false, super.key});
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    return FilledButton.tonalIcon(
      onPressed: () => showBmContactSheet(context),
      icon: const Icon(Icons.support_agent_outlined),
      label: Text(compact ? t.help : t.contactBm),
    );
  }
}

class CallAdminButton extends ConsumerWidget {
  const CallAdminButton({this.compact = false, super.key});
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final settings = ref.watch(businessSettingsProvider).valueOrNull;
    return FilledButton.icon(
      onPressed: settings?.canCall == true
          ? () => launchBmUri(
                context,
                Uri(scheme: 'tel', path: settings!.businessPhone),
              )
          : null,
      icon: const Icon(Icons.call_rounded),
      label: Text(compact ? t.call : t.callAdmin),
    );
  }
}

Future<void> showBmContactSheet(BuildContext context) => showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => const _ContactSheet(),
    );

class _ContactSheet extends ConsumerWidget {
  const _ContactSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final settings = ref.watch(businessSettingsProvider);
    return SafeArea(
      minimum: const EdgeInsets.all(24),
      child: settings.when(
        loading: () => const SizedBox(
            height: 180, child: Center(child: CircularProgressIndicator())),
        error: (_, __) => SizedBox(
            height: 180, child: Center(child: Text(t.contactUnavailable))),
        data: (value) => Column(mainAxisSize: MainAxisSize.min, children: [
          Text(value.businessName,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          if (value.isDevelopmentFallback)
            Text(t.contactPending, textAlign: TextAlign.center)
          else ...[
            if (value.canCall)
              ListTile(
                leading: const Icon(Icons.call_outlined),
                title: Text(t.callBm),
                subtitle: Text(value.businessPhone),
                onTap: () => launchBmUri(
                    context, Uri(scheme: 'tel', path: value.businessPhone)),
              ),
            if (value.canWhatsapp)
              ListTile(
                leading: const Icon(Icons.chat_outlined),
                title: Text(t.whatsappBm),
                subtitle: Text(value.whatsappNumber),
                onTap: () => launchBmUri(
                    context,
                    Uri.parse(
                        'https://wa.me/${value.whatsappNumber.substring(1)}')),
              ),
            if (value.hasSupportEmail)
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: Text(t.emailBm),
                subtitle: Text(value.supportEmail),
                onTap: () => launchBmUri(
                    context, Uri(scheme: 'mailto', path: value.supportEmail)),
              ),
            if (value.supportHours.isNotEmpty)
              ListTile(
                  leading: const Icon(Icons.schedule_outlined),
                  title: Text(t.supportHours),
                  subtitle: Text(value.supportHours)),
          ],
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

Future<void> launchBmUri(BuildContext context, Uri uri) async {
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).contactUnavailable)),
    );
  }
}
