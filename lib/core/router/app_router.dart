import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../screens/admin/admin_screen.dart';
import '../../screens/cart_screen.dart';
import '../../screens/checkout_screen.dart';
import '../../screens/contact_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/order_detail_screen.dart';
import '../../screens/order_success_screen.dart';
import '../../screens/orders_screen.dart';
import '../../screens/privacy_screen.dart';
import '../../screens/product_detail_screen.dart';
import '../../screens/products_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/sign_in_screen.dart';
import '../../state/auth_controller.dart';
import '../constants/app_durations.dart';

class AppRoutes {
  AppRoutes._();
  static const String home = '/';
  static const String products = '/products';
  static const String productDetail = '/products/:slug';
  static const String contact = '/contact';
  static const String privacy = '/privacy';
  static const String signIn = '/sign-in';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String orderDetail = '/order/:id';
  static const String orderSuccess = '/order-success/:id';
  static const String profile = '/profile';
  static const String admin = '/admin';

  static String productDetailPath(String slug) => '/products/$slug';
  static String orderDetailPath(String id) => '/order/$id';
  static String orderSuccessPath(String id) => '/order-success/$id';

  /// Routes that require a signed-in user.
  static const _protected = {checkout, orders, profile, admin};
}

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: AuthController.instance,
    redirect: (context, state) {
      final auth = AuthController.instance;
      if (!auth.ready) return null; // wait for first auth resolution

      final path = state.uri.path;
      final needsAuth =
          AppRoutes._protected.any((p) => path == p || path.startsWith('$p/'));

      if (needsAuth && !auth.isSignedIn) {
        return '${AppRoutes.signIn}?from=${Uri.encodeComponent(state.uri.toString())}';
      }
      if (path == AppRoutes.admin && !auth.isAdmin) {
        return AppRoutes.home;
      }
      if (path == AppRoutes.signIn && auth.isSignedIn) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (c, s) => _fade(s,
            HomeScreen(initialSection: s.uri.queryParameters['section'])),
      ),
      GoRoute(
        path: AppRoutes.products,
        pageBuilder: (c, s) => _fade(s, const ProductsScreen()),
      ),
      GoRoute(
        path: AppRoutes.productDetail,
        pageBuilder: (c, s) =>
            _fade(s, ProductDetailScreen(slug: s.pathParameters['slug'] ?? '')),
      ),
      GoRoute(
        path: AppRoutes.contact,
        pageBuilder: (c, s) => _fade(s, const ContactScreen()),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        pageBuilder: (c, s) => _fade(s, const PrivacyScreen()),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        pageBuilder: (c, s) =>
            _fade(s, SignInScreen(from: s.uri.queryParameters['from'])),
      ),
      GoRoute(
        path: AppRoutes.cart,
        pageBuilder: (c, s) => _fade(s, const CartScreen()),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        pageBuilder: (c, s) => _fade(s, const CheckoutScreen()),
      ),
      GoRoute(
        path: AppRoutes.orders,
        pageBuilder: (c, s) => _fade(s, const OrdersScreen()),
      ),
      GoRoute(
        path: AppRoutes.orderDetail,
        pageBuilder: (c, s) =>
            _fade(s, OrderDetailScreen(orderId: s.pathParameters['id'] ?? '')),
      ),
      GoRoute(
        path: AppRoutes.orderSuccess,
        pageBuilder: (c, s) =>
            _fade(s, OrderSuccessScreen(orderId: s.pathParameters['id'] ?? '')),
      ),
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder: (c, s) => _fade(s, const ProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.admin,
        pageBuilder: (c, s) => _fade(s, const AdminScreen()),
      ),
    ],
  );

  static CustomTransitionPage<void> _fade(GoRouterState state, Widget child) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      transitionDuration: AppDurations.medium,
      child: child,
      transitionsBuilder: (c, anim, sec, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: child,
      ),
    );
  }
}
