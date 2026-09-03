import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/notifications/notification_providers.dart';
import '../l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/bm_theme.dart';

final GlobalKey<ScaffoldMessengerState> bmScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class BmApp extends StatelessWidget {
  const BmApp({super.key});

  @override
  Widget build(BuildContext context) =>
      const ProviderScope(child: _BmAppRoot());
}

class _BmAppRoot extends ConsumerStatefulWidget {
  const _BmAppRoot();

  @override
  ConsumerState<_BmAppRoot> createState() => _BmAppState();
}

class _BmAppState extends ConsumerState<_BmAppRoot> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifications = ref.read(notificationServiceProvider);
      notifications.deepLinks.listen((route) => appRouter.go(route));
      notifications.foregroundNotifications.listen((message) {
        bmScaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(content: Text('${message.title}\n${message.body}')));
      });
      await notifications.start();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BM',
      debugShowCheckedModeBanner: false,
      theme: BmTheme.light,
      routerConfig: appRouter,
      scaffoldMessengerKey: bmScaffoldMessengerKey,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
