import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/expense.dart';

class ExpenseRepository {
  final SupabaseClient _client;

  ExpenseRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> stream() {
    return _client.from('expenses').stream(primaryKey: ['id']).order('date', ascending: false);
  }

  Future<void> insert(Expense expense) async {
    await _client.from('expenses').insert({
      'id': expense.id,
      'title': expense.title,
      'description': expense.description,
      'amount': expense.amount,
      'category': expense.category.name,
      'date': expense.date.toIso8601String(),
      'paid_to': expense.paidTo,
    });
  }

  Future<void> updateFields(Expense expense) async {
    await _client
        .from('expenses')
        .update({
          'title': expense.title,
          'description': expense.description,
          'amount': expense.amount,
          'category': expense.category.name,
          'date': expense.date.toIso8601String(),
          'paid_to': expense.paidTo,
        })
        .eq('id', expense.id);
  }

  Future<void> delete(String id) async {
    await _client.from('expenses').delete().eq('id', id);
  }

  static Expense parseExpense(Map<String, dynamic> row) {
    return Expense(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String,
      amount: (row['amount'] as num).toDouble(),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == row['category'],
        orElse: () => ExpenseCategory.other,
      ),
      date: DateTime.parse(row['date'] as String),
      paidTo: row['paid_to'] as String,
    );
  }
}
