import 'dart:async';

import 'package:flutter/foundation.dart';
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

  // Issue 32: friendly fallback instead of the default red error screen when a
  // widget build throws (e.g. a provider fails during build). In debug the red
  // screen is kept so problems stay visible during development.
  if (kReleaseMode) {
    ErrorWidget.builder = (FlutterErrorDetails details) =>
        const _AppErrorView();
  }

  // Set high refresh rate on Android only (no-op on web)
  await setHighRefreshRate();

  // Load client-safe env bundled as an asset. This file contains ONLY public
  // values (URL, publishable key, QR secret) — never the Supabase secret key or
  // database URL. See assets/app.env.
  await dotenv.load(fileName: "assets/app.env");

  if (!validateEnv(dotenv.env)) {
    throw StateError(
      'Missing required environment variables. '
      'Ensure SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY are set in .env',
    );
  }

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
    // persistSession is true by default in supabase_flutter ^2.15.0.
    // Sessions are stored in FlutterSecureStorage (mobile) / localStorage (web).
    // The auth flow is PKCE automatically on web.
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
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _setupListener();
  }

  void _setupListener() {
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      // On sign-out, invalidate session-scoped providers (Issue 14)
      if (event.event == AuthChangeEvent.signedOut) {
        // clearCart() wipes the persistent SharedPreferences cart so it does
        // not leak to the next user on this device; invalidate() alone would
        // only reset in-memory state and the prefs would rehydrate it.
        ref.read(cartProvider.notifier).clearCart();
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
  void dispose() {
    _authSub?.cancel();
    super.dispose();
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

/// Friendly fallback shown (in release builds) when a widget fails to build,
/// instead of Flutter's default red error screen. (Issue 32)
class _AppErrorView extends StatelessWidget {
  const _AppErrorView();

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: Color(0xFFFFF8F0),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.coffee_rounded, size: 48, color: Color(0xFF6F4E37)),
                SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3A2C22),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please restart the app or try again in a moment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B5B4F)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
