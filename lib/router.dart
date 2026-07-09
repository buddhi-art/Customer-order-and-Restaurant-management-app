import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'screens/consumer/onboarding_screen.dart';
import 'screens/consumer/login_screen.dart';
import 'screens/consumer/profile_completion_screen.dart';
import 'screens/consumer/home_screen.dart';
import 'screens/consumer/product_detail_screen.dart';
import 'screens/consumer/qr_scanner_screen.dart';
import 'screens/consumer/checkout_screen.dart';
import 'screens/consumer/order_status_screen.dart';
import 'screens/consumer/order_history_screen.dart';
import 'screens/consumer/profile_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/dashboard_screen.dart';
import 'screens/admin/order_management_screen.dart';
import 'screens/admin/menu_management_screen.dart';
import 'screens/admin/table_management_screen.dart';
import 'screens/admin/notifications_management_screen.dart';
import 'screens/admin/members_screen.dart';
import 'screens/admin/analytics_screen.dart';
import 'screens/admin/inventory_screen.dart';
import 'screens/admin/staff_screen.dart';
import 'screens/admin/expenses_screen.dart';
import 'screens/admin/feedback_screen.dart';
import 'screens/admin/settings_screen.dart';
import 'providers/auth_provider.dart';
import 'widgets/morph_transitions.dart';

final storage = const FlutterSecureStorage();

