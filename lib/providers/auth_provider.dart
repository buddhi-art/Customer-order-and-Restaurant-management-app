import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Cached admin status for the currently authenticated user.
///
/// - `true`  → user has admin role
/// - `false` → user is logged in but not admin
/// - `null`  → not yet loaded / not authenticated
///
/// Updated by the auth state listener in main(). Widgets should watch this
/// instead of calling Supabase directly.
class AdminStatusNotifier extends Notifier<bool?> {
  RealtimeChannel? _subscription;

  @override
  bool? build() {
    ref.onDispose(() => _subscription?.unsubscribe());
    return null;
  }

  void setStatus(bool? status) {
    state = status;

    _subscription?.unsubscribe();
    _subscription = null;

    final user = Supabase.instance.client.auth.currentUser;
    if (status == true && user != null) {
      _subscription = Supabase.instance.client
          .channel('admin_status_${user.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'profiles',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: user.id,
            ),
            callback: (payload) {
              final newRole = payload.newRecord['role'];
              if (newRole != 'admin') {
                state = false;
              }
            },
          )
          .subscribe();
    }
  }
}

final adminStatusProvider = NotifierProvider<AdminStatusNotifier, bool?>(
  AdminStatusNotifier.new,
);
