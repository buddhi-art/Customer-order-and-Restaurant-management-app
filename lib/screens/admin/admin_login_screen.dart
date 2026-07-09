import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/cafe_colors.dart';
import '../../animations/m3_animations.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  // Client-side brute-force throttle (defense-in-depth; Supabase also rate
  // limits server-side). After [_maxAttempts] failures, Sign In is disabled
  // for [_lockoutSeconds] with a visible countdown. (Issue 9)
  static const int _maxAttempts = 5;
  static const int _lockoutSeconds = 30;
  int _failedAttempts = 0;
  int _lockoutRemaining = 0;
  Timer? _lockoutTimer;

  bool get _isLockedOut => _lockoutRemaining > 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _startLockout() {
    _lockoutRemaining = _lockoutSeconds;
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _lockoutRemaining--;
        if (_lockoutRemaining <= 0) {
          timer.cancel();
          _failedAttempts = 0; // reset after the cooldown
        }
      });
    });
  }

  void _registerFailedAttempt() {
    _failedAttempts++;
    if (_failedAttempts >= _maxAttempts) {
      _startLockout();
    }
  }

  Future<void> _signIn() async {
    if (_isLockedOut) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        setState(() {
          _errorMessage = 'Sign-in succeeded but no user returned.';
          _isLoading = false;
        });
        return;
      }

      final userId = response.user!.id;

      // ── Verify admin role BEFORE navigating ──
      // The GoRouter redirect checks profiles.role. If the signed-in user
      // isn't admin, navigating to /admin bounces right back to /admin/login
      // — which is the reload-loop bug. We check here so we can sign out
      // and show a clear error instead of an invisible redirect loop.
      final res = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      final isAdmin = res != null && res['role'] == 'admin';

      if (!mounted) return;

      if (!isAdmin) {
        await Supabase.instance.client.auth.signOut();
        _registerFailedAttempt();
        setState(() {
          _isLoading = false;
          _errorMessage =
              'This account does not have admin privileges. '
              'Please contact your system administrator.';
        });
        return;
      }

      // Admin verified — reset throttle and navigate to dashboard.
      _failedAttempts = 0;
      if (mounted) context.go('/admin');
    } on AuthException catch (e) {
      _registerFailedAttempt();
      setState(() {
        _isLoading = false;
        _errorMessage = _isLockedOut
            ? 'Too many failed attempts. Try again in $_lockoutRemaining s.'
            : e.message;
      });
    } catch (e) {
      _registerFailedAttempt();
      setState(() {
        _isLoading = false;
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: CafeColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Back Button ─────────────────────────────────────────────
              FadeInWidget(
                duration: const Duration(milliseconds: 700),
                child: M3PressScale(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: CafeColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: CafeColors.outline),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: CafeColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: CafeColors.onSurface.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: CafeColors.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // ── Logo Lockup ─────────────────────────────────────────────
              FadeInWidget(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 100),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/logo.png', height: 48, width: 48),
                      const SizedBox(width: 14),
                      Text(
                        'कल्प',
                        style: textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: CafeColors.primary,
                          letterSpacing: -1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Admin Badge ─────────────────────────────────────────────
              FadeInWidget(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 150),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: CafeColors.onSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ADMIN',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: CafeColors.surface,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // ── Heading ─────────────────────────────────────────────────
              FadeInWidget(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Welcome back',
                  style: textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeInWidget(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 250),
                child: Text(
                  'Sign in to manage your café.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: CafeColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // ── Email Field — Double-Bezel Pattern ──────────────────────
              FadeInWidget(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email',
                      style: textTheme.titleSmall?.copyWith(
                        color: CafeColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: CafeColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: CafeColors.outline),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: CafeColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: CafeColors.onSurface.withValues(
                                alpha: 0.03,
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: CafeColors.primary,
                              size: 20,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            hintText: 'admin@kalpacoffee.com',
                            hintStyle: TextStyle(
                              color: CafeColors.onSurfaceVariant.withValues(
                                alpha: 0.5,
                              ),
                              fontSize: 15,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          style: textTheme.bodyLarge?.copyWith(
                            color: CafeColors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Password Field — Double-Bezel Pattern ───────────────────
              FadeInWidget(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 350),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password',
                      style: textTheme.titleSmall?.copyWith(
                        color: CafeColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: CafeColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: CafeColors.outline),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: CafeColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: CafeColors.onSurface.withValues(
                                alpha: 0.03,
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onSubmitted: (_) => _signIn(),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: CafeColors.primary,
                              size: 20,
                            ),
                            suffixIcon: M3PressScale(
                              onTap: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: CafeColors.onSurfaceVariant,
                                  size: 20,
                                ),
                              ),
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            hintText: '••••••••',
                            hintStyle: TextStyle(
                              color: CafeColors.onSurfaceVariant.withValues(
                                alpha: 0.5,
                              ),
                              fontSize: 15,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          style: textTheme.bodyLarge?.copyWith(
                            color: CafeColors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ── Error Message ───────────────────────────────────────────
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                FadeInWidget(
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: CafeColors.errorContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: CafeColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: CafeColors.onErrorContainer,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // ── Sign In Button — Pill, Espresso Fill ────────────────────
              FadeInWidget(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 450),
                child: M3PressScale(
                  onTap: (_isLoading || _isLockedOut) ? null : _signIn,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isLockedOut
                          ? CafeColors.onSurface.withValues(alpha: 0.4)
                          : CafeColors.onSurface,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: CafeColors.onSurface.withValues(alpha: 0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 24),
                        Expanded(
                          child: Text(
                            _isLockedOut
                                ? 'Locked — retry in ${_lockoutRemaining}s'
                                : 'Sign In',
                            style: textTheme.titleMedium?.copyWith(
                              color: CafeColors.surface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (_isLoading)
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Colors.white10,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: CafeColors.surface,
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Colors.white10,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: CafeColors.surface,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
