import 'package:bm/core/theme/bm_theme.dart';
import 'package:bm/features/auth/login_page.dart';
import 'package:bm/features/onboarding/onboarding_page.dart';
import 'package:bm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  testWidgets('language selection renders English and Tamil choices',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: BmTheme.light,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const LanguageSelectionPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose your language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('தமிழ்'), findsOneWidget);
  });

  testWidgets('customer login opens the admin login route', (tester) async {
    final router = GoRouter(
      initialLocation: '/login',
      routes: <RouteBase>[
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(
          path: '/admin/login',
          builder: (_, __) => const Scaffold(
            body: Center(child: Text('Admin destination')),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: BmTheme.light,
          locale: const Locale('en'),
          routerConfig: router,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('admin-login-link')), findsOneWidget);
    expect(find.text('Admin login'), findsOneWidget);

    await tester.tap(find.byKey(const Key('admin-login-link')));
    await tester.pumpAndSettle();

    expect(find.text('Admin destination'), findsOneWidget);
  });
}
