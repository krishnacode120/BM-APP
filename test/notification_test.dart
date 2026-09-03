import 'package:bm/core/app.dart';
import 'package:bm/features/admin/admin_pages.dart';
import 'package:bm/features/admin/admin_providers.dart';
import 'package:bm/features/notifications/notification_providers.dart';
import 'package:bm/features/notifications/notification_settings_page.dart';
import 'package:bm/models/report_sync.dart';
import 'package:bm/repositories/admin_repository.dart';
import 'package:bm/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bm/l10n/app_localizations.dart';

void main() {
  test('accepts only supported notification deep links', () {
    expect(NotificationDeepLink.fromData({'route': '/orders/order-1'}),
        '/orders/order-1');
    expect(NotificationDeepLink.fromData({'route': '/admin/orders/order-1'}),
        '/admin/orders/order-1');
    expect(NotificationDeepLink.fromData({'route': '/settings'}), isNull);
    expect(NotificationDeepLink.fromData({'route': 'https://unsafe.example'}),
        isNull);
  });

  test('unavailable notification service does not claim push is enabled',
      () async {
    final service = UnavailableNotificationService();
    expect(await service.permissionState(),
        NotificationPermissionState.unavailable);
    service.dispose();
  });

  testWidgets('notification settings explain unavailable development setup',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        notificationServiceProvider
            .overrideWithValue(UnavailableNotificationService()),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: NotificationSettingsPage(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Order updates'), findsOneWidget);
    expect(
        find.text('Notifications are available after Firebase is configured.'),
        findsOneWidget);
  });

  testWidgets('admin reports shows failed sync jobs', (tester) async {
    final summary = AdminReportingSummary(
      totalOrders: 3,
      synced: 1,
      pending: 1,
      failed: 1,
      recentJobs: [
        ReportSyncJob(
          orderId: 'order-1',
          orderNumber: 'BM10025',
          status: ReportSyncStatus.failed,
          attemptCount: 5,
          updatedAt: DateTime(2026),
          lastError: 'CONFIGURATION_REQUIRED',
        ),
      ],
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [
        adminReportingProvider.overrideWith((ref) async => summary),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: bmScaffoldMessengerKey,
        home: const Scaffold(body: AdminReportsPage()),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Reports & Sync'), findsOneWidget);
    expect(find.text('BM10025'), findsOneWidget);
    expect(find.text('Retry sync'), findsOneWidget);
  });
}
