import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../services/notification_service.dart';
import 'notification_providers.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final state = ref.watch(notificationPermissionProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.notifications)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(child: Text(t.somethingWentWrong)),
          data: (permission) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.notifications_active_outlined, size: 56),
              const SizedBox(height: 20),
              Text(t.orderUpdates,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(t.notificationRationale),
              const SizedBox(height: 24),
              Text(_permissionLabel(t, permission)),
              const Spacer(),
              FilledButton(
                onPressed: permission ==
                            NotificationPermissionState.unavailable ||
                        permission == NotificationPermissionState.authorized ||
                        permission == NotificationPermissionState.provisional
                    ? null
                    : () async {
                        await ref
                            .read(notificationServiceProvider)
                            .requestPermissionAndRegister();
                        ref.invalidate(notificationPermissionProvider);
                      },
                child: Text(t.enableNotifications),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _permissionLabel(
          AppLocalizations t, NotificationPermissionState state) =>
      switch (state) {
        NotificationPermissionState.authorized ||
        NotificationPermissionState.provisional =>
          t.notificationsEnabled,
        NotificationPermissionState.denied => t.notificationsDenied,
        NotificationPermissionState.unavailable => t.notificationsUnavailable,
        NotificationPermissionState.notDetermined => t.notificationsNotEnabled,
      };
}
