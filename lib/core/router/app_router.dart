import 'package:go_router/go_router.dart';

import '../../features/auth/login_page.dart';
import '../../features/auth/otp_page.dart';
import '../../features/home/home_shell.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/splash/splash_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: <RouteBase>[
    GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(
        path: '/otp',
        builder: (_, state) => OtpPage(phone: state.extra! as String)),
    GoRoute(path: '/home', builder: (_, __) => const HomeShell()),
  ],
);
