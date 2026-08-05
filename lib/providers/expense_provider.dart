import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../data/repositories/expense_repository.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) => ExpenseRepository());

class ExpenseNotifier extends Notifier<List<Expense>> {
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;
  late final ExpenseRepository _repo;

  @override
  List<Expense> build() {
    _repo = ref.read(expenseRepositoryProvider);
    _listenToExpenses();
    ref.onDispose(() => _subscription?.cancel());
    return const [];
  }

  void _listenToExpenses() {
    try {
      _subscription = _repo.stream().listen(
        (List<Map<String, dynamic>> data) {
          final loaded = data.map<Expense>(ExpenseRepository.parseExpense).toList();
          state = loaded;
        },
        onError: (error) {
          debugPrint('Expense stream error: $error');
        },
      );
    } catch (e) {
      debugPrint('Expense stream not available: $e');
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await _repo.insert(expense);
    } catch (e) {
      debugPrint('Failed to add expense: $e');
      rethrow;
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await _repo.updateFields(expense);
    } catch (e) {
      debugPrint('Failed to update expense: $e');
      rethrow;
    }
  }

  Future<void> removeExpense(String id) async {
    try {
      await _repo.delete(id);
    } catch (e) {
      debugPrint('Failed to remove expense: $e');
      rethrow;
    }
  }

  double get totalExpenses => state.fold<double>(0, (sum, e) => sum + e.amount);

  Map<ExpenseCategory, double> get byCategory {
    final map = <ExpenseCategory, double>{};
    for (final e in state) {
      map.update(e.category, (v) => v + e.amount, ifAbsent: () => e.amount);
    }
    return map;
  }

  List<Expense> forDateRange(DateTime start, DateTime end) {
    return state
        .where((e) => !e.date.isBefore(start) && !e.date.isAfter(end))
        .toList();
  }
}

final expenseProvider = NotifierProvider<ExpenseNotifier, List<Expense>>(
  ExpenseNotifier.new,
);
