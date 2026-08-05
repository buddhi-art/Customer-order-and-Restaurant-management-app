import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feedback.dart';
import '../data/repositories/feedback_repository.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) => FeedbackRepository());

class FeedbackNotifier extends Notifier<List<FeedbackItem>> {
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;
  late final FeedbackRepository _repo;

  @override
  List<FeedbackItem> build() {
    _repo = ref.read(feedbackRepositoryProvider);
    _listenToFeedback();
    ref.onDispose(() => _subscription?.cancel());
    return const [];
  }

  void _listenToFeedback() {
    try {
      _subscription = _repo.stream().listen(
        (List<Map<String, dynamic>> data) {
          final loaded = data.map<FeedbackItem>(FeedbackRepository.parseFeedback).toList();
          state = loaded;
        },
        onError: (error) {
          debugPrint('Feedback stream error: $error');
        },
      );
    } catch (e) {
      debugPrint('Feedback stream not available: $e');
    }
  }
}

final feedbackProvider = NotifierProvider<FeedbackNotifier, List<FeedbackItem>>(
  FeedbackNotifier.new,
);
