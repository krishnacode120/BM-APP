import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/admin_pages.dart';
import '../../features/admin/admin_login_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/cart/cart_pages.dart';
import '../../features/auth/otp_page.dart';
import '../../features/catalog/catalog_pages.dart';
import '../../features/home/home_shell.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/profile/customer_pages.dart';
import '../../features/orders/order_pages.dart';
import '../../features/splash/splash_page.dart';
import '../../models/order.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: <RouteBase>[
    GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
    GoRoute(
        path: '/language', builder: (_, __) => const LanguageSelectionPage()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/signup', builder: (_, __) => const SignUpPage()),
    GoRoute(
        path: '/otp',
        builder: (_, state) =>
            OtpPage(arguments: state.extra! as OtpArguments)),
    GoRoute(
        path: '/home',
        pageBuilder: (_, state) => _fadePage(state, const HomeShell())),
    GoRoute(
        path: '/categories',
        pageBuilder: (_, state) => _fadePage(state, const CategoriesPage())),
    GoRoute(
        path: '/search',
        pageBuilder: (_, state) => _fadePage(state, const SearchPage())),
    GoRoute(
        path: '/profile',
        pageBuilder: (_, state) => _fadePage(state, const ProfilePage())),
    GoRoute(path: '/support', builder: (_, __) => const SupportPage()),
    GoRoute(
        path: '/admin',
        pageBuilder: (_, state) => _fadePage(state, const AdminGatePage())),
    GoRoute(path: '/admin/login', builder: (_, __) => const AdminLoginPage()),
    GoRoute(
        path: '/admin/orders/:id',
        builder: (_, state) =>
            AdminGatePage(orderId: state.pathParameters['id']!)),
    GoRoute(path: '/cart', builder: (_, __) => const CartPage()),
    GoRoute(path: '/checkout', builder: (_, __) => const CheckoutPage()),
    GoRoute(
        path: '/orders',
        pageBuilder: (_, state) => _fadePage(state, const OrderHistoryPage())),
    GoRoute(
        path: '/orders/:id',
        builder: (_, state) =>
            OrderDetailPage(orderId: state.pathParameters['id']!)),
    GoRoute(
        path: '/order-success',
        builder: (_, state) =>
            OrderSuccessPage(order: state.extra! as BmOrder)),
    GoRoute(
        path: '/locations', builder: (_, __) => const LocationSelectorPage()),
    GoRoute(
        path: '/category/:id',
        builder: (_, state) => CategoryProductsPage(
            categoryId: state.pathParameters['id']!,
            title: state.extra! as String)),
    GoRoute(
        path: '/product/:id',
        builder: (_, state) =>
            ProductDetailPage(productId: state.pathParameters['id']!)),
  ],
);

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 240),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    );
