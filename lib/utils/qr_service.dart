import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Server-side QR table-token operations.
///
/// The HMAC secret lives only in Supabase Vault. Signing (admin) and
/// verification (any caller) both run in Postgres via SECURITY DEFINER RPCs
/// (`generate_table_qr` / `redeem_table_qr`, see migration
/// 20260710000001_qr_server_side_tokens.sql), so the secret is never shipped to
/// the client and tokens cannot be forged.
class QrService {
  QrService._();

  static SupabaseClient get _client => Supabase.instance.client;

  /// Admin-only: mint a signed token for [tableId] (e.g. `table_5`).
  /// Throws if the caller is not an admin or the secret is missing.
  static Future<String> generateTableToken(String tableId) async {
    final res = await _client.rpc(
      'generate_table_qr',
      params: {'p_table_id': tableId},
    );
    return res as String;
  }

  /// Verify a scanned token server-side. Returns the trusted table id, or null
  /// if the token is invalid/expired/forged.
  static Future<String?> redeemToken(String token) async {
    final res = await _client.rpc(
      'redeem_table_qr',
      params: {'p_token': token},
    );
    return res as String?;
  }
}

/// Cached admin QR token for a given table id. Family key is the table id
/// (e.g. `table_5`). Tokens are valid 24h; the provider caches for the session.
final tableQrTokenProvider = FutureProvider.family<String, String>((
  ref,
  tableId,
) async {
  return QrService.generateTableToken(tableId);
});