/// Check admin status by querying the profiles table.
/// Returns true only if the user has role == 'admin'.
Future<bool> _checkAdminStatus(String userId) async {
  final res = await Supabase.instance.client
      .from('profiles')
      .select('role')
      .eq('id', userId)
      .maybeSingle();
  return res != null && res['role'] == 'admin';
}

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final path = state.matchedLocation;
    final isAdminRoute = path.startsWith('/admin');
    final isAdminLogin = path == '/admin/login';

    final user = Supabase.instance.client.auth.currentUser;
    final isAnonymous = user?.isAnonymous ?? true;

    // Secure Admin Routes – use cached admin status from provider
    if (isAdminRoute && !isAdminLogin) {
      if (user == null || isAnonymous) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          toastification.show(
            context: context,
            title: const Text('Access Denied'),
            description: const Text(
              'You must be an administrator to view this.',
            ),
            type: ToastificationType.error,
            style: ToastificationStyle.flatColored,
            autoCloseDuration: const Duration(seconds: 4),
          );
        });
        return '/admin/login';
      }

      // Read from cached provider instead of calling Supabase on every nav
      final adminStatus = ProviderScope.containerOf(
        context,
        listen: false,
      ).read(adminStatusProvider);

      // If cache is null (not yet loaded), fetch and cache
      bool isAdmin;
      if (adminStatus == null) {
        // Capture reference before the async gap to avoid
        // use_build_context_synchronously.
        final container = ProviderScope.containerOf(context, listen: false);
        isAdmin = await _checkAdminStatus(user.id);
        container.read(adminStatusProvider.notifier).setStatus(isAdmin);
      } else {
        isAdmin = adminStatus;
      }

      if (!isAdmin) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          toastification.show(
            context: context,
            title: const Text('Access Denied'),
            description: const Text(
              'You must be an administrator to view this.',
            ),
            type: ToastificationType.error,
            style: ToastificationStyle.flatColored,
            autoCloseDuration: const Duration(seconds: 4),
          );
        });
        return '/admin/login';
      }
    }

    // Enforce Table Scanning for /home
    if (path == '/home') {
      final tableId = await storage.read(key: 'table_id');
      if (tableId == null) {
        return '/scan';
      }
    }

    return null;
  },
  routes: [
    GoRoute(
      name: 'onboarding',
      path: '/',
      pageBuilder: (context, state) =>
          morphTransitionPage(child: const OnboardingScreen(), state: state),
    ),
    GoRoute(
      name: 'login',
      path: '/login',
      pageBuilder: (context, state) =>
          morphTransitionPage(child: const LoginScreen(), state: state),
    ),
    GoRoute(
      name: 'profile_completion',
      path: '/profile_completion',
      pageBuilder: (context, state) => morphTransitionPage(
        child: const ProfileCompletionScreen(),
        state: state,
      ),
    ),
    GoRoute(
      name: 'home',
      path: '/home',
      pageBuilder: (context, state) =>
          morphTransitionPage(child: const HomeScreen(), state: state),
    ),
    GoRoute(
      name: 'product_detail',
      path: '/product/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return morphTransitionPage(
          child: ProductDetailScreen(id: id),
          state: state,
        );
      },
    ),
    GoRoute(
      name: 'cart',
      path: '/cart',
      pageBuilder: (context, state) =>
          morphTransitionPage(child: const CheckoutScreen(), state: state),
    ),
    GoRoute(
      name: 'scan',
      path: '/scan',
      pageBuilder: (context, state) =>
          morphTransitionPage(child: const QRScannerScreen(), state: state),
    ),
    GoRoute(
      name: 'order_status',
      path: '/order_status/:orderId',
      pageBuilder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return morphTransitionPage(
          child: OrderStatusScreen(orderId: orderId),
          state: state,
        );
      },
    ),
    // NEW USER ROUTES
    GoRoute(
      name: 'orders',
      path: '/orders',
      pageBuilder: (context, state) =>
          morphTransitionPage(child: const OrderHistoryScreen(), state: state),
    ),
    GoRoute(
      name: 'profile',
      path: '/profile',
      pageBuilder: (context, state) =>
          morphTransitionPage(child: const ProfileScreen(), state: state),
    ),
    // Admin Routes
    GoRoute(
      name: 'admin_login',
      path: '/admin/login',
      pageBuilder: (context, state) =>
          morphTransitionPage(child: const AdminLoginScreen(), state: state),
    ),
    GoRoute(
      name: 'admin_dashboard',
      path: '/admin',
      pageBuilder: (context, state) => morphTransitionPage(
        child: const AdminDashboardScreen(),
        state: state,
      ),
    ),
    GoRoute(
      name: 'admin_orders',
      path: '/admin/orders',
      pageBuilder: (context, state) => morphTransitionPage(
        child: const OrderManagementScreen(),
        state: state,
      ),
    ),
    GoRoute(
      name: 'admin_menu',
      path: '/admin/menu',
      pageBuilder: (context, state) => morphTransitionPage(
        child: const MenuManagementScreen(),
        state: state,
      ),
    ),
    GoRoute(
      name: 'admin_tables',
      path: '/admin/tables',
      pageBuilder: (context, state) => morphTransitionPage(
        child: const TableManagementScreen(),
        state: state,
      ),
    ),
    GoRoute(
      name: 'admin_analytics',
      path: '/admin/analytics',
      pageBuilder: (context, state) => morphTransitionPage(
        child: const AdminAnalyticsScreen(),
        state: state,
      ),
    ),
    GoRoute(
      name: 'admin_inventory',
      path: '/admin/inventory',
      pageBuilder: (context, state) =>
          morphTransitionPage(child: const InventoryScreen(), state: state),
    ),
    GoRoute(
      name: 'admin_staff',
      path: '/admin/staff',
      pageBuilder: (context, state) =>
          morphTransitionPage(child: const StaffScreen(), state: state),
    ),
    GoRoute(
      name: 'admin_members',
      path: '/admin/members',
      pageBuilder: (context, state) =>
          morphTransitionPage(child: const MembersScreen(), state: state),
    ),
    GoRoute(
      name: 'admin_expenses',
      path: '/admin/expenses',
      pageBuilder: (context, state) =>
          morphTransitionPage(child: const ExpensesScreen(), state: state),
    ),
    GoRoute(
      name: 'admin_offers',
      path: '/admin/offers',
      pageBuilder: (context, state) => morphTransitionPage(
        child: const NotificationsManagementScreen(),
        state: state,
      ),
    ),
    GoRoute(
      name: 'admin_feedback',
      path: '/admin/feedback',
      pageBuilder: (context, state) => morphTransitionPage(
        child: const FeedbackManagementScreen(),
        state: state,
      ),
    ),
    GoRoute(
      name: 'admin_settings',
      path: '/admin/settings',
      pageBuilder: (context, state) =>
          morphTransitionPage(child: const AdminSettingsScreen(), state: state),
    ),
  ],
);
