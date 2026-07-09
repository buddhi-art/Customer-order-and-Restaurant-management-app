import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cached admin status for the currently authenticated user.
///
/// - `true`  → user has admin role
/// - `false` → user is logged in but not admin
/// - `null`  → not yet loaded / not authenticated
///
/// Updated by the auth state listener in main(). Widgets should watch this
/// instead of calling Supabase directly.
class AdminStatusNotifier extends Notifier<bool?> {
  @override
  bool? build() => null;

  void setStatus(bool? status) => state = status;
}

final adminStatusProvider = NotifierProvider<AdminStatusNotifier, bool?>(
  AdminStatusNotifier.new,
);
