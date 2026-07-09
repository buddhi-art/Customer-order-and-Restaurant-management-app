import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/cafe_colors.dart';
import '../../animations/m3_animations.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;
  int _countdown = 300;
  Timer? _timer;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _countdown = 300;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _formattedTime {
    final minutes = _countdown ~/ 60;
    final seconds = _countdown % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithOtp(phone: '+977$phone');
      setState(() => _otpSent = true);
      _startTimer();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    final phone = _phoneController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit PIN')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        phone: '+977$phone',
        token: otp,
        type: OtpType.sms,
      );

      if (response.user != null) {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', response.user!.id)
            .maybeSingle();

        if (profile != null && profile['is_profile_complete'] == true) {
          if (mounted) context.go('/scan');
        } else {
          if (mounted) context.go('/profile_completion');
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Verification Failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CafeColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Semantics(
            button: true,
            label: 'Back',
            child: M3PressScale(
            onTap: () => context.go('/'),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: CafeColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: CafeColors.outline),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 16, color: CafeColors.onSurface),
            ),
          ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo Header
              FadeInWidget(
                duration: const Duration(milliseconds: 700),
                slideOffset: const Offset(0, 0.1),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: CafeColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: CafeColors.outline),
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      height: 80,
                      width: 80,
                      semanticLabel: 'Kalpa Coffee logo',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 56),

              // Title block
              FadeInWidget(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 100),
                slideOffset: const Offset(0, 0.1),
                child: Text(
                  _otpSent ? 'Enter code' : 'Welcome',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeInWidget(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 150),
                slideOffset: const Offset(0, 0.1),
                child: Text(
                  _otpSent
                      ? 'We have sent an SMS with a code to +977 ${_phoneController.text}'
                      : 'Please confirm your country code and enter your phone number to continue.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: CafeColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Inputs (Double-Bezel styling)
              if (!_otpSent)
                FadeInWidget(
                  duration: const Duration(milliseconds: 700),
                  delay: const Duration(milliseconds: 250),
                  slideOffset: const Offset(0, 0.1),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: CafeColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: CafeColors.outline),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: CafeColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: CafeColors.onSurface.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '+977',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: CafeColors.onSurface,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 1,
                            height: 24,
                            color: CafeColors.outline,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                fillColor: Colors.transparent,
                                filled: false,
                                hintText: 'Phone number',
                              ),
                              style: const TextStyle(
                                fontSize: 18,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                FadeInWidget(
                  duration: const Duration(milliseconds: 700),
                  delay: const Duration(milliseconds: 250),
                  slideOffset: const Offset(0, 0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: CafeColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: CafeColors.outline),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: CafeColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: CafeColors.onSurface.withValues(alpha: 0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              fillColor: Colors.transparent,
                              filled: false,
                              hintText: '- - - - - -',
                              counterText: '',
                            ),
                            style: const TextStyle(
                              fontSize: 28,
                              letterSpacing: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _countdown > 0
                                  ? CafeColors.primary
                                  : CafeColors.error,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Time remaining: $_formattedTime',
                            style: TextStyle(
                              color: _countdown > 0
                                  ? CafeColors.onSurfaceVariant
                                  : CafeColors.error,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 56),

              // Nested CTA Button
              FadeInWidget(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 350),
                slideOffset: const Offset(0, 0.1),
                child: Semantics(
                  button: true,
                  enabled: !_isLoading,
                  label: _otpSent ? 'Verify' : 'Continue',
                  child: M3PressScale(
                  onTap: _isLoading
                      ? null
                      : (_otpSent ? _verifyOtp : _sendOtp),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CafeColors.onSurface,
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
                            _otpSent ? 'Verify' : 'Continue',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: CafeColors.surface,
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
              ),
            ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
