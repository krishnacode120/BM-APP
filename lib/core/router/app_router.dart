import 'package:go_router/go_router.dart';

import '../../features/admin/admin_pages.dart';
import '../../features/admin/admin_login_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/cart/cart_pages.dart';
import '../../features/auth/otp_page.dart';
import '../../features/catalog/catalog_pages.dart';
import '../../features/home/home_shell.dart';
import '../../features/notifications/notification_settings_page.dart';
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
    GoRoute(
        path: '/otp',
        builder: (_, state) =>
            OtpPage(arguments: state.extra! as OtpArguments)),
    GoRoute(path: '/home', builder: (_, __) => const HomeShell()),
    GoRoute(path: '/categories', builder: (_, __) => const CategoriesPage()),
    GoRoute(path: '/search', builder: (_, __) => const SearchPage()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
    GoRoute(path: '/wishlist', builder: (_, __) => const WishlistPage()),
    GoRoute(path: '/addresses', builder: (_, __) => const AddressesPage()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
    GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationCenterPage()),
    GoRoute(path: '/support', builder: (_, __) => const SupportPage()),
    GoRoute(path: '/about', builder: (_, __) => const AboutPage()),
    GoRoute(
        path: '/orders/:id/tracking',
        builder: (_, state) =>
            OrderTrackingPage(orderId: state.pathParameters['id']!)),
    GoRoute(path: '/admin', builder: (_, __) => const AdminGatePage()),
    GoRoute(path: '/admin/login', builder: (_, __) => const AdminLoginPage()),
    GoRoute(
        path: '/admin/orders/:id',
        builder: (_, state) =>
            AdminGatePage(orderId: state.pathParameters['id']!)),
    GoRoute(
        path: '/notification-settings',
        builder: (_, __) => const NotificationSettingsPage()),
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
