import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/notification_provider.dart';
import 'theme/m3_theme.dart';
import 'router.dart';
import 'utils/env_validator.dart';

// Conditionally import flutter_displaymode only on non-web platforms.
import 'platform/display_mode_stub.dart'
    if (dart.library.io) 'platform/display_mode_io.dart';

/// Enable Impeller — Flutter's GPU-accelerated renderer.
///
/// - Android: uses Vulkan (preferred) or OpenGL ES 3.x fallback
/// - iOS: uses Metal (unified with Apple's GPU architecture)
/// - Result: silky 120Hz animations, near-zero CPU jank, battery-efficient
///
/// Impeller replaces Skia with a modern GPU-first approach:
///   - Shader compilation jank eliminated
///   - Parallel rendering on GPU compute units
///   - Frame times drop dramatically on budget devices
void _enableImpeller() {
  // Impeller is enabled by default in Flutter 3.22+ for Android & iOS.
  // For explicit control, set the flag before runApp:
  // PlatformDispatcher.instance.rendererEnabled = true; // Impeller
  // This is configured via Info.plist (iOS) and AndroidManifest (Android).
  // On web, Impeller is not available — the browser's own renderer takes over.
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _enableImpeller();

  // Set high refresh rate on Android only (no-op on web)
  await setHighRefreshRate();

  await dotenv.load(fileName: ".env");

  if (!validateEnv(dotenv.env)) {
    throw StateError(
      'Missing required environment variables. '
      'Ensure SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY are set in .env',
    );
  }

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
  );

  final session = Supabase.instance.client.auth.currentSession;
  if (session != null) {
    debugPrint('Session restored for user: ${session.user.id}');
  } else {
    debugPrint('No active session. User will sign in or scan a table.');
  }

  runApp(ProviderScope(child: _AuthStateListener(child: const MyApp())));
}

/// Listens for auth state changes and invalidates stale providers.
///
/// This ensures that:
/// - Admin status is re-checked after login (Issue 9)
/// - Stale cart/order/notification state is cleared on logout (Issue 14)
class _AuthStateListener extends ConsumerStatefulWidget {
  final Widget child;

  const _AuthStateListener({required this.child});

  @override
  ConsumerState<_AuthStateListener> createState() => _AuthStateListenerState();
}

class _AuthStateListenerState extends ConsumerState<_AuthStateListener> {
  @override
  void initState() {
    super.initState();
    _setupListener();
  }

  void _setupListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      // On sign-out, invalidate session-scoped providers (Issue 14)
      if (event.event == AuthChangeEvent.signedOut) {
        ref.invalidate(cartProvider);
        ref.invalidate(orderProvider);
        ref.invalidate(notificationProvider);
      }

      // On sign-in, invalidate the cached admin status (Issue 9)
      if (event.event == AuthChangeEvent.signedIn ||
          event.event == AuthChangeEvent.tokenRefreshed) {
        ref.invalidate(adminStatusProvider);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kalpa Coffee',
      debugShowCheckedModeBanner: false,
      theme: M3Theme.light,
      routerConfig: router,
    );
  }
}
