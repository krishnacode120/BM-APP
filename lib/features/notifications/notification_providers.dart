import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = createNotificationService();
  ref.onDispose(service.dispose);
  return service;
});

final notificationPermissionProvider =
    FutureProvider<NotificationPermissionState>(
        (ref) => ref.watch(notificationServiceProvider).permissionState());
