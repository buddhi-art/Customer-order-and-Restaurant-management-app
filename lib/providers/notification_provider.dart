import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/notification_repository.dart';
import '../models/notification.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(),
);

class NotificationNotifier extends Notifier<List<AppNotification>> {
  StreamSubscription<List<Map<String, dynamic>>>? _notificationSubscription;
  late final NotificationRepository _repo;

  @override
  List<AppNotification> build() {
    _repo = ref.read(notificationRepositoryProvider);
    // The realtime stream emits the current rows on subscribe, so a separate
    // fetchNotifications() here would race the stream and could overwrite a
    // newer snapshot with a staler one. Rely on the stream's initial emission.
    _initRealtime();
    ref.onDispose(() => _notificationSubscription?.cancel());
    return <AppNotification>[];
  }

  Future<void> fetchNotifications() async {
    try {
      final notifications = await _repo.fetchAll();
      state = notifications;
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
  }

  void _initRealtime() {
    _notificationSubscription = _repo.stream().listen(
      (List<Map<String, dynamic>> data) {
        final notifications = data
            .map((json) => AppNotification.fromJson(json))
            .toList();
        state = notifications;
      },
      onError: (error) {
        debugPrint('Notification stream error: $error');
      },
    );
  }
}

final notificationProvider =
    NotifierProvider<NotificationNotifier, List<AppNotification>>(
      NotificationNotifier.new,
    );
