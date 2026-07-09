import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/notification.dart';

/// All notification-related Supabase calls live here.
class NotificationRepository {
  final SupabaseClient _client;

  NotificationRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// One-shot fetch of all notifications (newest first).
  Future<List<AppNotification>> fetchAll() async {
    final response = await _client
        .from('notifications')
        .select()
        .order('created_at', ascending: false);
    return (response as List<dynamic>)
        .map((data) => AppNotification.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  /// Realtime stream of all notifications (newest first).
  Stream<List<Map<String, dynamic>>> stream() {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }
}
