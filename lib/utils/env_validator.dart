import 'package:flutter/foundation.dart';

/// Validates required environment variables at startup.
/// Returns true if all required vars are present and non-empty.
bool validateEnv(Map<String, String> env) {
  final required = [
    'SUPABASE_URL',
    'SUPABASE_PUBLISHABLE_KEY',
    'QR_HMAC_SECRET',
  ];

  final missing = <String>[];
  for (final key in required) {
    final value = env[key];
    if (value == null || value.trim().isEmpty) {
      missing.add(key);
    }
  }

  if (missing.isNotEmpty) {
    debugPrint(
      '❌ Missing required environment variables: ${missing.join(', ')}',
    );
    return false;
  }

  debugPrint('✅ Environment variables validated successfully');
  return true;
}
