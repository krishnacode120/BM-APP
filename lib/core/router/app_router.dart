import 'package:go_router/go_router.dart';

import '../../features/admin/admin_pages.dart';
import '../../features/auth/login_page.dart';
import '../../features/cart/cart_pages.dart';
import '../../features/auth/otp_page.dart';
import '../../features/catalog/catalog_pages.dart';
import '../../features/home/home_shell.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/orders/order_pages.dart';
import '../../features/splash/splash_page.dart';
import '../../models/order.dart';

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
    GoRoute(path: '/admin', builder: (_, __) => const AdminGatePage()),
    GoRoute(path: '/cart', builder: (_, __) => const CartPage()),
    GoRoute(path: '/checkout', builder: (_, __) => const CheckoutPage()),
    GoRoute(path: '/orders', builder: (_, __) => const OrderHistoryPage()),
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
