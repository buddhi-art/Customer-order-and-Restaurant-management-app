import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/feedback.dart';

class FeedbackRepository {
  final SupabaseClient _client;

  FeedbackRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> stream() {
    return _client.from('feedback').stream(primaryKey: ['id']).order('created_at', ascending: false);
  }

  Future<void> insert(FeedbackItem feedback) async {
    await _client.from('feedback').insert({
      'id': feedback.id,
      'user_id': feedback.userId,
      'customer_name': feedback.customerName,
      'rating': feedback.rating,
      'comment': feedback.comment,
      'item_name': feedback.itemName,
      'created_at': feedback.createdAt.toIso8601String(),
    });
  }

  Future<void> delete(String id) async {
    await _client.from('feedback').delete().eq('id', id);
  }

  static FeedbackItem parseFeedback(Map<String, dynamic> row) {
    return FeedbackItem(
      id: row['id'] as String,
      userId: row['user_id'] as String?,
      customerName: row['customer_name'] as String,
      rating: (row['rating'] as num).toDouble(),
      comment: row['comment'] as String,
      itemName: row['item_name'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
